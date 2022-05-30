/* pli_disassemble.c */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

#ifdef unix
#include <unistd.h>
#endif

#ifdef _WIN32
typedef int off_t;
#endif

#include "vpi_user.h"

#ifdef __CVER__
#include "cv_vpi_user.h"
#endif

#ifdef __MODELSIM__
#include "veriuser.h"
#endif

PLI_INT32 pli_disassemble(void);
static void register_my_systfs(void);

/*
 *
 */
PLI_INT32 pli_disassemble(void)
{
    vpiHandle href, iter, mhref;
    vpiHandle pcref, irref;
    int numargs;
    unsigned short pc, ir;
    s_vpi_value tmpval;

    int op, mode, addr;
    char line[128];

    //vpi_printf("pli_disassemble:\n");

    href = vpi_handle(vpiSysTfCall, NULL); 
    if (href == NULL) {
        vpi_printf("** ERR: $pli_disassemble PLI 2.0 can't get systf call handle\n");
        return(0);
    }

    mhref = vpi_handle(vpiScope, href);

    if (vpi_get(vpiType, mhref) != vpiModule)
        mhref = vpi_handle(vpiModule, mhref); 

    iter = vpi_iterate(vpiArgument, href);

    numargs = vpi_get(vpiSize, iter);

    pcref = vpi_scan(iter);
    irref = vpi_scan(iter);

    if (pcref == NULL || irref == NULL)
    {
        vpi_printf("**ERR: $pli_disassemble bad args\n");
        return(0);
    }

    tmpval.format = vpiIntVal; 
    vpi_get_value(pcref, &tmpval);
    pc = tmpval.value.integer;

    tmpval.format = vpiIntVal; 
    vpi_get_value(irref, &tmpval);
    ir = tmpval.value.integer;

    op = (ir >> 9) & 7;
    mode = (ir >> 7) & 3;
    addr = ir & 0177;
    line[0] = 0;

    switch (op) {
    case 0: strcpy(line, "AND "); break;
    case 1: strcpy(line, "TAD "); break;
    case 2: strcpy(line, "ISZ "); break;
    case 3: strcpy(line, "DCA "); break;
    case 4: strcpy(line, "JMS "); break;
    case 5: strcpy(line, "JMP "); break;
    case 6:
        switch (ir) {
        case 06031: strcpy(line, "KSF "); break;
        case 06036: strcpy(line, "KRB "); break;
        case 06046: strcpy(line, "TLS "); break;
        case 06042: strcpy(line, "TCF "); break;
        case 06041: strcpy(line, "TSF "); break;
        case 06603: strcpy(line, "DMAR "); break;
        }
        break;
    case 7:
        switch ( (((ir >> 8) & 1) << 1) | (ir&1) ) {
        case 0:
        case 1:
            if (ir & 0200) strcat(line, "CLA ");
            if (ir & 0100) strcat(line, "CLL ");
            if (ir & 0040) strcat(line, "CMA ");
            if (ir & 0020) strcat(line, "CML ");
            if (ir & 0010) strcat(line, (ir & 2) ? "RTR " : "RAR ");
            if (ir & 0004) strcat(line, (ir & 2) ? "RTL " : "RAL ");
            if (ir & 0001) strcat(line, "IAC ");
            break;
        case 2:
            if (ir & 0200) strcat(line, "CLA ");
            if (ir & 0100) strcat(line, (ir & 010) ? "SPA " : "SLA");
            if (ir & 0040) strcat(line, (ir & 010) ? "SNA " : "SZA");
            if (ir & 0020) strcat(line, (ir & 010) ? "SZL " : "SNL");
            if (ir & 0004) strcat(line, "OSR ");
            if (ir & 0002) strcat(line, "HALT ");
            break;
        case 3:
            if (ir & 0200) strcat(line, "CLA ");
            break;
        }
        break;
    }

    if (op < 6) {
        char al[64];
        switch (mode) {
        case 0: sprintf(al, "Z %o", addr); break;
        case 1: sprintf(al, "%o", (pc & 07600) | addr); break;
        case 2: sprintf(al, "I Z %o", addr); break;
        case 3: sprintf(al, "I %o", (pc & 07600) | addr); break;
        }

        strcat(line, al);
    }

    vpi_printf("%04o: %04o %s\n", pc, ir, line);

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
        { vpiSysTask, 0, "$pli_disassemble", pli_disassemble, NULL, NULL, NULL },
        { 0, 0, NULL, NULL, NULL, NULL, NULL }
    };

    systf_data_p = &(systf_data_list[0]);
    while (systf_data_p->type != 0) vpi_register_systf(systf_data_p++);
}

#ifdef __CVER__
void (*disassemble_vlog_startup_routines[]) () =
{
 register_my_systfs, 
 0
};

/* dummy +loadvpi= boostrap routine - mimics old style exec all routines */
/* in standard PLI vlog_startup_routines table */
void disassemble_vpi_compat_bootstrap(void)
{
    int i;

    for (i = 0;; i++) 
    {
        if (disassemble_vlog_startup_routines[i] == NULL) break; 
        disassemble_vlog_startup_routines[i]();
    }
}

void vpi_compat_bootstrap(void)
{
    disassemble_vpi_compat_bootstrap();
}

void __stack_chk_fail_local(void) {}
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
