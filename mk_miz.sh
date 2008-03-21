#!/bin/bash
# $1= 7.8.10_4.99.1005
# script creating the mizar html from a mizar distro
# current dir should contain the Makefile for doing this,
# and all prerequisities required by the Makefile have to be present 
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
make -j8 allacc | tee 00acc.log
make -j8 allxml | tee 00xml.log
make -j8 allxml1 | tee 00xml1.log
make -j8 allhtmla1 | tee 00htmla1.log
make hidden.acc
make hidden.xml
make hidden.xml1
make hidden.htmla1
make tarski.acc
make tarski.xml
make tarski.xml1
make tarski.htmla1
for j in `ls *.htmla1| sed -e 's/.htmla1//'`; do mv $j.htmla1 ../html/$j.html; done
cd ..
tar czf html_abstr.$i.noproofs.tar.gz html
mv miztmp/proofs html
tar czf html_abstr.$i.tar.gz html
