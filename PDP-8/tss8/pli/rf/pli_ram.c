/* pli_ram.c */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

#ifdef unix
#include <unistd.h>
#endif

#include "vpi_user.h"

#ifdef __CVER__
#include "cv_vpi_user.h"
#endif

#ifdef __MODELSIM__
#include "veriuser.h"
#endif

typedef unsigned short u16;

static char last_rd_bit;
static char last_wr_bit;
static unsigned last_addr;
static int rom_enabled;
static int rom_disabling;

static vpiHandle do_aref;
static int mem_init;
u16 *M;

/*
static char *instnam_tab[10]; 
static int last_evh;
*/
extern int running_cver;

void do_mem_preload(char *fn)
{
    FILE *f;
    f = fopen(fn, "r");
    if (f) {
        unsigned int a, v;
        while (fscanf(f, "%o %o\n", &a, &v) == 2) {
            vpi_printf("[%06o] <- %06o\n", a, v);
            M[a] = v;
        }
        fclose(f);
    }
}
void do_mem_init(void)
{
    int i;

    vpi_printf("pli_ram: allocate memory array\n");

    M = (u16 *)malloc(1024*32*2);
    mem_init = 1;

    for (i = 0; i < 32768; i++)
        M[i] = 0;

    if (0) do_mem_preload("test1.mem");
}

#if 0
static int getadd_inst_id(vpiHandle mhref)
{
    register int i;
    char *chp;
 
    chp = vpi_get_str(vpiFullName, mhref);
    //vpi_printf("getadd_inst_id() %s\n", chp);

    for (i = 1; i <= last_evh; i++) {
        if (strcmp(instnam_tab[i], chp) == 0)
            return(i);
    }

    vpi_printf("pli_ram: adding instance %d, %s\n", last_evh+1, chp);

    instnam_tab[++last_evh] = malloc(strlen(chp) + 1);
    strcpy(instnam_tab[last_evh], chp);

    return(last_evh);
} 
#endif

