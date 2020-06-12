OPTS=-DPDP2011 -DFPSIM -DUCB_METER -DINET
OPTS=-DPDP2011 -DFPSIM -DUCB_METER -DINET
#
# Copyright (c) 1988 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms are permitted
# provided that this notice is preserved and that due credit is given
# to the University of California at Berkeley. The name of the University
# may not be used to endorse or promote products derived from this
# software without specific prior written permission. This software
# is provided ``as is'' without express or implied warranty.
#
#	2.10	(2.11BSD GTE) 1997/11/28
#
#########################################################
# Networking, separate I/D kernel			#
#########################################################

H=	../h
I=	/usr/include
M=	../machine
N1=	../net
N2=	../netimp
N3=	../netinet
N4=	../netns
N6=	../pdpif
S=	../sys
U=	../pdpuba
MB=	../pdpmba

DEFS=	-DKERNEL ${OPTS} -I. -I${H}
CFLAGS=	-O ${DEFS}

CPP=	/lib/cpp -P ${DEFS}
AS=	/bin/as -V
ED=	/bin/ed
SED=	/bin/sed

SUB=	sys pdp pdpuba pdpmba net pdpnet

# GENERAL RULES:
# scb.o MUST be loaded first, param.o MUST be loaded last,
# boot.o must be loaded in the base well above 0 data.
# enable34.o must be in the base segment for overlaid kernels.
# Don't forget the "-i" flag for split I/D, use "-n" otherwise.
#
# CONF	Non-network assembly binaries.  scb.o must be first!
#		boot.o should be close to the end.
# NCONF	Network (network space) assembly binaries.  net_scb.o
#		doesn't have to be first.

CONF=	scb.o \
	mch_backup.o mch_click.o mch_copy.o mch_csv.o \
	mch_dump.o mch_dzpdma.o mch_KScall.o mch_profile.o \
	mch_start.o mch_trap.o mch_vars.o mch_xxx.o conf.o ioconf.o boot.o

NCONF=	net_copy.o net_csv.o \
	net_mbuf.o net_scb.o net_SKcall.o net_trap.o net_xxx.o

BASE=	br.o cons.o dh.o dhu.o dhv.o dr.o dz.o hk.o ht.o init_sysent.o \
	kern_clock.o kern_descrip.o kern_mman.o kern_proc.o kern_prot.o \
	kern_prot2.o kern_subr.o kern_synch.o lp.o machdep.o ra.o ram.o \
	rk.o rl.o rx.o si.o subr_rmap.o sys_inode.o sys_kern.o \
	tm.o ts.o tty.o tty_conf.o tty_subr.o tty_tb.o ufs_alloc.o \
	ufs_bio.o ufs_fio.o ufs_inode.o ufs_namei.o \
	vm_proc.o vm_sched.o vm_swap.o xp.o quota_subr.o
OV1=	sys_generic.o ufs_syscalls.o vfs_vnops.o
OV2=	kern_acct.o kern_exec.o kern_exit.o kern_fork.o kern_resource.o
OV3=	kern_time.o sys_process.o ufs_mount.o ufs_subr.o uipc_syscalls.o
OV4=	dkbad.o kern_sig.o mem.o subr_xxx.o trap.o tty_pty.o tty_tty.o
OV5=	quota_kern.o quota_ufs.o quota_sys.o ufs_bmap.o	\
	sys_pipe.o ingreslock.o mch_fpsim.o
# OV6 gets the (hopefully) never used routines
OV6=	clock.o dn.o init_main.o kern_pdp.o machdep2.o subr_prf.o syscalls.o \
	subr_log.o toy.o vm_swp.o
OV7=	ufs_disksubr.o ufs_dsort.o ufs_syscalls2.o kern_sig2.o
OV8=	kern_sysctl.o kern_xxx.o vm_text.o
OV9=	tmscp.o tmscpdump.o

KERNOBJ=${CONF} ${BASE} ${OV1} ${OV2} ${OV3} ${OV4} ${OV5} \
	${OV6} ${OV7} ${OV8} ${OV9} ${OV10} ${OV11} ${OV12} \
	${OV13} ${OV14} ${OV15} \
	enable34.o vers.o param.o

# param.o must be last!  enable34.o must be in base.
LD_KOBJ=${CONF} ${BASE} \
	-Z ${OV1} -Z ${OV2} -Z ${OV3} -Z ${OV4} -Z ${OV5} -Z ${OV6} \
	-Z ${OV7} -Z ${OV8} -Z ${OV9} -Z ${OV10} -Z ${OV11} -Z ${OV12} \
	-Z ${OV13} -Z ${OV14} -Z ${OV15} -Y \
	enable34.o vers.o -lkern param.o

