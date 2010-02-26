<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet -->
  <!-- producing one line of text for the .evl file with environ declarations -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL evl2txt.xsltxt >evl2txt.xsl -->
  <!-- Than run e.g. this way: -->
  <!-- xsltproc evl2txt.xsl xboole_0.evl -->
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
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@aid"/>
    </xsl:call-template>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="Directive">
    <xsl:text>(</xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <xsl:template match="Ident">
    <xsl:text> </xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
