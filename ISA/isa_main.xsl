<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="dc" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- the import directive is useful because anything -->
  <!-- imported can be later overrriden - we'll use it for -->
  <!-- the pretty-printing funcs -->
  <xsl:import href="../MHTML/mhtml_block_top.xsl"/>
  <!-- ##INCLUDE HERE -->
  <xsl:output method="html"/>
  <!-- $Revision: 1.4 $ -->
  <!--  -->
  <!-- File: isa_main.xsltxt - Isabell-ization of Mizar XML, main file -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- XML terms, formulas and types to Isabelle format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar ../xsltxt.jar toXSL isa_main.xsltxt >isa_main.xsl -->
  <!-- include fm_print_complex.xsl; -->
  <!-- include mhtml_block_top.xsl;  // ##INCLUDE HERE -->
  <!-- the (very initial) Isabelle specific code: -->
  <xsl:param name="for_s">
    <xsl:text> &#8704; </xsl:text>
  </xsl:param>
  <xsl:param name="ex_s">
    <xsl:text> &#8707; </xsl:text>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:text> &#172; </xsl:text>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:text> non </xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text> &#8743; </xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text> &#8658; </xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text> &#8660; </xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text> &#8744; </xsl:text>
  </xsl:param>
  <xsl:param name="holds_s">
    <xsl:text> . </xsl:text>
  </xsl:param>
  <xsl:param name="being_s">
    <xsl:text> :: </xsl:text>
  </xsl:param>
  <xsl:param name="be_s">
    <xsl:text> :: </xsl:text>
  </xsl:param>
  <xsl:param name="st_s">
    <xsl:text> . </xsl:text>
  </xsl:param>
  <xsl:param name="is_s">
    <xsl:text> is </xsl:text>
  </xsl:param>
  <xsl:param name="dots_s">
    <xsl:text> ... </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_start">
    <xsl:text> { </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_end">
    <xsl:text> } </xsl:text>
  </xsl:param>
  <xsl:param name="of_sel_s">
    <xsl:text> of  </xsl:text>
  </xsl:param>
  <xsl:param name="of_typ_s">
    <xsl:text> of  </xsl:text>
  </xsl:param>
  <xsl:param name="the_sel_s">
    <xsl:text> the  </xsl:text>
  </xsl:param>
  <xsl:param name="choice_s">
    <xsl:text> the  </xsl:text>
  </xsl:param>
  <xsl:param name="lbracket_s">
    <xsl:text>(</xsl:text>
  </xsl:param>
  <xsl:param name="rbracket_s">
    <xsl:text>)</xsl:text>
  </xsl:param>

  <xsl:template name="thm_header">
    <xsl:param name="nr1"/>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>let </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="($proof_links &gt; 0) and ($print_lab_identifiers = 0)">
        <xsl:call-template name="plab1">
          <xsl:with-param name="nr" select="$nr1"/>
          <xsl:with-param name="txt">
            <xsl:text>Th</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="Proposition[@nr &gt; 0]">
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="vid" select="@vid"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> = thm `</xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;T&quot;, $nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pcomment0">
        <xsl:with-param name="str" select="concat($aname,&quot;:&quot;, $nr1)"/>
      </xsl:call-template>
      <xsl:element name="br"/>
    </xsl:element>
  </xsl:template>

  <!-- tpl add_hs_attrs { } -->
  <!-- tpl add_hs2_attrs { } -->
  <!-- tpl add_hsNdiv_attrs { } -->
  <!-- tpl add_ajax_attrs(#u) { } -->
  <xsl:template match="/">
    <xsl:element name="html">
      <xsl:attribute name="prefix">
        <xsl:text>oo: http://omdoc.org/ontology# owl: http://www.w3.org/2002/07/owl#</xsl:text>
      </xsl:attribute>
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
#tt { position:absolute; display:block; font-size: small; background: LightYellow; padding:2px 12px 3px 7px; margin-left:5px;}
:target { background: #5D9BF7; border: solid 1px #aaa;}
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

// for saving in rs
var mizhtm=&apos;</xsl:text>
          <xsl:value-of select="$mizhtml"/>
          <xsl:text>&apos;;</xsl:text>
          <xsl:value-of select="$mizjs1"/>
        </xsl:element>
        <xsl:element name="base">
          <xsl:attribute name="target">
            <xsl:value-of select="$default_target"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="body">
        <xsl:if test="$mk_header &gt; 0">
          <xsl:apply-templates select="document($hdr,/)/Header/*"/>
          <xsl:element name="br"/>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

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

  <!-- comment rules -->
  <xsl:template match="Comment">
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>comment</xsl:text>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$commentcolor"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CmtLine">
    <xsl:value-of select="text()"/>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="CmtLink">
    <xsl:text>:: </xsl:text>
    <xsl:call-template name="add_wp_icon"/>
    <xsl:text> </xsl:text>
    <xsl:for-each select="*">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="text()"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template name="add_wp_icon">
    <xsl:element name="img">
      <xsl:attribute name="src">
        <xsl:value-of select="concat($ltptproot,&quot;WP.ico&quot;)"/>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:text>WP: </xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
