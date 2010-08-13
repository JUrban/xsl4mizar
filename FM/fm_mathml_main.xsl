<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- the import directive is useful because anything -->
  <!-- imported can be later overrriden - we'll use it for -->
  <!-- the pretty-printing funcs -->
  <xsl:import href="../MHTML/mhtml_block_top.xsl"/>
  <!-- ##INCLUDE HERE -->
  <xsl:output method="xml" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN" doctype-system="http://www.w3c.org/TR/MathML2/dtd/xhtml-math11-f.dtd" media-type="application/xhtml+xml"/>
  <!-- output omit-xml-declaration="no"; -->
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
  <!-- java -jar ../xsltxt.jar toXSL fm_mathml_main.xsltxt >fm_mathml_main.xsl -->
  <!-- include fm_print_complex.xsl; -->
  <!-- include mhtml_block_top.xsl;  // ##INCLUDE HERE -->
  <!-- the FM specific code: -->
  <!-- XML file containing FM formats -->
  <xsl:param name="fmformats">
    <xsl:text>file:///home/urban/gr/xsl4mizar/FM/mathml_formats.fmx</xsl:text>
  </xsl:param>
  <!-- .bxx file with the bibtex info in xml (see article_bib.rnc) -->
  <xsl:param name="bibtex">
    <xsl:value-of select="concat($anamelc, &apos;.bbx&apos;)"/>
  </xsl:param>
  <!-- lookup of the FMFormat based on the symbol, kind,argnr and leftargnr - -->
  <!-- TODO: add the rightsymbol too (otherwise probably not unique) -->
  <xsl:key name="FM" match="FMFormatMap" use="concat( @symbol, &quot;::&quot;, @kind, &apos;:&apos;, @argnr, &apos;:&apos;, @leftargnr)"/>
  <xsl:param name="mspace_width">
    <xsl:text>0.5ex</xsl:text>
  </xsl:param>
  <!-- symbols, overloaded for mathml presentation -->
  <xsl:param name="for_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x02200; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="ex_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x02203; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x000AC; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:element name="m:mo">
      <xsl:text> non </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x02227; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x021D2; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x021D4; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:element name="m:mo">
      <xsl:text> &#x02228; </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="holds_s">
    <xsl:element name="m:mo">
      <xsl:text> holds </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="being_s">
    <xsl:element name="m:mo">
      <xsl:text> : </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="be_s">
    <xsl:element name="m:mo">
      <xsl:text> be </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="st_s">
    <xsl:element name="m:mo">
      <xsl:text> st  </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="is_s">
    <xsl:element name="m:mo">
      <xsl:text> is </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="fraenkel_start">
    <xsl:element name="m:mo">
      <xsl:text> { </xsl:text>
    </xsl:element>
  </xsl:param>
  <xsl:param name="fraenkel_end">
    <xsl:element name="m:mo">
      <xsl:text> } </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="of_sel_s">
    <xsl:element name="m:mo">
      <xsl:text> of </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="of_typ_s">
    <xsl:element name="m:mo">
      <xsl:text> of </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="the_sel_s">
    <xsl:element name="m:mo">
      <xsl:text> the </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="choice_s">
    <xsl:element name="m:mo">
      <xsl:text> the </xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>
  <xsl:param name="lbracket_s">
    <xsl:element name="m:mo">
      <xsl:text>(</xsl:text>
    </xsl:element>
  </xsl:param>
  <xsl:param name="rbracket_s">
    <xsl:element name="m:mo">
      <xsl:text>)</xsl:text>
    </xsl:element>
    <xsl:element name="m:mspace">
      <xsl:attribute name="width">
        <xsl:value-of select="$mspace_width"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:param>

  <!-- overloading of identifiers to print m:mi -->
  <xsl:template name="pqvar">
    <xsl:param name="nr"/>
    <xsl:param name="vid"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($vid &gt; 0)">
        <xsl:variable name="nm">
          <xsl:call-template name="get_vid_name">
            <xsl:with-param name="vid" select="$vid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="m:mi">
          <xsl:choose>
            <xsl:when test="$colored = &quot;1&quot;">
              <xsl:element name="font">
                <xsl:attribute name="color">
                  <xsl:value-of select="$varcolor"/>
                </xsl:attribute>
                <xsl:if test="$titles=&quot;1&quot;">
                  <xsl:attribute name="title">
                    <xsl:value-of select="concat(&quot;b&quot;,$nr)"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$nm"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$nm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pvar">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pvar">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$varcolor"/>
            </xsl:attribute>
            <xsl:text>b</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>b</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pconst">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$constcolor"/>
            </xsl:attribute>
            <xsl:text>c</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>c</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- #pl gives the optional proof level -->
  <xsl:template name="ppconst">
    <xsl:param name="nr"/>
    <xsl:param name="vid"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($vid &gt; 0)">
        <xsl:variable name="ctarget">
          <xsl:choose>
            <xsl:when test="($const_links&gt;0) and  ($pl)">
              <xsl:text>c</xsl:text>
              <xsl:value-of select="$nr"/>
              <xsl:call-template name="addp">
                <xsl:with-param name="pl" select="$pl"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(&quot;c&quot;,$nr)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nm">
          <xsl:call-template name="get_vid_name">
            <xsl:with-param name="vid" select="$vid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="m:mi">
          <xsl:choose>
            <xsl:when test="($const_links=2)">
              <xsl:element name="a">
                <xsl:attribute name="class">
                  <xsl:text>txt</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat(&quot;#&quot;,$ctarget)"/>
                </xsl:attribute>
                <xsl:element name="font">
                  <xsl:attribute name="color">
                    <xsl:value-of select="$constcolor"/>
                  </xsl:attribute>
                  <xsl:if test="$titles=&quot;1&quot;">
                    <xsl:attribute name="title">
                      <xsl:value-of select="$ctarget"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$nm"/>
                </xsl:element>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$colored = &quot;1&quot;">
                  <xsl:element name="font">
                    <xsl:attribute name="color">
                      <xsl:value-of select="$constcolor"/>
                    </xsl:attribute>
                    <xsl:if test="$titles=&quot;1&quot;">
                      <xsl:attribute name="title">
                        <xsl:value-of select="$ctarget"/>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$nm"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$nm"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pploci">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($proof_links&gt;0)">
        <xsl:variable name="pl">
          <xsl:call-template name="get_nearest_level">
            <xsl:with-param name="el" select=".."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="absconst">
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ploci">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$locicolor"/>
            </xsl:attribute>
            <xsl:text>a</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>a</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pschpvar">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$schpcolor"/>
            </xsl:attribute>
            <xsl:text>P</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>P</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pschfvar">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$schfcolor"/>
            </xsl:attribute>
            <xsl:text>F</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>F</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pppred">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$ppcolor"/>
            </xsl:attribute>
            <xsl:text>S</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>S</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="ppfunc">
    <xsl:param name="nr"/>
    <xsl:element name="m:mi">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$pfcolor"/>
            </xsl:attribute>
            <xsl:text>H</xsl:text>
            <xsl:element name="sub">
              <xsl:value-of select="$nr"/>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>H</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

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
                  <xsl:element name="m:mo">
                    <!-- if [not($parenth>0) or ($la>0)] { " "; } -->
                    <xsl:call-template name="abs">
                      <xsl:with-param name="k" select="$k"/>
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="sym" select="@s"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                  </xsl:element>
                  <xsl:element name="m:mspace">
                    <xsl:attribute name="width">
                      <xsl:value-of select="$mspace_width"/>
                    </xsl:attribute>
                  </xsl:element>
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
      <xsl:copy-of select="$non_s"/>
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
                <xsl:when test="@kind=&quot;V&quot;">
                  <xsl:value-of select="@argnr - 1"/>
                </xsl:when>
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
          <xsl:element name="m:mo">
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
          </xsl:element>
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
          <xsl:element name="m:mo">
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
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="($np &gt; 0)">
          <xsl:element name="m:mo">
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
          </xsl:element>
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
          <xsl:element name="m:mo">
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
    <xsl:element name="m:math">
      <xsl:element name="m:mrow">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
      </xsl:element>
    </xsl:element>
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
  <!-- tpl absref(#elems, #c, #sym, #pid) -->
  <!-- { -->
  <!-- $n1 = { if [($pid > 0)] { "N"; } else { ""; } } -->
  <!-- for-each [$elems] -->
  <!-- { -->
  <!-- $mk0  = mkind(#kind = `@kind`); -->
  <!-- $mk   = { if [($pid > 0)] { `concat($mk0, "not")`; } else { $mk0; } } -->
  <!-- $alc  = lc(#s=`@aid`); -->
  <!-- if [$sym] -->
  <!-- { -->
  <!-- $sym; -->
  <!-- } -->
  <!-- else -->
  <!-- { -->
  <!-- if [$relnames > 0] -->
  <!-- { -->
  <!-- $n1; `@kind`; `@relnr`; -->
  <!-- } -->
  <!-- else -->
  <!-- { -->
  <!-- $n1; `@kind`; `@nr`; "_"; `@aid`; -->
  <!-- } -->
  <!-- } -->
  <!-- } -->
  <!-- } -->
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
  <!-- tpl [/] { -->
  <!-- for-each [document($bibtex,/)] -->
  <!-- { -->
  <!-- apply[ARTICLE_BIB]; -->
  <!-- } -->
  <!-- first read the keys for imported stuff -->
  <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
  <!-- apply[document($thms,/)/Theorems/Theorem]; -->
  <!-- apply[document($schms,/)/Schemes/Scheme]; -->
  <!-- then process the whole document -->
  <!-- apply; -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$generate_items = &quot;1&quot;">
        <xsl:apply-templates select="/*/JustifiedTheorem|/*/DefTheorem|/*/SchemeBlock"/>
        <xsl:apply-templates select="//RCluster|//CCluster|//FCluster|//Definition|//IdentifyWithExp"/>
        <!-- top-level lemmas -->
        <xsl:for-each select="/*/Proposition">
          <!-- <xsl:document href="proofhtml/lemma/{$anamelc}.{@propnr}" format="html"> -->
          <xsl:apply-templates select="."/>
          <!-- </xsl:document> -->
          <xsl:variable name="bogus" select="1"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$body_only = &quot;0&quot;">
            <xsl:element name="html">
              <!-- output the css defaults for div and p (for indenting) -->
              <xsl:element name="style">
                <xsl:attribute name="type">
                  <xsl:text>text/css</xsl:text>
                </xsl:attribute>
                <xsl:text>
div { padding: 0 0 0 0; margin: 0 0 0 0; } 
div.add { padding-left: 3mm; padding-bottom: 0mm;  margin: 0 0 0 0; } 
div.box { border-width:thin; border-color:blue; border-style:solid; }
p { margin: 0 0 0 0; } 
body {font-family: monospace; margin: 0px;}
a {text-decoration:none} a:hover { color: red; } 
a.ref { font-size:x-small; }
a.ref:link { color:green; } 
a.ref:hover { color: red; } 
a.txt:link { color:black; } 
a.txt:hover { color: red; } 
.wikiactions ul { background-color: DarkSeaGreen ; color:blue; margin: 0; padding: 6px; list-style-type: none; border-bottom: 1px solid #000; }
.wikiactions li { display: inline; padding: .2em .4em; }
.wikiactions a {text-decoration:underline;} 
span.kw {font-weight: bold; }
span.lab {font-style: italic; }
span.comment {font-style: italic; }
span.hide { display: none; }
span.p1:hover { color : inherit; background-color : #BAFFFF; } 
span.p2:hover { color : inherit; background-color : #FFCACA; }
span.p3:hover { color : inherit; background-color : #FFFFBA; }
span.p4:hover { color : inherit; background-color : #CACAFF; }
span.p5:hover { color : inherit; background-color : #CAFFCA; }
span.p0:hover { color : inherit; background-color : #FFBAFF; }
.default { background-color: white; color: black; } 
.default:hover { background-color: white; color: black; }
:target { background: ##5D9BF7; border: solid 1px #aaa;}
</xsl:text>
              </xsl:element>
              <xsl:element name="head">
                <xsl:element name="title">
                  <xsl:choose>
                    <xsl:when test="$mk_header &gt; 0">
                      <xsl:value-of select="$aname"/>
                      <xsl:text>: </xsl:text>
                      <xsl:for-each select="document($hdr,/)/Header/dc:title">
                        <xsl:value-of select="text()"/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$aname"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="script">
                  <xsl:attribute name="type">
                    <xsl:text>text/javascript</xsl:text>
                  </xsl:attribute>
                  <xsl:text>
&lt;!-- 
function hs(obj)
{
// document.getElementById(&apos;myimage&apos;).nextSibling.style.display = &apos;block&apos;;
if (obj.nextSibling.style.display == &apos;inline&apos;)
 { obj.nextSibling.style.display = &apos;none&apos;; }
else { if (obj.nextSibling.style.display == &apos;none&apos;)
 { obj.nextSibling.style.display = &apos;inline&apos;; }
 else { obj.nextSibling.style.display = &apos;inline&apos;;  }}
return false;
}

function hs2(obj)
{
if (obj.nextSibling.style.display == &apos;block&apos;)
 { obj.nextSibling.style.display = &apos;none&apos;; }
else { if (obj.nextSibling.style.display == &apos;none&apos;)
 { obj.nextSibling.style.display = &apos;block&apos;; }
 else { obj.nextSibling.style.display = &apos;none&apos;;  }}
return false;
}
function hsNdiv(obj)
{
var ndiv = obj;
while (ndiv.nextSibling.nodeName != &apos;DIV&apos;) { ndiv = ndiv.nextSibling; }
return hs2(ndiv);
}

// explorer7 implements XMLHttpRequest in some strange way
function makeRequest(obj,url) {
        var http_request = false;
        if (window.XMLHttpRequest &amp;&amp; !(window.ActiveXObject)) { // Mozilla, Safari,...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
                http_request.overrideMimeType(&apos;text/xml&apos;);
            }
        } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject(&apos;Msxml2.XMLHTTP&apos;);
            } catch (e) {
                try {
                    http_request = new ActiveXObject(&apos;Microsoft.XMLHTTP&apos;);
                } catch (e) {}
            }
        }
        if (!http_request) {
            alert(&apos;Giving up :( Cannot create an XMLHTTP instance&apos;);
            return false;
        }
        http_request.onreadystatechange = function() { insertRequest(obj,http_request); };
        http_request.open(&apos;GET&apos;, url, true);
        http_request.send(null);
    }
// commented the 200 state to have local requests too
function insertRequest(obj,http_request) {
        if (http_request.readyState == 4) {
//            if (http_request.status == 200) {
	    var ndiv = obj;
	    while (ndiv.nodeName != &apos;SPAN&apos;) { ndiv = ndiv.nextSibling; }
	    ndiv.innerHTML = http_request.responseText;
	    obj.onclick = function(){ return hs2(obj) };
//            } else {
//                alert(&apos;There was a problem with the request.&apos;);
//		alert(http_request.status);
//            }
	    }}
// End --&gt;
</xsl:text>
                </xsl:element>
                <xsl:if test="$idv&gt;0">
                  <xsl:element name="script">
                    <xsl:attribute name="type">
                      <xsl:text>text/javascript</xsl:text>
                    </xsl:attribute>
                    <xsl:text>
&lt;!--
var tstp_dump;
function openSoTSTP (dump) {
var tstp_url = &apos;http://www.cs.miami.edu/~tptp/cgi-bin/SystemOnTSTP&apos;;
var tstp_browser = window.open(tstp_url, &apos;_blank&apos;);
tstp_dump = dump;
}
function getTSTPDump () {
return tstp_dump;
}
// End --&gt;
</xsl:text>
                  </xsl:element>
                </xsl:if>
                <xsl:element name="base">
                  <xsl:attribute name="target">
                    <xsl:value-of select="$default_target"/>
                  </xsl:attribute>
                </xsl:element>
              </xsl:element>
              <xsl:element name="body">
                <xsl:if test="$wiki_links=1">
                  <xsl:element name="div">
                    <xsl:attribute name="class">
                      <xsl:text>wikiactions</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="ul">
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=edit;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:attribute name="rel">
                            <xsl:text>nofollow</xsl:text>
                          </xsl:attribute>
                          <xsl:text>Edit</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=history;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:text>History</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=blob_plain;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:attribute name="rel">
                            <xsl:text>nofollow</xsl:text>
                          </xsl:attribute>
                          <xsl:text>Raw</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <!-- <li {  <a { @href=`concat("../discussion/",$anamelc, ".html")`; "Discussion"; } } -->
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="$lmwikiindex"/>
                          </xsl:attribute>
                          <xsl:text>Index</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=gitweb&quot;)"/>
                          </xsl:attribute>
                          <xsl:text>Gitweb</xsl:text>
                        </xsl:element>
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$mk_header &gt; 0">
                  <xsl:apply-templates select="document($hdr,/)/Header/*"/>
                  <xsl:element name="br"/>
                </xsl:if>
                <!-- first read the keys for imported stuff -->
                <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
                <!-- apply[document($thms,/)/Theorems/Theorem]; -->
                <!-- apply[document($schms,/)/Schemes/Scheme]; -->
                <!-- then process the whole document -->
                <xsl:apply-templates/>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <!-- $body_only > 0 -->
          <xsl:otherwise>
            <xsl:if test="$mk_header &gt; 0">
              <xsl:apply-templates select="document($hdr,/)/Header/*"/>
              <xsl:element name="br"/>
            </xsl:if>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [*] { copy { apply [@*]; apply; } } -->
  <!-- tpl [@*] { copy-of `.`; } -->
  <!-- Header rules -->
  <xsl:template match="dc:title">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:creator">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;by &quot;, text())"/>
    </xsl:call-template>
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str">
        <xsl:text/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:date">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Received &quot;, text())"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:rights">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Copyright &quot;, text())"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
