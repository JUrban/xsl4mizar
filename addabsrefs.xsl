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

  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;P&apos;">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="Pred">
          <xsl:call-template name="abs">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Func">
    <xsl:choose>
      <xsl:when test="@kind=&apos;F&apos;">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="Func">
          <xsl:call-template name="abs">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Adjective -->
  <xsl:template match="Adjective">
    <xsl:element name="Adjective">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="abs">
        <xsl:with-param name="k">
          <xsl:text>V</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Types -->
  <xsl:template match="Typ">
    <xsl:element name="Typ">
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
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="From">
    <xsl:element name="From">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="getschref">
        <xsl:with-param name="anr" select="@articlenr"/>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Ref">
    <xsl:choose>
      <xsl:when test="not(@articlenr)">
        <xsl:copy-of select="."/>
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

  <!-- add absolute numbers to these (they are kind-dependent) -->
  <xsl:template match="Theorem|Constructor|Pattern">
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:variable name="k" select="@kind"/>
      <xsl:attribute name="aid">
        <xsl:value-of select="$aname"/>
      </xsl:attribute>
      <xsl:attribute name="nr">
        <xsl:value-of select="1 + count(preceding::*[(name()=$n) and (@kind=$k)])"/>
      </xsl:attribute>
      <xsl:if test="@redefnr &gt; 0">
        <xsl:call-template name="abs">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="@redefnr"/>
          <xsl:with-param name="r">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Scheme|Definiens|RCluster|CCluster|FCluster">
    <xsl:variable name="n" select="name()"/>
    <xsl:element name="{$n}">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="aid">
        <xsl:value-of select="$aname"/>
      </xsl:attribute>
      <xsl:attribute name="nr">
        <xsl:value-of select="1 + count(preceding::*[(name()=$n)])"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Field">
    <xsl:element name="Field">
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="abs">
        <xsl:with-param name="k">
          <xsl:text>U</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- add the constructor href, $r tells if it is from redefinition -->
  <xsl:template name="absref">
    <xsl:param name="elems"/>
    <xsl:param name="r"/>
    <xsl:for-each select="$elems">
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
      <xsl:value-of select="@aid"/>
    </xsl:attribute>
    <xsl:attribute name="absnr">
      <xsl:value-of select="@nr"/>
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

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
