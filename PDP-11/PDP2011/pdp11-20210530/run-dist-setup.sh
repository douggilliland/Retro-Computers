#!/bin/bash

QPATH=/opt/intelFPGA_lite/20.1/quartus/bin/
export QPATH
WDIR=`pwd`
export WDIR

SRCDIR=$WDIR/cons-c1k-basic

rm -rf $WDIR/cons-c1k-rl
rm -rf $WDIR/cons-c1k-rk
rm -rf $WDIR/cons-c1k-rh
rm -rf $WDIR/cons-c1k-rhxu

cd $WDIR
mkdir $WDIR/cons-c1k-rl
cd $WDIR/cons-c1k-rl
cp $SRCDIR/top.qsf .
cp $SRCDIR/top.qpf .
cp $SRCDIR/top.vhd .
cp $SRCDIR/pll* .
cp $SRCDIR/top.sdc .
cp $SRCDIR/top.cof .
sed -E -i 's/r._sdcard_(.*) => /rl_sdcard_\1 => /' top.vhd
sed -i 's/have_r. => 1/have_rl => 1/' top.vhd
sed -i 's/have_xu => ./have_xu => 0/' top.vhd

cd $WDIR
mkdir $WDIR/cons-c1k-rk
cd $WDIR/cons-c1k-rk
cp $SRCDIR/top.qsf .
cp $SRCDIR/top.qpf .
cp $SRCDIR/top.vhd .
cp $SRCDIR/pll* .
cp $SRCDIR/top.sdc .
cp $SRCDIR/top.cof .
sed -E -i 's/r._sdcard_(.*) => /rk_sdcard_\1 => /' top.vhd
sed -i 's/have_r. => 1/have_rk => 1/' top.vhd
sed -i 's/have_xu => ./have_xu => 0/' top.vhd

cd $WDIR
mkdir $WDIR/cons-c1k-rh
cd $WDIR/cons-c1k-rh
cp $SRCDIR/top.qsf .
cp $SRCDIR/top.qpf .
cp $SRCDIR/top.vhd .
cp $SRCDIR/pll* .
cp $SRCDIR/top.sdc .
cp $SRCDIR/top.cof .
sed -E -i 's/r._sdcard_(.*) => /rh_sdcard_\1 => /' top.vhd
sed -i 's/have_r. => 1/have_rh => 1/' top.vhd
sed -i 's/have_xu => ./have_xu => 0/' top.vhd

cd $WDIR
mkdir $WDIR/cons-c1k-rhxu
cd $WDIR/cons-c1k-rhxu
cp $SRCDIR/top.qsf .
cp $SRCDIR/top.qpf .
cp $SRCDIR/top.vhd .
cp $SRCDIR/pll* .
cp $SRCDIR/top.sdc .
cp $SRCDIR/top.cof .
sed -E -i 's/rh_sdcard_(.*) => /rh_sdcard_\1 => /' top.vhd
sed -i 's/have_r. => 1/have_rh => 1/' top.vhd
sed -i 's/have_xu => ./have_xu => 1/' top.vhd
sed -i 's/cons-c1k-basic/cons-c1k-rhxu/' top.cof
