/*
 * basic pdp-8i behavioral model
 * ment to look and act like the verilog model
 * brad@heeltoe.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <fcntl.h>

typedef unsigned char u8;
typedef unsigned short u12;
typedef unsigned short u15;
typedef unsigned int u20;
typedef unsigned char u3;
typedef unsigned char u7;

u8 binfile[16*1024];
int binfile_size;

#define MEMSIZE (32*1024)
u12 mem[MEMSIZE];

#define RFSIZE (1024*1024)
u12 rf[RFSIZE];
int rf_size;

int tc_status_a;
int tc_status_b;
int tc_err_flag;

char tto_buf[1024];
int tto_buf_count;

int kw_flag;
int kw_clk_en;
int kw_int_en;
int kw_int_req;
int kw_clk;
int kw_int_count;

int d_load = 0;
int d_fetch = 0;
int d_decode = 0;
int d_cycle = 0;
int d_mem = 0;
int d_trace = 0;
int d_dma = 0;
int d_io = 0;

int loadbin(char *fn)
{
    int f, ch, o;
    int rubout, newfield, state, high, low, done;
    int word, csum;
    u12 origin, field;

    f = open(fn, O_RDONLY);
    if (f < 0) {
	perror(fn);
	return -1;
    }

    binfile_size = read(f, binfile, sizeof(binfile));

    if (d_load) printf("binload: %d bytes\n", binfile_size);

    done = 0;
    rubout = 0;
    state = 0;
    csum = 0;

    for (o = 0; o < binfile_size && !done; o++) {
	ch = binfile[o];

	if (rubout) {
	    rubout = 0;
	    continue;
	}

	if (ch == 0377) {
	    rubout = 1;
	    continue;
	}

	if (ch > 0200) {
	    newfield = (ch & 070) << 9;
	    continue;
	}

	switch (state) {
	case 0:
	    /* leader */
	    if ((ch != 0) && (ch != 0200)) state = 1;
	    high = ch;
	    break;

	case 1:
	    /* low byte */
	    low = ch;
	    state = 2;
	    break;

	case 2:
	    /* high with test */
	    word = (high << 6) | low;
	    if (ch == 0200) {
		if ((csum - word) & 07777) {
		    printf("loadbin: checksum error\n");
		}
		done = 1;
		continue;
	    }
	    csum = csum + low + high;
	    if (word >= 010000) {
		origin = word & 07777;
	    } else {
		if ((field | origin) >= MEMSIZE) {
		    printf("loadbin: too big\n");
		}

		if (d_load) printf("mem[%o] = %o\n", field|origin, word&07777);

		mem[field | origin] = word & 07777;
		origin = (origin + 1) & 07777;
	    }
	    field = newfield;
	    high = ch;
	    state = 1;
	    break;
	}
    }

    close(f);
    return 0;
}

int loaddisk(char *fn)
{
    int fd, ret;

    fd = open(fn, O_RDONLY);
    if (fd < 0) {
	perror(fn);
	return -1;
    }

    ret = read(fd, rf, sizeof(rf));
    if (ret < 0) {
	perror(fn);
    } else {
	rf_size = ret / 2;
	printf("rf_size %d\n", rf_size);
	ret = 0;
    }

    close(fd);
    return ret;
}

