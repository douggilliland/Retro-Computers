/* pli_rf.c */
/*
 * minimal implementation of rf08 disk controller,
 * designed to be shared by the rtl simulation and simh
 * so they both operate the same way
 * (to facilitate comparisons of cpu flow)
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

#ifdef unix
#include <unistd.h>
#endif

#ifdef _WIN32
#endif

#include "vpi_user.h"

#ifdef __CVER__
#include "cv_vpi_user.h"
#endif

#ifdef __MODELSIM__
#include "veriuser.h"
#endif

typedef unsigned short u16;
typedef unsigned int u22;

extern PLI_INT32 pli_ram(void);
PLI_INT32 pli_rf(void);

/*
static char *instnam_tab[10];
static int last_evh;
*/
int running_cver;

static char last_iot_bit;
static char last_clk_bit;

static int io_rf_debug = 0;
static int rf_debug = 0;

static struct rf_context_s {
    int DMA;
    int EMA;
    int DCF;
    int PEF;
    int CIE, EIE, NXD, PIE, WLS;
    int MEX;
    int ADC, PCA, DRE, DRL, PER;

    int is_read;
    int is_write;
    int dma_start;
    int dma_done;
    unsigned int disk_addr;

    int rf_fd;
    int has_init;
    int size;
    u16 buffer[256*1024];
} rf_context[10];

#define WC_ADDR 07750
#define CA_ADDR 07751

static struct {
    int ord;
    char *name;
    int preset;
    vpiHandle ref;
    vpiHandle aref;
    char bits[32];
    unsigned int value;
} argl[] = {
    { 1, "clk", 0 },
    { 2, "reset", 0 },
    { 3, "iot", 0 },
    { 4, "state", 0 },
    { 5, "mb", 0 },
    { 6, "io_data_in", 0 },

    { 7, "io_select", 0 },
    { 8, "io_selected", 1 },
    { 9, "io_data_out", 0 },
    { 10, "io_data_avail", 1 },

    { 11, "io_interrupt", 0 },
    { 12, "io_skip", 0 },
    { 13, "io_clear_ac", 0 },
    { 0, NULL, 0 }
};
#define A_CLK (1-1)
#define A_RESET (2-1)
#define A_IOT (3-1)
#define A_STATE (4-1)
#define A_MB (5-1)
#define A_IO_DATA_IN (6-1)
#define A_IO_SELECT (7-1)
#define A_IO_SELECTED (8-1)
#define A_IO_DATA_OUT (9-1)
#define A_IO_DATA_AVAIL (10-1)
#define A_IO_INTERRUPT (11-1)
#define A_IO_SKIP (12-1)
#define A_IO_CLEAR_AC (13-1)

/* ----------------- */

void rf_raw_write_memory(struct rf_context_s *rf, int ma, u16 data)
{
    extern u16 *M;

    if (ma > 1024*1024) {
        vpi_printf("pli_rf: dma write, address error %x\n", ma);
        while (1);
    }

    M[ma] = data;
}

u16 rf_raw_read_memory(struct rf_context_s *rf, int ma)
{
    extern u16 *M;

    if (ma > 1024*1024) {
        vpi_printf("pli_rf: dma read, address error %x\n", ma);
        while (1);
    }

    return M[ma];
}

/* ----------------- */

static void set_output_str(int ord, char *str)
{
    s_vpi_value outval;

//    if (running_cver) {
//        if (argl[ord].aref == 0)
//            argl[ord].aref = vpi_put_value(argl[ord].ref, NULL, NULL, vpiAddDriver);
//    } else
        argl[ord].aref = argl[ord].ref;

    outval.format = vpiBinStrVal;
    outval.value.str = str;

    if (0) vpi_printf("rk: set output %s %s\n", argl[ord].name, str);

    vpi_put_value(argl[ord].aref, &outval, NULL, vpiNoDelay);
}

