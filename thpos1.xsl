<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="exsl exsl-str xt" xmlns:exsl="http://exslt.org/common" xmlns:exsl-str="http://exslt.org/strings" xmlns:xt="http://www.jclark.com/xt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet -->
  <!-- rremoving all proof elements from the xml -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL remproofs.xsltxt > remproofs.xsl -->
  <!-- Then e.g.: xsltproc remproofs.xsl ordinal2.xml > remproofs.xml1 -->
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

  <xsl:template match="Proof">
    <xsl:text>proof </xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="EndPosition[1]/@line"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="Now">
    <xsl:text>now </xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="EndPosition[1]/@line"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="IterEquality">
    <xsl:text>itereq </xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="IterStep[position() = last()]/*[(name()=&quot;By&quot;) or (name()=&quot;From&quot;)]/@line"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
</xsl:stylesheet>
