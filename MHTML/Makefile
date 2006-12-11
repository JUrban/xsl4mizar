## $Revision: 1.1 $

JAVA = java
XSLTXT = /home/urban/xsltxt/xsltxt.jar
CAT = cat

MIZDEPS = mhtml_params mhtml_keys mhtml_print_simple mhtml_utils mhtml_frmtrm mhtml_print_complex mhtml_reasoning mhtml_block_top
MIZXSLDEPS = $(addsuffix .xsl, $(MIZDEPS))
MIZXSLTXTDEPS = $(addsuffix .xsltxt, $(MIZDEPS))

mizmainxsl: $(MIZXSLDEPS) mhtml_main.xsl

miz.xsltxt: $(MIZXSLDEPS) mhtml_main.xsl
	echo "// This file is now automatically produced from the files in the MHTML directory." > miz.xsltxt
	echo "// Its only reason is to have just one big .xsl file in the Mizar distro." >> miz.xsltxt
	echo "// So any changes should be done to the MHTML files, running 'make miz.xsl' afterwards." >> miz.xsltxt
	echo "// The main stylesheet mhtml_main.xsl can be used instead miz.xsl," >> miz.xsltxt
	echo "// provided the included .xsl files are available in the same directory" >> miz.xsltxt
	perl -e 'while(<>) {if(/#INCLUDE HERE/) { exit; } else{ print $$_ } }' mhtml_main.xsltxt >> miz.xsltxt
	for i in $(MIZXSLTXTDEPS); do perl -e 'while(<>) {if($$s==1) {print $$_} elsif(/Revision/) {$$s=1}}' $$i >> miz.xsltxt; done
	perl -e 'while(<>) {if($$s==1) {print $$_} elsif(/INCLUDE HERE/) {$$s=1}}' mhtml_main.xsltxt >> miz.xsltxt


%.xsl: %.xsltxt
	$(JAVA) -jar $(XSLTXT) toXSL $*.xsltxt | sed -e 's/<!\-\- *\(<\/*xsl:document.*\) *\-\->/\1/g' > $*.xsl


## Unrelated stuff, ignore the rest of this file

# MFILES  = $(MIZFILES)
# MMLLAR  = $(MFILES)/mml.lar
# MMLLAR100  = $(MFILES)/mml.lar.100
# MIZ100     = $(shell cat $(MMLLAR100))
# STANDARDMIZ     = $(shell cat $(MMLLAR))
# SHMIZ = $(MMLLAR)
# SHMIZ = $(shell shuffle < $(MMLLAR))

# XSLTPROC = xsltproc
# XML2HTML = /home/urban/xsltxt/miz.xsl
# ADDABS = /home/urban/xsltxt/addabsrefs.xsl
# ACCOM = $(MFILES)/bin/accom
# VERIFIER = $(MFILES)/bin/verifier

# %.acc: %.miz
# 	$(ACCOM) $* > $*.acc

# %.xml: %.acc
# 	$(VERIFIER) -q -a  $*

# %.xml1: %.xml
# 	$(XSLTPROC) $(ADDABS)  $*.xml > $*.xml1

# %.html: %.xml1
# 	$(XSLTPROC) --param proof_links \'1\' $(XML2HTML)  $*.xml1 > $*.html

# %.htmla1: %.xml1
# 	$(XSLTPROC) --param ajax_proofs \'1\' --param colored \'1\' --param proof_links \'1\' $(XML2HTML)  $*.xml1 > $*.htmla1

# %.htmla2: %.xml1
# 	$(XSLTPROC) --param ajax_proofs \'2\' --param proof_links \'1\' $(XML2HTML)  $*.xml1 > $*.htmla2


# # all: xboole.html
# allhtml: $(addsuffix .html, $(SHMIZ))
# allhtmla1: $(addsuffix .htmla1, $(SHMIZ))
# allhtmla2: $(addsuffix .htmla2, $(SHMIZ))
# html100: $(addsuffix .html, $(MIZ100))
# allacc: $(addsuffix .acc, $(STANDARDMIZ))
# allxml: $(addsuffix .xml, $(STANDARDMIZ))
# allxml1: $(addsuffix .xml1, $(SHMIZ))

