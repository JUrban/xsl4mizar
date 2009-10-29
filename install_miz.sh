#!/bin/bash
# $1= 7.8.10_4.99.1005
# script fetching and installing new mizar version into the current directory
wget ftp://mizar.uwb.edu.pl/pub/system/i386-linux/mizar-$1-i386-linux.tar
mkdir $1
tar xf mizar-$1-i386-linux.tar -C$1 
cd $1
tar xzf mizshare.tar.gz 
tar xzf mizdoc.tar.gz 
mkdir bin
tar xzf mizbin.tar.gz -Cbin
mkdir html 
cp ../Makefile .
cp -a mml miztmp
cp Makefile  miztmp
export MIZFILES=`pwd`
cd miztmp