char *disassem(int pc, int mb)
{
    static char buf[128];
    char b1[64];
    int i, b[12];

    for (i = 0; i < 12; i++)
	b[i] = mb & (1 << i);

    buf[0] = 0;

    switch ((mb & 07000) >> 9) {
    case 0: sprintf(buf, "and "); goto d;
    case 1: sprintf(buf, "tad "); goto d;;
    case 2: sprintf(buf, "isz "); goto d;;
    case 3: sprintf(buf, "dca "); goto d;;
    case 4: sprintf(buf, "jms "); goto d;;
    case 5: sprintf(buf, "jmp ");
    d:
	if (b[8]) strcat(buf, "I ");
	if (!b[7]) strcat(buf, "Z ");
	sprintf(b1, "%o", mb & 0177);
	strcat(buf, b1);
	break;

    case 6: sprintf(buf, "iot "); break;

    case 7:
	if (b[8] == 0) {
	    if (b[7]) strcat(buf, "cla ");
	    if (b[6]) strcat(buf, "clf ");
	    if (b[5]) strcat(buf, "cma ");
	    if (b[4]) strcat(buf, "cmla ");
	    switch ((mb & 016) >> 1) {
	    case 1: strcat(buf, "bsw "); break;
	    case 2: strcat(buf, "ral "); break;
	    case 3: strcat(buf, "rtl "); break;
	    case 4: strcat(buf, "rar "); break;
	    case 5: strcat(buf, "rtr "); break;
	    }
	    if (b[0]) strcat(buf, "iac ");
	} else 
	    if (b[8] && b[0] == 0) {
		if (b[7]) strcat(buf, "cla ");

		if (b[6]) strcat(buf, "sma ");
		if (b[5]) strcat(buf, "sza ");
		if (b[4]) strcat(buf, "snl ");
		if (b[3]) strcat(buf, "skp ");

		if (b[2]) strcat(buf, "osr ");
		if (b[1]) strcat(buf, "hlt ");
	    } else {
		if (b[7]) strcat(buf, "cla ");
		if (b[6]) strcat(buf, "mqa ");
		if (b[5]) strcat(buf, "sca ");
		if (b[4]) strcat(buf, "mql ");
	    }
	break;
    }

    return buf;
}

typedef unsigned char wire;
typedef unsigned char reg;

u15 pc;
u15 fetch_pc;
u12 ac;
reg l;
u3 DF, IF, IB;
u7 SF;
reg UF, UB, UI;

u12 ma;
u12 mq;

u12 switches;
wire run;
wire interrupt;
wire interrupt_enable;
//wire interrupt_enable_req;
wire interrupt_inhibit;
wire interrupt_cycle;
wire interrupt_skip;

wire UB_pending;
wire IB_pending;
wire io_interrupt;
wire io_skip, skip_condition, pc_incr, pc_skip;

int tti_flag;
int tti_event;

int tto_flag;
int tt_data;
int tt_countdown;

int tti_input_index;
char tti_data;
char tti_input[] = "START\r01:01:85\r10:10\r\r\r";
int tti_input_count = sizeof(tti_input)-1;

//int io_cycle_count;
wire io_data_avail;
u12 io_data;

wire ram_we;

u20 rf_da;
wire rf_done;
u12 rf_sta;
int rf_func;
int rf_int_req;
int rf_capac = 262144;
int rf_wlk;
int rf_burst = 1;

#define RFS_PCA		04000				/* photocell status */
#define RFS_DRE		02000				/* data req enable */
#define RFS_WLS		01000				/* write lock status */
#define RFS_EIE		00400				/* error int enable */
#define RFS_PIE		00200				/* photocell int enb */
#define RFS_CIE		00100				/* done int enable */
#define RFS_MEX		00070				/* memory extension */
#define RFS_DRL		00004				/* data late error */
#define RFS_NXD		00002				/* non-existent disk */
#define RFS_PER		00001				/* parity error */
#define RFS_ERR		(RFS_WLS + RFS_DRL + RFS_NXD + RFS_PER)

#define RF_WMASK 03777

#define RF_WC		07750				/* word count */
#define RF_MA		07751				/* mem address */

#define RF_READ		2
#define RF_WRITE	4

#define INT_RF		1

void rf_int_update(void)
{
   if ((rf_done && (rf_sta & RFS_CIE)) ||
       ((rf_sta & RFS_ERR) && (rf_sta & RFS_EIE)) ||
       ((rf_sta & RFS_PCA) && (rf_sta & RFS_PIE)))
   {
       if (d_io) printf("set rf_int_req\n");
       rf_int_req |= INT_RF;
   } else {
       if (d_io) printf("clear rf_int_req\n");
       rf_int_req &= ~INT_RF;
   }
}

