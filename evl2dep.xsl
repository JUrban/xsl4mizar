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
    <xsl:text>-dep</xsl:text>
    <xsl:text>: </xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@aid"/>
    </xsl:call-template>
    <xsl:text>.miz</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="Directive">
    <xsl:if test="@name=&quot;Notations&quot; or @name=&quot;Definitions&quot; or @name=&quot;Theorems&quot; or @name=&quot;Schemes&quot; or @name=&quot;Registrations&quot; or @name=&quot;Constructors&quot;">
      <xsl:apply-templates select="Ident"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Ident">
    <xsl:text> </xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@name"/>
    </xsl:call-template>
    <xsl:text>-prel</xsl:text>
  </xsl:template>
</xsl:stylesheet>
