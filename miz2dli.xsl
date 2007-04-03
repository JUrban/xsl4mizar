<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.1 $ -->
  <!--  -->
  <!-- File: miz2dli.xsltxt - stylesheet translating Mizar XML syntax to MML Query DLI syntax -->
  <!--  -->
  <!-- Authors: Josef Urban, ... -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- Mizar XML syntax to MML Query DLI syntax -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL miz2dli.xsltxt > miz2dli.xsl -->
  <xsl:strip-space elements="*"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>
  <!-- this needs to be set to 1 for processing MML prel files -->
  <!-- and to 0 for processing of the original .xml file -->
  <xsl:param name="mml">
    <xsl:text>0</xsl:text>
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
  <!-- which cluster in Typ is used (lower or upper); nontrivial only -->
  <!-- if $cluster_nr = 2 (default in that case is now the first (lower) cluster) -->
  <xsl:param name="which_cluster">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- macros for symbols used by Query (some of them are not used yet) -->
  <xsl:param name="is_s">
    <xsl:text>$is</xsl:text>
  </xsl:param>
  <xsl:param name="for_s">
    <xsl:text>$for</xsl:text>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:text>$not</xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text>$and</xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text>$implies</xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text>$iff</xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text>$or</xsl:text>
  </xsl:param>
  <xsl:param name="srt_s">
    <xsl:text>$type</xsl:text>
  </xsl:param>
  <xsl:param name="frank_s">
    <xsl:text>$fraenkel</xsl:text>
  </xsl:param>
  <!-- put whatever debugging message here -->
  <xsl:param name="fail">
    <xsl:text>$SOMETHINGFAILED</xsl:text>
  </xsl:param>

  <xsl:template name="lc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $ucletters, $lcletters)"/>
  </xsl:template>

  <xsl:template name="uc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $lcletters, $ucletters)"/>
  </xsl:template>

  <!-- :::::::::::::::::::::  Expression stuff ::::::::::::::::::::: -->
  <!-- ##NOTE: the proof level (parameter #pl) is never used so far for Query, -->
  <!-- because Query does not handle proofs yet; since the code is -->
  <!-- just an adaptation of the MPTP code, I left it there - it will -->
  <!-- be useful in the future -->
  <!-- ###TODO: the XML now contains info on the original logical connective -->
  <!-- use them if Query has syntax for them -->
  <!-- #i is nr of the bound variable, 1 by default -->
  <xsl:template match="For">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:variable name="j">
      <xsl:choose>
        <xsl:when test="$i&gt;0">
          <xsl:value-of select="$i + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$for_s"/>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="pvar">
      <xsl:with-param name="nr" select="$j"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$srt_s"/>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="Typ[1]">
      <xsl:with-param name="i" select="$j"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:apply-templates select="*[2]">
      <xsl:with-param name="i" select="$j"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="Not">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$not_s"/>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="And">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$and_s"/>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="PrivPred">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:apply-templates select="*[position() = last()]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Is">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$is_s"/>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[2]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="Verum">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>$VERUM</xsl:text>
  </xsl:template>

  <xsl:template match="ErrorFrm">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>$ERRORFRM</xsl:text>
  </xsl:template>

  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;V&apos;">
        <xsl:value-of select="$is_s"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absc">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@kind=&apos;P&apos;">
            <xsl:call-template name="sch_fpname">
              <xsl:with-param name="k">
                <xsl:text>P</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="schnr" select="@schemenr"/>
              <xsl:with-param name="aid" select="@aid"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="absc">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="count(*)&gt;0">
          <xsl:text>(</xsl:text>
          <xsl:call-template name="ilist">
            <xsl:with-param name="separ">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="*"/>
            <xsl:with-param name="i" select="$i"/>
            <xsl:with-param name="pl" select="$pl"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Terms -->
  <xsl:template match="Var">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="pvar">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="LocusVar">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="ploci">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Const">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="pconst">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Num">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="pnum">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ##GRM: Sch_Func : "f" Number "_" Scheme_Name -->
  <xsl:template match="Func">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;F&apos;">
        <xsl:call-template name="sch_fpname">
          <xsl:with-param name="k">
            <xsl:text>F</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="schnr" select="@schemenr"/>
          <xsl:with-param name="aid" select="@aid"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="absc">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="count(*)&gt;0">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="*"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="PrivFunc">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:apply-templates select="*[position() = 1]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="ErrorTrm">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>$ERRORTRM</xsl:text>
  </xsl:template>

  <xsl:template match="Fraenkel">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:variable name="j">
      <xsl:choose>
        <xsl:when test="$i&gt;0">
          <xsl:value-of select="$i"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$frank_s"/>
    <xsl:text>(</xsl:text>
    <xsl:for-each select="Typ">
      <xsl:text>$var(</xsl:text>
      <xsl:variable name="k" select="$j + position()"/>
      <xsl:call-template name="pvar">
        <xsl:with-param name="nr" select="$k"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select=".">
        <xsl:with-param name="i" select="$k"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:text>)</xsl:text>
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="Typ">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:variable name="l" select="$j + count(Typ)"/>
    <xsl:apply-templates select="*[position() = last() - 1]">
      <xsl:with-param name="i" select="$l"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[position() = last()]">
      <xsl:with-param name="i" select="$l"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- we expect 'L' instead of 'G' (that means addabsrefs preprocessing) -->
  <xsl:template match="Typ">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$srt_s"/>
    <xsl:text>(</xsl:text>
    <xsl:choose>
      <xsl:when test="@kind=&apos;errortyp&apos;">
        <xsl:text>$ERRORTYP</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;L&quot;)">
            <xsl:variable name="adjectives">
              <xsl:value-of select="count(Cluster[$which_cluster]/*)"/>
            </xsl:variable>
            <xsl:if test="$adjectives &gt; 0">
              <xsl:apply-templates select="Cluster[$which_cluster]">
                <xsl:with-param name="i" select="$i"/>
                <xsl:with-param name="pl" select="$pl"/>
              </xsl:apply-templates>
              <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:call-template name="absc">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
            <xsl:if test="count(*) &gt; $cluster_nr ">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="ilist">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="*[position() &gt; $cluster_nr]"/>
                <xsl:with-param name="i" select="$i"/>
                <xsl:with-param name="pl" select="$pl"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="Cluster">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ###TODO: the current Query syntax seems to forget about arguments of adjectives -->
  <xsl:template match="Adjective">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@value=&quot;false&quot;">
        <xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>+</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="absc">
      <xsl:with-param name="el" select="."/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- :::::::::::::::::::::  End of expression stuff ::::::::::::::::::::: -->
  <!-- :::::::::::::::::::::  Top items ::::::::::::::::::::: -->
  <xsl:template match="RCluster">
    <xsl:value-of select="@aid"/>
    <xsl:text>:exreg </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=exreg(</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:text>$cluster</xsl:text>
    <xsl:if test="Cluster/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="Typ"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- ###TODO: not sure how Query deals with the optional Typ specification - now omitted -->
  <xsl:template match="FCluster">
    <xsl:value-of select="@aid"/>
    <xsl:text>:funcreg </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=funcreg(</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:text>$cluster</xsl:text>
    <xsl:if test="Cluster/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="CCluster">
    <xsl:value-of select="@aid"/>
    <xsl:text>:condreg </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=condreg(</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:text>$antecedent</xsl:text>
    <xsl:if test="Cluster[1]/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster[1]"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="Typ"/>
    <xsl:text>$cluster</xsl:text>
    <xsl:if test="Cluster[2]/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster[2]"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[3]"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="IdentifyWithExp">
    <xsl:value-of select="@aid"/>
    <xsl:text>:idreg </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=idreg(</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[position() = last() - 1]"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[position() = last()]"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="JustifiedTheorem|DefTheorem">
    <xsl:value-of select="@aid"/>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="refkind">
      <xsl:with-param name="kind" select="@kind"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=theorem(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="RegistrationBlock">
    <xsl:apply-templates select="IdentifyRegistration/IdentifyWithExp
	| Registration/RCluster
	| Registration/CCluster
	| Registration/FCluster"/>
  </xsl:template>

  <!-- :::::::::::::::::::::  End of top items ::::::::::::::::::::: -->
  <!-- :::::::::::::::::::::  Utilities :::::::::::::::::::::::::: -->
  <!-- ###TODO: constants should use levels when Query deals with proofs -->
  <xsl:template name="pvar">
    <xsl:param name="nr"/>
    <xsl:text>$B </xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <xsl:template name="pconst">
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:text>$C </xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <xsl:template name="ploci">
    <xsl:param name="nr"/>
    <xsl:text>$A </xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <xsl:template name="pnum">
    <xsl:param name="nr"/>
    <xsl:text>$N </xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <!-- absolute constructor names (use $fail for debugging absnrs) -->
  <xsl:template name="absc">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@absnr and @aid">
          <xsl:value-of select="@aid"/>
          <xsl:text>:</xsl:text>
          <xsl:call-template name="mkind">
            <xsl:with-param name="kind" select="@kind"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@absnr"/>
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

  <!-- name of scheme functor (#k='f') or predicate (#k='p') -->
  <!-- ###TODO: the current Query syntax should be changed to contain -->
  <!-- the article name, and the scheme number (to make it absolute -->
  <!-- - see e.g. the commented MPTP syntax) -->
  <xsl:template name="sch_fpname">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="schnr"/>
    <xsl:param name="aid"/>
    <xsl:choose>
      <xsl:when test="$k and $nr and $aid and $schnr">
        <!-- lc(#s=`concat($k,$nr,'_s',$schnr,'_',$aid)`); -->
        <xsl:text>$private functor </xsl:text>
        <xsl:value-of select="$nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="$k"/>
        </xsl:call-template>
        <xsl:value-of select="@nr"/>
        <xsl:value-of select="$fail"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- translate constructor (notation) kinds to their mizar/mmlquery names -->
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
      <xsl:when test="$kind = &apos;F&apos;">
        <xsl:text>private functor</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;P&apos;">
        <xsl:text>private formula</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- translate reference kinds to their mizar/mmlquery names -->
  <xsl:template name="refkind">
    <xsl:param name="kind"/>
    <xsl:choose>
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

  <!-- List utility with additional arg -->
  <xsl:template name="ilist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select=".">
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- print Typ elements in #el as loci -->
  <xsl:template name="loci">
    <xsl:param name="el"/>
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>$loci</xsl:text>
    <xsl:if test="$el">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="$el"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- :::::::::::::::::::::  End of utilities ::::::::::::::::::::: -->
  <!-- :::::::::::::::::::::  Entry to XSL processing :::::::::::::: -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mml=&quot;0&quot;">
        <xsl:for-each select="/Article">
          <!-- ###TODO: add items here when their processing is defined -->
          <xsl:apply-templates select="RegistrationBlock | JustifiedTheorem | DefTheorem"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
