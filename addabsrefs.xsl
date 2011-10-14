<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet adding -->
  <!-- absolute names to Mizar constructors and references. -->
  <!-- This means that the "aid" (article name) and the "absnr" -->
  <!-- (serial number in its article) attributes are added, -->
  <!-- and the "kind" attribute is added if not present. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL addabsrefs.xsltxt > addabsrefs.xsl -->
  <!-- Then e.g.: xalan -XSL addabsrefs.xsl <ordinal2.xml >ordinal2.xml1 -->
  <!-- or: xsltproc addabsrefs.xsl ordinal2.xml >ordinal2.xml1 -->
  <!-- TODO: -->
  <!-- article numbering in Ref? -->
  <!-- absolute definiens numbers for thesisExpansions? -->
  <!-- add @nr to canceled -->
  <!-- Constructor should know its serial number! - needed in defs -->
  <!-- NOTES: constructor disambiguation is done using the absolute numbers -->
  <!-- (attribute 'nr' and 'aid' of the Constructor element. -->
  <!-- This info for Constructors not defined in the article is -->
  <!-- taken from the .atr file (see variable $constrs) -->
  <xsl:output method="xml"/>
  <!-- keys for fast constructor and reference lookup -->
  <xsl:key name="M" match="Constructor[@kind=&apos;M&apos;]" use="@relnr"/>
  <xsl:key name="L" match="Constructor[@kind=&apos;L&apos;]" use="@relnr"/>
  <xsl:key name="V" match="Constructor[@kind=&apos;V&apos;]" use="@relnr"/>
  <xsl:key name="R" match="Constructor[@kind=&apos;R&apos;]" use="@relnr"/>
  <xsl:key name="K" match="Constructor[@kind=&apos;K&apos;]" use="@relnr"/>
  <xsl:key name="U" match="Constructor[@kind=&apos;U&apos;]" use="@relnr"/>
  <xsl:key name="G" match="Constructor[@kind=&apos;G&apos;]" use="@relnr"/>
  <xsl:key name="T" match="/Theorems/Theorem[@kind=&apos;T&apos;]" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="D" match="/Theorems/Theorem[@kind=&apos;D&apos;]" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="S" match="/Schemes/Scheme" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="DF" match="Definiens" use="@relnr"/>
  <!-- lookup for FromExplanations (in .fex) -->
  <xsl:key name="SI" match="/FromExplanations/SchemeInstantiation" use="concat(@line,&apos;:&apos;,@col)"/>
  <!-- lookup for ByExplanations (in .bex) -->
  <!-- after running verifier, postprocess (sort away redundant stuff from) .bex with: -->
  <!-- perl -e 'local $/;$_=<>; m/((.|[\n])*?)<PolyEval/; print $1; while(m/(<PolyEval((.|[\n])*?)<\/PolyEval>)/g) { if(!(exists $h{$1})) { print $1; $h{$1} = (); }} print "</ByExplanations>";' -->
  <xsl:key name="PE" match="/ByExplanations/PolyEval" use="concat(@line,&apos;:&apos;,@col)"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>
  <!-- name of current article (upper case) -->
  <xsl:param name="aname">
    <xsl:value-of select="string(/*/@aid)"/>
  </xsl:param>
  <!-- name of current article (lower case) -->
  <xsl:param name="anamelc">
    <xsl:value-of select="translate($aname, $ucletters, $lcletters)"/>
  </xsl:param>
  <!-- .atr file with imported constructors -->
  <xsl:param name="constrs">
    <xsl:value-of select="concat($anamelc, &apos;.atr&apos;)"/>
  </xsl:param>
  <!-- .dco file with exported constructors -->
  <xsl:param name="dcoconstrs">
    <xsl:value-of select="concat($anamelc, &apos;.dco&apos;)"/>
  </xsl:param>
  <!-- .eth file with imported theorems -->
  <xsl:param name="thms">
    <xsl:value-of select="concat($anamelc, &apos;.eth&apos;)"/>
  </xsl:param>
  <!-- .esh file with imported schemes -->
  <xsl:param name="schms">
    <xsl:value-of select="concat($anamelc, &apos;.esh&apos;)"/>
  </xsl:param>
  <!-- .dfs file with imported definientia -->
  <xsl:param name="dfs">
    <xsl:value-of select="concat($anamelc, &apos;.dfs&apos;)"/>
  </xsl:param>
  <!-- set this to 0 to get rid of missing document errors -->
  <!-- when the ByExplanations and SchemeInstantiation are missing -->
  <xsl:param name="explainbyfrom">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- .fex file with FromExplanations -->
  <xsl:param name="fex">
    <xsl:value-of select="concat($anamelc, &apos;.fex&apos;)"/>
  </xsl:param>
  <!-- .bex file with ByExplanations -->
  <xsl:param name="bex">
    <xsl:value-of select="concat($anamelc, &apos;.bex&apos;)"/>
  </xsl:param>
  <!-- this needs to be set to 1 for processing .eth files -->
  <xsl:param name="ethprocess">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- top level element instead of top-level document, which is hard to -->
  <!-- know -->
  <xsl:param name="top" select="/"/>

  <!-- tpl [Const](#s) {  <Const { copy-of `@*`; @plevel=$s; }} -->
  <!-- #e optionally is the element giving context, e.g. for schemes -->
  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:element name="Pred">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@kind=&apos;P&apos;">
          <xsl:choose>
            <xsl:when test="$e">
              <xsl:call-template name="abs_fp">
                <xsl:with-param name="el" select="$e"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs_fp">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates>
            <xsl:with-param name="s" select="$s"/>
            <xsl:with-param name="e" select="$e"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="abs">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
          <xsl:apply-templates>
            <xsl:with-param name="s" select="$s"/>
            <xsl:with-param name="e" select="$e"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Func">
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:element name="Func">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@kind=&apos;F&apos;">
          <xsl:choose>
            <xsl:when test="$e">
              <xsl:call-template name="abs_fp">
                <xsl:with-param name="el" select="$e"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs_fp">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates>
            <xsl:with-param name="s" select="$s"/>
            <xsl:with-param name="e" select="$e"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="abs">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
          <xsl:apply-templates>
            <xsl:with-param name="s" select="$s"/>
            <xsl:with-param name="e" select="$e"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- for .fex (FromExplanations file) -->
  <xsl:template match="FuncInstance | PredInstance">
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:if test="(@kind=&apos;K&apos;) or (@kind=&apos;R&apos;) or (@kind=&apos;V&apos;)">
        <xsl:call-template name="abs">
          <xsl:with-param name="k" select="@kind"/>
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="e" select="$e"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <!-- Adjective -->
  <xsl:template match="Adjective">
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:element name="Adjective">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="abs">
        <xsl:with-param name="k">
          <xsl:text>V</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="e" select="$e"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <!-- Types -->
  <xsl:template match="Typ">
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:element name="Typ">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@kind=&quot;M&quot;">
          <xsl:call-template name="abs">
            <xsl:with-param name="k">
              <xsl:text>M</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@kind=&quot;G&quot;">
              <xsl:call-template name="abs">
                <xsl:with-param name="k">
                  <xsl:text>L</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="nr" select="@nr"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@kind"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="e" select="$e"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="From">
    <xsl:param name="s"/>
    <xsl:element name="From">
      <xsl:copy-of select="@*"/>
      <xsl:variable name="schnr" select="@nr"/>
      <xsl:variable name="el" select="."/>
      <xsl:variable name="anr" select="@articlenr"/>
      <xsl:call-template name="getschref">
        <xsl:with-param name="anr" select="$anr"/>
        <xsl:with-param name="nr" select="$schnr"/>
      </xsl:call-template>
      <!-- insert the SchemeInstantiation element from $fex, make -->
      <!-- them absolute by adding @schemnr, @aid, @instaid, @instschemenr -->
      <xsl:variable name="l" select="@line"/>
      <xsl:variable name="c" select="@col"/>
      <xsl:variable name="pos" select="concat($l,&apos;:&apos;,$c)"/>
      <xsl:if test="$explainbyfrom &gt; 0">
        <xsl:for-each select="document($fex,/)">
          <xsl:for-each select="key(&apos;SI&apos;,$pos)">
            <xsl:element name="SchemeInstantiation">
              <xsl:copy-of select="@*"/>
              <xsl:for-each select="FuncInstance | PredInstance">
                <xsl:variable name="nm" select="name()"/>
                <xsl:element name="{$nm}">
                  <xsl:copy-of select="@*"/>
                  <xsl:call-template name="getschattrs">
                    <xsl:with-param name="anr" select="$anr"/>
                    <xsl:with-param name="nr" select="$schnr"/>
                    <xsl:with-param name="i">
                      <xsl:text>1</xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:variable name="k" select="@kind"/>
                  <!-- instantiated to other functor -->
                  <xsl:if test="$k">
                    <xsl:choose>
                      <xsl:when test="($k=&quot;K&quot;) or ($k=&quot;R&quot;) or ($k=&quot;V&quot;)">
                        <xsl:call-template name="abs">
                          <xsl:with-param name="k" select="$k"/>
                          <xsl:with-param name="nr" select="@nr"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:when test="($k=&quot;F&quot;) or ($k= &quot;P&quot;)">
                        <xsl:call-template name="abs_fp">
                          <xsl:with-param name="el" select="$el"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </xsl:if>
                  <xsl:apply-templates>
                    <xsl:with-param name="s" select="$s"/>
                    <xsl:with-param name="e" select="$el"/>
                  </xsl:apply-templates>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Requirement">
    <xsl:param name="s"/>
    <xsl:element name="Requirement">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="abs">
        <xsl:with-param name="k" select="@constrkind"/>
        <xsl:with-param name="nr" select="@constrnr"/>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="By">
    <xsl:param name="s"/>
    <xsl:element name="By">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
      <!-- insert the PolyEval elements from $bex, make -->
      <!-- them absolute by adding @schemnr, @aid, @instaid, @instschemenr -->
      <xsl:variable name="l" select="@line"/>
      <xsl:variable name="c" select="@col"/>
      <xsl:variable name="pos" select="concat($l,&apos;:&apos;,$c)"/>
      <xsl:if test="$explainbyfrom &gt; 0">
        <xsl:for-each select="document($bex,/)">
          <xsl:for-each select="key(&apos;PE&apos;,$pos)">
            <xsl:element name="PolyEval">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates>
                <xsl:with-param name="s" select="$s"/>
              </xsl:apply-templates>
            </xsl:element>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Ref">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="not(@articlenr)">
        <xsl:copy>
          <xsl:apply-templates select="@*">
            <xsl:with-param name="s" select="$s"/>
          </xsl:apply-templates>
          <xsl:apply-templates>
            <xsl:with-param name="s" select="$s"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="Ref">
          <xsl:copy-of select="@*"/>
          <xsl:call-template name="getref">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="anr" select="@articlenr"/>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- the pair is copied here too, for easy handling by miz.xsl, -->
  <!-- but is ignored by mizpl.xsl -->
  <xsl:template match="ThesisExpansions/Pair">
    <xsl:element name="Pair">
      <xsl:copy-of select="@*"/>
    </xsl:element>
    <xsl:variable name="x" select="@x"/>
    <xsl:element name="Ref">
      <xsl:choose>
        <xsl:when test="key(&apos;DF&apos;,$x)">
          <xsl:for-each select="key(&apos;DF&apos;,$x)">
            <xsl:attribute name="nr">
              <xsl:value-of select="@defnr"/>
            </xsl:attribute>
            <xsl:call-template name="mkref">
              <xsl:with-param name="aid" select="@aid"/>
              <xsl:with-param name="nr" select="@defnr"/>
              <xsl:with-param name="k">
                <xsl:text>D</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="c">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="document($dfs,/)">
            <xsl:choose>
              <xsl:when test="key(&apos;DF&apos;,$x)">
                <xsl:for-each select="key(&apos;DF&apos;,$x)">
                  <xsl:attribute name="nr">
                    <xsl:value-of select="@defnr"/>
                  </xsl:attribute>
                  <xsl:call-template name="mkref">
                    <xsl:with-param name="aid" select="@aid"/>
                    <xsl:with-param name="nr" select="@defnr"/>
                    <xsl:with-param name="k">
                      <xsl:text>D</xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>errorexpansion</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- add absolute numbers to these (they are kind-dependent) -->
  <!-- note that redefnr of Patterns (relative nr of the synonym/antonym -->
  <!-- Pattern) is ignored -->
  <xsl:template match="Theorem|Constructor|Pattern">
    <xsl:param name="s"/>
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$ethprocess = 0">
        <xsl:variable name="k" select="@kind"/>
        <xsl:attribute name="aid">
          <xsl:value-of select="$aname"/>
        </xsl:attribute>
        <xsl:attribute name="nr">
          <xsl:value-of select="1 + count(preceding::*[(name()=$n) and (@kind=$k)])"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="(@redefnr &gt; 0) and ($n = &quot;Constructor&quot;)">
            <xsl:call-template name="abs">
              <xsl:with-param name="k" select="$k"/>
              <xsl:with-param name="nr" select="@redefnr"/>
              <xsl:with-param name="r">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="($n = &quot;Pattern&quot;) and (not(Expansion))">
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="@constrkind"/>
                <xsl:with-param name="nr" select="@constrnr"/>
                <xsl:with-param name="r">
                  <xsl:text>2</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <!-- the aid and nr are already in the standard xml now -->
  <xsl:template match="RCluster|CCluster|FCluster|IdentifyWithExp|Identify">
    <xsl:param name="s"/>
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Scheme|Definiens">
    <xsl:param name="s"/>
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$ethprocess = 0">
        <xsl:attribute name="aid">
          <xsl:value-of select="$aname"/>
        </xsl:attribute>
        <xsl:attribute name="nr">
          <xsl:value-of select="1 + count(preceding::*[(name()=$n)])"/>
        </xsl:attribute>
        <xsl:if test="($n = &quot;Definiens&quot;)">
          <xsl:call-template name="abs">
            <xsl:with-param name="k" select="@constrkind"/>
            <xsl:with-param name="nr" select="@constrnr"/>
            <xsl:with-param name="r">
              <xsl:text>2</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Field">
    <xsl:param name="s"/>
    <xsl:element name="Field">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="abs">
        <xsl:with-param name="k">
          <xsl:text>U</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:attribute name="arity">
        <xsl:call-template name="arity">
          <xsl:with-param name="k">
            <xsl:text>U</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template name="arity">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="key($k,$nr)">
        <xsl:for-each select="key($k,$nr)">
          <xsl:value-of select="count(ArgTypes/Typ)"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="document($constrs,/)">
          <xsl:choose>
            <xsl:when test="key($k,$nr)">
              <xsl:for-each select="key($k,$nr)">
                <xsl:value-of select="count(ArgTypes/Typ)"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="document($dcoconstrs,/)">
                <xsl:for-each select="key($k,$nr)">
                  <xsl:value-of select="count(ArgTypes/Typ)"/>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [Field] { <Field -->
  <!-- { copy-of `@*`; abs(#k="U", #nr=`@nr`); -->
  <!-- $typs = widening(typ(U),typ(L),typ(U)); -->
  <!-- for-each [$typs] { -->
  <!-- repl_loc_args(#w= -->
  <!-- apply; }} -->
  <!-- // find widening path from $f to $t -->
  <!-- tpl widening(#f,#t,#path) { -->
  <!-- if [absname($f) = absname($t)] { $path } else { -->
  <!-- for-each [$f/Typ] { -->
  <!-- $p1 = { `.`; $path; } -->
  <!-- widening(#f=`.`,#t=$t,#path=$p1) }}} -->
  <!-- tpl repl_path(#f,#t,#a) { -->
  <!-- if [$f=$t] { $a; } else { -->
  <!-- if [$f/@nr < $t/@nr] { -->
  <!-- for-each [$f/Typ] { -->
  <!-- $p1 = { <Path { $f $path } } -->
  <!-- widening(#f=`.`,#t=$t,#path=$p1) }}} -->
  <!-- // replace Loci vars in $w with respective terms from $a -->
  <!-- tpl repl_loc_args(#w,#a) { for-each [$w] { $n=`name()`; -->
  <!-- if [($n = "Locus") and (count($a) >= @nr)] { -->
  <!-- $nr=`@nr`; `$a[position() = $nr]`; } -->
  <!-- else { <$n { copy-of `@*`; for-each [*] { repl_loc_args(#w=`.`,#a) } }}}} -->
  <!-- // replace Locus var nr $f with term $t in $w -->
  <!-- tpl repl_loci(#w,#f,#t) { $n=`name()`; -->
  <!-- if [($n = "Locus") and (@nr = $f)] { $t; } else { <$n { -->
  <!-- copy-of `@*`; for-each [*] { repl_loci(#w=`.`,#f=$f,#t=$t) } }}} -->
  <!-- add the constructor href, if $r, it tells if this is from redefinition (r=1) -->
  <!-- or constr (r=2) -->
  <xsl:template name="absref">
    <xsl:param name="elems"/>
    <xsl:param name="r"/>
    <xsl:for-each select="$elems">
      <xsl:choose>
        <xsl:when test="$r&gt;0">
          <xsl:choose>
            <xsl:when test="$r=1">
              <xsl:attribute name="redefaid">
                <xsl:value-of select="@aid"/>
              </xsl:attribute>
              <xsl:attribute name="absredefnr">
                <xsl:value-of select="@nr"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$r=2">
                <xsl:attribute name="constraid">
                  <xsl:value-of select="@aid"/>
                </xsl:attribute>
                <xsl:attribute name="absconstrnr">
                  <xsl:value-of select="@nr"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="kind">
            <xsl:value-of select="@kind"/>
          </xsl:attribute>
          <!-- @kind=mkind(#kind=`@kind`); -->
          <xsl:attribute name="nr">
            <xsl:value-of select="@relnr"/>
          </xsl:attribute>
          <xsl:attribute name="aid">
            <xsl:value-of select="@aid"/>
          </xsl:attribute>
          <xsl:attribute name="absnr">
            <xsl:value-of select="@nr"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="abs">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="r"/>
    <xsl:for-each select="$top">
      <xsl:choose>
        <xsl:when test="key($k,$nr)">
          <xsl:call-template name="absref">
            <xsl:with-param name="elems" select="key($k,$nr)"/>
            <xsl:with-param name="r" select="$r"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="document($constrs,/)">
            <xsl:choose>
              <xsl:when test="key($k,$nr)">
                <xsl:call-template name="absref">
                  <xsl:with-param name="elems" select="key($k,$nr)"/>
                  <xsl:with-param name="r" select="$r"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="document($dcoconstrs,/)">
                  <xsl:call-template name="absref">
                    <xsl:with-param name="elems" select="key($k,$nr)"/>
                    <xsl:with-param name="r" select="$r"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- add the @aid and @schemenr attrs to scheme functor or predicate -->
  <!-- must get the element explicitely, resolves by its SchemeBlock -->
  <!-- or Scheme ancestor -->
  <xsl:template name="abs_fp">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="ancestor::SchemeBlock">
          <xsl:for-each select="ancestor::SchemeBlock">
            <xsl:call-template name="getschattrs">
              <xsl:with-param name="nr" select="@schemenr"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="ancestor::Scheme">
            <xsl:variable name="anr1">
              <xsl:choose>
                <xsl:when test="@articlenr">
                  <xsl:value-of select="@articlenr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="n1">
              <xsl:choose>
                <xsl:when test="@nr">
                  <xsl:value-of select="@nr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="1 + count(preceding::*[(name()=&quot;Scheme&quot;)])"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="getschattrs">
              <xsl:with-param name="anr" select="$anr1"/>
              <xsl:with-param name="nr" select="$n1"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- theorem, definition and scheme references -->
  <!-- add the reference's href, $c tells if it is from current article -->
  <xsl:template name="mkref">
    <xsl:param name="aid"/>
    <xsl:param name="nr"/>
    <xsl:param name="k"/>
    <xsl:param name="c"/>
    <xsl:attribute name="kind">
      <xsl:value-of select="$k"/>
    </xsl:attribute>
    <!-- @kind=refkind(#kind=$k); -->
    <xsl:attribute name="aid">
      <xsl:value-of select="$aid"/>
    </xsl:attribute>
    <xsl:attribute name="absnr">
      <xsl:value-of select="$nr"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="getschref">
    <xsl:param name="anr"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$anr&gt;0">
        <xsl:for-each select="document($schms,/)">
          <xsl:for-each select="key(&apos;S&apos;,concat($anr,&apos;:&apos;,$nr))">
            <xsl:call-template name="mkref">
              <xsl:with-param name="aid" select="@aid"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="k">
                <xsl:text>S</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="$aname"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="k">
            <xsl:text>S</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="c">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- insert schemenr and aid attrs for scheme functors, -->
  <!-- possibly change to inst... if #i > 0 -->
  <xsl:template name="mkschattrs">
    <xsl:param name="aid"/>
    <xsl:param name="nr"/>
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="$i&gt;0">
        <xsl:attribute name="instaid">
          <xsl:value-of select="$aid"/>
        </xsl:attribute>
        <xsl:attribute name="instschemenr">
          <xsl:value-of select="$nr"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="aid">
          <xsl:value-of select="$aid"/>
        </xsl:attribute>
        <xsl:attribute name="schemenr">
          <xsl:value-of select="$nr"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getschattrs">
    <xsl:param name="anr"/>
    <xsl:param name="nr"/>
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="$anr&gt;0">
        <xsl:for-each select="document($schms,/)">
          <xsl:for-each select="key(&apos;S&apos;,concat($anr,&apos;:&apos;,$nr))">
            <xsl:call-template name="mkschattrs">
              <xsl:with-param name="aid" select="@aid"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="i" select="$i"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkschattrs">
          <xsl:with-param name="aid" select="$aname"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getref">
    <xsl:param name="k"/>
    <xsl:param name="anr"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$anr&gt;0">
        <xsl:for-each select="document($thms,/)">
          <xsl:for-each select="key($k,concat($anr,&apos;:&apos;,$nr))">
            <xsl:call-template name="mkref">
              <xsl:with-param name="aid" select="@aid"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="k" select="$k"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="$aname"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="c">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- translate constructor kinds to their mizar/mmlquery names -->
  <xsl:template name="mkind">
    <xsl:param name="kind"/>
    <xsl:choose>
      <xsl:when test="$kind = &apos;M&apos;">
        <xsl:text>mode</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;V&apos;">
        <xsl:text>attr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;R&apos;">
        <xsl:text>pred</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;K&apos;">
        <xsl:text>func</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;G&apos;">
        <xsl:text>aggr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;L&apos;">
        <xsl:text>struct</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;U&apos;">
        <xsl:text>sel</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- translate reference kinds to their mizar/mmlquery names -->
  <xsl:template name="refkind">
    <xsl:param name="kind"/>
    <xsl:choose>
      <xsl:when test="$kind = &apos;T&apos;">
        <xsl:text>th</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;D&apos;">
        <xsl:text>def</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;S&apos;">
        <xsl:text>sch</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- add plevel and also @kind, @nr and @aid -->
  <xsl:template match="JustifiedTheorem">
    <xsl:param name="s"/>
    <xsl:variable name="nr1" select="1+count(preceding-sibling::JustifiedTheorem)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="aid">
        <xsl:value-of select="$aname"/>
      </xsl:attribute>
      <xsl:attribute name="kind">
        <xsl:text>T</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="nr">
        <xsl:value-of select="$nr1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="DefTheorem">
    <xsl:param name="s"/>
    <xsl:variable name="nr1" select="1+count(preceding-sibling::DefTheorem)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="aid">
        <xsl:value-of select="$aname"/>
      </xsl:attribute>
      <xsl:attribute name="kind">
        <xsl:text>D</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="nr">
        <xsl:value-of select="$nr1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- add plevel explicitly to items and propositions -->
  <xsl:template match="Conclusion | Assume | Take | Thesis | BlockThesis | 
    Case | Suppose | PerCases | SchemeFuncDecl | SchemePredDecl |
   UnknownCorrCond | Coherence | 
   Compatibility | Consistency | Existence | Uniqueness | 
   Correctness | JustifiedProperty">
    <xsl:param name="s"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- numbering of private funcs and defs -->
  <!-- scheme funcs and preds are numbered by the standard @nr attribute and plevel -->
  <!-- adds the @plevel and @nr and @nr attributes -->
  <xsl:template match="DefFunc">
    <xsl:param name="s"/>
    <xsl:variable name="c" select="1 + count(preceding-sibling::DefFunc)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="privnr">
        <xsl:value-of select="$c"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="DefPred">
    <xsl:param name="s"/>
    <xsl:variable name="c" select="1 + count(preceding-sibling::DefPred)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="privnr">
        <xsl:value-of select="$c"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- numbering of constants -->
  <!-- adds the @plevel and @constnr attributes -->
  <xsl:template match="Let | Given | TakeAsVar | Consider | Set | Reconsider">
    <xsl:param name="s"/>
    <xsl:variable name="c">
      <xsl:call-template name="prevconsts">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="constnr">
        <xsl:value-of select="1 + $c"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="prevconsts">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:value-of select="count(preceding-sibling::Reconsider/*[(name() = &quot;Var&quot;) or 
    (name() = &quot;LocusVar&quot;) or (name() = &quot;Const&quot;) or (name() = &quot;InfConst&quot;) 
    or (name() = &quot;Num&quot;) or (name() = &quot;Func&quot;) or (name() = &quot;PrivFunc&quot;) 
    or (name() = &quot;Fraenkel&quot;) or (name() = &quot;QuaTrm&quot;) or (name() = &quot;It&quot;) 
    or (name() = &quot;Choice&quot;) or (name() = &quot;ErrorTrm&quot;)]) +
     count(preceding-sibling::*[(name() = &quot;Let&quot;) or (name() = &quot;TakeAsVar&quot;) 
     or (name() = &quot;Given&quot;) or (name() = &quot;Consider&quot;) or (name() = &quot;Set&quot;)]/Typ)"/>
    </xsl:for-each>
  </xsl:template>

  <!-- serial numbering of embedded propositions -->
  <!-- adds the @plevel and @propnr  attributes -->
  <xsl:template match="Assume/Proposition | Given/Proposition | Consider/Proposition |
     Reconsider/Proposition | Conclusion/Proposition | PerCases/Proposition |
     Case/Proposition | Suppose/Proposition | 
    JustifiedTheorem/Proposition | DefTheorem/Proposition | 
    UnknownCorrCond/Proposition | Coherence/Proposition | 
    Compatibility/Proposition | Consistency/Proposition | 
    Existence/Proposition | Uniqueness/Proposition | 
    SchemePremises/Proposition | 
    Correctness/Proposition | JustifiedProperty/Proposition">
    <xsl:param name="s"/>
    <xsl:variable name="s0">
      <xsl:call-template name="prevprops">
        <xsl:with-param name="el" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s1" select="1 + $s0 + count(preceding-sibling::Proposition)"/>
    <!-- in this item -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="propnr">
        <xsl:value-of select="$s1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="Conclusion/Now | Conclusion/IterEquality">
    <xsl:param name="s"/>
    <xsl:variable name="p0">
      <xsl:call-template name="prevprops">
        <xsl:with-param name="el" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="p1" select="1 + $p0"/>
    <xsl:variable name="s0">
      <xsl:call-template name="prevblocks">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s1" select="1 + $s0"/>
    <xsl:variable name="s2">
      <xsl:choose>
        <xsl:when test="$s">
          <xsl:value-of select="concat($s,&quot;_&quot;,$s1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="newlevel">
        <xsl:value-of select="$s2"/>
      </xsl:attribute>
      <xsl:attribute name="propnr">
        <xsl:value-of select="$p1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s2"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- lemmas - both proof items and propositions -->
  <xsl:template match=" Proposition">
    <xsl:param name="s"/>
    <xsl:variable name="s0">
      <xsl:call-template name="prevprops">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s1" select="1 + $s0"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="propnr">
        <xsl:value-of select="$s1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match=" Now | IterEquality">
    <xsl:param name="s"/>
    <xsl:variable name="p0">
      <xsl:call-template name="prevprops">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="p1" select="1 + $p0"/>
    <xsl:variable name="s0">
      <xsl:call-template name="prevblocks">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s1" select="1 + $s0"/>
    <xsl:variable name="s2">
      <xsl:choose>
        <xsl:when test="$s">
          <xsl:value-of select="concat($s, &quot;_&quot;, $s1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="newlevel">
        <xsl:value-of select="$s2"/>
      </xsl:attribute>
      <xsl:attribute name="propnr">
        <xsl:value-of select="$p1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s2"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match=" IterStep">
    <xsl:param name="s"/>
    <xsl:variable name="s1" select="1 + count(preceding-sibling::IterStep)"/>
    <!-- in this IterEquality -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="propnr">
        <xsl:value-of select="$s1"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="prevprops">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:value-of select="count(preceding-sibling::*[(name() = &quot;Assume&quot;) or (name() = &quot;Given&quot;) 
	or (name() = &quot;Consider&quot;) or (name() = &quot;Reconsider&quot;) 
	or (name() = &quot;Conclusion&quot;) or (name() = &quot;PerCases&quot;) 
	or (name() = &quot;JustifiedTheorem&quot;) or (name() = &quot;DefTheorem&quot;) 
	or (name() = &quot;Case&quot;) or (name() = &quot;Suppose&quot;) 
	or (name() = &quot;UnknownCorrCond&quot;) or (name() = &quot;Coherence&quot;) 
	or (name() = &quot;Compatibility&quot;) or (name() = &quot;Consistency&quot;) 
	or (name() = &quot;Existence&quot;) or (name() = &quot;Uniqueness&quot;)
	or (name() = &quot;SchemePremises&quot;)
	or (name() = &quot;Correctness&quot;) or (name() = &quot;JustifiedProperty&quot;)]/*[(name() = &quot;Now&quot;) 
	or (name() = &quot;Proposition&quot;) or (name() = &quot;IterEquality&quot;)]) +
     count(preceding-sibling::*[(name() = &quot;Now&quot;) or (name() = &quot;Proposition&quot;) 
	or (name() = &quot;IterEquality&quot;)])"/>
    </xsl:for-each>
  </xsl:template>

  <!-- raise level - Now is handled separately -->
  <!-- adds the @plevel and @newlevel attributes. -->
  <!-- Each Definition, Registration, and IdentifyRegistration inside such blocks create -->
  <!-- their own block to properly number correctness conditions. -->
  <xsl:template match="Proof|CaseBlock|SupposeBlock|PerCasesReasoning|DefinitionBlock|RegistrationBlock|NotationBlock|SchemeBlock|Definition|Registration|IdentifyRegistration|SkippedProof">
    <xsl:param name="s"/>
    <xsl:variable name="s0">
      <xsl:call-template name="prevblocks">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s1" select="1 + $s0"/>
    <xsl:variable name="s2">
      <xsl:choose>
        <xsl:when test="$s">
          <xsl:value-of select="concat($s,&quot;_&quot;,$s1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="plevel">
        <xsl:value-of select="$s"/>
      </xsl:attribute>
      <xsl:attribute name="newlevel">
        <xsl:value-of select="$s2"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s2"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="s"/>
    <xsl:param name="e"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="e" select="$e"/>
      </xsl:apply-templates>
      <xsl:apply-templates>
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="e" select="$e"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- count previous blocks on the same level\ -->
  <!-- IterEquality counts as a block too - reserved for -->
  <!-- propositions created from IterSteps -->
  <xsl:template name="prevblocks">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="parent::*[(name() = &quot;Conclusion&quot;) or (name() = &quot;JustifiedTheorem&quot;)
       or (name() = &quot;UnknownCorrCond&quot;) or (name() = &quot;Coherence&quot;) 
       or (name() = &quot;Compatibility&quot;) or (name() = &quot;Consistency&quot;) 
       or (name() = &quot;Existence&quot;) or (name() = &quot;Uniqueness&quot;)
       or (name() = &quot;Correctness&quot;) or (name() = &quot;JustifiedProperty&quot;)]">
          <xsl:for-each select="parent::*">
            <xsl:value-of select="count(preceding-sibling::*[(name() = &quot;Proof&quot;) or (name() = &quot;Now&quot;) 
	or (name() = &quot;CaseBlock&quot;) or (name() = &quot;SupposeBlock&quot;) or 
	(name() = &quot;PerCasesReasoning&quot;) or (name() = &quot;Definition&quot;) or
	(name() = &quot;Registration&quot;) or (name() = &quot;IterEquality&quot;) or
	(name() = &quot;IdentifyRegistration&quot;) or (name() = &quot;SkippedProof&quot;) or
	(name() = &quot;DefinitionBlock&quot;) or (name() = &quot;RegistrationBlock&quot;) or 
	(name() = &quot;NotationBlock&quot;) or (name() = &quot;SchemeBlock&quot;)]) +
	count(preceding-sibling::*[(name() = &quot;Conclusion&quot;) 
	 or (name() = &quot;JustifiedTheorem&quot;) or (name() = &quot;UnknownCorrCond&quot;) 
	 or (name() = &quot;Coherence&quot;) or (name() = &quot;Compatibility&quot;) 
	 or (name() = &quot;Consistency&quot;) or (name() = &quot;Existence&quot;) 
	 or (name() = &quot;Uniqueness&quot;) or (name() = &quot;Correctness&quot;)
	 or (name() = &quot;JustifiedProperty&quot;)]/*[(name() = &quot;Proof&quot;) or 
	 (name() = &quot;Now&quot;) or (name() = &quot;SkippedProof&quot;) or (name() = &quot;IterEquality&quot;)])"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(preceding-sibling::*[(name() = &quot;Proof&quot;) or (name() = &quot;Now&quot;) 
	or (name() = &quot;CaseBlock&quot;) or (name() = &quot;SupposeBlock&quot;) or 
	(name() = &quot;PerCasesReasoning&quot;) or (name() = &quot;Definition&quot;) or
	(name() = &quot;Registration&quot;) or (name() = &quot;IterEquality&quot;) or
	(name() = &quot;IdentifyRegistration&quot;) or (name() = &quot;SkippedProof&quot;) or
	(name() = &quot;DefinitionBlock&quot;) or (name() = &quot;RegistrationBlock&quot;) or 
	(name() = &quot;NotationBlock&quot;) or (name() = &quot;SchemeBlock&quot;)]) +
         count(preceding-sibling::*[(name() = &quot;Conclusion&quot;) 
	 or (name() = &quot;JustifiedTheorem&quot;) or (name() = &quot;UnknownCorrCond&quot;) 
	 or (name() = &quot;Coherence&quot;) or (name() = &quot;Compatibility&quot;) 
	 or (name() = &quot;Consistency&quot;) or (name() = &quot;Existence&quot;) 
	 or (name() = &quot;Uniqueness&quot;) or (name() = &quot;Correctness&quot;)
	 or (name() = &quot;JustifiedProperty&quot;)]/*[(name() = &quot;Proof&quot;) or 
	 (name() = &quot;Now&quot;) or (name() = &quot;SkippedProof&quot;) or (name() = &quot;IterEquality&quot;)])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
