<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <!-- $Revision: 1.1 $ -->
  <!--  -->
  <!-- File: params.xsltxt - html-ization of Mizar XML, top-level parameters -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- The following are user-customizable -->
  <!-- mmlquery address -->
  <xsl:param name="mmlq">
    <xsl:text>http://merak.pb.bialystok.pl/mmlquery/fillin.php?entry=</xsl:text>
  </xsl:param>
  <!-- #mmlq= {"";} -->
  <!-- linking methods: -->
  <!-- "q" - query, everything is linked to mmlquery -->
  <!-- "s" - self, everything is linked to these xml/html files -->
  <!-- "m" - mizaring, current article's constructs are linked to self, -->
  <!-- the rest is linked to mmlquery -->
  <xsl:param name="linking">
    <xsl:text>s</xsl:text>
  </xsl:param>
  <!-- extension for linking - either xml or html -->
  <xsl:param name="ext">
    <xsl:text>html</xsl:text>
  </xsl:param>
  <!-- put titles to links or not -->
  <xsl:param name="titles">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- coloured output or not -->
  <xsl:param name="colored">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- print identifiers (like in JFM) instead of normalized names -->
  <xsl:variable name="print_identifiers">
    <xsl:text>1</xsl:text>
  </xsl:variable>
  <!-- tells whether relative or absolute names are shown -->
  <xsl:param name="relnames">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- link by inferences to ATP solutions rendered by MMLQuery; experimental - off -->
  <!-- 1 - static linking (to pre-generated html) -->
  <!-- 2 - dynamic linking to MML Query (static dli sent to MMLQuery DLI-processor) -->
  <xsl:param name="linkby">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- directory with by ATP solutions in HTML; each article in its own subdir -->
  <xsl:param name="lbydir">
    <xsl:text>_by/</xsl:text>
  </xsl:param>
  <!-- directory with by ATP solutions in DLI; each article in its own subdir -->
  <!-- now whole url for the CGI script -->
  <xsl:param name="lbydliurl">
    <xsl:text>http://lipa.ms.mff.cuni.cz/~urban/xmlmml/html.930/_by_dli/</xsl:text>
  </xsl:param>
  <!-- URL of the DLI-processor CGI -->
  <xsl:param name="lbydlicgi">
    <xsl:text>http://mmlquery.mizar.org/cgi-bin/mmlquery/dli</xsl:text>
  </xsl:param>
  <!-- complete prefix of the DLI-processor CGI request -->
  <xsl:variable name="lbydlicgipref">
    <xsl:value-of select="concat($lbydlicgi,&quot;?url=&quot;,$lbydliurl)"/>
  </xsl:variable>
  <!-- tells if linkage of proof elements is done; default is off -->
  <xsl:param name="proof_links">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- tells if proofs are fetched through AJAX; default is off -->
  <xsl:param name="ajax_proofs">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- tells if only selected items are generated to subdirs; default is off -->
  <xsl:param name="generate_items">
    <xsl:text>0</xsl:text>
  </xsl:param>
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
  <!-- this needs to be set to 1 for processing MML files -->
  <xsl:param name="mml">
    <xsl:choose>
      <xsl:when test="/Article">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- nr. of clusters in Typ -->
  <!-- this is set to 1 for processing MML files -->
  <xsl:param name="cluster_nr">
    <xsl:choose>
      <xsl:when test="$mml = &quot;0&quot;">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- .atr file with imported constructors -->
  <xsl:param name="constrs">
    <xsl:value-of select="concat($anamelc, &apos;.atr&apos;)"/>
  </xsl:param>
  <!-- .eth file with imported theorems -->
  <xsl:param name="thms">
    <xsl:value-of select="concat($anamelc, &apos;.eth&apos;)"/>
  </xsl:param>
  <!-- .esh file with imported schemes -->
  <xsl:param name="schms">
    <xsl:value-of select="concat($anamelc, &apos;.esh&apos;)"/>
  </xsl:param>
  <!-- .eno file with imported patterns -->
  <xsl:param name="patts">
    <xsl:value-of select="concat($anamelc, &apos;.eno&apos;)"/>
  </xsl:param>
  <!-- .frx file with all (both imported and article's) formats -->
  <xsl:param name="formats">
    <xsl:value-of select="concat($anamelc, &apos;.frx&apos;)"/>
  </xsl:param>
  <!-- .dcx file with vocabulary -->
  <xsl:param name="vocs">
    <xsl:value-of select="concat($anamelc, &apos;.dcx&apos;)"/>
  </xsl:param>
  <!-- .idx file with identifier names -->
  <xsl:param name="ids">
    <xsl:value-of select="concat($anamelc, &apos;.idx&apos;)"/>
  </xsl:param>
  <!-- .dfs file with imported definientia -->
  <xsl:param name="dfs">
    <xsl:value-of select="concat($anamelc, &apos;.dfs&apos;)"/>
  </xsl:param>
  <xsl:param name="varcolor">
    <xsl:text>Olive</xsl:text>
  </xsl:param>
  <xsl:param name="constcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="locicolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="schpcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="schfcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="ppcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="pfcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="labcolor">
    <xsl:text>Green</xsl:text>
  </xsl:param>
  <xsl:param name="commentcolor">
    <xsl:text>Red</xsl:text>
  </xsl:param>
  <!-- number of parenthesis colors (see the stylesheet in the bottom) -->
  <xsl:param name="pcolors_nr">
    <xsl:text>6</xsl:text>
  </xsl:param>
  <!-- top level element instead of top-level document, which is hard to -->
  <!-- know -->
  <xsl:param name="top" select="/"/>
  <!-- debugging message -->
  <xsl:param name="dbgmsg">
    <xsl:text>zzzzzzzzz</xsl:text>
  </xsl:param>
</xsl:stylesheet>
