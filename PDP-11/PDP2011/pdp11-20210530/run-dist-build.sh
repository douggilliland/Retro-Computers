#!/bin/bash

QPATH=/opt/intelFPGA_lite/20.1/quartus/bin/
export QPATH
WDIR=`pwd`
export WDIR

cd $WDIR/cons-c1k-rl
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/cons-c1k-rk
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/cons-c1k-rh
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/cons-c1k-rhxu
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/cons-de0n-basic
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/minc-de0n
$QPATH/quartus_sh --flow compile top
$QPATH/quartus_cpf --convert top.cof

cd $WDIR/minc-de10l
$QPATH/quartus_sh --flow compile top