void rf_go(void)
{
    unsigned mex, t, pa;

    mex = (rf_sta & 070) >> 3;
    printf("rf_go! rf_func %o, rf_da %o, wc %o, pa %o\n",
	   rf_func, rf_da, mem[RF_WC], (mex << 12) | mem[RF_MA]);

    do {
	if ((unsigned) rf_da >= rf_size) {
	    rf_sta = rf_sta | RFS_NXD;
	    break;
	}

	mem[RF_WC] = (mem[RF_WC] + 1) & 07777;
	mem[RF_MA] = (mem[RF_MA] + 1) & 07777;

	pa = (mex << 12) | mem[RF_MA];

	if (rf_func == RF_READ) {
	    mem[pa] = rf[rf_da];
	    if (d_dma) printf("dma [%o] <- %o\n", pa, mem[pa]);
	} else {
	    t = ((rf_da >> 15) & 030) | ((rf_da >> 14) & 07);
	    if ((rf_wlk >> t) & 1)			/* write locked? */
		rf_sta = rf_sta | RFS_WLS;
	    else {					/* not locked */
		rf[rf_da] = mem[pa];
	    }
	}

	rf_da = (rf_da + 1) & 03777777;			/* incr disk addr */
    } while ((mem[RF_WC] != 0) && (rf_burst != 0));	/* brk if wc, no brst */

    if ((mem[RF_WC] != 0) && ((rf_sta & RFS_ERR) == 0))	/* more to do? */
	;
    else {
	if (d_io) printf("rf_done!\n");
	rf_done = 1;
	rf_int_update(); 
    }

    if (d_io) printf("rf_go done; rf_da %o\n", rf_da);
}

void tti_set_event(void)
{
    tti_event = 1;
}

void tti_service(void)
{
    if (tti_input_index < tti_input_count &&
        tti_flag == 0 && tti_event)
    {
        tti_data = tti_input[tti_input_index++];
        tti_event = 0;
        tti_flag = 1;
        io_interrupt = 1;
    }
}

void tto_service(void)
{
    if (tt_countdown > 0) {
	tt_countdown--;
	if (tt_countdown == 0) {

	    printf("xxx tx_data %o\n", tt_data);

            tto_flag = 1;
	    io_interrupt = 1;

	    {
		int i;
		tto_buf[tto_buf_count++] = tt_data;
		printf("xxx output: ");
		for (i = 0; i < tto_buf_count; i++) {
		    char ch = tto_buf[i] & 0177;
		    switch (ch) {
		    case '\n': printf("\\n"); break;
		    case '\r': printf("\\r"); break;
		    default: printf("%c", ch & 0177); break;
		    }
		}
		printf("\n");
	    }

	}
    } else {
        if (tto_flag && interrupt_enable) {
            printf("tto_flag set; set int\n");
	    io_interrupt = 1;
        }
    }
}

unsigned long cycles;