static void set_output_int(int ord, int val)
{
    s_vpi_value outval;

//    if (running_cver) {
//        if (argl[ord].aref == 0)
//            argl[ord].aref = vpi_put_value(argl[ord].ref, NULL, NULL, vpiAddDriver);
//    } else
        argl[ord].aref = argl[ord].ref;

    outval.format = vpiIntVal;
    outval.value.integer = val;

    if (0) vpi_printf("rk: set output %s %d\n", argl[ord].name, val);

    vpi_put_value(argl[ord].aref, &outval, NULL, vpiNoDelay);
}

void
io_rf_reset(struct rf_context_s *rf)
{
    rf->EMA = 0;
    rf->DMA = 0;
    rf->MEX = 0;
    rf->PEF = 0;
    rf->CIE = 0;
    rf->PIE = 0;
    rf->EIE = 0;
    rf->DCF = 1;
    rf->NXD = 0;

    rf->DRL = 0;
    rf->PER = 0;
    rf->WLS = 0;

    if (!rf->has_init) {
        if (rf->rf_fd) {
            close(rf->rf_fd);
            rf->rf_fd = 0;
        }

        vpi_printf("io_rf_reset() opening file\n");

        rf->rf_fd = open("rf.dsk", O_RDONLY);
        if (rf->rf_fd >= 0) {
            rf->size = read(rf->rf_fd, rf->buffer, sizeof(rf->buffer));
            rf->has_init = 1;
            vpi_printf("io_rf_reset() read %d bytes\n", rf->size);
        }
    }
}

void io_rf_cpu_int_set(struct rf_context_s *rf)
{
    vpi_printf("io_rf_cpu_int_set() intset seek\n");

//    set_output_str(A_INTERRUPT, "1");
//    set_output_int(A_VECTOR, 0220);
}

void io_rf_cpu_int_clear(struct rf_context_s *rf)
{
    vpi_printf("io_rf_cpu_int_clear() intset seek\n");

//    set_output_str(A_INTERRUPT, "0");
//    set_output_int(A_VECTOR, 0);
}


/* ------------------------------------------------------ */

void io_rf_service(struct rf_context_s *rf)
{
    u16 wc, ca;
    unsigned int pa;

    if (rf->dma_start) {

        rf->disk_addr = (rf->EMA << 12) | rf->DMA;

        vpi_printf("rf: %s dma to %o%o, count %o; disk_addr %o (%d) EMA %o DMA %o\n", 
                   rf->is_read ? "read" : "write",
                   rf->MEX, rf_raw_read_memory(rf, CA_ADDR),
                   rf_raw_read_memory(rf, WC_ADDR),
                   rf->disk_addr, rf->disk_addr,
                   rf->EMA, rf->DMA);

        do {
            wc = rf_raw_read_memory(rf, WC_ADDR);
            wc = (wc + 1) & 07777;
            rf_raw_write_memory(rf, WC_ADDR, wc);

            ca = rf_raw_read_memory(rf, CA_ADDR);
            ca = (ca + 1) & 07777;
            rf_raw_write_memory(rf, CA_ADDR, ca);

            pa = (rf->MEX << 12) | ca;

            if (rf->is_read) {
                rf_raw_write_memory(rf, pa, rf->buffer[rf->disk_addr]);
                if (0) vpi_printf("dma %06o <- %06o\n", pa, rf->buffer[rf->disk_addr]);
            }

            if (rf->is_write) {
                rf->buffer[rf->disk_addr] = rf_raw_read_memory(rf, pa);
                if (0) vpi_printf("dma %06o -> %06o\n", pa, rf->buffer[rf->disk_addr]);
            }

            rf->disk_addr = (rf->disk_addr + 1) & 03777777;

        } while (wc != 0);

        rf->dma_done = 1;

        vpi_printf("rf: dma done\n");
    }

    rf->dma_start = 0;
}

