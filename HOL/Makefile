## $Revision: 1.3 $

JAVA = java
XSLTXT = /home/urban/xsltxt/xsltxt.jar
CAT = cat

MIZDEPS = mhtml_params mhtml_keys mhtml_print_simple mhtml_utils mhtml_frmtrm mhtml_print_complex mhtml_reasoning mhtml_block_top
MIZXSLDEPS = $(addprefix ../MHTML/, $(addsuffix .xsl, $(MIZDEPS)))
MIZXSLTXTDEPS = $(addprefix ../MHTML/, $(addsuffix .xsltxt, $(MIZDEPS)))

hollm3mainxsl: $(MIZXSLDEPS) hollm3_main.xsl

hollm3.xsltxt: $(MIZXSLDEPS) hollm3_main.xsl
	echo "// This file is now automatically produced from the files in the MHTML directory." > hollm3.xsltxt
	echo "// Its only reason is to have just one big .xsl file in the Mizar distro." >> hollm3.xsltxt
	echo "// So any changes should be done to the MHTML files, running 'make hollm3.xsl' afterwards." >> hollm3.xsltxt
	echo "// The main stylesheet mhtml_main.xsl can be used instead hollm3.xsl," >> hollm3.xsltxt
	echo "// provided the included .xsl files are available in the same directory" >> hollm3.xsltxt
	perl -e 'while(<>) {if(/#INCLUDE HERE/) { exit; } else{ print $$_ } }' hollm3_main.xsltxt >> hollm3.xsltxt
	for i in $(MIZXSLTXTDEPS); do perl -e 'while(<>) {if($$s==1) {print $$_} elsif(/Revision/) {$$s=1}}' $$i >> hollm3.xsltxt; done
	perl -e 'while(<>) {if($$s==1) {print $$_} elsif(/INCLUDE HERE/) {$$s=1}}' hollm3_main.xsltxt >> hollm3.xsltxt


%.xsl: %.xsltxt
	$(JAVA) -jar $(XSLTXT) toXSL $*.xsltxt | sed -e 's/<!\-\- *\(<\/*xsl:document.*\) *\-\->/\1/g' > $*.xsl

TAGS: $(MIZXSLTXTDEPS)
	etags   --language=none  --regex='/^tpl *\[? *\([^]({\n]+\) *\]?.*/\1/' $(MIZXSLTXTDEPS)

clean: 
	rm -rf hollm3_main.xsl hollm3.xsltxt hollm3.xsl