void
execute(void)
{
    u12 memory_bus, mb;
    wire ir;
    wire and, tad, isz, dca, jms, jmp, iot, opr;
    u12 io_select;

    cycles++;
    if (cycles >= 300000)
        run = 0;

    if (kw_clk_en) {
        kw_clk++;
        if (kw_clk > 16000/*125000*/) {
            if (0) printf("kw_clk fired\n");
            kw_clk = 0;
            kw_flag = 1;
            if (kw_int_en) {
                kw_int_req = 1;
                io_interrupt = 1;
                kw_int_count++;
            }
        }
    }

    tti_service();

F0:
    memory_bus = mem[(IF<<12) | pc];
    fetch_pc = pc;

    interrupt_skip = 0;
    if (interrupt && interrupt_enable &&
	!interrupt_inhibit && !interrupt_cycle)
    {
	printf("xxx %lu interrupt @ %o (UF%d IF%o DF%o)\n",
               cycles, (IF<<12)|pc, UF, IF, DF);
	interrupt_cycle = 1;
	interrupt = 0;
	interrupt_enable = 0;
	mb = 04000;
	memory_bus = mb;
	ir = 4;
	SF = (UF<<6) | (IF<<3) | DF;
	IF = 0;
	DF = 0;
        IB = 0;
        UF = 0;
        UB = 0;

        if (0) {
            d_trace = 1;
            d_mem = 1;
            d_io = 1;
        }
    } else {
	interrupt_cycle = 0;
	mb = memory_bus;
    }

    if (d_fetch) {
	printf("\n");
	printf("fetch: if=%o, pc=%04o %04o %s\n", IF, pc, mb, disassem(pc, mb));
	printf("       l=%d ac=%04o\n", l, ac);
    }

    if (d_trace) {
#if 0
	printf("pc %04o ir %04o l%o ac %04o ion %d "
               "(%s%s%s%sIF%o DF%o UF%o SF%o IB%o UB%o)\n",
	       (IF<<12)|pc, mb, l, ac, interrupt_enable,
	       IB_pending ? "i" : "",
               UB_pending ? "u" : "",
               interrupt_enable_req ? "I" : "",
	       (IB_pending || UB_pending || interrupt_enable_req) ? " " : "",
	       IF, DF, UF, SF, IB, UB);
#else
	printf("pc %04o ir %04o l%o ac %04o ion %d "
               "(IF%o DF%o UF%o SF%o IB%o UB%o)\n",
	       (IF<<12)|pc, mb, l, ac, interrupt_enable,
	       IF, DF, UF, SF, IB, UB);
#endif
    }

#define bitmask(l) ((unsigned int)0xffffffff >> (31-(l)))
#define mb_bit(n)  ((mb & (1<<n)) ? 1 : 0)
#define mb_bits(h,l)  ((mb >> l) & bitmask(h-l))

    ir = (memory_bus >> 9) & 7;

    and = ir == 0;
    tad = ir == 1;
    isz = ir == 2;
    dca = ir == 3;
    jms = ir == 4;
    jmp = ir == 5;
    iot = ir == 6;
    opr = ir == 7;

    skip_condition =
	((mb_bit(6) && (ac & 04000)) ||
	 (mb_bit(5) && (ac == 0)) ||
	 (mb_bit(4) && (l == 1))) ? 1 : 0;

    pc_incr =
        /* group 1 */
	(opr & !mb_bit(8)) ||
	/* group 2 */
	(opr && (mb_bit(8) && !mb_bit(0)) && (skip_condition == mb_bit(3))) ||
        /* group 3? */
	(opr && (mb_bit(8) && mb_bit(0))) ||
	iot ||
	(!(opr || iot) && !interrupt_cycle);

    pc_skip =
	(opr && (mb_bit(8) && !mb_bit(0)) && (skip_condition ^ mb_bit(3))) ||
	(iot && (io_skip || interrupt_skip));
//		(iot && mb_bit(0) && io_skip);

    if (d_decode) {
	printf("and %d tad %d isz %d dca %d jms %d jmp %d ito %d opr %d\n",
	       and, tad, isz, dca, jms, jmp, iot, opr);
	printf("skip %d, pc_incr %d, pc_skip %d\n",
	       skip_condition, pc_incr, pc_skip);

	if (0) printf("skip_condition %o; %o %o %o\n",
		      skip_condition, mb_bit(3),
		      (skip_condition == mb_bit(3)),
		      (skip_condition ^ mb_bit(3)));
    }

F1:
    if (opr) {
	/* group 1 */
	if (mb_bit(8) == 0) {
	    if (mb_bit(7)) ac = 0;
	    if (mb_bit(6)) l = 0;
	    if (mb_bit(5)) ac = ~ac & 07777;
	    if (mb_bit(4)) l = ~l & 1;
	}

	/* group 2 */
	if (mb_bit(8) && !mb_bit(0)) {
	    if (mb_bit(7)) ac = 0;
	}

	/* group 3 */
	if (mb_bit(8) && mb_bit(0)) {
	    if (mb_bit(7)) ac = 0;
	}
    }

    io_select = (mb >> 3) & 077;

    if (iot) {
	if (d_cycle) printf("iot; io_select %o\n", io_select);

	switch (io_select) {
	case 0:	// ION, IOF
	    switch (mb & 7) {
	    case 1:				// ION
		if (d_fetch) printf("xxx ints on\n");
//		interrupt_enable_req = 1;
		interrupt_enable = 1;
interrupt_inhibit = 1;
		break;
	    case 2:				// IOF
		if (d_fetch) printf("xxx ints off\n");
		interrupt_enable = 0;
		break;
	    case 3: /* srq? */
                if (interrupt_enable)
                    interrupt_skip = 1;
                break;
            default:
                printf("UNKNOWN IOX %o @ %o\n", mb, pc);
                break;
	    }
	    break;

	case 020: case 021: case 022: case 023:	// CDF..RMF
	case 024: case 025: case 026: case 027:
            /* KT8/I */
            switch (mb) {
            case 06204:
                if (d_io) printf("CINT\n");
                UI = 0;
                break;
            case 06254:
                if (d_io) printf("SINT\n");
                if (UI)
                    io_skip = 1;
                break;
            case 06264:
                if (d_io) printf("CUF\n");
                UB = 0;
                UB_pending = 1;
                IB_pending = 1;
                interrupt_inhibit = 1;
                break;
            case 06274:
                if (d_io) printf("SUF\n");
                UB = 1;
                UB_pending = 1;
                IB_pending = 1;
                interrupt_inhibit = 1;
                break;

            default:
                if (mb & 1)
                    DF = (mb >> 3) & 7;		// CDF
                if (mb & 2) {
                    IB = (mb >> 3) & 7;		// CIF
                    interrupt_inhibit = 1;
                    IB_pending = 1;
                }
                switch (mb & 7) {
                case 4:
                    switch (io_select & 7) {
                    case 1: ac = DF << 3; break;// RDF
                    case 2: ac = IF << 3; break;// RIF
                    case 3: ac = SF; break;	// RIB
                    case 4:			// RMF
                        if (d_io) printf("RMF\n");
                        UB = (SF >> 6) & 1;
                        IB = (SF >> 3) & 7;
                        DF = SF & 7;
                        IB_pending = 1;
                        UB_pending = 1;
                        interrupt_inhibit = 1;
                        break;
                    }
                    break;
                }
                break;
            }
	}

#if 1
	switch (io_select) {
	case 003:
            /* ignore kie */
            if (mb_bits(2,0) == 5) {
                printf("KIE! %o\n", ac);
#if 0
                if ((ac & 1)) {
                    tti_input_index = 0;
                    tti_input_count = 1;
                    tti_input[0] = '\r';
                    tti_set_event();
                }
#endif
                break;
            }

	    if (mb_bit(0)) {
                if (tti_input_index == 0 && !tti_flag)
                    tti_set_event();

                if (tti_flag)
		    io_skip = 1;
	    }

	    if (mb_bit(1)) {
                tti_set_event();
                tti_flag = 0;
	    }

	    if (mb_bit(2)) {
		if (tti_input_count > 0) {
		    ac = tti_data/* | 0200*/;
		    printf("xxx rx input %o (%d/%d)\n",
                           tti_data, tti_input_index, tti_input_count);
		}
	    }

            if (mb_bits(2,0) == 0) {
                tti_set_event();
                tti_flag = 0;
            }
	    break;

	case 004:
	    if (mb_bit(0)) {
		if (d_io) printf("tls; tt_countdown %d\n", tt_countdown);
		if (tto_flag)
		    io_skip = 1;
	    }
	    if (mb_bit(1)) {
                tto_flag = 0;
	    }
	    if (mb_bit(2)) {
		tt_data = ac;
		tt_countdown = 98/*100*/;
                tto_flag = 0;
	    }

            if (mb_bits(2,0) == 5) {
                printf("SPI! %o\n", ac);
            }
	    break;

        case 013: /* KW8/I */
	    switch (mb_bits(2, 0)) {
            default:
                printf("kw8/i %o?\n", mb);
                break;
            case 1:
                kw_int_en = 1;
                kw_clk_en = 1;
                break;
            case 2:
                kw_flag = 0;
                kw_clk_en = 0;
                kw_int_en = 0;
                printf("CCFF\n");
                break;
            case 3:
                if (d_io) printf("CSCF\n");
                if (kw_flag) {
                    io_skip = 1;
                }
                kw_flag = 0;
                break;
            case 6:
                printf("CCEC\n");
                kw_clk_en = 1;
                break;
            case 7:
                printf("CECI\n");
                kw_clk_en = 1;
                kw_int_en = 1;
                break;
            }
            break;

	case 060:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DCMA\n"); break;
            case 3: printf("DMAR\n"); break;
            case 5: printf("DMAW\n"); break;
            default: printf("RF60 %o\n", mb);
            }

	    if (mb_bit(0)) {
		rf_da = rf_da & ~07777;			/* clear DAR<8:19> */
		rf_done = 0;				/* clear done */
		rf_sta = rf_sta & ~RFS_ERR;		/* clear errors */
		rf_int_update();			/* update int req */
	    }
	    if (mb_bit(1) || mb_bit(2)) {
		rf_da |= ac & 07777;			/* DAR<8:19> |= AC */
		rf_func = mb_bits(2,0) & ~1;		/* save function */
		ac = 0;					/* clear AC */
		printf("xxx rf_go!\n");
		rf_go();
	    }
	    break;

	case 061:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DCIM\n"); break;
            case 5: printf("DIML\n"); break;
            case 6: printf("DIMA\n"); break;
            default: printf("RF61 %o\n", mb);
            }

	    switch (mb_bits(2, 0)) {
	    case 1:					/* DCIM */
		rf_sta = rf_sta & 07007;		/* clear STA<3:8> */
		rf_int_req = 0;
                if (d_io) printf("clear rf_int_req\n");
		break;

	    case 2:					/* DSAC */
//		  if ((rf_da & RF_WMASK) == GET_POS (rf_time))
		    io_skip = 1;
		ac = 0;
		break;

	    case 5:					/* DIML */
                if (d_io) printf("DIML\n");
		rf_sta = (rf_sta & 07007) | (ac & 0770);/* STA<3:8> <- AC */
		if (rf_sta & RFS_PIE) {			/* photocell int? */
                    if (d_io) printf("DIML PIE\n");
                    /* generate future int for photocel */
		} else {
		    /* cancel furture interrupt */
                    if (d_io) printf("DIML !PIE\n");
		}
		rf_int_update();			/* update int req */
		ac = 0;
		break;

	    case 6:					/* DIMA */
		ac = rf_sta;				/* AC <- STA<0:11> */
		break;
	    }
	    break;

	case 062:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DFSE\n"); break;
            case 2: printf("DFSC\n"); break;
            case 3: printf("DISK\n"); break;
            case 6: printf("DMAC\n"); break;
            default: printf("RF62 %o\n", mb);
            }

	    if (mb_bit(0)) {				/* DFSE */
		if (rf_sta & RFS_ERR)
		    io_skip = 1;
	    }
	    if (mb_bit(1)) {				/* DFSC */
		if (mb_bit(2))
		    ac = 0;
		else {
		    if (rf_done) 
			io_skip = 1;
                }
	    }
	    if (mb_bit(2)) {
		ac = rf_da & 07777;			/* DMAC */
	    }
	    break;

	case 064:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DCXA\n"); break;
            case 3: printf("DXAL\n"); break;
            case 5: printf("DXAC\n"); break;
            case 6: printf("DMMT\n"); break;
            default: printf("RF64 %o\n", mb);
            }

	    switch (mb_bits(2,0)) {
	    case 1:					/* DCXA */
		rf_da = rf_da & 07777;			/* clear DAR<0:7> */
printf("xxx rf_da %o\n", rf_da);
		break;

	    case 3:					/* DXAL */
		rf_da = rf_da & 07777;			/* clear DAR<0:7> */
	    case 2:					/* DXAL w/o clear */
		rf_da = rf_da | ((ac & 0377) << 12);	/* DAR<0:7> |= AC */
printf("xxx rf_da %o\n", rf_da);
		ac = 0;					/* clear AC */
		break;

	    case 5:					/* DXAC */
		ac = 0;					/* clear AC */
	    case 4:					/* DXAC w/o clear */
		ac = ac | ((rf_da >> 12) & 0377);	/* AC |= DAR<0:7> */
		break;

	    default:
//		  ac = (stop_inst << IOT_V_REASON) + AC;
		break;
	    }

	    if ((unsigned) rf_da >= rf_capac) {
		rf_sta = rf_sta | RFS_NXD;
	    } else
		rf_sta = rf_sta & ~RFS_NXD;
	    rf_int_update();
	    break;

	case 076:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DTRA\n"); break;
            case 2: printf("DCTA\n"); break;
            case 4: printf("DTXA\n"); break;
            default: printf("676x? %o\n", mb);
            }

