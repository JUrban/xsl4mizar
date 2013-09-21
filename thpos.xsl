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

  <xsl:template match="JustifiedTheorem">
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select="."/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="Proposition[1]/@line"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="Proof">
        <xsl:value-of select="Proof[1]/EndPosition[1]/@line"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="By|From">
            <xsl:value-of select="*[2]/@line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template name="absr">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@nr and @aid and @kind">
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="concat(@kind,@nr,&apos;_&apos;,@aid)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="@kind"/>
          </xsl:call-template>
          <xsl:value-of select="@nr"/>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