void io_rf_iot(struct rf_context_s *rf,
               unsigned state, unsigned io_select, unsigned mb, unsigned io_data_in,
               unsigned *pio_data_out, unsigned *pio_clear_ac, unsigned *pio_skip)
{
    *pio_clear_ac = 0;
    *pio_skip = 0;

    if (state == 1)
    switch (io_select) {
    case 060:
        switch (mb & 7) {
        case 3: // DMAR
            *pio_data_out = 0;
            *pio_clear_ac = 1;
            rf->dma_start = 1;
        case 5: // DMAW
            *pio_data_out = 0;
            *pio_clear_ac = 1;
            rf->dma_start = 1;
        }
        break;
    case 061:
        switch (mb & 7) {
        case 2: // DSAC
            if (rf->ADC) {
                *pio_skip = 1;
                *pio_data_out = 0;
                *pio_clear_ac = 1;
            }
            break;
        case 6: // DIMA
            *pio_data_out = 
                (rf->PCA << 11) |
                (rf->DRE << 10) |
                (rf->WLS << 9) |
                (rf->EIE << 8) |
                (rf->PIE << 7) |
                (rf->CIE << 6) |
                (rf->MEX << 3) |
                (rf->DRL << 2) |
                (rf->NXD << 1) |
                (rf->PER << 0);
            break;
        case 5: // DIML
            *pio_data_out = 0;
            *pio_clear_ac = 1;
            break;
        }
        break;
    case 062:
        switch (mb & 7) {
        case 1: // DFSE
            if (rf->DRL || rf->PER || rf->WLS || rf->NXD)
                *pio_skip = 1;
            break;
        case 2: // ?
            if (rf->DCF)
                *pio_skip = 1;
            break;
        case 3: // DISK
            if (rf->DRL || rf->PER || rf->WLS || rf->NXD || rf->DCF) {
                if (0) vpi_printf("rf: DISK %d %d %d %d %d\n",
                                  rf->DRL, rf->PER, rf->WLS, rf->NXD, rf->DCF);
                *pio_skip = 1;
            }
            break;
        case 6: // DMAC
            *pio_data_out = rf->DMA & 07777;
            break;
        }
        break;
    case 064:
        switch (mb & 7) {
        case 3: // DXAL
            *pio_data_out = 0;
            *pio_clear_ac = 1;
            break;
        case 5: // DXAC
            *pio_data_out = rf->EMA & 07777;
            break;
        }
        break;
    }

    switch (state) {
    case 0:
        switch (io_select) {
        case 060:
            if ((mb & 7) == 1) {
                vpi_printf("rf: DCMA\n");
                rf->DMA = 0;
                rf->PEF = 0;
                rf->NXD = 0;
                rf->DCF = 0;
            }
            break;
        case 061:
            switch (mb & 7) {
            case 1: // DCIM
                vpi_printf("rf: DCIM\n");
                rf->EIE = 0;
                rf->PIE = 0;
                rf->CIE = 0;
                rf->MEX = 0;
                break;
            case 2: // DSAC
                break;
            case 3: // DIML
                break;
            }
            break;
        }
        break;
    case 1:
        switch (io_select) {
        case 060:
            switch (mb & 7) {
            case 3: // DMAR
                rf->DMA = io_data_in & 07777;
                rf->is_read = 1;
                rf->DCF = 0;
                vpi_printf("rf: DMAR ac %o\n", io_data_in);
                break;
            case 5: // DMAW
                rf->DMA = io_data_in & 07777;
                rf->is_write = 1;
                rf->DCF = 0;
                vpi_printf("rf: DMAW ac %o\n", io_data_in);
                break;
            }
            break;
        case 061:
            switch (mb & 7) {
            case 5: // DIML
                rf->EIE = (io_data_in>>8) & 1;
                rf->PIE = (io_data_in>>7) & 1 ;
                rf->CIE = (io_data_in>>6) & 1;
                rf->MEX = (io_data_in>>3) & 7;
                vpi_printf("rf: DIML %o\n", io_data_in);
                break;
            }
            break;
        case 064:
            switch (mb & 7) {
            case 1: // DCXA
                rf->EMA = 0;
                break;
            case 3: // DXAL
                rf->EMA = io_data_in & 0377;
                break;
            }
            break;
        }
        break;

    case 2:
        break;

    case 3:
        io_rf_service(rf);

        if (rf->dma_done) {
            rf->EMA = (rf->disk_addr >> 12) & 0377;
            rf->DMA = rf->disk_addr & 07777;
            rf->is_read = 0;
            rf->is_write = 0;
            vpi_printf("rf: set DCF (CIE %d)\n", rf->CIE);
            rf->DCF = 1;

            rf->dma_start = 0;
            rf->dma_done = 0;
        }
        break;
    }

}