//            tc_status_a = 00034;
//            tc_err_flag = 1;

	    if (mb_bit(0)) {
		ac |= (tc_status_a & 01777);
	    }
	    if (mb_bit(1)) {
		tc_status_a = 0;
	    }
	    if (mb_bit(2)) {
		tc_status_a |= ac;
		if ((ac & 02000) == 0)
		    ; /* clear error flags */
		if ((ac & 04000) == 0)
		    ; /* clear control flag */
	    }
	    break;

        case 077:
            if (d_io)
	    switch (mb_bits(2,0)) {
            case 1: printf("DTSF\n"); break;
            case 2: printf("DTRB\n"); break;
            default: printf("677x? %o\n", mb);
            }

//            tc_status_a = 00034;
//            tc_err_flag = 1;

	    switch (mb_bits(2,0)) {
            case 1:
                if (tc_err_flag || 1)
                    io_skip = 1;
                break;
            case 2:
		ac |= (tc_status_b & 01777);
                break;
            }
            break;
	}

#endif
    }

    tto_service();

    if (rf_int_req) {
	  io_interrupt = 1;
    }

//    io_cycle_count++;
//    if (io_cycle_count > 100) {
//	  io_cycle_count = 0;
//	  io_interrupt = 1;
//	  //printf("xxx io_interrupt\n");
//    }

    if (io_interrupt) {
	interrupt = 1;
	io_interrupt = 0;
    }

    if (pc_skip || io_skip)
	pc = (pc + 2) & 07777;
    else
	if (pc_incr)
	    pc = (pc + 1) & 07777;

    io_skip = 0;

