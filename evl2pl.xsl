<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet producing one line -->
  <!-- of MPTP for the .evl file with environ declarations this has to be -->
  <!-- typically postprocesed by a perl script reading recursive -->
  <!-- constructor info from the.sgl file. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL evl2pl.xsltxt >evl2pl.xsl -->
  <!-- Than run e.g. this way: -->
  <!-- xsltproc evl2pl.xsl xboole_0.evl -->
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

  <xsl:template match="/">
    <xsl:apply-templates select="/Environ"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="Environ">
    <xsl:text>theory(</xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@aid"/>
    </xsl:call-template>
    <xsl:text>,[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="Directive"/>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <xsl:template match="Directive">
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
    <xsl:text>([</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="Ident"/>
    </xsl:call-template>
    <xsl:text>])</xsl:text>
  </xsl:template>

  <xsl:template match="Ident">
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
  </xsl:template>

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
</xsl:stylesheet>