PLI_INT32 pli_ram(void)
{
    vpiHandle href, iter/*, mhref*/;
    vpiHandle resetref, aref, diref, doref, rdref, wrref;
    s_vpi_value tmpval, outval;
    int numargs, inst_id;

    char reset_bit;
    char di_bits[17], do_bits[17];
    char rd_bit, wr_bit;
    unsigned int a, datai;

    int read_start, read_stop, write_start, write_stop, addr_change;

    if (0) vpi_printf("pli_ram: entry\n");

    if (M == 0/*!mem_init*/) {
        do_mem_init();
    }

    href = vpi_handle(vpiSysTfCall, NULL); 
    if (href == NULL) {
        vpi_printf("** ERR: $pli_ram PLI 2.0 can't get systf call handle\n");
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

    //vpi_printf("pli_ram: inst_id %d\n", inst_id);

    iter = vpi_iterate(vpiArgument, href);

    numargs = vpi_get(vpiSize, iter);

    /* reset, a, di, do, rd, wr */
    resetref = vpi_scan(iter);
    aref = vpi_scan(iter);
    diref = vpi_scan(iter);
    doref = vpi_scan(iter);
    rdref = vpi_scan(iter);
    wrref = vpi_scan(iter);

//    vpi_free_object(iter);
    vpi_free_object(href);

    if (resetref == NULL || aref == NULL ||
	diref == NULL || doref == NULL || rdref == NULL ||
	wrref == NULL)
    {
        vpi_printf("**ERR: $pli_ram bad args\n");
        return(0);
    }

    /* */
    tmpval.format = vpiBinStrVal; 
    vpi_get_value(resetref, &tmpval);
    reset_bit = tmpval.value.str[0];

    memset(&tmpval, 0, sizeof(tmpval));
    tmpval.format = vpiIntVal; 
    vpi_get_value(aref, &tmpval);
    a = tmpval.value.integer;

    tmpval.format = vpiBinStrVal; 
    vpi_get_value(diref, &tmpval);
    strcpy(di_bits, tmpval.value.str);

    tmpval.format = vpiIntVal; 
    vpi_get_value(diref, &tmpval);
    datai = tmpval.value.integer;

    tmpval.format = vpiBinStrVal; 
    vpi_get_value(doref, &tmpval);
    strcpy(do_bits, tmpval.value.str);

    memset(&tmpval, 0, sizeof(tmpval));
    tmpval.format = vpiBinStrVal; 
    vpi_get_value(rdref, &tmpval);
    rd_bit = tmpval.value.str[0];

    memset(&tmpval, 0, sizeof(tmpval));
    tmpval.format = vpiBinStrVal; 
    vpi_get_value(wrref, &tmpval);
    wr_bit = tmpval.value.str[0];

    /* */
    read_start = 0;
    read_stop = 0;
    write_start = 0;
    write_stop = 0;
    addr_change = 0;

    if (a != last_addr)
        addr_change = 1;

    if (wr_bit != last_wr_bit || addr_change) {
        if (wr_bit == '1') write_start = 1;
        if (wr_bit == '0') write_stop = 1;
    }

    if (rd_bit != last_rd_bit || write_stop || addr_change) {
        if (rd_bit == '1') read_start = 1;
        if (rd_bit == '0') read_stop = 1;
    }

    last_rd_bit = rd_bit;
    last_wr_bit = wr_bit;
    last_addr = a;

    if (0) vpi_printf("pli_ram: rd %c wr %c\n", rd_bit, wr_bit);

    if (reset_bit == '1') {
        vpi_printf("pli_ram: reset\n");
        rom_enabled = 1;
        rom_disabling = 0;
    }

    if (0) {
        if (read_start) vpi_printf("pli_ram: read start\n");
        if (read_stop) vpi_printf("pli_ram: read stop\n");
        if (write_start) vpi_printf("pli_ram: write start\n");
        if (write_stop) vpi_printf("pli_ram: write stop\n");
    }

    /* */
    if (write_start) {
        if (1) vpi_printf("pli_ram: write %o <- %o\n", a, datai);

        if (a > 1024*1024) {
            vpi_printf("pli_ram: write, address error %o\n", a);
            while (1);
        }

        M[a] = datai;
    }

    if (read_start) {
        u16 value;

        if (a > 1024*32) {
            vpi_printf("pli_ram: write, address error %x\n", a);
            while (1);
        }

#if 1
        if (rom_enabled) {
            switch (a) {
                // copy tss8 bootstrap to ram and jump to it
                // (see ../rom/rom.pal)
	    case 07400: value = 07240; break;
	    case 07401: value = 01224; break;
	    case 07402: value = 03010; break;
	    case 07403: value = 01217; break;
	    case 07404: value = 03410; break;
	    case 07405: value = 01220; break;
	    case 07406: value = 03410; break;
	    case 07407: value = 01221; break;
	    case 07410: value = 03410; break;
	    case 07411: value = 01222; break;
	    case 07412: value = 03410; break;
	    case 07413: value = 01223; break;
	    case 07414: value = 03410; break;
	    case 07415: value = 07300; break;
	    case 07416: value = 05624; break;
	    case 07417: value = 07600; break;
	    case 07420: value = 06603; break;
	    case 07421: value = 06622; break;
	    case 07422: value = 05352; break;
	    case 07423: value = 05752; break;
	    case 07424: value = 07750; break;
            default: value = M[a]; break;
            }

            if (a == 07416)
                rom_disabling = 1;

            if (rom_disabling)
                rom_disabling++;

            if (rom_disabling == 3) {
                rom_enabled = 0;
            }
        } else
#endif
        {
            value = M[a];
        }

        if (1) vpi_printf("pli_ram: read %o -> %o\n", a, value);

//        if (running_cver) {
//            if (do_aref == 0)
//                do_aref = vpi_put_value(doref, NULL, NULL, vpiAddDriver);
//        } else
            do_aref = doref;

        outval.format = vpiIntVal;
        outval.value.integer = value;

        vpi_put_value(do_aref, &outval, NULL, vpiNoDelay);
    }

//    if (read_stop) {
//        outval.format = vpiBinStrVal;
//        outval.value.str = "16'b0000000000000000";
//        if (do_aref)
//            vpi_put_value(do_aref, &outval, NULL, vpiNoDelay);
//    }

#if 0
    vpi_free_object(resetref);
    vpi_free_object(aref);
    vpi_free_object(diref);
    vpi_free_object(doref);
    vpi_free_object(rdref);
    vpi_free_object(wrref);
#endif

    vpi_free_object(iter);

    if (0) vpi_printf("pli_ram: exit\n");

    return 0;
}



/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