F2:
    if (opr) {

	ma = (IF<<12) | fetch_pc;

	// group 3
	if (mb_bit(8) && mb_bit(0))
	    switch (mb_bits(6,4)) {
	    case 1: mq = ac; break; 
	    case 2: ac = ac | mq; break; 
//	case 5: tmq <= mq; break; 
	    case 4: ac = mq; break; 
	    case 5: ac = mq; break;
	    }
    }
	     
    if (iot)
	ma = (IF<<12) | fetch_pc;

    if (!(opr || iot)) {
	ma = (IF<<12) | ((mb_bit(7) ? (fetch_pc & 07600) : 0) | mb_bits(6,0));
	if (d_cycle) printf("ea if=%o df=%o, pc %o, ma=%05o (bits %o)\n", 
			    IF, DF, fetch_pc, ma, mb_bits(6,0));
    }

#define get_l_ac()  ( (l << 12) | ac )
#define set_l_ac(v)  do { unsigned int vv = (v); \
			  l = (vv >> 12) & 1; ac = vv & 07777; } while(0);

F3:
    if (opr) {

	// group 1
	if (!mb_bit(8)) {
	    if (mb_bit(0))			// IAC
		set_l_ac( get_l_ac() + 1 );

	    switch (mb_bits(3,1)) {
	    case 1:		// BSW
		set_l_ac( ((get_l_ac() & 077) << 6) |
			  ((get_l_ac() & 07700) >> 6) );
		break;

	    case 2:		// RAL
		//printf("ral\n");
		set_l_ac( ((get_l_ac() & 010000) >> 12) |
			  (ac << 1) );
		break;

	    case 3:		// RTL
		//printf("rtl\n");
		set_l_ac( ((get_l_ac() & 010000) ? 2 : 0) |
			  ((get_l_ac() & 004000) ? 1 : 0) |
			  (ac << 2) );
		break;

	    case 4:		// RAR
		//printf("rar\n");
		set_l_ac( ((ac & 1) << 12) |
			  (get_l_ac() >> 1) );
		break;

	    case 5:		// RTR
		//printf("rtr\n");
		set_l_ac( ((ac & 1) ? 004000 : 0) |
			  ((ac & 2) ? 010000 : 0) |
			  (get_l_ac() >> 2) );
		break;
	    }
	}

	if (!UF) {
	    // group 2
	    if (mb_bit(8) & !mb_bit(0)) {
		if (mb_bit(2))
		    ac = ac | switches;
		if (mb_bit(1)) {
		    printf("halt!\n");
		    run = 0;
		}
	    }
	}

	if (UF) {
	    // group 2 - user mode (halt & osr)
	    if (mb_bit(8) & !mb_bit(0)) {
		if (mb_bit(2))
		    UI = 1;
		if (mb_bit(1))
		    UI = 1;
	    }
	}

	// group 3
	if (mb_bit(8) && mb_bit(0)) {
	    if (mb_bits(7,4) == 016) mq = 0;
        }
		 
	ir = 0;
	mb = 0;
	goto done;
    }

    if (iot) {
	ir = 0;
	mb = 0;
	goto done;
    }

    if (!(opr || iot)) {
		
	if (!mb_bit(8) & jmp) {
	    pc = ma & 07777;
	    ir = 0;
	    mb = 0;
	    goto done;
	}
		
	if (mb_bit(8)) {
	    mb = 0;
	    goto D0;
	}

	if (!mb_bit(8) & !jmp) {
	    mb = 0;
	    goto E0;
	}
    }

    // DEFER

