<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- for displaying MML items -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL foo.xsltxt >foo.xsl -->
  <xsl:output method="html"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>
  <!-- mmlquery address -->
  <xsl:param name="mmlq">
    <xsl:text>http://merak.pb.bialystok.pl/mmlquery/fillin.php?entry=</xsl:text>
  </xsl:param>
  <!-- linking methods: -->
  <!-- "q" - query, everything is linked to mmlquery -->
  <!-- "s" - self, everything is linked to these xml files -->
  <!-- "m" - mizaring, current article's constructs are linked to self, -->
  <!-- the rest is linked to mmlquery -->
  <xsl:param name="linking">
    <xsl:text>q</xsl:text>
  </xsl:param>

  <!-- Formulas -->
  <!-- #i is nr of the bound variable, 1 by default -->
  <xsl:template match="For">
    <xsl:param name="i"/>
    <xsl:text>for B</xsl:text>
    <xsl:choose>
      <xsl:when test="$i">
        <xsl:value-of select="$i"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> being</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> holds </xsl:text>
    <xsl:element name="br"/>
    <xsl:choose>
      <xsl:when test="$i">
        <xsl:apply-templates select="*[2]">
          <xsl:with-param name="i" select="$i+1"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[2]">
          <xsl:with-param name="i">
            <xsl:text>2</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [And/For] { <div {"for B being"; apply[*[1]]; -->
  <!-- " holds "; <div { @class="add";  apply[*[2]]; } } } -->
  <xsl:template match="Not">
    <xsl:param name="i"/>
    <xsl:text>not </xsl:text>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="i" select="$i"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- tpl [And/Not] { if [For] { <div { "not "; apply[*[1]]; } } -->
  <!-- else { "not "; apply[*[1]]; } } -->
  <xsl:template match="And">
    <xsl:param name="i"/>
    <xsl:text>( </xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text> &amp; </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="i" select="$i"/>
    </xsl:call-template>
    <xsl:text> )</xsl:text>
  </xsl:template>

  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;P&apos;">
        <xsl:value-of select="@kind"/>
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:when test="@kind=&apos;V&apos;">
        <xsl:apply-templates select="*[position() = last()]"/>
        <xsl:text> is </xsl:text>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@absnr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@absnr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
        <xsl:text>( </xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="PrivPred">
    <xsl:param name="i"/>
    <xsl:text>S</xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>[ </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="Is">
    <xsl:param name="i"/>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> is </xsl:text>
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <xsl:template match="Verum">
    <xsl:param name="i"/>
    <xsl:text>verum</xsl:text>
  </xsl:template>

  <xsl:template match="ErrorFrm">
    <xsl:param name="i"/>
    <xsl:text>errorfrm</xsl:text>
  </xsl:template>

  <!-- Terms -->
  <xsl:template match="Var">
    <xsl:text>B</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="LocusVar">
    <xsl:text>A</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="FreeVar">
    <xsl:text>X</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Const">
    <xsl:text>C</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="InfConst">
    <xsl:text>D</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Num">
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Func">
    <xsl:choose>
      <xsl:when test="@kind=&apos;F&apos;">
        <xsl:value-of select="@kind"/>
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:when test="@kind=&apos;U&apos;">
        <xsl:text>the </xsl:text>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@absnr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
        <xsl:text> of </xsl:text>
        <xsl:apply-templates select="*[position() = last()]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@absnr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
        <xsl:text>( </xsl:text>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="PrivFunc">
    <xsl:text>H</xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>( </xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="ErrorTrm">
    <xsl:text>errortrm</xsl:text>
  </xsl:template>

  <xsl:template match="Fraenkel">
    <xsl:text>{ </xsl:text>
    <xsl:apply-templates select="*[position() = last() - 1]"/>
    <xsl:if test="count(*)&gt;2">
      <xsl:text> where B is </xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>, B is </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="*[position() &lt; last() - 1]"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text> : </xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text> } </xsl:text>
  </xsl:template>

  <!-- Types -->
  <xsl:template match="Typ">
    <xsl:text> </xsl:text>
    <xsl:if test="count(*)&gt;0">
      <xsl:apply-templates select="*[1]"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;L&quot;)">
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@absnr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
        <xsl:if test="count(*)&gt;1">
          <xsl:text> of </xsl:text>
          <xsl:call-template name="list">
            <xsl:with-param name="separ">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="*[position()&gt;1]"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@kind"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Clusters -->
  <xsl:template match="Cluster">
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text> </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Adjective -->
  <xsl:template match="Adjective">
    <xsl:if test="@value=&quot;false&quot;">
      <xsl:text>non </xsl:text>
    </xsl:if>
    <xsl:call-template name="mkref">
      <xsl:with-param name="aid" select="@aid"/>
      <xsl:with-param name="nr" select="@absnr"/>
      <xsl:with-param name="k">
        <xsl:text>V</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="count(*)&gt;0">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="*"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Registrations -->
  <xsl:template match="RCluster">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>cluster </xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="ErrorCluster">
            <xsl:text>errorcluster</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*[3]"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="*[2]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CCluster">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>cluster </xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="ErrorCluster">
            <xsl:text>errorcluster</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*[2]"/>
            <xsl:text> -&gt; </xsl:text>
            <xsl:apply-templates select="*[4]"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="*[3]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="FCluster">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>cluster </xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="ErrorCluster">
            <xsl:text>errorcluster</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*[2]"/>
            <xsl:text> -&gt; </xsl:text>
            <xsl:apply-templates select="*[3]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Definiens">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>definiens </xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
      <xsl:element name="b">
        <xsl:text>end;</xsl:text>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- List utilities -->
  <xsl:template name="list">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- List utility with additional arg -->
  <xsl:template name="ilist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:param name="i"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select=".">
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- newlined list -->
  <xsl:template name="nlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:element name="br"/>
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:element name="div">
        <xsl:apply-templates select="."/>
        <xsl:if test="not(position()=last())">
          <xsl:value-of select="$separ"/>
        </xsl:if>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <!-- argument list -->
  <xsl:template name="arglist">
    <xsl:param name="separ"/>
    <xsl:param name="letter"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:value-of select="$letter"/>
      <xsl:value-of select="position()"/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- add numbers starting at #j+1 between #sep1 and #sep2 -->
  <xsl:template name="jlist">
    <xsl:param name="j"/>
    <xsl:param name="sep1"/>
    <xsl:param name="sep2"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$sep1"/>
        <xsl:value-of select="$j+position()"/>
        <xsl:value-of select="$sep2"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- theorem, definition and scheme references -->
  <!-- add the reference's href, $c tells if it is from current article -->
  <xsl:template name="mkref">
    <xsl:param name="aid"/>
    <xsl:param name="nr"/>
    <xsl:param name="k"/>
    <xsl:param name="c"/>
    <xsl:variable name="mk">
      <xsl:call-template name="mkind">
        <xsl:with-param name="kind" select="$k"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="a">
      <xsl:choose>
        <xsl:when test="($linking = &apos;q&apos;) or (($linking = &apos;m&apos;) and not($c))">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($mmlq,$aid,&quot;:&quot;,$mk,&quot;.&quot;,$nr)"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="concat($aid,&quot;:&quot;,$mk,&quot;.&quot;,$nr)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:value-of select="concat(translate($aid,$ucletters,$lcletters),
                       &quot;.xml#&quot;,$k,$nr)"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="concat(translate($aid,$ucletters,$lcletters),
                        &quot;:&quot;,$mk,&quot;.&quot;,$nr)"/>
          </xsl:attribute>
          <xsl:if test="$c">
            <xsl:attribute name="target">
              <xsl:text>_self</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$aid"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$mk"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$nr"/>
    </xsl:element>
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

  <!-- processing of imported documents -->
  <xsl:template match="Theorem">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>theorem </xsl:text>
      </xsl:element>
      <xsl:call-template name="mkref">
        <xsl:with-param name="aid" select="@aid"/>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="k" select="@kind"/>
      </xsl:call-template>
      <xsl:element name="br"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Scheme">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>scheme </xsl:text>
      </xsl:element>
      <xsl:call-template name="mkref">
        <xsl:with-param name="aid" select="@aid"/>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="k">
          <xsl:text>S</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="br"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Constructor">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>constructor </xsl:text>
      </xsl:element>
      <xsl:call-template name="mkref">
        <xsl:with-param name="aid" select="@aid"/>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="k" select="@kind"/>
      </xsl:call-template>
      <xsl:element name="br"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="k" select="@kind"/>
        </xsl:call-template>
        <xsl:text>( </xsl:text>
        <xsl:call-template name="arglist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="letter">
            <xsl:text>A</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="ArgTypes/Typ"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        <xsl:if test="(@kind = &apos;M&apos;) or (@kind = &apos;K&apos;) or (@kind= &apos;G&apos;) 
        or (@kind= &apos;U&apos;) or (@kind= &apos;L&apos;)">
          <xsl:text> -&gt; </xsl:text>
          <xsl:call-template name="list">
            <xsl:with-param name="separ">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="Typ"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Pattern">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>pattern</xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Definiens">
    <xsl:element name="div">
      <xsl:element name="b">
        <xsl:text>definiens</xsl:text>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- Default -->
  <xsl:template match="/">
    <xsl:element name="html">
      <!-- output the css defaults for div and p (for indenting) -->
      <xsl:element name="style">
        <xsl:attribute name="type">
          <xsl:text>text/css</xsl:text>
        </xsl:attribute>
        <xsl:text>div { padding: 0 0 0 0; margin: 0 0 0 0; } div.add { padding-left: 3mm; padding-bottom: 0mm;  margin: 0 0 0 0; } p { margin: 0 0 0 0; }</xsl:text>
      </xsl:element>
      <xsl:element name="head">
        <xsl:element name="base">
          <xsl:attribute name="target">
            <xsl:text>mmlquery</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="body">
        <!-- first read the keys for imported stuff -->
        <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
        <!-- apply[document($thms,/)/Theorems/Theorem]; -->
        <!-- apply[document($schms,/)/Schemes/Scheme]; -->
        <!-- then process the whole document -->
        <xsl:for-each select="*/*">
          <xsl:apply-templates select="."/>
          <xsl:element name="br"/>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
