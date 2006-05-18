<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- TSTP XML solutions to MML Query DLI syntax -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL tstp2dli.xsltxt >tstp2dli.xsl -->
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>

  <xsl:template name="lc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $ucletters, $lcletters)"/>
  </xsl:template>

  <xsl:template name="uc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $lcletters, $ucletters)"/>
  </xsl:template>

  <!-- tpl [tstp] { "Mizar rendering of ATP proof steps:\n"; apply; } -->
  <xsl:template match="formula">
    <xsl:text>A:step </xsl:text>
    <xsl:variable name="nm" select="@name"/>
    <xsl:value-of select="$nm"/>
    <xsl:text>=</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier/variable">
    <xsl:text>$for(</xsl:text>
    <xsl:call-template name="pvar">
      <xsl:with-param name="nm" select="@name"/>
    </xsl:call-template>
    <xsl:text>,$type(HIDDEN:mode 1),</xsl:text>
  </xsl:template>

  <xsl:template match="variable">
    <xsl:call-template name="pvar">
      <xsl:with-param name="nm" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="quantifier[@type=&apos;existential&apos;]">
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="negation|">
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="function|predicate">
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:call-template name="transl_constr">
      <xsl:with-param name="nm" select="@name"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="conjunction">
    <xsl:text>$and(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="disjunction">
    <xsl:text>$not($and(</xsl:text>
    <xsl:call-template name="notlist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>))</xsl:text>
  </xsl:template>

  <xsl:template match="implication">
    <xsl:text>$not($and(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)))</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;equal&apos;]">
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:call-template name="transl_constr">
      <xsl:with-param name="nm">
        <xsl:text>r1_hidden</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;false&apos;]">
    <xsl:text>$not($verum)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;true&apos;]">
    <xsl:text>$verum</xsl:text>
  </xsl:template>

  <xsl:template name="transl_constr">
    <xsl:param name="nm"/>
    <xsl:variable name="pref" select="substring-before($nm,&quot;_&quot;)"/>
    <xsl:choose>
      <xsl:when test="$pref">
        <xsl:variable name="k" select="substring($pref,1,1)"/>
        <xsl:variable name="nr" select="substring($pref,2)"/>
        <!-- test if $nr is digit -->
        <xsl:choose>
          <xsl:when test="$nr &gt;= 0">
            <xsl:variable name="art" select="substring-after($nm,&quot;_&quot;)"/>
            <xsl:call-template name="uc">
              <xsl:with-param name="s" select="$art"/>
            </xsl:call-template>
            <xsl:text>:</xsl:text>
            <xsl:call-template name="mkind">
              <xsl:with-param name="kind" select="$k"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$nr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nm"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pvar">
    <xsl:param name="nm"/>
    <xsl:variable name="l" select="substring($nm,1,1)"/>
    <xsl:variable name="nr" select="substring($nm,2)"/>
    <!-- test if $nr is digit -->
    <xsl:choose>
      <xsl:when test="$nr &gt;= 0">
        <xsl:text>$</xsl:text>
        <xsl:value-of select="$l"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ilist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="notlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:text>$not(</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>)</xsl:text>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="mkind">
    <xsl:param name="kind"/>
    <xsl:choose>
      <xsl:when test="$kind = &apos;m&apos;">
        <xsl:text>mode</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;v&apos;">
        <xsl:text>attr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;r&apos;">
        <xsl:text>pred</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;k&apos;">
        <xsl:text>func</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;g&apos;">
        <xsl:text>aggr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;l&apos;">
        <xsl:text>struct</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;u&apos;">
        <xsl:text>sel</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