D0:
    memory_bus = mem[ma];
    if (d_cycle) printf("D0: ");
    if (d_mem) printf("mem read [%o] -> %o\n", ma, memory_bus);
    mb = memory_bus;

    ram_we = 0;
    // auto increment regs

    if (((ma >> 3) & 0377) == 1) {
	mb++;
	ram_we = 1;
    }

    if (ram_we) {
	if (d_cycle) printf("D0: ");
	if (d_mem || (ma == 0 && d_trace))
            printf("mem write [%o] <- %o\n", ma, mb);
	mem[ma] = mb & 07777;
    }
    ram_we = 0;

    if (jms) {
        ma = (IF << 12) | mb;

        if (IB_pending)
            ma = (IB << 12) | mb;
    } else
        ma = (DF << 12) | mb;
        

    if (jmp) {
	pc = mb & 07777;
	ir = 0;
	mb = 0;
	goto done;
    }

    if (!jmp) {
	mb = 0;
    }

    // EXECUTE
E0:
    mb = mem[ma];
    if (d_cycle) printf("E0: ");
    if (d_mem /*|| (ma == 0 && d_trace)*/)
        printf("mem read [%o] -> %o\n", ma, mb);

    if (isz) {
	if (mb == 07777) pc++;
	mb++;
    }

    if (dca)
	mb = ac;

    if (jms)
	mb = pc;

    if (isz || dca || jms) {
	ram_we = 1;
    }

    if (ram_we) {
	if (d_cycle) printf("E0: ");
	if (d_mem /*|| (ma == 0 && d_trace)*/)
            printf("mem write [%o] <- %o\n", ma, mb);
	mem[ma] = mb & 07777;
    }
    ram_we = 0;

    // note timing here; ma above is different

    if (!jms)
	ma = (IF << 12) | pc;

    if (jms)
	ma = ((ma & 070000) << 12) | ((ma & 07777) + 1);

    if (and)
	ac = ac & mb;

    if (tad) {
	set_l_ac( get_l_ac() + mb );
    }

    if (dca)
	ac = 0;

    if (jms) {
	if (d_fetch) printf("jms - ma %o\n", ma & 07777);
	pc = ma & 07777;
    }

    ir = 0;