/* ------------------------------------------------------ */

#if 0
static int getadd_inst_id(vpiHandle mhref)
{
    register int i;
    char *chp;
 
    chp = vpi_get_str(vpiFullName, mhref);

    for (i = 1; i <= last_evh; i++) {
        if (strcmp(instnam_tab[i], chp) == 0)
            return(i);
    }

    vpi_printf("pli_rf: adding instance %d, %s\n", last_evh+1, chp);

    instnam_tab[++last_evh] = malloc(strlen(chp) + 1);
    strcpy(instnam_tab[last_evh], chp);

    return(last_evh);
} 
#endif

/*
 *
 */
PLI_INT32 pli_rf(void)
{
    vpiHandle href, iter/*, mhref*/;
    int numargs, inst_id;
    s_vpi_value tmpval;
    int i, badarg;
    char iot_bit, iot, clk_bit;
    struct rf_context_s *rf;
    unsigned int state, mb, decode, io_decode, io_select, data;
    int iot_start, iot_stop;
    int clk_start, clk_stop;

    if (0) vpi_printf("pli_rf: entry\n");

    href = vpi_handle(vpiSysTfCall, NULL); 
    if (href == NULL) {
        vpi_printf("** ERR: $pli_rf PLI 2.0 can't get systf call handle\n");
        return(0);
    }

#if 0
    mhref = vpi_handle(vpiScope, href);

    if (vpi_get(vpiType, mhref) != vpiModule) {
        vpiHandle old_mhref = mhref;
        mhref = vpi_handle(vpiModule, mhref); 
//        vpi_free_object(old_mhref);
    }

    inst_id = getadd_inst_id(mhref);
#else
    inst_id = 1;
#endif
    rf = &rf_context[inst_id];

    //vpi_printf("pli_rf: inst_id %d\n", inst_id);

    iter = vpi_iterate(vpiArgument, href);

    numargs = vpi_get(vpiSize, iter);

    badarg = 0;
    for (i = 0; argl[i].ord; i++) {
        argl[i].ref = vpi_scan(iter);
        if (argl[i].ref == NULL)
            badarg++;
        else {
            tmpval.format = vpiBinStrVal; 
            vpi_get_value(argl[i].ref, &tmpval);
            strcpy(argl[i].bits, tmpval.value.str);

            tmpval.format = vpiIntVal; 
            vpi_get_value(argl[i].ref, &tmpval);
            argl[i].value = tmpval.value.integer;
        }
    }

//    vpi_free_object(iter);
    vpi_free_object(href);

    if (badarg)
    {
        vpi_printf("**ERR: $pli_rf bad args\n");
        return(0);
    }

    if (!rf->has_init) {
        io_rf_reset(rf);

        for (i = 0; argl[i].ord; i++) {
            if (argl[i].preset) {
                if (0) vpi_printf("pli_rf: preset %s\n", argl[i].name);
                set_output_str(i, "0");
            }
        }
    }

    /* */
    iot_start = 0;
    iot_stop = 0;

    iot_bit = argl[A_IOT].bits[0];
    clk_bit = argl[A_CLK].bits[0];

    if (iot_bit != last_iot_bit) {
        if (iot_bit == '1') iot_start = 1;
        if (iot_bit == '0') iot_stop = 1;
    }

    if (clk_bit != last_clk_bit) {
        if (clk_bit == '1') clk_start = 1;
        if (clk_bit == '0') clk_stop = 1;
    }

    last_iot_bit = iot_bit;
    last_clk_bit = clk_bit;

    iot = argl[A_IOT].value;
    state = argl[A_STATE].value;
    io_select = argl[A_IO_SELECT].value;
    mb = argl[A_MB].value;
    data = argl[A_IO_DATA_IN].value;

    io_decode = iot && (io_select == 060 ||
                        io_select == 061 ||
                        io_select == 062 ||
                        io_select == 064);

    decode = (state == 1) && io_decode;

    if (0)
        vpi_printf("pli_rf: state %d iot %d mb %o decode %d\n", state, iot, mb, decode);

    if (0) {
        if (iot_start) vpi_printf("pli_rf: iot start\n");
        if (iot_stop) vpi_printf("pli_rf: iot stop\n");
    }

    /* */
    if (argl[A_RESET].value == 1) {
        vpi_printf("pli_rf: reset\n");
        io_rf_reset(rf);
    }

    set_output_int(A_IO_SELECTED, decode ? 1 : 0);

//    if ((iot_start && decode) || state <= 3)
    if (clk_stop && io_decode)
    {
        unsigned io_data_out, io_clear_ac, io_skip;

        if (0) vpi_printf("pli_rf: iot %o data %o\n", iot, data);

        io_data_out = argl[A_IO_DATA_IN].value;

        io_rf_iot(rf, state, io_select, mb, data, &io_data_out, &io_clear_ac, &io_skip);

        set_output_int(A_IO_DATA_OUT, io_data_out);
        set_output_int(A_IO_CLEAR_AC, io_clear_ac);
        set_output_int(A_IO_SKIP, io_skip);

        if ((rf->CIE & rf->DCF) ||
            (rf->PIE & rf->PCA) ||
            (rf->EIE & (rf->WLS | rf->DRL | rf->NXD | rf->PER)))
        {
            vpi_printf("pli_rf: set interrupt\n");
            set_output_int(A_IO_INTERRUPT, 1);
        } else
            set_output_int(A_IO_INTERRUPT, 0);
    }

    set_output_int(A_IO_DATA_AVAIL, 1);

//    if (iot_stop && decode) {
//        set_output_str(A_IO_DATA_OUT, "16'b0000000000000000");
//    }

#if 0
    /* free argument handles */
    for (i = 0; argl[i].ord; i++) {
        if (argl[i].ref != NULL)
            vpi_free_object(argl[i].ref);
        if (argl[i].aref != NULL && argl[i].aref != argl[i].ref)
            vpi_free_object(argl[i].aref);
        argl[i].ref = NULL;
        argl[i].aref = NULL;
    }
#endif

    vpi_free_object(iter);

    if (0) vpi_printf("pli_rf: exit\n");

    return(0);
}

