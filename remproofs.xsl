<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet -->
  <!-- rremoving all proof elements from the xml -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL remproofs.xsltxt > remproofs.xsl -->
  <!-- Then e.g.: xsltproc remproofs.xsl ordinal2.xml > remproofs.xml1 -->
  <xsl:output method="xml"/>

  <xsl:template match="Proof"/>

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