done:
    /* defered loading of IF from IB until after next jmp/jms */
    if ((jmp || jms) && IB_pending) {
	//printf("loading IF %o\n", IB);
	IF = IB;
	IB_pending = 0;
	interrupt_inhibit = 0;
    }

    /* defer setting user flag until after next jmp/jms */
    if ((jmp || jms) && UB_pending) {
        UF = UB;
        UB_pending = 0;
    }

#if 0
    /* defer setting of interrupt enable */
    if ((jmp || jms) && interrupt_enable_req) {
        interrupt_enable_req = 0;
        interrupt_enable = 1;
    }
#endif

#if 0
    /* defer setting of interrupt enable */
    if (interrupt_enable_req == 1) {
        interrupt_enable_req = 2;
    } else
        if (interrupt_enable_req == 2) {
            interrupt_enable_req = 0;
            interrupt_enable = 1;
        }
#endif

    if (!UB_pending && !IB_pending) {
        switch (interrupt_inhibit) {
        case 1:
            interrupt_inhibit = 2;
            break;
        case 2:
            interrupt_inhibit = 0;
            break;
        }
    }
}

void
loop(void)
{
    run = 1;

    IF = (pc & 070000) >> 12;
    DF = IF;
    pc &= 07777;

    while (1) {
	if (!run)
	    break;
	execute();
    }
}

void sigint_handler(int arg)
{
    printf("SIGINT @ %lu cycles\n", cycles);
    if (d_trace)
        exit(1);

    d_trace++;
}

main()
{
    if (1) {
//	d_load = 1;
//	d_fetch = 1;
//	d_decode = 1;
//	d_cycle = 1;
	d_trace = 1;
//	d_mem = 1;
//	d_dma = 1;
//	d_io = 1;
    }

    if (1) {
	loadbin("../tss8/tss8_init.bin");
	loaddisk("../tss8/tss8_rf.dsk");
	pc = 024200;
        IB = 2;
    }

    if (0) {
	loadbin("../images/focal569.bin");
	pc = 0200;
    }

    signal(SIGINT, sigint_handler);

    loop();
}


/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