NETOBJ=	${NCONF} af.o idp_usrreq.o if.o if_acc.o if_css.o if_de.o \
	if_dmc.o if_ec.o if_en.o if_ether.o if_il.o if_imp.o if_imphost.o \
	if_loop.o if_qe.o if_qt.o if_sl.o if_sri.o if_uba.o if_vv.o in.o \
	in_cksum.o in_pcb.o in_proto.o ip_icmp.o ip_input.o ip_output.o \
	ns.o ns_error.o ns_input.o ns_ip.o ns_output.o ns_pcb.o \
	ns_proto.o raw_cb.o raw_imp.o raw_ip.o \
	raw_usrreq.o route.o spp_debug.o spp_usrreq.o sys_socket.o \
	sys_net.o tcp_debug.o tcp_input.o tcp_output.o tcp_subr.o \
	tcp_timer.o tcp_usrreq.o udp_usrreq.o uipc_domain.o uipc_mbuf.o \
	uipc_proto.o uipc_socket.o uipc_socket2.o uipc_usrreq.o

all: unix netnix

# d.unix.o must be last object file in the dependency list!
unix: ${SUB} ${KERNOBJ} d.unix.o checksys
	ld -X -i -o unix ${LD_KOBJ} d.unix.o
	size unix
	@echo Compacting symbol table
	-symcompact unix
	@echo Compacting strings table
	-strcompact unix
	@echo rearranging symbols
	-symorder ../pdp/symbols.sort unix
	./checksys unix

# d.netnix.o must be the last object file in the dependency list!
netnix: d.netnix.o
	-ld -X -i -o netnix ${NETOBJ} -lkern d.netnix.o
	size netnix
	@echo Compacting symbol table
	-symcompact netnix
	@echo Compacting strings table - this will take a few minutes
	-strcompact netnix
	@echo rearranging symbols
	-symorder ../pdp/symbols.sort netnix

# Resolve all references between the kernel and the net.  Always regenerate!!!
# This was a constant source of problems during development.  Should really
# include ${NETOBJ} and ${KERNOBJ} on dependency line, but the pdp make doesn't
# have enough table space.
d.unix.o d.netnix.o: netbind FRC
	ld -q -r -d -X -i -o unix.o ${LD_KOBJ}
	ld -q -r -d -X -i -o netnix.o ${NETOBJ} -lkern
	./netbind unix.o netnix.o
	rm unix.o netnix.o
	${AS} - -o d.unix.o d.unix.s
	${AS} - -o d.netnix.o d.netnix.s

vers.o: FRC
	sh ../conf/newvers.sh
	${CC} -c vers.c

boot.o: boot.s
	${CPP} boot.s | ${AS} -o boot.o

param.o:
	${CC} -S ${CFLAGS} param.c
	${ED} - param.s < ../conf/:comm-to-bss
	${AS} - -o param.o param.s
	rm -f param.s

ioconf.o: ioconf.c
	${CC} -c ${CFLAGS} ioconf.c

checksys: ../conf/checksys.c
	${CC} ${CFLAGS} -o $@ ../conf/checksys.c

netbind: ../conf/netbind.c
	${CC} ${CFLAGS} -o $@ ../conf/netbind.c

sys pdp pdpuba pdpmba:
	make -f Make.$@ I=${I} H=${H} M=${M} AS="${AS}" CPP="${CPP}" \
	    CFLAGS="${CFLAGS}" SED="${SED}"

net pdpnet:
	make -f Make.$@ I=${I} H=${H} M=${M} AS="${AS}" \
	    CPP="${CPP} -DSUPERVISOR" CFLAGS="${CFLAGS} -DSUPERVISOR" \
	    SED="${SED}" ED="${ED}"

clean:
	rm -f unix core mklog *.o assym.h genassym checksys
	rm -f netnix netbind d.unix.s d.netnix.s

install:
	install -c -o root -g kmem -m 744 unix ${DESTDIR}/unix
	install -c -o root -g kmem -m 744 netnix ${DESTDIR}/netnix

depend: FRC
	for i in ${SUB}; do \
		make -f Make.$$i CFLAGS="${CFLAGS}" depend; done
	mkdep ${CFLAGS} param.c ioconf.c ../conf/checksys.c ../conf/netbind.c

TAGSFILE= ${S}/tags
TLIST=	${H} ${I} ${N1} ${N2} ${N3} ${N4} ${N5} ${N6} ${M} ${S} ${U} ${MB} ${SS}

tags: FRC
	rm -f ${TAGSFILE}
	for i in ${TLIST}; do \
		(cd ${S}; /usr/ucb/ctags -a -t $$i/*.[ch]); done
	/usr/bin/egrep "^ASENTRY|^ENTRY" ${M}/*.s | \
	    /bin/sed 's;\([^:]*\):\([^(]*\)(\([^)]*\));\3	\1	/^\2(\3)$$/;' \
	    >> ${TAGSFILE}
	/usr/bin/sort -o ${TAGSFILE} ${TAGSFILE}

FRC:

# DO NOT DELETE THIS LINE -- mkdep uses it.
# DO NOT PUT ANYTHING AFTER THIS LINE, IT WILL GO AWAY.
