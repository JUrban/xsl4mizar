<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.2 $ -->
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
  <!-- name of current article (upper case) -->
  <xsl:param name="aname">
    <xsl:value-of select="string(/*/@aid)"/>
  </xsl:param>
  <!-- name of current article (lower case) -->
  <xsl:param name="anamelc">
    <xsl:value-of select="translate($aname, $ucletters, $lcletters)"/>
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
  <xsl:key name="F" match="Format" use="@nr"/>
  <xsl:key name="D_G" match="Symbol[@kind=&apos;G&apos;]" use="@nr"/>
  <xsl:key name="D_K" match="Symbol[@kind=&apos;K&apos;]" use="@nr"/>
  <xsl:key name="D_J" match="Symbol[@kind=&apos;J&apos;]" use="@nr"/>
  <xsl:key name="D_L" match="Symbol[@kind=&apos;L&apos;]" use="@nr"/>
  <xsl:key name="D_M" match="Symbol[@kind=&apos;M&apos;]" use="@nr"/>
  <xsl:key name="D_O" match="Symbol[@kind=&apos;O&apos;]" use="@nr"/>
  <xsl:key name="D_R" match="Symbol[@kind=&apos;R&apos;]" use="@nr"/>
  <xsl:key name="D_U" match="Symbol[@kind=&apos;U&apos;]" use="@nr"/>
  <xsl:key name="D_V" match="Symbol[@kind=&apos;V&apos;]" use="@nr"/>
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
  <xsl:param name="prefices_s">
    <xsl:text>$prefices</xsl:text>
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
    <xsl:apply-templates select="Typ[1]">
      <xsl:with-param name="i" select="$j"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>,</xsl:text>
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
              <xsl:value-of select="count(Cluster[position()=$which_cluster]/*)"/>
            </xsl:variable>
            <xsl:if test="$adjectives &gt; 0">
              <xsl:apply-templates select="Cluster[position()=$which_cluster]">
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

  <!-- Cluster = ( Adjective*  ) -->
  <!--  -->
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
  <!-- RCluster = ( ArgTypes, Typ, Cluster, Cluster? ) -->
  <!--  -->
  <!-- the second optional Cluster is after rounding-up -->
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
    <xsl:if test="Cluster[1]/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster[1]"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="Typ"/>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- FCluster = (ArgTypes, Term, Cluster, Cluster?, Typ?) -->
  <!--  -->
  <!-- the second optional Cluster is after rounding-up -->
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
    <xsl:if test="Cluster[1]/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster[1]"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:if test="Typ">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="Typ"/>
    </xsl:if>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- CCluster = (ArgTypes, Cluster, Typ, Cluster, Cluster?) -->
  <!--  -->
  <!-- the last optional Cluster is after rounding-up -->
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
    <xsl:text>,</xsl:text>
    <xsl:text>$cluster</xsl:text>
    <xsl:if test="Cluster[2]/*">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="Cluster[2]"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- IdentifyWithExp = (Typ*, ( (Term, Term) | (Formula, Formula) ) ) -->
  <!--  -->
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

  <!-- JustifiedTheorem = (Proposition, Justification) -->
  <!-- DefTheorem = (Proposition) -->
  <!--  -->
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

  <!-- Scheme blocks are used for declaring the types of second-order -->
  <!-- variables appearing in a scheme, and for its justification. -->
  <!-- This could be a bit unified with Scheme later. -->
  <!-- schemenr is its serial nr in the article, while vid is -->
  <!-- its identifier number. -->
  <!-- SchemeBlock = -->
  <!-- element SchemeBlock { -->
  <!-- attribute schemenr { xsd:integer }, -->
  <!-- attribute vid { xsd:integer }?, -->
  <!-- Position, -->
  <!-- ( SchemeFuncDecl | SchemePredDecl )*, -->
  <!-- element SchemePremises { Proposition* }, -->
  <!-- Proposition, Justification, -->
  <!-- EndPosition -->
  <!-- } -->
  <!--  -->
  <!-- Declaration of a scheme functor, possibly with its identifier number. -->
  <!-- SchemeFuncDecl = -->
  <!-- element SchemeFuncDecl { -->
  <!-- attribute nr { xsd:integer}, -->
  <!-- attribute vid { xsd:integer}?, -->
  <!-- ArgTypes, Typ -->
  <!-- } -->
  <!--  -->
  <!-- ABCMIZ_0:sch 1=scheme(ABCMIZ_0:sch 1,$parameters,$premisses($not($for($B 1,$type(+(FINSET_1:attr 1),HIDDEN:mode 1),$not($private_formula 1($B 1))))),$thesis($not($for($B 1,$type(+(FINSET_1:attr 1),HIDDEN:mode 1),$not($and($private_formula 1($B 1),$for($B 2,$type(HIDDEN:mode 1),$not($and(TARSKI:pred 1($B 2,$B 1),$private_formula 1($B 2),$not(HIDDEN:pred 1($B 2,$B 1))))))))))) -->
  <!--  -->
  <!-- ABCMIZ_0:sch 2=scheme(ABCMIZ_0:sch 2,$parameters($type(-(XBOOLE_0:attr 1),HIDDEN:mode 1),$type(RELSET_1:mode 2($private_functor 1,$private_functor 1))),$premisses($for($B 1,$type(SUBSET_1:mode 1($private_functor 1)),$for($B 2,$type(SUBSET_1:mode 1($private_functor 1)),$not($and(HIDDEN:pred 2(DOMAIN_1:func 1($private_functor 1,$private_functor 1,$B 1,$B 2),$private_functor 2),$not($private_formula 1($B 1,$B 2)))))),$for($B 1,$type(SUBSET_1:mode 1($private_functor 1)),$private_formula 1($B 1,$B 1)),$for($B 1,$type(SUBSET_1:mode 1($private_functor 1)),$for($B 2,$type(SUBSET_1:mode 1($private_functor 1)),$for($B 3,$type(SUBSET_1:mode 1($private_functor 1)),$not($and($private_formula 1($B 1,$B 2),$private_formula 1($B 2,$B 3),$not($private_formula 1($B 1,$B 3)))))))),$thesis($for($B 1,$type(SUBSET_1:mode 1($private_functor 1)),$for($B 2,$type(SUBSET_1:mode 1($private_functor 1)),$not($and(REWRITE1:pred 1($private_functor 2,$B 1,$B 2),$not($private_formula 1($B 1,$B 2)))))))) -->
  <xsl:template match="SchemeBlock">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$aname"/>
    <xsl:text>:</xsl:text>
    <xsl:text>sch</xsl:text>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@schemenr"/>
    <xsl:text>=scheme(</xsl:text>
    <xsl:value-of select="$aname"/>
    <xsl:text>:</xsl:text>
    <xsl:text>sch</xsl:text>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@schemenr"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$parameters</xsl:text>
    <xsl:if test="SchemeFuncDecl">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="SchemeFuncDecl/Typ"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:text>$premisses</xsl:text>
    <xsl:if test="SchemePremises/*">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="SchemePremises/Proposition"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:text>$thesis(</xsl:text>
    <xsl:apply-templates select="Proposition">
      <xsl:with-param name="i"/>
      <xsl:with-param name="pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="RegistrationBlock">
    <xsl:apply-templates select="IdentifyRegistration/IdentifyWithExp
	| Registration/RCluster
	| Registration/CCluster
	| Registration/FCluster"/>
  </xsl:template>

  <xsl:template match="DefinitionBlock">
    <xsl:apply-templates select="Definition/Constructor | Definition/Pattern | Definition/Registration/RCluster"/>
  </xsl:template>

  <!-- Constructor = (Properties? , ArgTypes, StructLoci?, Typ*, Fields?) -->
  <!--  -->
  <xsl:template match="Constructor">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="@aid"/>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="mkind">
      <xsl:with-param name="kind" select="@kind"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=</xsl:text>
    <xsl:call-template name="mkind">
      <xsl:with-param name="kind" select="@kind"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="ArgTypes/Typ"/>
      <xsl:with-param name="us">
        <xsl:text>1</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="locicount" select="count(ArgTypes/Typ)"/>
    <xsl:variable name="typcount" select="count(Typ)"/>
    <xsl:choose>
      <xsl:when test="(@kind=&apos;K&apos;) or (@kind=&apos;U&apos;) or (@kind=&apos;G&apos;) or (@kind=&apos;M&apos;) or (@kind=&apos;V&apos;)">
        <xsl:if test="$locicount &gt; 0">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="Typ[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="(@kind=&apos;L&apos;)">
          <xsl:if test="$locicount &gt; 0">
            <xsl:text>,</xsl:text>
          </xsl:if>
          <xsl:value-of select="$prefices_s"/>
          <xsl:if test="Typ">
            <xsl:text>(</xsl:text>
            <xsl:call-template name="ilist">
              <xsl:with-param name="separ">
                <xsl:text>,</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="elems" select="Typ"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="Properties">
      <xsl:if test="($locicount + $typcount) &gt; 0">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>$properties(</xsl:text>
      <xsl:for-each select="Properties/*">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="name()"/>
        </xsl:call-template>
        <xsl:if test="not(position() = last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- Definiens = ( Typ*, Essentials, %Formula?, DefMeaning ) -->
  <!-- DefMeaning = ( PartialDef* , ( %Formula; | %Term;  )? ) -->
  <!-- PartialDef = (( %Formula; | %Term;  ) %Formula;) -->
  <!--  -->
  <!-- ABCMIZ_0:dfs 1=$definiens($definiendum(ABCMIZ_0:attr 1),$loci($type(ORDERS_2:struct 1)),$visible(1),$assumptions($VERUM),$proper_definiens($is(ORDERS_2:sel 1($A 1),REWRITE1:attr 1))) -->
  <!--  -->
  <!-- SUBSET_1:dfs 1=$definiens($definiendum(SUBSET_1:mode 1),$loci($type(HIDDEN:mode 1),$type(HIDDEN:mode 1)),$visible(1,2),$assumptions($VERUM),$proper_definiens($part(HIDDEN:pred 2($A 2,$A 1),$not($is($A 1,XBOOLE_0:attr 1))),$is($A 2,XBOOLE_0:attr 1))) -->
  <xsl:template match="Definiens">
    <xsl:value-of select="@aid"/>
    <xsl:text>:</xsl:text>
    <xsl:text>dfs </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=</xsl:text>
    <xsl:text>$definiens($definiendum(</xsl:text>
    <xsl:value-of select="@constraid"/>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="mkind">
      <xsl:with-param name="kind" select="@constrkind"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@absconstrnr"/>
    <xsl:text>),</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="Essentials"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$assumptions</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:choose>
      <xsl:when test="not(name(*[position()=last() -1]) = &quot;Essentials&quot;)">
        <xsl:apply-templates select="*[position()=last() -1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>$VERUM</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>$proper_definiens</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:for-each select="DefMeaning/*">
      <xsl:choose>
        <xsl:when test="name()=&quot;PartialDef&quot;">
          <xsl:text>$part</xsl:text>
          <xsl:text>(</xsl:text>
          <xsl:apply-templates select="*[1]"/>
          <xsl:text>,</xsl:text>
          <xsl:apply-templates select="*[2]"/>
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>))
</xsl:text>
  </xsl:template>

  <!-- Pattern = ( Format?, ArgTypes, Visible, Expansion?) -->
  <!--  -->
  <!-- element Pattern { -->
  <!-- attribute kind { 'M' | 'L' | 'V' | 'R' | 'K' | 'U' | 'G' | 'J' }, -->
  <!-- ( attribute nr { xsd:integer }, -->
  <!-- attribute aid { xsd:string } )?, -->
  <!-- ( attribute formatnr { xsd:integer} -->
  <!-- | Format ), -->
  <!-- attribute constrkind { 'M' | 'L' | 'V' | 'R' | 'K' | 'U' | 'G' | 'J' }, -->
  <!-- attribute constrnr { xsd:integer}, -->
  <!-- attribute antonymic { xsd:boolean }?, -->
  <!-- attribute relnr { xsd:integer }?, -->
  <!-- attribute redefnr { xsd:integer }?, -->
  <!-- ArgTypes, -->
  <!-- element Visible { Int*}, -->
  <!-- element Expansion { Typ }? -->
  <!-- } -->
  <!-- ABCMIZ_0:attrnot 1=attrnot(IDEAL_1:vocV 5("Noetherian"),$loci($type(ORDERS_2:struct 1)),$format(0,1),$visible(1),$constructor(ABCMIZ_0:attr 1)) -->
  <!--  -->
  <!-- MCART_1:funcnot 12=funcnot(HIDDEN:vocK 4("[:"),HIDDEN:vocL 4(":]"),$loci($type(HIDDEN:mode 1),$type(HIDDEN:mode 1),$type(SUBSET_1:mode 1(ZFMISC_1:func 1($A 1))),$type(SUBSET_1:mode 1(ZFMISC_1:func 1($A 2)))),$format(0,2),$visible(3,4),$constructor(MCART_1:func 12),$synonym) -->
  <xsl:template match="Pattern">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="@aid"/>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="mkind">
      <xsl:with-param name="kind" select="@kind"/>
    </xsl:call-template>
    <xsl:text>not </xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>=</xsl:text>
    <xsl:call-template name="mkind">
      <xsl:with-param name="kind" select="@kind"/>
    </xsl:call-template>
    <xsl:text>not</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:variable name="fnr" select="@formatnr"/>
    <xsl:call-template name="format_info">
      <xsl:with-param name="fnr1" select="$fnr"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:call-template name="loci">
      <xsl:with-param name="el" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:for-each select="document($formats,/)">
      <xsl:for-each select="key(&apos;F&apos;, $fnr)">
        <xsl:variable name="largnr">
          <xsl:choose>
            <xsl:when test="@leftargnr">
              <xsl:value-of select="@leftargnr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rargnr">
          <xsl:value-of select="@argnr - $largnr"/>
        </xsl:variable>
        <xsl:text>$format(</xsl:text>
        <xsl:value-of select="$largnr"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$rargnr"/>
        <xsl:text>),</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:text>$visible</xsl:text>
    <xsl:if test="Visible/Int">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Visible/Int"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <!-- ###TODO: MML Query now prints construcor even for forgetful functors, but there are none -->
    <xsl:choose>
      <xsl:when test="not(Expansion)">
        <xsl:text>$constructor(</xsl:text>
        <xsl:choose>
          <xsl:when test="@kind = &quot;J&quot;">
            <xsl:value-of select="@aid"/>
            <xsl:text>:</xsl:text>
            <xsl:text>forg</xsl:text>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@nr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@constraid"/>
            <xsl:text>:</xsl:text>
            <xsl:call-template name="mkind">
              <xsl:with-param name="kind" select="@constrkind"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@absconstrnr"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>$abbreviation(</xsl:text>
        <xsl:apply-templates select="Expansion/Typ"/>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@redefnr &gt; 0">
      <xsl:text>,</xsl:text>
      <xsl:choose>
        <xsl:when test="@antonymic = &quot;true&quot;">
          <xsl:text>$antonym</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>$synonym</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <!-- :::::::::::::::::::::  End of top items ::::::::::::::::::::: -->
  <xsl:template match="Essentials">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>$visible</xsl:text>
    <xsl:if test="Int">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Int"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Int">
    <xsl:value-of select="@x"/>
  </xsl:template>

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
        <xsl:text>$private_</xsl:text>
        <xsl:choose>
          <xsl:when test="$k=&quot;F&quot;">
            <xsl:text>functor </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>formula </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
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
      <xsl:when test="$kind = &apos;J&apos;">
        <xsl:text>forg</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;F&apos;">
        <xsl:text>private_functor</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;P&apos;">
        <xsl:text>private_formula</xsl:text>
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
  <!-- if #us=1, prints as a series of locus instead of one loci: -->
  <!-- $locus($A 1,$type(HIDDEN:mode 1)),$locus($A 2,$type(HIDDEN:mode 1)) -->
  <xsl:template name="loci">
    <xsl:param name="el"/>
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:param name="us"/>
    <xsl:choose>
      <xsl:when test="$us=1">
        <xsl:for-each select="$el">
          <xsl:text>$locus(</xsl:text>
          <xsl:call-template name="ploci">
            <xsl:with-param name="nr" select="position()"/>
          </xsl:call-template>
          <xsl:text>,</xsl:text>
          <xsl:apply-templates select=".">
            <xsl:with-param name="i" select="$i"/>
            <xsl:with-param name="pl" select="$pl"/>
          </xsl:apply-templates>
          <xsl:text>)</xsl:text>
          <xsl:if test="not(position()=last())">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ## Format keeps the kind of a given symbol and arities. -->
  <!-- ## For bracket formats (K) this keeps both symbols. -->
  <!-- ## Optionally a nr (of the format) is kept, to which patterns may refer, -->
  <!-- ## This implementation might change in some time. -->
  <!-- Format = -->
  <!-- element Format { -->
  <!-- attribute kind {'G'|'K'|'J'|'L'|'M'|'O'|'R'|'U'|'V'}, -->
  <!-- attribute nr { xsd:integer }?, -->
  <!-- attribute symbolnr { xsd:integer }, -->
  <!-- attribute argnr { xsd:integer }, -->
  <!-- attribute leftargnr { xsd:integer }?, -->
  <!-- attribute rightsymbolnr { xsd:integer }? -->
  <!-- } -->
  <!--  -->
  <!-- element Symbol { -->
  <!-- attribute kind { xsd:string }, -->
  <!-- attribute nr { xsd:integer }, -->
  <!-- attribute name { xsd:integer } -->
  <!-- } -->
  <!--  -->
  <!-- ###TODO: absolute numbering of symbols (is only relative now - needs to be kept -->
  <!-- with additional attributes in .dcx) -->
  <!--  -->
  <!-- MCART_1:funcnot 12=funcnot(HIDDEN:vocK 4("[:"),HIDDEN:vocL 4(":]"),$loci($type(HIDDEN:mode 1),$type(HIDDEN:mode 1),$type(SUBSET_1:mode 1(ZFMISC_1:func 1($A 1))),$type(SUBSET_1:mode 1(ZFMISC_1:func 1($A 2)))),$format(0,2),$visible(3,4),$constructor(MCART_1:func 12),$synonym) -->
  <xsl:template name="format_info">
    <xsl:param name="fnr1"/>
    <xsl:for-each select="document($formats,/)">
      <xsl:choose>
        <xsl:when test="not(key(&apos;F&apos;,$fnr1))">
          <xsl:value-of select="concat($fail,&quot;:&quot;,$fnr1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="key(&apos;F&apos;,$fnr1)">
            <xsl:variable name="snr" select="@symbolnr"/>
            <xsl:variable name="sk1" select="@kind"/>
            <xsl:variable name="sk">
              <xsl:choose>
                <xsl:when test="($sk1=&quot;L&quot;) or ($sk1=&quot;J&quot;)">
                  <xsl:text>G</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$sk1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="dkey" select="concat(&apos;D_&apos;,$sk)"/>
            <xsl:variable name="rsnr">
              <xsl:choose>
                <xsl:when test="$sk=&apos;K&apos;">
                  <xsl:value-of select="@rightsymbolnr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="document($vocs,/)">
              <xsl:choose>
                <xsl:when test="key($dkey,$snr)">
                  <xsl:for-each select="key($dkey,$snr)">
                    <xsl:text>UNKNOWN: voc</xsl:text>
                    <xsl:value-of select="$sk"/>
                    <xsl:text> 1(&quot;</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>&quot;)</xsl:text>
                    <xsl:if test="$rsnr&gt;0">
                      <xsl:text>,UNKNOWN: voc</xsl:text>
                      <xsl:text>L</xsl:text>
                      <xsl:text> 1(&quot;</xsl:text>
                      <xsl:for-each select="key(&apos;D_L&apos;,$rsnr)">
                        <xsl:value-of select="@name"/>
                      </xsl:for-each>
                      <xsl:text>&quot;)</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- try the built-in symbols -->
                <xsl:otherwise>
                  <xsl:text>UNKNOWN: voc</xsl:text>
                  <xsl:value-of select="$sk"/>
                  <xsl:text> 1(&quot;</xsl:text>
                  <xsl:choose>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;M&apos;)">
                      <xsl:text>set</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;R&apos;)">
                      <xsl:text>=</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;K&apos;)">
                      <xsl:text>[</xsl:text>
                      <xsl:text>&quot;)</xsl:text>
                      <xsl:text>,UNKNOWN: voc</xsl:text>
                      <xsl:text>L</xsl:text>
                      <xsl:text> 1(&quot;</xsl:text>
                      <xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;2&apos;) and ($sk=&apos;K&apos;)">
                      <xsl:text>{</xsl:text>
                      <xsl:text>&quot;)</xsl:text>
                      <xsl:text>,UNKNOWN: voc</xsl:text>
                      <xsl:text>L</xsl:text>
                      <xsl:text> 1(&quot;</xsl:text>
                      <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat($fail,&quot;:&quot;,$fnr1)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>&quot;)</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- :::::::::::::::::::::  End of utilities ::::::::::::::::::::: -->
  <!-- :::::::::::::::::::::  Entry to XSL processing :::::::::::::: -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mml=&quot;0&quot;">
        <xsl:for-each select="/Article">
          <!-- ###TODO: add items here when their processing is defined -->
          <xsl:apply-templates select="RegistrationBlock | JustifiedTheorem | DefTheorem | SchemeBlock| DefinitionBlock | Definiens| NotationBlock/Pattern"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
