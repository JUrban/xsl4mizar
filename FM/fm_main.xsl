<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- the import directive is useful because anything -->
  <!-- imported can be later overrriden - we'll use it for -->
  <!-- the pretty-printing funcs -->
  <xsl:import href="../MHTML/mhtml_block_top.xsl"/>
  <!-- ##INCLUDE HERE -->
  <xsl:output method="html"/>
  <!-- $Revision: 1.4 $ -->
  <!--  -->
  <!-- File: fm_main.xsltxt - TeX-ization of Mizar XML, main file -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- XML terms, formulas and types to FM format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar ../xsltxt.jar toXSL fm_main.xsltxt >fm_main.xsl -->
  <!-- include fm_print_complex.xsl; -->
  <!-- include mhtml_block_top.xsl;  // ##INCLUDE HERE -->
  <!-- the FM specific code: -->
  <!-- XML file containing FM formats -->
  <xsl:param name="fmformats">
    <xsl:text>file:///home/urban/gr/xsl4mizar/FM/fm_formats.fmx</xsl:text>
  </xsl:param>
  <!-- .bxx file with the bibtex info in xml (see article_bib.rnc) -->
  <xsl:param name="bibtex">
    <xsl:value-of select="concat($anamelc, &apos;.bbx&apos;)"/>
  </xsl:param>
  <!-- lookup of the FMFormat based on the symbol, kind,argnr and leftargnr - -->
  <!-- TODO: add the rightsymbol too (otherwise probably not unique) -->
  <xsl:key name="FM" match="FMFormatMap" use="concat( @symbol, &quot;::&quot;, @kind, &apos;:&apos;, @argnr, &apos;:&apos;, @leftargnr)"/>
  <!-- symbols, overloaded for tex presentation -->
  <xsl:param name="for_s">
    <xsl:text> \forall </xsl:text>
  </xsl:param>
  <xsl:param name="ex_s">
    <xsl:text> \exists </xsl:text>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:text> \lnot </xsl:text>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:text> \: non \: </xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text> \&amp; </xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text> \Rightarrow </xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text> \Leftrightarrow </xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text> \lor </xsl:text>
  </xsl:param>
  <xsl:param name="holds_s">
    <xsl:text> \: holds \: </xsl:text>
  </xsl:param>
  <xsl:param name="being_s">
    <xsl:text> : </xsl:text>
  </xsl:param>
  <xsl:param name="be_s">
    <xsl:text> be </xsl:text>
  </xsl:param>
  <xsl:param name="st_s">
    <xsl:text> \: st \: </xsl:text>
  </xsl:param>
  <xsl:param name="is_s">
    <xsl:text> \: is \: </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_start">
    <xsl:text> { </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_end">
    <xsl:text> } </xsl:text>
  </xsl:param>
  <xsl:param name="of_sel_s">
    <xsl:text> \: of \: </xsl:text>
  </xsl:param>
  <xsl:param name="of_typ_s">
    <xsl:text> \: of \: </xsl:text>
  </xsl:param>
  <xsl:param name="the_sel_s">
    <xsl:text> \: the \: </xsl:text>
  </xsl:param>
  <xsl:param name="choice_s">
    <xsl:text> \: the \: </xsl:text>
  </xsl:param>

  <!-- Get symbol of kind #sk and number #nr . -->
  <!-- If $sk is K and $r=1, get the rightbracketsymbol with #rsnr instead. -->
  <xsl:template name="get_vocsymbol">
    <xsl:param name="sk"/>
    <xsl:param name="snr"/>
    <xsl:param name="r"/>
    <xsl:param name="rsnr"/>
    <xsl:variable name="dkey" select="concat(&apos;D_&apos;,$sk)"/>
    <xsl:for-each select="document($vocs,/)">
      <xsl:choose>
        <xsl:when test="key($dkey,$snr)">
          <xsl:for-each select="key($dkey,$snr)">
            <xsl:choose>
              <xsl:when test="($sk=&apos;K&apos;) and ($r=&apos;1&apos;)">
                <xsl:for-each select="key(&apos;D_L&apos;,$rsnr)">
                  <xsl:value-of select="@name"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <!-- try the built-in symbols -->
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;M&apos;)">
              <xsl:text>set</xsl:text>
            </xsl:when>
            <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;R&apos;)">
              <xsl:text>=</xsl:text>
            </xsl:when>
            <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;K&apos;)">
              <xsl:choose>
                <xsl:when test="$r=&apos;1&apos;">
                  <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="($snr=&apos;2&apos;) and ($sk=&apos;K&apos;)">
              <xsl:choose>
                <xsl:when test="$r=&apos;1&apos;">
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>{</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(&quot;FAILEDVOC:&quot;,$k,$nr)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- given an aticle-relative format number #fnr, return -->
  <!-- the lookup key for the corresponding FMFormatMap -->
  <xsl:template name="get_fmformat_key">
    <xsl:param name="fnr"/>
    <xsl:for-each select="document($formats,/)">
      <xsl:for-each select="key(&apos;F&apos;,$fnr)">
        <xsl:variable name="snr" select="@symbolnr"/>
        <xsl:variable name="sk1" select="@kind"/>
        <xsl:variable name="sk">
          <xsl:choose>
            <xsl:when test="$sk1=&quot;L&quot;">
              <xsl:text>G</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sk1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rsnr">
          <xsl:if test="$sk=&apos;K&apos;">
            <xsl:value-of select="@rightsymbolnr"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="sym">
          <xsl:call-template name="get_vocsymbol">
            <xsl:with-param name="sk" select="$sk"/>
            <xsl:with-param name="snr" select="$snr"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat($sym, &apos;::&apos;, $sk1, &apos;:&apos;, @argnr, &apos;:&apos;, @leftargnr)"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- rudimentary pp2 version for TeX (see mhtml_print_complex for the pretty -->
  <!-- printing equivalent html stuff, which this overrides) -->
  <!-- currently just prints the strings and arguments given -->
  <!-- by their order in FMTranslPattern corresponding to format #fnr -->
  <!-- TODO: how is texmode used? what are the rules of its application to arguments? -->
  <xsl:template name="pp2">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="i"/>
    <xsl:param name="vis"/>
    <xsl:param name="la"/>
    <xsl:param name="loci"/>
    <xsl:param name="args"/>
    <xsl:param name="np"/>
    <xsl:param name="rsym"/>
    <xsl:param name="parenth"/>
    <xsl:param name="fnr"/>
    <xsl:param name="pid"/>
    <xsl:variable name="fmkey">
      <xsl:call-template name="get_fmformat_key">
        <xsl:with-param name="fnr" select="$fnr"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($fmkey,&apos;FAILEDVOC&apos;)">
        <xsl:value-of select="$fmkey"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- ":#"; $fmkey; ":#"; -->
        <xsl:for-each select="document($fmformats,/)">
          <xsl:for-each select="key(&apos;FM&apos;,$fmkey)">
            <xsl:for-each select="FMTranslPattern/*">
              <xsl:choose>
                <xsl:when test="name()=&quot;Str&quot;">
                  <xsl:value-of select="@s"/>
                </xsl:when>
                <xsl:otherwise>
                  <!-- TODO: do the numbering of arguments in FMTranslPattern refer -->
                  <!-- to only visible arguments, or all?? -taking visible now: -->
                  <xsl:variable name="x" select="@x"/>
                  <xsl:variable name="y" select="$vis[position() = $x]/@x"/>
                  <xsl:apply-templates select="$args[position() = $y]">
                    <xsl:with-param name="p" select="$np"/>
                    <xsl:with-param name="i" select="$i"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Adjective">
    <xsl:param name="i"/>
    <xsl:variable name="pi">
      <xsl:call-template name="patt_info">
        <xsl:with-param name="k">
          <xsl:text>V</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="pid" select="@pid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fnr">
      <xsl:call-template name="car">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="anto">
      <xsl:call-template name="cadr">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="plink">
      <xsl:call-template name="third">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pid">
      <xsl:choose>
        <xsl:when test="$plink=&quot;1&quot;">
          <xsl:value-of select="@pid"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="neg">
      <xsl:choose>
        <xsl:when test="@value=&quot;false&quot;">
          <xsl:value-of select="($anto + 1) mod 2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$anto mod 2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$neg=&quot;1&quot;">
      <xsl:text>non </xsl:text>
    </xsl:if>
    <xsl:call-template name="pp2">
      <xsl:with-param name="k">
        <xsl:text>V</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="vis">
        <xsl:text/>
      </xsl:with-param>
      <xsl:with-param name="la">
        <xsl:text/>
      </xsl:with-param>
      <xsl:with-param name="args">
        <xsl:text/>
      </xsl:with-param>
      <xsl:with-param name="np">
        <xsl:text>0</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="fnr" select="$fnr"/>
      <xsl:with-param name="pid" select="@pid"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pp1">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="args"/>
    <xsl:param name="vis"/>
    <xsl:param name="fnr"/>
    <xsl:param name="parenth"/>
    <xsl:param name="loci"/>
    <xsl:param name="pid"/>
    <xsl:param name="i"/>
    <xsl:variable name="la">
      <xsl:choose>
        <xsl:when test="($k=&apos;M&apos;) or ($k=&apos;G&apos;) or ($k=&apos;L&apos;)">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="document($formats,/)">
            <xsl:for-each select="key(&apos;F&apos;,$fnr)">
              <xsl:choose>
                <xsl:when test="@leftargnr">
                  <xsl:value-of select="@leftargnr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- try if right bracket - returns '' if not -->
    <xsl:variable name="rsym">
      <xsl:if test="($k=&apos;K&apos;) and ($la=&apos;0&apos;)">
        <xsl:call-template name="abs1">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="r">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="np">
      <xsl:choose>
        <xsl:when test="not($vis) or ($k=&apos;G&apos;)">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$parenth&gt;0">
              <xsl:value-of select="$parenth"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="not($rsym=&apos;&apos;)">
                  <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="paren_color" select="$np mod $pcolors_nr"/>
    <!-- print spanned paranthesis or left bracket -->
    <xsl:choose>
      <xsl:when test="($parenspans = 1) and ($np &gt; 0)">
        <xsl:element name="span">
          <xsl:attribute name="class">
            <xsl:value-of select="concat(&quot;p&quot;,$paren_color)"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>(</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym">
                  <xsl:call-template name="abs1">
                    <xsl:with-param name="k" select="$k"/>
                    <xsl:with-param name="nr" select="$nr"/>
                    <xsl:with-param name="fnr" select="$fnr"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:element name="span">
            <xsl:attribute name="class">
              <xsl:text>default</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="pp2">
              <xsl:with-param name="k" select="$k"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="vis" select="$vis"/>
              <xsl:with-param name="la" select="$la"/>
              <xsl:with-param name="loci" select="$loci"/>
              <xsl:with-param name="args" select="$args"/>
              <xsl:with-param name="np" select="$np"/>
              <xsl:with-param name="rsym" select="$rsym"/>
              <xsl:with-param name="parenth" select="$parenth"/>
              <xsl:with-param name="fnr" select="$fnr"/>
              <xsl:with-param name="pid" select="$pid"/>
            </xsl:call-template>
          </xsl:element>
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym" select="$rsym"/>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="($np &gt; 0)">
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>(</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="pp2">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="vis" select="$vis"/>
          <xsl:with-param name="la" select="$la"/>
          <xsl:with-param name="loci" select="$loci"/>
          <xsl:with-param name="args" select="$args"/>
          <xsl:with-param name="np" select="$np"/>
          <xsl:with-param name="rsym" select="$rsym"/>
          <xsl:with-param name="parenth" select="$parenth"/>
          <xsl:with-param name="fnr" select="$fnr"/>
          <xsl:with-param name="pid" select="$pid"/>
        </xsl:call-template>
        <xsl:if test="($np &gt; 0)">
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Proposition">
    <xsl:if test="following-sibling::*[1][(name()=&quot;By&quot;) and (@linked=&quot;true&quot;)]">
      <xsl:if test="not((name(..) = &quot;Consider&quot;) or (name(..) = &quot;Reconsider&quot;) 
           or (name(..) = &quot;Conclusion&quot;))">
        <xsl:text>then </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@nr&gt;0">
      <xsl:choose>
        <xsl:when test="($proof_links&gt;0) and ($print_lab_identifiers = 0) 
            and not(string-length(@plevel)&gt;0)">
          <xsl:call-template name="plab1">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="txt">
              <xsl:text>Lemma</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="vid" select="@vid"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:text>$</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
    <xsl:text>$</xsl:text>
  </xsl:template>

  <xsl:template name="add_hs_attrs"/>

  <xsl:template name="add_hs2_attrs"/>

  <xsl:template name="add_hsNdiv_attrs"/>

  <xsl:template name="add_ajax_attrs">
    <xsl:param name="u"/>
  </xsl:template>

  <xsl:template name="mkref">
    <xsl:param name="aid"/>
    <xsl:param name="nr"/>
    <xsl:param name="k"/>
    <xsl:param name="c"/>
    <xsl:param name="nm"/>
    <xsl:variable name="mk">
      <xsl:call-template name="refkind">
        <xsl:with-param name="kind" select="$k"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="alc">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$aid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$nm">
        <xsl:value-of select="$nm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$aid"/>
        <xsl:text>:</xsl:text>
        <xsl:if test="not($k=&quot;T&quot;)">
          <xsl:value-of select="$mk"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="$nr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- add the constructor/pattern href, $c tells if it is from current article -->
  <!-- #sym is optional Mizar symbol -->
  <!-- #pid links to  patterns instead of constructors -->
  <xsl:template name="absref">
    <xsl:param name="elems"/>
    <xsl:param name="c"/>
    <xsl:param name="sym"/>
    <xsl:param name="pid"/>
    <xsl:variable name="n1">
      <xsl:choose>
        <xsl:when test="($pid &gt; 0)">
          <xsl:text>N</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$elems">
      <xsl:variable name="mk0">
        <xsl:call-template name="mkind">
          <xsl:with-param name="kind" select="@kind"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="mk">
        <xsl:choose>
          <xsl:when test="($pid &gt; 0)">
            <xsl:value-of select="concat($mk0, &quot;not&quot;)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$mk0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="alc">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$sym">
          <xsl:value-of select="$sym"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$relnames &gt; 0">
              <xsl:value-of select="$n1"/>
              <xsl:value-of select="@kind"/>
              <xsl:value-of select="@relnr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$n1"/>
              <xsl:value-of select="@kind"/>
              <xsl:value-of select="@nr"/>
              <xsl:text>_</xsl:text>
              <xsl:value-of select="@aid"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="AUTHOR|TITLE|ACKNOWLEDGEMENT|SUMMARY|NOTE|ADDRESS">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="text()"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="DATE">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Received &quot;, @month,&quot; &quot;, @day, &quot;, &quot;, @year)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ARTICLE_BIB">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Default -->
  <xsl:template match="/">
    <xsl:for-each select="document($bibtex,/)">
      <xsl:apply-templates select="ARTICLE_BIB"/>
    </xsl:for-each>
    <!-- first read the keys for imported stuff -->
    <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
    <!-- apply[document($thms,/)/Theorems/Theorem]; -->
    <!-- apply[document($schms,/)/Schemes/Scheme]; -->
    <!-- then process the whole document -->
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