/*
 * register all vpi_ PLI 2.0 style user system tasks and functions
 */
static void register_my_systfs(void)
{
    p_vpi_systf_data systf_data_p;

    /* use predefined table form - could fill systf_data_list dynamically */
    static s_vpi_systf_data systf_data_list[] = {
        { vpiSysTask, 0, "$pli_rf", pli_rf, NULL, NULL, NULL },
        { vpiSysTask, 0, "$pli_ram", pli_ram, NULL, NULL, NULL },
        { 0, 0, NULL, NULL, NULL, NULL, NULL }
    };

    systf_data_p = &(systf_data_list[0]);
    while (systf_data_p->type != 0) {
        vpi_register_systf(systf_data_p++);
    }
}

#ifdef unix
/* all routines are called to register system tasks */
/* called just after all PLI 1.0 tf_ veriusertfs table routines are set up */
/* before source is read */ 
static void (*rf_vlog_startup_routines[]) () =
{
 register_my_systfs, 
 0
};

/* dummy +loadvpi= boostrap routine - mimics old style exec all routines */
/* in standard PLI vlog_startup_routines table */
void rf_vpi_compat_bootstrap(void)
{
    int i;

    io_rf_debug = 0;
    rf_debug = 1;

    for (i = 0;; i++) {
        if (rf_vlog_startup_routines[i] == NULL)
            break; 
        rf_vlog_startup_routines[i]();
    }
}

void vpi_compat_bootstrap(void)
{
    running_cver = 1;
    rf_vpi_compat_bootstrap();
}

#ifndef BUILD_ALL
void __stack_chk_fail_local() {}
#endif

#endif

#ifdef __MODELSIM__
static void (*vlog_startup_routines[]) () =
{
 register_my_systfs, 
 0
};
#endif


/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
