#!/bin/bash
# $1= 7.8.10_4.99.1005
# script creating the mizar html from a mizar distro
# current dir should contain the Makefile.html for doing this,
# and all prerequisities required by the Makefile have to be present 

# This now assumes to be called from the directory containing Makefile.html

wget ftp://mizar.uwb.edu.pl/pub/system/i386-linux/mizar-$1-i386-linux.tar
mkdir $1
tar xf mizar-$1-i386-linux.tar -C$1 
cd $1
tar xzf mizshare.tar.gz 
tar xzf mizdoc.tar.gz 
mkdir bin
tar xzf mizbin.tar.gz -Cbin
mkdir html 
cp ../Makefile.html Makefile
cp -a mml miztmp
cp Makefile  miztmp
export MIZFILES=`pwd`
cd miztmp
make -j8 allacc | tee 00acc.log
make -j8 allhdr | tee 00hdr.log
make -j16 allxml | tee 00xml.log
make -j16 allxml1 | tee 00xml1.log
make -j16 allhtmla1 | tee 00htmla1.log
make hidden.acc
make hidden.hdr
make hidden.xml
make hidden.xml1
make hidden.htmla1
make tarski_0.acc
make tarski_0.hdr
make tarski_0.xml
make tarski_0.xml1
make tarski_0.htmla1
make tarski_a.acc
make tarski_a.hdr
make tarski_a.xml
make tarski_a.xml1
make tarski_a.htmla1
make tarski.acc
make tarski.hdr
make tarski.xml
make tarski.xml1
make tarski.htmla1
for j in `ls *.htmla1| sed -e 's/.htmla1//'`; do mv $j.htmla1 ../html/$j.html; done
cd ..
mv miztmp/refs html
tar czf html_abstr.$1.noproofs.tar.gz html
mv miztmp/proofs html
tar czf html_abstr.$1.tar.gz html
