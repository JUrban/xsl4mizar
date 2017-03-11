<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="dc" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <!-- $Revision: 1.8 $ -->
  <!--  -->
  <!-- File: mhtml_main.xsltxt - html-ization of Mizar XML, main file -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- XML terms, formulas and types to less verbose format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL miz.xsltxt | sed -e 's/<!\-\- *\(<\/*xsl:document.*\) *\-\->/\1/g' >miz.xsl -->
  <!-- (the sed hack is there because xsl:document is not yet supported by xsltxtx) -->
  <!-- Then e.g.: xsltproc miz.xsl ordinal2.pre >ordinal2.pre1 -->
  <!-- TODO: number B vars in fraenkel - done since 1.72 -->
  <!-- handle F and H parenthesis as K parenthesis -->
  <!-- article numbering in Ref? -->
  <!-- absolute definiens numbers for thesisExpansions? - done -->
  <!-- do not display BlockThesis for Proof? - done, should but should be optional for Now -->
  <!-- add @nr to canceled -->
  <!-- Constructor should know its serial number! - needed in defs -->
  <!-- possibly also article? -->
  <!-- change globally 'G' to 'L' for types? -> then change the -->
  <!-- hacks here and in emacs.el -->
  <!-- display definiens? - done -->
  <!-- NOTES: constructor disambiguation is done using the absolute numbers -->
  <!-- (attribute 'nr' and 'aid' of the Constructor element. -->
  <!-- This info for Constructors not defined in the article is -->
  <!-- taken from the .atr file (see variable $constrs) -->
  <xsl:include href="mhtml_block_top.xsl"/>

  <!-- ##INCLUDE HERE -->
  <!-- Default -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$generate_items = &quot;1&quot;">
        <xsl:apply-templates select="/*/JustifiedTheorem|/*/DefTheorem|/*/SchemeBlock"/>
        <xsl:apply-templates select="//RCluster|//CCluster|//FCluster|//Definition|//IdentifyWithExp"/>
        <!-- top-level lemmas -->
        <xsl:for-each select="/*/Proposition">
          <xsl:document href="proofhtml/lemma/{$anamelc}.{@propnr}" format="html"> 
          <xsl:apply-templates select="."/>
          </xsl:document> 
          <xsl:variable name="bogus" select="1"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$body_only = &quot;0&quot;">
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
                <xsl:element name="script">
                  <xsl:attribute name="type">
                    <xsl:text>text/x-mathjax-config</xsl:text>
                  </xsl:attribute>
                  <xsl:text>
  MathJax.Hub.Config({                                                                                                                            
    extensions: [&apos;tex2jax.js&apos;],                                                                                                                   
    jax: [&apos;input/TeX&apos;, &apos;output/HTML-CSS&apos;],                                                                                                        
    tex2jax: {                                                                                                                                    
      inlineMath: [ [&apos;$&apos;,&apos;$&apos;], [&apos;\(&apos;,&apos;\)&apos;] ],                                                                                                   
      displayMath: [ [&apos;$$&apos;,&apos;$$&apos;], [&apos;\[&apos;,&apos;\]&apos;] ],                                                                                                
  processClass: &apos;mathjax&apos;,                                                                                                                        
  ignoreClass: &apos;no-mathjax&apos;,                                                                                                                      
      processEscapes: true,                                                                                                                       
    },                                                                                                                                            
    &apos;HTML-CSS&apos;: {   scale: 80, availableFonts: [&apos;TeX&apos;] }                                                                                          
  });
</xsl:text>
                </xsl:element>
                <xsl:element name="script">
                  <xsl:attribute name="type">
                    <xsl:text>text/javascript</xsl:text>
                  </xsl:attribute>
                  <xsl:attribute name="src">
                    <xsl:text>https://cdn.mathjax.org/mathjax/latest/MathJax.js</xsl:text>
                  </xsl:attribute>
                </xsl:element>
              </xsl:element>
              <xsl:element name="body">
                <xsl:attribute name="class">
                  <xsl:text>no-mathjax</xsl:text>
                </xsl:attribute>
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
                <xsl:if test="$mk_environ &gt; 0">
                  <xsl:call-template name="pkeyword">
                    <xsl:with-param name="str">
                      <xsl:text>environ </xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:element name="br"/>
                  <xsl:element name="br"/>
                  <xsl:apply-templates select="document($evl,/)/Environ/*"/>
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
            <xsl:if test="$mk_environ &gt; 0">
              <xsl:call-template name="pkeyword">
                <xsl:with-param name="str">
                  <xsl:text>environ </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:element name="br"/>
              <xsl:element name="br"/>
              <xsl:apply-templates select="document($evl,/)/Environ/*"/>
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

  <xsl:template match="Directive">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str" select="@name"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>, </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="Ident"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="Ident">
    <xsl:call-template name="aidref">
      <xsl:with-param name="aid" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <!-- comment rules -->
  <xsl:template match="Comment">
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>comment mathjax</xsl:text>
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
