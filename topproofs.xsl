<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet -->
  <!-- printing top proof positions -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL topproofs.xsltxt > topproofs.xsl -->
  <!-- Then e.g.: xsltproc topproofs.xsl ordinal2.parx > ordinal2.tpr -->
  <xsl:output method="text"/>

  <xsl:template match="Proof">
    <xsl:value-of select="@line"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="EndPosition[(position()=last())]/@line"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="EndPosition/@col"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="/">
    <xsl:apply-templates select="//Proof[not((name(..)=&quot;Proof&quot;) or (name(..)=&quot;Now&quot;) or (name(..)=&quot;Hereby&quot;) or (name(..)=&quot;CaseBlock&quot;) or (name(..)=&quot;SupposeBlock&quot;))]"/>
  </xsl:template>
</xsl:stylesheet>
