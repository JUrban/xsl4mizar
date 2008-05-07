<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="exsl exsl-str xt" xmlns:exsl="http://exslt.org/common" xmlns:exsl-str="http://exslt.org/strings" xmlns:xt="http://www.jclark.com/xt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.8 $ -->
  <!--  -->
  <!-- File: mizpl.xsltxt - stylesheet translating Mizar XML terms, -->
  <!-- formulas and types to Prolog TSTP-like format. -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- Mizar XML terms, formulas and types to Prolog TSTP-like format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL mizpl.xsltxt >mizpl.xsl -->
  <!-- ##NOTE: TPTP types 'theorem' and 'definition' are wider -->
  <!-- than in Mizar. Mizar 'property' is also exported as -->
  <!-- TPTP 'theorem', and there are various Mizar items -->
  <!-- exported as TPTP 'definition'. Use the 'mptp_info' slot -->
  <!-- to determine the Mizar item kind. -->
  <!--  -->
  <!-- ##TODO: try to replace the exsl stuff by get_parent_level like in miz.xsltxt -->
  <xsl:strip-space elements="*"/>
  <!-- this needs to be set to 1 for processing MML files -->
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
  <!-- include natural deduction explanations (also computes -->
  <!-- the assumptions of each proposition) -->
  <xsl:param name="do_nd">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- symbols, take care, the spaces are sometimes (e.g. for '~') -->
  <!-- needed for correct Prolog parsing -->
  <xsl:param name="not_s">
    <xsl:text>~ </xsl:text>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:text>~ </xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text> &amp; </xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text> =&gt; </xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text> &lt;=&gt; </xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text> | </xsl:text>
  </xsl:param>
  <xsl:param name="srt_s">
    <xsl:text>sort</xsl:text>
  </xsl:param>
  <xsl:param name="frank_s">
    <xsl:text>all</xsl:text>
  </xsl:param>
  <xsl:param name="eq_s">
    <xsl:text> = </xsl:text>
  </xsl:param>
  <xsl:param name="derived_lemma">
    <xsl:text>lemma_conjecture</xsl:text>
  </xsl:param>
  <!-- this will ensure failure of Prolog parsing -->
  <xsl:param name="fail">
    <xsl:text>zzz k l-**)))))))</xsl:text>
  </xsl:param>
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
  <!-- this is for lookup of selectors for Abstractness property -->
  <xsl:key name="G" match="Constructor[@kind=&apos;G&apos;]" use="@nr"/>
  <!-- lookup for local constants -->
  <xsl:key name="C" match="Let|Given|TakeAsVar|Consider|Set|Reconsider" use="@plevel"/>
  <!-- lookup for propositions -->
  <xsl:key name="E" match="Proposition|IterEquality|Now" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <!-- lookup for JustifiedTheorems' propnr (needed in plname) -->
  <xsl:key name="JT" match="/Article/JustifiedTheorem/Proposition" use="@propnr"/>
  <!-- lookup for scheme functors and predicates -->
  <xsl:key name="f" match="SchemeFuncDecl" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <xsl:key name="p" match="SchemePredDecl" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <!-- lookup for private functors and predicates -->
  <xsl:key name="pf" match="DefFunc" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <xsl:key name="pp" match="DefPred" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <!-- name of current article (upper case) -->
  <xsl:param name="aname">
    <xsl:value-of select="string(/*/@aid)"/>
  </xsl:param>
  <!-- name of current article (lower case) -->
  <xsl:param name="anamelc">
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="$aname"/>
    </xsl:call-template>
  </xsl:param>
  <!-- Formulas -->
  <!-- old versions without pretty-printing -->
  <!-- // #i is nr of the bound variable, 1 by default -->
  <!-- // empty list can be after ':' for type 'set' -->
  <!-- tpl [For](#i,#pl,#k) { -->
  <!-- $j = { if [$i>0] { `$i + 1`;} else { "1"; } } -->
  <!-- "!["; pvar(#nr=$j); ": "; apply[Typ[1]](#i=$j,#pl=$pl); "]: "; -->
  <!-- apply[*[2]](#i=$j,#pl=$pl); } -->
  <!-- // need to put brackets around PrivPred here - may contain For -->
  <!-- tpl [Not](#i,#pl) { $not_s; -->
  <!-- if [For|PrivPred] { "("; apply[*[1]](#i=$i,#pl=$pl); ")"; } -->
  <!-- else { apply[*[1]](#i=$i,#pl=$pl); }} -->
  <!-- tpl [And](#i,#pl) { "( "; -->
  <!-- ilist(#separ=$and_s, #elems=`*`, #i=$i,#pl=$pl); " )"; } -->
  <!-- pretty printing for FOF -->
  <xsl:param name="pid_Ex">
    <xsl:text>-1</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Ex_Univ">
    <xsl:text>-2</xsl:text>
  </xsl:param>
  <!-- usually UnivFrmPtr -->
  <xsl:param name="pid_Ex_InnerNot">
    <xsl:text>-3</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Impl">
    <xsl:text>-4</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Impl_And">
    <xsl:text>-5</xsl:text>
  </xsl:param>
  <!-- usually ConjFrmPtr -->
  <xsl:param name="pid_Impl_RightNot">
    <xsl:text>-6</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Iff">
    <xsl:text>-7</xsl:text>
  </xsl:param>
  <!-- usually ConjFrmPtr -->
  <xsl:param name="pid_Or">
    <xsl:text>-8</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Or_And">
    <xsl:text>-9</xsl:text>
  </xsl:param>
  <!-- usually ConjFrmPtr -->
  <xsl:param name="pid_Or_LeftNot">
    <xsl:text>-10</xsl:text>
  </xsl:param>
  <!-- usually NegFrmPtr -->
  <xsl:param name="pid_Or_RightNot">
    <xsl:text>-11</xsl:text>
  </xsl:param>

  <!-- usually NegFrmPtr -->
  <xsl:template name="is_or">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Or) 
        and (*[1][@pid=$pid_Or_And]) and (count(*[1]/*)=2)
	and (*[1]/*[1][@pid=$pid_Or_LeftNot])
	and (*[1]/*[2][@pid=$pid_Or_RightNot])">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="is_impl">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)=2)
	and (*[1]/*[2][@pid=$pid_Impl_RightNot])">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="is_impl1">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;2)
	and (*[1]/*[@pid=$pid_Impl_RightNot])">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="is_impl2">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;=2)
	and (*[1]/*[@pid=$pid_Impl_RightNot])">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="is_equiv">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:variable name="e1">
        <xsl:choose>
          <xsl:when test="(@pid=$pid_Iff) and (count(*)=2)">
            <xsl:variable name="i1">
              <xsl:call-template name="is_impl">
                <xsl:with-param name="el" select="$el/*[1]"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$i1=&quot;1&quot;">
                <xsl:call-template name="is_impl">
                  <xsl:with-param name="el" select="*[2]"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>0</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$e1=&quot;1&quot;">
          <xsl:variable name="res1">
            <xsl:call-template name="are_equal">
              <xsl:with-param name="el1" select="*[1]/*[1]/*[1]"/>
              <xsl:with-param name="el2" select="*[2]/*[1]/*[2]/*[1]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="res2">
            <xsl:call-template name="are_equal">
              <xsl:with-param name="el1" select="*[2]/*[1]/*[1]"/>
              <xsl:with-param name="el2" select="*[1]/*[1]/*[2]/*[1]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="($res1=&quot;1&quot;) and ($res2=&quot;1&quot;)">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$e1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- recursive equality on subnodes and attributes -->
  <xsl:template name="are_equal">
    <xsl:param name="el1"/>
    <xsl:param name="el2"/>
    <xsl:choose>
      <xsl:when test=" not(name($el1)=name($el2)) or not(count($el1/*)=count($el2/*))
	or not(count($el1/@*)=count($el2/@*))">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="s1">
          <xsl:for-each select="$el1/@*">
            <xsl:value-of select="string()"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="s2">
          <xsl:for-each select="$el2/@*">
            <xsl:value-of select="string()"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="not($s1=$s2)">
            <xsl:text>0</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="are_equal_many">
              <xsl:with-param name="els1" select="$el1/*"/>
              <xsl:with-param name="els2" select="$el2/*"/>
              <xsl:with-param name="nr" select="count($el1/*)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="are_equal_many">
    <xsl:param name="els1"/>
    <xsl:param name="els2"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$nr &gt; 0">
        <xsl:variable name="el1" select="$els1[position()=$nr]"/>
        <xsl:variable name="el2" select="$els2[position()=$nr]"/>
        <xsl:variable name="res1">
          <xsl:call-template name="are_equal">
            <xsl:with-param name="el1" select="$el1"/>
            <xsl:with-param name="el2" select="$el2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$res1=&quot;1&quot;">
            <xsl:call-template name="are_equal_many">
              <xsl:with-param name="els1" select="$els1"/>
              <xsl:with-param name="els2" select="$els2"/>
              <xsl:with-param name="nr" select="$nr - 1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #i is nr of the bound variable, 1 by default -->
  <!-- empty list can be after ':' for type 'set' -->
  <xsl:template match="For">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:param name="k"/>
    <xsl:param name="ex"/>
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
    <xsl:choose>
      <xsl:when test="$ex=&quot;1&quot;">
        <xsl:variable name="nm">
          <xsl:value-of select="name(*[2])"/>
        </xsl:variable>
        <xsl:text>?[</xsl:text>
        <xsl:call-template name="pvar">
          <xsl:with-param name="nr" select="$j"/>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="Typ[1]">
          <xsl:with-param name="i" select="$j"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
        <xsl:text>]: </xsl:text>
        <xsl:choose>
          <xsl:when test="$nm = &quot;For&quot;">
            <xsl:apply-templates select="*[2]">
              <xsl:with-param name="i" select="$j"/>
              <xsl:with-param name="ex" select="$ex"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="Not/*[1]">
              <xsl:with-param name="i" select="$j"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>![</xsl:text>
        <xsl:call-template name="pvar">
          <xsl:with-param name="nr" select="$j"/>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="Typ[1]">
          <xsl:with-param name="i" select="$j"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
        <xsl:text>]: </xsl:text>
        <xsl:apply-templates select="*[2]">
          <xsl:with-param name="i" select="$j"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- return 1 if this is a Not-ended sequence of For-s -->
  <xsl:template name="check_for_not">
    <xsl:param name="el"/>
    <xsl:choose>
      <xsl:when test="name($el)=&quot;Not&quot;">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="name($el)=&quot;For&quot;">
            <xsl:call-template name="check_for_not">
              <xsl:with-param name="el" select="$el/*[2]"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- need to put brackets around PrivPred here - may contain For -->
  <xsl:template match="Not">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:variable name="fnb">
      <xsl:choose>
        <xsl:when test="For">
          <xsl:call-template name="check_for_not">
            <xsl:with-param name="el" select="*[1]/*[2]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$fnb=&quot;1&quot;">
        <xsl:apply-templates select="*[1]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pl" select="$pl"/>
          <xsl:with-param name="ex">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="i1">
          <xsl:call-template name="is_impl">
            <xsl:with-param name="el" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$i1=&quot;1&quot;">
            <xsl:text>( </xsl:text>
            <xsl:apply-templates select="*[1]/*[1]">
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
            <xsl:value-of select="$imp_s"/>
            <xsl:apply-templates select="*[1]/*[2]/*[1]">
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
            <xsl:text> )</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="i2">
              <xsl:call-template name="is_or">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$i2=&quot;1&quot;">
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="*[1]/*[1]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pl" select="$pl"/>
                </xsl:apply-templates>
                <xsl:value-of select="$or_s"/>
                <xsl:apply-templates select="*[1]/*[2]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pl" select="$pl"/>
                </xsl:apply-templates>
                <xsl:text> )</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="i3">
                  <xsl:call-template name="is_impl1">
                    <xsl:with-param name="el" select="."/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="($i3=&quot;1&quot;) and (*[1]/*[not(name()=&quot;Not&quot;)]) and (*[1]/Not)">
                    <xsl:text>( ( </xsl:text>
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ" select="$and_s"/>
                      <xsl:with-param name="elems" select="*[1]/*[not(name()=&quot;Not&quot;)]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:call-template>
                    <xsl:text> )</xsl:text>
                    <xsl:value-of select="$imp_s"/>
                    <xsl:text>( </xsl:text>
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ" select="$or_s"/>
                      <xsl:with-param name="elems" select="*[1]/Not/*[1]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:call-template>
                    <xsl:text> ) )</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$not_s"/>
                    <xsl:choose>
                      <xsl:when test="For|PrivPred">
                        <xsl:text>(</xsl:text>
                        <xsl:apply-templates select="*[1]">
                          <xsl:with-param name="i" select="$i"/>
                          <xsl:with-param name="pl" select="$pl"/>
                        </xsl:apply-templates>
                        <xsl:text>)</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="*[1]">
                          <xsl:with-param name="i" select="$i"/>
                          <xsl:with-param name="pl" select="$pl"/>
                        </xsl:apply-templates>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- try for equivalence -->
  <xsl:template match="And">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>( </xsl:text>
    <xsl:variable name="e1">
      <xsl:call-template name="is_equiv">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$e1=&quot;1&quot;">
        <xsl:apply-templates select="*[1]/*[1]/*[1]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
        <xsl:value-of select="$equiv_s"/>
        <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!-- a bit risky? -->
        <xsl:choose>
          <xsl:when test="(@pid=$pid_Iff) and (count(*)=2)">
            <xsl:variable name="i1">
              <xsl:call-template name="is_impl">
                <xsl:with-param name="el" select="*[1]"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$i1=&quot;1&quot;">
                <xsl:apply-templates select="*[1]/*[1]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pl" select="$pl"/>
                </xsl:apply-templates>
                <xsl:value-of select="$equiv_s"/>
                <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pl" select="$pl"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="i2">
                  <xsl:call-template name="is_impl">
                    <xsl:with-param name="el" select="*[2]"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$i2=&quot;1&quot;">
                    <xsl:apply-templates select="*[2]/*[1]/*[2]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:apply-templates>
                    <xsl:value-of select="$equiv_s"/>
                    <xsl:apply-templates select="*[2]/*[1]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ" select="$and_s"/>
                      <xsl:with-param name="elems" select="*"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="ilist">
              <xsl:with-param name="separ" select="$and_s"/>
              <xsl:with-param name="elems" select="*"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> )</xsl:text>
  </xsl:template>

  <!-- here we differ from Mizar and ILF - all 'V' are turned into 'sort' -->
  <!-- ##GRM: Sch_Pred : "p" Number "_" Scheme_Name -->
  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;V&apos;">
        <xsl:value-of select="$srt_s"/>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="*[position() = last()]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absc">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
        <xsl:if test="count(*)&gt;1">
          <xsl:text>(</xsl:text>
          <xsl:call-template name="ilist">
            <xsl:with-param name="separ">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="*[position() &lt; last()]"/>
            <xsl:with-param name="i" select="$i"/>
            <xsl:with-param name="pl" select="$pl"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="(@kind=&apos;R&apos;) and (@absnr=1) and (@aid=&quot;HIDDEN&quot;)">
            <xsl:text>( </xsl:text>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
            <xsl:value-of select="$eq_s"/>
            <xsl:apply-templates select="*[2]">
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
            <xsl:text> )</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="@kind=&apos;P&apos;">
                <xsl:call-template name="abs_fp">
                  <xsl:with-param name="k">
                    <xsl:text>p</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="el" select="."/>
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="PrivPred">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:apply-templates select="*[position() = last()]">
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- empty list can be here - then it can be replaced by 'true' -->
  <xsl:template match="Is">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$srt_s"/>
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
    <xsl:text>$true</xsl:text>
  </xsl:template>

  <xsl:template match="ErrorFrm">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:text>errorfrm</xsl:text>
  </xsl:template>

  <!-- Terms -->
  <!-- #p is the parenthesis count -->
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

  <xsl:template match="FreeVar">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$fail"/>
  </xsl:template>

  <xsl:template match="Const">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="pconst">
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="InfConst">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="$fail"/>
  </xsl:template>

  <xsl:template match="Num">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <!-- ##GRM: Sch_Func : "f" Number "_" Scheme_Name -->
  <xsl:template match="Func">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;F&apos;">
        <xsl:call-template name="abs_fp">
          <xsl:with-param name="k">
            <xsl:text>f</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="el" select="."/>
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
    <xsl:text>errortrm</xsl:text>
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
    <xsl:text>([</xsl:text>
    <xsl:for-each select="Typ">
      <xsl:variable name="k" select="$j + position()"/>
      <xsl:call-template name="pvar">
        <xsl:with-param name="nr" select="$k"/>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select=".">
        <xsl:with-param name="i" select="$k"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>],</xsl:text>
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

  <!-- Types - the list of attributes and radix type in square brackets -->
  <!-- m1_hidden is not printed; we expect 'L' instead of 'G' -->
  <xsl:template match="Typ">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;errortyp&apos;">
        <xsl:text>errortyp</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;L&quot;)">
            <xsl:variable name="radix">
              <xsl:choose>
                <xsl:when test="(@aid = &quot;HIDDEN&quot;) and (@kind=&quot;M&quot;) and (@nr=&quot;1&quot;)">
                  <xsl:text>0</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>1</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="adjectives">
              <xsl:value-of select="count(*[1]/*)"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="($adjectives + $radix) = 0">
                <xsl:text>$true</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="($adjectives + $radix) &gt; 1">
                  <xsl:text>( </xsl:text>
                </xsl:if>
                <xsl:if test="$adjectives &gt; 0">
                  <xsl:apply-templates select="*[1]">
                    <xsl:with-param name="i" select="$i"/>
                    <xsl:with-param name="pl" select="$pl"/>
                  </xsl:apply-templates>
                  <xsl:if test="$radix &gt; 0">
                    <xsl:value-of select="$and_s"/>
                  </xsl:if>
                </xsl:if>
                <xsl:if test="($radix &gt; 0)">
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
                </xsl:if>
                <xsl:if test="($adjectives + $radix) &gt; 1">
                  <xsl:text> )</xsl:text>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Cluster">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ" select="$and_s"/>
      <xsl:with-param name="elems" select="*"/>
      <xsl:with-param name="i" select="$i"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Adjective">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:if test="@value=&quot;false&quot;">
      <xsl:value-of select="$non_s"/>
    </xsl:if>
    <xsl:call-template name="absc">
      <xsl:with-param name="el" select="."/>
    </xsl:call-template>
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

  <xsl:template name="addp">
    <xsl:param name="pl"/>
    <xsl:if test="string-length($pl)&gt;0">
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$pl"/>
    </xsl:if>
  </xsl:template>

  <!-- concat number and level -->
  <xsl:template name="propname">
    <xsl:param name="n"/>
    <xsl:param name="pl"/>
    <xsl:text>e</xsl:text>
    <xsl:value-of select="$n"/>
    <xsl:call-template name="addp">
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="abspropname">
    <xsl:param name="n"/>
    <xsl:param name="pl"/>
    <xsl:call-template name="propname">
      <xsl:with-param name="n" select="$n"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
    <xsl:text>__</xsl:text>
    <xsl:value-of select="$anamelc"/>
  </xsl:template>

  <xsl:template name="lemmaname">
    <xsl:param name="n"/>
    <xsl:text>l</xsl:text>
    <xsl:value-of select="$n"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$anamelc"/>
  </xsl:template>

  <xsl:template name="plname">
    <xsl:param name="n"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="string-length($pl)&gt;0">
        <xsl:call-template name="propname">
          <xsl:with-param name="n" select="$n"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="key(&quot;JT&quot;,$n)">
            <xsl:for-each select="key(&quot;JT&quot;,$n)">
              <xsl:call-template name="absr">
                <xsl:with-param name="el" select=".."/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="lemmaname">
              <xsl:with-param name="n" select="$n"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="thesisname">
    <xsl:param name="n"/>
    <xsl:param name="pl"/>
    <xsl:text>i</xsl:text>
    <xsl:value-of select="$n"/>
    <xsl:call-template name="addp">
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <!-- thesis is usually justified by following thesis, -->
  <!-- and some ND rule (and possibly axiom); -->
  <!-- the corresponding ND item can be -->
  <!-- %Let; | %Conclusion; | %Assume; | %Given; | %Take; | %TakeAsVar; | %Suppose; | %Case; -->
  <!-- for Proofs it immediately precedes the Thesis, while -->
  <!-- for Now it has to be looked up by having the same position -->
  <!-- among skeleton items as the current thesis has among theses -->
  <!-- ##NOTE: this is the same for  Suppose and Case, however for -->
  <!-- PerCases the thesis follows only if not diffuse - we hack it there anyway, -->
  <!-- and avoid its processing here -->
  <xsl:template match="Thesis">
    <xsl:variable name="prec_nm" select="name(preceding-sibling::*[1])"/>
    <xsl:if test="not($prec_nm = &quot;PerCases&quot;)">
      <xsl:variable name="nr" select="1 + count(preceding-sibling::Thesis)"/>
      <xsl:variable name="tname">
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$nr"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>fof(</xsl:text>
      <xsl:value-of select="$tname"/>
      <xsl:text>,thesis,</xsl:text>
      <xsl:apply-templates>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:apply-templates>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$tname"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$nr"/>
      <xsl:text>,[</xsl:text>
      <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
      <xsl:text>],thesis,position(0,0),[])</xsl:text>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="try_nd_inference">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="thes_nr" select="$nr"/>
      </xsl:call-template>
      <xsl:text>]).
</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- no thesis only subblock theses used -->
  <!-- usage of plevel in subblocks (instead of their newlevel) is correct -->
  <xsl:template match="PerCasesReasoning">
    <xsl:for-each select="CaseBlock|SupposeBlock">
      <xsl:variable name="nr" select="position()"/>
      <xsl:variable name="tname">
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$nr"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>fof(</xsl:text>
      <xsl:value-of select="$tname"/>
      <xsl:text>,thesis,</xsl:text>
      <xsl:apply-templates select="BlockThesis/*[position() = last()]">
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:apply-templates>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$tname"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$nr"/>
      <xsl:text>,[</xsl:text>
      <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
      <xsl:text>],thesis,position(0,0),[])</xsl:text>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="try_nd_inference">
        <xsl:with-param name="el" select="BlockThesis/*[position() = last()]"/>
        <xsl:with-param name="thes_nr">
          <xsl:text>0</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- tpl [CaseBlock/BlockThesis|SupposeBlock/BlockThesis] -->
  <!-- { -->
  <!-- $nr    = `1 + count(../../preceding-sibling::Thesis)`; -->
  <!-- $tname = { thesisname(#n = $nr, #pl = `@plevel`); } -->
  <!-- "fof(bl"; $tname; ",blockthesis,"; -->
  <!-- apply(#pl=`@plevel`); -->
  <!-- ",file("; $anamelc; ",bl"; $tname; -->
  <!-- "),[mptp_info("; $nr; ",["; `translate(@plevel,"_",",")`; -->
  <!-- "],thesis,position(0,0),[])"; ","; -->
  <!-- //   try_nd_inference(#el = `.`, #thes_nr = $nr); -->
  <!-- "]).\n"; -->
  <!-- } -->
  <!-- the henkin axioms will be created by MPTP (for each const. separately); -->
  <!-- doing it here would mean that we either have to cheat a bit (just -->
  <!-- imply previous thesis by thenext one, and call it axiom), or instantiate -->
  <!-- or generalize - which is much easier to do in prolog -->
  <xsl:template name="henkin_ax_nm">
    <xsl:param name="cnm"/>
    <xsl:text>dh_</xsl:text>
    <xsl:value-of select="$cnm"/>
  </xsl:template>

  <!-- can be empty string or more than one (separated by commas) -->
  <!-- private for Let, Consider, and Given -->
  <!-- #tpos optionally tells to use only first #tpos Typs -->
  <xsl:template name="get_henkin_axioms">
    <xsl:param name="tpos"/>
    <xsl:variable name="cnr" select="@constnr"/>
    <xsl:variable name="pl" select="@plevel"/>
    <xsl:variable name="pos">
      <xsl:choose>
        <xsl:when test="not($tpos)">
          <xsl:value-of select="count(Typ)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tpos"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="Typ[position() &lt;= $pos]">
      <xsl:variable name="nr" select="$cnr + position() - 1"/>
      <xsl:variable name="nm">
        <xsl:text>c</xsl:text>
        <xsl:value-of select="$nr"/>
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="henkin_ax_nm">
        <xsl:with-param name="cnm" select="$nm"/>
      </xsl:call-template>
      <xsl:if test="not(position() = $pos)">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ###GRM: -->
  <!-- Mizar_ND_Inference = "mizar_nd(" "inference(" Mizar_ND_Rule "," "[" Optional_ND_Info* "]" "," -->
  <!-- "[" Optional_Ref* Optional_NextThesis "]" ")" ")" -->
  <!-- Mizar_ND_Rule = "let" | "consider" | "take" | "assume" | "discharge_asm" | "conclusion" -->
  <!-- | "trivial" | "iterative_eq" | "percases" -->
  <!-- Optional_ND_Info = AssumptionList | DischargeAsmInfo | ThesisExpansions -->
  <!-- list of assumptions under which a formula is valid -->
  <!-- AssumptionList = "assumptions(" "[" References "]" ")" -->
  <!-- list of discharged assumptions used for inferring this formula; -->
  <!-- say "Foo implies Poo" (with assumptions(Asms1)) is justified by discharged(Dis2) -->
  <!-- and "Poo" with assumptions(Asms2), then "Foo" has to be equivalent to /\Dis2, -->
  <!-- and Asms2 has to be subset of Dis2 \/ Asms1 (i.e. ever y assumption of "Poo" is -->
  <!-- either discharged, or also an assumption of "Foo implies Poo") -->
  <!-- DischargeAsmInfo = "discharged(" "[" References "]" ")" -->
  <!-- expansions used to infer this thesis, note that these can only be definitions, -->
  <!-- and they have to appear among the standard inferences too -->
  <!-- ThesisExpansions = "thesis_expansions(" "[" References "]" ")" -->
  <!-- "let": Henkin_Axiom_For_Let: here it is that "for x1 p(x1)" is justified by -->
  <!-- "let c1"; translating to the henkin axiom: -->
  <!-- "p(c1) => for x1 p(x1)" and the next thesis "p(c1)" -->
  <!-- "consider": Henkin_Axiom_For_Consider: here "p(c1)" is justified by -->
  <!-- "ex x1 st p(x1)"; translating to the axiom: -->
  <!-- "(ex x1 st p(x1)) => p(c1)" (note that having Henkin_Axiom_For_Let is enough -->
  <!-- to justify Henkin_Axiom_For_Consider, and vice versa (use negated formulas)) -->
  <!-- "take": no special axiom is needed, since "take" justifies "ex x1 st p(x1)" -->
  <!-- by reference to "p(c1)", which is implicit in ATP systems; no bg should be needed -->
  <!-- "assume": no axiom needed, only check that the fof name is among its AssumptionList -->
  <!-- "discharge_asm": no axiom needed -->
  <!-- "conclusion" : Concluded_Proposition: "p & q" is justified by "thus p;" and next thesis "q"; no bg needed -->
  <!-- "trivial": this is the last thesis, and it must be trivial (i.e. $true) -->
  <!-- "iterative_eq": is justified by conjunction of the iterative steps; note that no background is needed -->
  <!-- "percases": is justified by all the subblocks implications, and the truth of disjucntion of all cases - propositional -->
  <!-- Optional_Ref = Henkin_Axiom_For_Let | Henkin_Axiom_For_Consider | Concluded_Proposition | Iterative_Step -->
  <!-- | CaseThesis -->
  <!-- #thes_nr gives a number of thesis for which this is created -->
  <!-- here we come from the "previous thesis", and look for the -->
  <!-- "next skeleton item" (which justifies the previous thesis) -->
  <xsl:template name="try_nd_inference">
    <xsl:param name="el"/>
    <xsl:param name="thes_nr"/>
    <xsl:variable name="res">
      <xsl:choose>
        <xsl:when test="name($el/..) = &quot;BlockThesis&quot;">
          <xsl:for-each select="$el/../../*[
	    (name()=&quot;Let&quot;) or (name()=&quot;Conclusion&quot;) or (name()=&quot;Assume&quot;) or (name()=&quot;Given&quot;) or 
	    (name()=&quot;Take&quot;) or (name()=&quot;TakeAsVar&quot;) or (name()=&quot;Case&quot;) or (name()=&quot;Suppose&quot;) or 
	    (name()=&quot;PerCasesReasoning&quot;)][$thes_nr + 1]">
            <xsl:call-template name="do_nd">
              <xsl:with-param name="thes_nr" select="$thes_nr"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$el/following-sibling::*[
            (name()=&quot;Let&quot;) or (name()=&quot;Conclusion&quot;) or (name()=&quot;Assume&quot;) or (name()=&quot;Given&quot;) or 
	    (name()=&quot;Take&quot;) or (name()=&quot;TakeAsVar&quot;) or (name()=&quot;Case&quot;) or (name()=&quot;Suppose&quot;) or 
	    (name()=&quot;PerCasesReasoning&quot;)][1]">
            <xsl:call-template name="do_nd">
              <xsl:with-param name="thes_nr" select="$thes_nr"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- if none of above existed, export as trivial (this is the case for last thesis) -->
    <xsl:choose>
      <xsl:when test="substring($res, 1, 8) = &apos;mizar_nd&apos;">
        <xsl:value-of select="$res"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>mizar_nd(</xsl:text>
        <xsl:text>inference(</xsl:text>
        <xsl:text>trivial</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[]</xsl:text>
        <xsl:text>))</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- if this is the last thesis, then the inference is "trivial" -->
  <!-- private for try_nd_inference() -->
  <!-- we look for an expansion in the following thesis (only for PerCasesReasoning for -->
  <!-- the expansion of the thesis following its PerCases item) -->
  <xsl:template name="do_nd">
    <xsl:param name="thes_nr"/>
    <xsl:param name="do_th_exps"/>
    <xsl:text>mizar_nd(</xsl:text>
    <xsl:text>inference(</xsl:text>
    <xsl:variable name="inm" select="name()"/>
    <xsl:variable name="thexps0">
      <xsl:choose>
        <xsl:when test="($inm = &quot;PerCasesReasoning&quot;)">
          <xsl:for-each select="PerCases">
            <xsl:if test="(following-sibling::*[1]/ThesisExpansions/Ref)">
              <xsl:for-each select="following-sibling::*[1]/ThesisExpansions/Ref">
                <xsl:call-template name="refname">
                  <xsl:with-param name="el" select="."/>
                  <xsl:with-param name="pl">
                    <xsl:text/>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="not(position()=last())">
                  <xsl:text>,</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="(following-sibling::*[1]/ThesisExpansions/Ref)">
            <xsl:for-each select="following-sibling::*[1]/ThesisExpansions/Ref">
              <xsl:call-template name="refname">
                <xsl:with-param name="el" select="."/>
                <xsl:with-param name="pl">
                  <xsl:text/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:if test="not(position()=last())">
                <xsl:text>,</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="thexps">
      <xsl:if test="string-length($thexps0) &gt; 0">
        <xsl:value-of select="$thexps0"/>
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="thexps1">
      <xsl:if test="string-length($thexps0) &gt; 0">
        <xsl:text>thesis_expansions([</xsl:text>
        <xsl:value-of select="$thexps0"/>
        <xsl:text>])</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="($inm = &quot;Let&quot;)">
        <xsl:text>let</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:call-template name="get_henkin_axioms"/>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$thes_nr + 1"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="($inm = &quot;Take&quot;) or ($inm = &quot;TakeAsVar&quot;)">
        <xsl:text>take</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$thes_nr + 1"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="($inm = &quot;Assume&quot;) or ($inm = &quot;Case&quot;) or ($inm = &quot;Suppose&quot;)">
        <xsl:text>discharge_asm</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:if test="string-length($thexps1) &gt; 0">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <!-- ###TODO: write this and uncomment! -->
        <!-- get_assumptions(#el = `.`); ","; -->
        <xsl:text>discharged([</xsl:text>
        <xsl:for-each select="Proposition">
          <xsl:call-template name="plname">
            <xsl:with-param name="n" select="@propnr"/>
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:call-template>
          <xsl:if test="not(position() = last())">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>])</xsl:text>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$thes_nr + 1"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="($inm = &quot;Given&quot;)">
        <xsl:text>discharge_asm</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:if test="string-length($thexps1) &gt; 0">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <!-- get_assumptions(#el = `.`); ","; -->
        <xsl:text>discharged([</xsl:text>
        <xsl:for-each select="Proposition[1]">
          <xsl:call-template name="plname">
            <xsl:with-param name="n" select="@propnr"/>
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:text>])</xsl:text>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$thes_nr + 1"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="($inm = &quot;Conclusion&quot;)">
        <xsl:text>conclusion</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:call-template name="plname">
          <xsl:with-param name="n" select="*[1]/@propnr"/>
          <xsl:with-param name="pl" select="*[1]/@plevel"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="thesisname">
          <xsl:with-param name="n" select="$thes_nr + 1"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <!-- ##NOTE: the thesis numbering in PerCasesReasoning is following: -->
      <!-- $thes_nr+1+PCR's plevel: the thesis preceding the whole block (justified by implications, and PerCases) -->
      <!-- 1+PCR's newlevel: the first cases BlockThesis - i.e. implication, justified by discharging -->
      <!-- the first cases' assumptions and its thesis -->
      <!-- ... -->
      <!-- N+PCR's newlevel: the last cases BlockThesis (i.e. implication) -->
      <!-- ##NOTE: the possible ThesisExpansions are now kept at the thesis following -->
      <!-- PerCases -->
      <xsl:when test="($inm = &quot;PerCasesReasoning&quot;)">
        <xsl:text>percases</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps1"/>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$thexps"/>
        <xsl:for-each select="CaseBlock|SupposeBlock">
          <xsl:call-template name="thesisname">
            <xsl:with-param name="n" select="position()"/>
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:call-template>
          <xsl:text>,</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="PerCases/Proposition">
          <xsl:call-template name="plname">
            <xsl:with-param name="n" select="@propnr"/>
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fail"/>
        <xsl:value-of select="$inm"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>))</xsl:text>
  </xsl:template>

  <!-- SchemePremises implies SchemeThesis -->
  <!-- the proof might rather be 'implication intro' - no -->
  <!-- the proof is standard, the premises are printed, because -->
  <!-- we just traverse all propositions. Note the following hacks: -->
  <!-- - scheme functors and preds get empty level (i.e. are defined globally) -->
  <!-- - the scheme gets empty level (i.e. one level up) -->
  <!-- - the scheme's proof is raised too (i.e. one number); on that proof level -->
  <!-- exist only the premises and the thesis (this is standard), the premises are -->
  <!-- treated as assumptions, the thesis as a proved conclusion -->
  <xsl:template match="SchemeBlock">
    <xsl:variable name="sname" select="concat(&apos;s&apos;,@schemenr,&apos;_&apos;,$anamelc)"/>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$sname"/>
    <xsl:text>,theorem,</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:if test="SchemePremises/Proposition">
      <xsl:text>( </xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ" select="$and_s"/>
        <xsl:with-param name="elems" select="SchemePremises/Proposition/*"/>
        <xsl:with-param name="pl" select="@newlevel"/>
      </xsl:call-template>
      <xsl:text> ) </xsl:text>
      <xsl:value-of select="$imp_s"/>
    </xsl:if>
    <xsl:apply-templates select="Proposition/*">
      <xsl:with-param name="pl" select="@newlevel"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$sname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@schemenr"/>
    <xsl:text>,[],</xsl:text>
    <xsl:text>scheme,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:value-of select="@schemenr"/>
    <xsl:text>])</xsl:text>
    <!-- only Proof and SkippedProof -->
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="*[position() = (last() - 1)]"/>
      <xsl:with-param name="pl" select="@newlevel"/>
      <xsl:with-param name="nl" select="@newlevel"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <!-- the ND stuff -->
    <xsl:text>mizar_nd(</xsl:text>
    <xsl:text>inference(</xsl:text>
    <xsl:text>discharge_asm</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>[</xsl:text>
    <!-- ###TODO: write this and uncomment! -->
    <!-- get_assumptions(#el = `.`); ","; -->
    <xsl:text>discharged([</xsl:text>
    <xsl:for-each select="SchemePremises/Proposition">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>])</xsl:text>
    <xsl:text>]</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="plname">
      <xsl:with-param name="n" select="Proposition/@propnr"/>
      <xsl:with-param name="pl" select="Proposition/@plevel"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
    <xsl:text>))</xsl:text>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <!-- SchemePremises implies SchemeThesis -->
  <xsl:template match="Scheme">
    <xsl:variable name="sname">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="concat(&apos;s&apos;,@nr,&apos;_&apos;,@aid)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$sname"/>
    <xsl:text>,theorem,</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:if test="count(*)&gt;2">
      <xsl:text>( </xsl:text>
      <xsl:call-template name="ilist">
        <xsl:with-param name="separ" select="$and_s"/>
        <xsl:with-param name="elems" select="*[position() &gt; 2]"/>
      </xsl:call-template>
      <xsl:text> ) </xsl:text>
      <xsl:value-of select="$imp_s"/>
    </xsl:if>
    <xsl:apply-templates select="*[position()=2]"/>
    <xsl:text>)</xsl:text>
    <xsl:text>,file(</xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@aid"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$sname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>,[],</xsl:text>
    <xsl:text>scheme,position(0,0),[0])]).
</xsl:text>
  </xsl:template>

  <xsl:template match="JustifiedTheorem/Proposition">
    <xsl:text>fof(</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select=".."/>
    </xsl:call-template>
    <xsl:text>,theorem,</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select=".."/>
    </xsl:call-template>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="../@nr"/>
    <xsl:text>,[],</xsl:text>
    <xsl:text>theorem,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="add_mizar_item"/>
    <xsl:text>])</xsl:text>
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="../*[2]"/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <xsl:template match="Theorem">
    <xsl:text>fof(</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select="."/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:variable name="kword">
      <xsl:choose>
        <xsl:when test="@kind=&quot;T&quot;">
          <xsl:text>theorem</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@kind=&quot;D&quot;">
              <xsl:text>definition</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$fail"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$kword"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>,file(</xsl:text>
    <xsl:call-template name="lc">
      <xsl:with-param name="s" select="@aid"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select="."/>
    </xsl:call-template>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:text>,[],</xsl:text>
    <xsl:value-of select="$kword"/>
    <xsl:text>,position(0,0),[0])]).
</xsl:text>
  </xsl:template>

  <!-- ##GRM: Mptp_Info : "mptp_info(" -->
  <!-- Item_Number "," Level "," Item_Kind "," -->
  <!-- Position "," "[" Item_Arguments "]" ")" . -->
  <xsl:template match="DefTheorem/Proposition">
    <xsl:text>fof(</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select=".."/>
    </xsl:call-template>
    <xsl:text>,definition,</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select=".."/>
    </xsl:call-template>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="../@nr"/>
    <xsl:text>,[],</xsl:text>
    <xsl:text>definition,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="add_mizar_item"/>
    <xsl:text>]</xsl:text>
    <xsl:text>)]).
</xsl:text>
  </xsl:template>

  <!-- add the name of the mizar item which introduced the current proposition -->
  <!-- private - assumes that we are inside Proposition, Now, IterEquality: -->
  <!--  -->
  <!-- Assume,Case,Conclusion,Given (expanded as assume and consider),PerCases,Suppose, -->
  <!-- Consider(2 kinds of props),Reconsider, -->
  <!-- DefTheorem,JustifiedTheorem,SchemeBlock,SchemePremises, -->
  <!-- Coherence,Compatibility,Consistency,Correctness,Existence,Uniqueness,UnknownCorrCond, -->
  <!-- JustifiedProperty -->
  <!--  -->
  <!-- additionally, regular statements can have just block parents, Proof, Now, and Article, -->
  <!-- and IterStep (never makes it here) gets iterstep -->
  <!--  -->
  <!-- ##GRM: Mizar_Item: "mizar_item(" Mizar_Item_Name ")" . -->
  <!-- ##GRM: Mizar_Item_Name: -->
  <!-- ##GRM:       "assume" | "case" | "conclusion" | "percases" | "suppose" -->
  <!-- ##GRM:       | "consider_definition" | "consider_justification" | "reconsider" -->
  <!-- ##GRM:       | "deftheorem" | "justifiedtheorem" | "schemethesis" | "schemepremise" -->
  <!-- ##GRM:       | "coherence" | "compatibility" | "consistency" | "correctness" -->
  <!-- ##GRM:       | "existence" | "uniqueness" | "unknowncorrcond" -->
  <!-- ##GRM:       | "unexpectedprop" | "symmetry" | "reflexivity" | "irreflexivity" -->
  <!-- ##GRM:       | "associativity" | "transitivity" | "commutativity" | "connectedness" -->
  <!-- ##GRM:       | "antisymmetry" | "idempotence" | "involutiveness" | "projectivity" | "abstractness" -->
  <!-- ##GRM:       | "auxiliary_lemma" | "iterstep" . -->
  <xsl:template name="add_mizar_item">
    <!-- temporarily commented to compile -->
    <xsl:text>,mizar_item(</xsl:text>
    <xsl:variable name="parent_nm" select="name(..)"/>
    <xsl:choose>
      <xsl:when test="$parent_nm = &quot;SchemeBlock&quot;">
        <xsl:text>schemethesis</xsl:text>
      </xsl:when>
      <xsl:when test="$parent_nm = &quot;SchemePremises&quot;">
        <xsl:text>schemepremise</xsl:text>
      </xsl:when>
      <xsl:when test="$parent_nm = &quot;JustifiedProperty&quot;">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="name(preceding-sibling::*[1])"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$parent_nm = &quot;Consider&quot;">
        <xsl:choose>
          <xsl:when test="preceding-sibling::Typ">
            <xsl:text>consider_definition</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>consider_justification</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$parent_nm = &quot;Given&quot;">
        <!-- "given" is intentionally exported as an "assume" followed by a -->
        <!-- "consider" - it is just a macro (like e.g. "hereby") -->
        <xsl:choose>
          <xsl:when test="preceding-sibling::Typ">
            <xsl:text>consider_definition</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>assume</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="($parent_nm = &quot;Proof&quot;) or ($parent_nm = &quot;Now&quot;) or 
           ($parent_nm = &quot;Article&quot;) or (contains($parent_nm, &quot;Block&quot;))">
        <xsl:text>auxiliary_lemma</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="$parent_nm"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="Proposition">
    <xsl:variable name="pname">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="consider_kind">
      <xsl:choose>
        <xsl:when test="((name(..) = &quot;Consider&quot;) or (name(..) = &quot;Given&quot;))">
          <xsl:choose>
            <xsl:when test="preceding-sibling::Typ">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>2</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>,</xsl:text>
    <xsl:choose>
      <xsl:when test="following-sibling::*[1][name() = &quot;By&quot; or name() = &quot;From&quot; or name() = &quot;Proof&quot;]">
        <xsl:value-of select="$derived_lemma"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$consider_kind = 1">
            <xsl:value-of select="$derived_lemma"/>
          </xsl:when>
          <!-- derived in ND-sense -->
          <xsl:otherwise>
            <xsl:text>assumption</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@propnr"/>
    <xsl:text>,[</xsl:text>
    <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
    <xsl:text>],proposition,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="add_mizar_item"/>
    <xsl:if test="$consider_kind = 2">
      <xsl:text>,</xsl:text>
      <xsl:text>considered_constants([</xsl:text>
      <xsl:variable name="cnr" select="../@constnr"/>
      <xsl:variable name="pl" select="@plevel"/>
      <xsl:for-each select="../Typ">
        <xsl:variable name="pos1" select="position()"/>
        <xsl:variable name="nr" select="$cnr + $pos1 - 1"/>
        <xsl:text>c</xsl:text>
        <xsl:value-of select="$nr"/>
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>])</xsl:text>
    </xsl:if>
    <xsl:text>])</xsl:text>
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="following-sibling::*[1]"/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:if test="$consider_kind = 1">
      <xsl:text>,</xsl:text>
      <xsl:text>mizar_nd(</xsl:text>
      <xsl:text>inference(</xsl:text>
      <xsl:text>consider</xsl:text>
      <xsl:text>,</xsl:text>
      <xsl:text>[]</xsl:text>
      <xsl:text>,</xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:for-each select="..">
        <xsl:call-template name="get_henkin_axioms"/>
      </xsl:for-each>
      <xsl:text>,</xsl:text>
      <xsl:for-each select="../Proposition[1]">
        <xsl:call-template name="plname">
          <xsl:with-param name="n" select="@propnr"/>
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>]))</xsl:text>
    </xsl:if>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <xsl:template match="Now">
    <xsl:variable name="pname">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$derived_lemma"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="BlockThesis/*[position() = last()]">
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@propnr"/>
    <xsl:text>,[</xsl:text>
    <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
    <xsl:text>],proposition,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="add_mizar_item"/>
    <xsl:text>]),</xsl:text>
    <xsl:call-template name="proofinfer">
      <xsl:with-param name="el" select="."/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:call-template name="try_nd_inference">
      <xsl:with-param name="el" select="BlockThesis/*[position() = last()]"/>
      <xsl:with-param name="thes_nr">
        <xsl:text>0</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <xsl:template match="IterEquality">
    <xsl:variable name="pname">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$derived_lemma"/>
    <xsl:text>,</xsl:text>
    <xsl:text>( </xsl:text>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:value-of select="$eq_s"/>
    <xsl:apply-templates select="IterStep[position() = last()]/*[1]">
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text> )</xsl:text>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@propnr"/>
    <xsl:text>,[</xsl:text>
    <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
    <xsl:text>],proposition,position(</xsl:text>
    <xsl:value-of select="@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="add_mizar_item"/>
    <xsl:text>]),</xsl:text>
    <xsl:call-template name="proofinfer">
      <xsl:with-param name="el" select="."/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
    <xsl:text>mizar_nd(</xsl:text>
    <xsl:text>inference(</xsl:text>
    <xsl:text>iterative_eq</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>[]</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="IterStep">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
      <xsl:if test="not(position() = last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
    <xsl:text>))</xsl:text>
    <xsl:text>]).
</xsl:text>
    <xsl:apply-templates select="IterStep"/>
  </xsl:template>

  <!-- ##NOTE: not sure if IterStep should be treated as just auxiliary_lemma, or -->
  <!-- as a special kind of skeleton item, which changes the thesis -->
  <!-- to equality with the next term. So I'll better use iterstep to -->
  <!-- preserve the info for now. -->
  <!-- ##SOLUTION: currently the IterEquality is justified by mizar_proof, and also -->
  <!-- by "mizar_nd(iterative_eq,...", which just contains all the internal -->
  <!-- Iterstep equalities. -->
  <xsl:template match="IterStep">
    <xsl:variable name="pname">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$derived_lemma"/>
    <xsl:text>,</xsl:text>
    <xsl:text>( </xsl:text>
    <xsl:choose>
      <xsl:when test="name(preceding-sibling::*[1])=&quot;IterStep&quot;">
        <xsl:apply-templates select="preceding-sibling::*[1]/*[1]">
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="preceding-sibling::*[1]">
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$eq_s"/>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:apply-templates>
    <xsl:text> )</xsl:text>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@propnr"/>
    <xsl:text>,[</xsl:text>
    <xsl:value-of select="translate(@plevel,&quot;_&quot;,&quot;,&quot;)"/>
    <xsl:text>],proposition,position(</xsl:text>
    <xsl:value-of select="*[2]/@line"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="*[2]/@col"/>
    <xsl:text>),[</xsl:text>
    <xsl:choose>
      <xsl:when test="@nr">
        <xsl:value-of select="@nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,mizar_item(iterstep)</xsl:text>
    <xsl:text>])</xsl:text>
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="*[2]"/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <!-- #nl is only passsed to proofinfer when dealing with schemes; -->
  <!-- it is also used to prevent trying ND for schemes -->
  <xsl:template name="try_inference">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:param name="nl"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="name() = &quot;By&quot;">
          <xsl:text>,</xsl:text>
          <xsl:call-template name="byinfer">
            <xsl:with-param name="el" select="."/>
            <xsl:with-param name="pl" select="$pl"/>
            <xsl:with-param name="prnr" select="$prnr"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="name() = &quot;From&quot;">
              <xsl:text>,</xsl:text>
              <xsl:call-template name="frominfer">
                <xsl:with-param name="el" select="."/>
                <xsl:with-param name="pl" select="$pl"/>
                <xsl:with-param name="prnr" select="$prnr"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="name() = &quot;Proof&quot;">
                  <xsl:text>,</xsl:text>
                  <xsl:call-template name="proofinfer">
                    <xsl:with-param name="el" select="."/>
                    <xsl:with-param name="pl" select="$pl"/>
                    <xsl:with-param name="prnr" select="$prnr"/>
                    <xsl:with-param name="nl" select="$nl"/>
                  </xsl:call-template>
                  <xsl:if test="not($nl)">
                    <xsl:text>,</xsl:text>
                    <xsl:call-template name="try_nd_inference">
                      <xsl:with-param name="el" select="BlockThesis/*[position() = last()]"/>
                      <xsl:with-param name="thes_nr">
                        <xsl:text>0</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="name() = &quot;SkippedProof&quot;">
                    <xsl:text>,</xsl:text>
                    <xsl:call-template name="skippedinfer">
                      <xsl:with-param name="el" select="."/>
                      <xsl:with-param name="pl" select="$pl"/>
                      <xsl:with-param name="prnr" select="$prnr"/>
                    </xsl:call-template>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="skippedinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:text>inference(mizar_skipped_proof,[],[])</xsl:text>
  </xsl:template>

  <!-- ##GRM: By_Inference: "inference(" "mizar_by" "," "[" "]" "," "[" References "]" ")". -->
  <!-- assumes By -->
  <xsl:template name="byinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:text>inference(mizar_by,[</xsl:text>
      <xsl:text>position(</xsl:text>
      <xsl:value-of select="@line"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="@col"/>
      <xsl:text>)],</xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:call-template name="refs">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="pl" select="$pl"/>
        <xsl:with-param name="prnr" select="$prnr"/>
      </xsl:call-template>
      <xsl:text>])</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- handles Refs for From, (possibly linked) By and ThesisExpansions -->
  <!-- ignores possible ThesisExpansions/Pair - each has a Ref added to it -->
  <xsl:template name="refs">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@linked">
          <xsl:choose>
            <xsl:when test="name(..)=&quot;IterStep&quot;">
              <xsl:call-template name="plname">
                <xsl:with-param name="n" select="../../@propnr - 1"/>
                <xsl:with-param name="pl" select="../../@plevel"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$prnr&gt;1">
                  <xsl:call-template name="plname">
                    <xsl:with-param name="n" select="$prnr - 1"/>
                    <xsl:with-param name="pl" select="$pl"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$fail"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="Ref|PolyEval">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="name()=&quot;From&quot;">
            <xsl:call-template name="sch_instname">
              <xsl:with-param name="el" select="."/>
              <xsl:with-param name="pl" select="$pl"/>
              <xsl:with-param name="prnr" select="$prnr"/>
            </xsl:call-template>
            <xsl:if test="Ref|PolyEval">
              <xsl:text>,</xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="Ref">
        <xsl:call-template name="refname">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="PolyEval">
        <xsl:if test="Ref">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:for-each select="PolyEval">
          <xsl:call-template name="polyeval_name">
            <xsl:with-param name="el" select="."/>
            <xsl:with-param name="pl" select="$pl"/>
          </xsl:call-template>
          <xsl:if test="not(position()=last())">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="FuncInstance">
    <xsl:param name="pl"/>
    <xsl:variable name="k" select="@kind"/>
    <xsl:call-template name="sch_fpname">
      <xsl:with-param name="k">
        <xsl:text>f</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="nr" select="@instnr"/>
      <xsl:with-param name="schnr" select="@instschemenr"/>
      <xsl:with-param name="aid" select="@instaid"/>
    </xsl:call-template>
    <xsl:text>/</xsl:text>
    <!-- instantiated to other functor -->
    <xsl:choose>
      <xsl:when test="$k">
        <xsl:choose>
          <xsl:when test="$k=&quot;K&quot;">
            <xsl:call-template name="absc">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$k=&quot;F&quot;">
            <xsl:call-template name="abs_fp">
              <xsl:with-param name="k">
                <xsl:text>f</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$k=&quot;H&quot;">
            <xsl:text>(</xsl:text>
            <xsl:call-template name="priv_def">
              <xsl:with-param name="k">
                <xsl:text>pf</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- instantiated to term -->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="*[1]">
            <xsl:text>([] : </xsl:text>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:apply-templates>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="PredInstance">
    <xsl:param name="pl"/>
    <xsl:variable name="k" select="@kind"/>
    <xsl:call-template name="sch_fpname">
      <xsl:with-param name="k">
        <xsl:text>p</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="nr" select="@instnr"/>
      <xsl:with-param name="schnr" select="@instschemenr"/>
      <xsl:with-param name="aid" select="@instaid"/>
    </xsl:call-template>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="$k=&quot;R&quot;">
        <xsl:call-template name="absc">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$k=&quot;P&quot;">
        <xsl:call-template name="abs_fp">
          <xsl:with-param name="k">
            <xsl:text>p</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$k=&quot;S&quot;">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="priv_def">
          <xsl:with-param name="k">
            <xsl:text>pp</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fail"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="SchemeInstantiation">
    <xsl:param name="pl"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="FuncInstance | PredInstance">
      <xsl:apply-templates select=".">
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- assumes From, introduces a unique name for this scheme instance -->
  <!-- ##GRM: Scheme_Inference : -->
  <!-- "inference(mizar_from,[scheme_instance(" -->
  <!-- Scheme_Instance_Name "," Scheme_Name "," Proposition_Name -->
  <!-- "," Aid "," Scheme_Instantiation ")],[" -->
  <!-- Scheme_Instance_Name [ "," References ] "])" . -->
  <xsl:template name="frominfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:text>inference(mizar_from,[</xsl:text>
      <xsl:text>position(</xsl:text>
      <xsl:value-of select="@line"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="@col"/>
      <xsl:text>),</xsl:text>
      <xsl:text>scheme_instance(</xsl:text>
      <xsl:call-template name="sch_instname">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="pl" select="$pl"/>
        <xsl:with-param name="prnr" select="$prnr"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absr">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="$prnr"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="SchemeInstantiation">
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:text>)],[</xsl:text>
      <xsl:call-template name="refs">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="pl" select="$pl"/>
        <xsl:with-param name="prnr" select="$prnr"/>
      </xsl:call-template>
      <xsl:text>])</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- ###TODO: finish the description!! -->
  <!-- assumes Proof, Now or IterEquality, -->
  <!-- selects all references (no matter what their level is) used for -->
  <!-- justifying anything inside the proof (so e.g. assumption, which -->
  <!-- is never used to justify anything willnot be listed). This is a -->
  <!-- bit arbitrary choice, because in computing background theory for -->
  <!-- a given proof, this is not sufficient for getting a complete -->
  <!-- symbol set (all formulas inside the proof have to be collected anyway). -->
  <!-- Another options would be to encode just the Mizar ND proof's -->
  <!-- last inference (e.g. "universal intro", if the proof starts with "let"), -->
  <!-- or to encode only the formulas on the child level. -->
  <!-- ##GRM: Proof_Inference : -->
  <!-- "inference(mizar_proof,[proof_level(" Level ")], -->
  <!-- [ References ] ")" . -->
  <!-- seems that #pl and #prnr are no longer used, only #nl is used to possibly -->
  <!-- override #el's own @newlevel (used for schemes) -->
  <xsl:template name="proofinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:param name="nl"/>
    <xsl:for-each select="$el">
      <xsl:text>inference(mizar_proof,[proof_level([</xsl:text>
      <xsl:choose>
        <xsl:when test="$nl">
          <xsl:value-of select="translate($nl,&quot;_&quot;,&quot;,&quot;)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@newlevel">
              <xsl:value-of select="translate(@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$fail"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>])],[</xsl:text>
      <xsl:for-each select=".//By[((name(preceding-sibling::*[1])=&quot;Proposition&quot;) 
	              or (name(..)=&quot;IterStep&quot;))
	            and ((@linked=&quot;true&quot;) or (count(Ref)&gt;0))] 
	     | .//From[((name(preceding-sibling::*[1])=&quot;Proposition&quot;) 
	                 or (name(..)=&quot;IterStep&quot;))]
             | .//ThesisExpansions[count(Ref)&gt;0]">
        <xsl:choose>
          <xsl:when test="name()=&quot;ThesisExpansions&quot;">
            <xsl:call-template name="refs">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="name(..)=&quot;IterStep&quot;">
                <xsl:call-template name="refs">
                  <xsl:with-param name="el" select="."/>
                  <xsl:with-param name="pl" select="../@plevel"/>
                  <xsl:with-param name="prnr" select="../@propnr"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="refs">
                  <xsl:with-param name="el" select="."/>
                  <xsl:with-param name="pl" select="preceding-sibling::*[1]/@plevel"/>
                  <xsl:with-param name="prnr" select="preceding-sibling::*[1]/@propnr"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>])</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- create name and info for a scheme instance -->
  <xsl:template name="sch_instname">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:call-template name="absr">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>__</xsl:text>
      <xsl:call-template name="abspropname">
        <xsl:with-param name="n" select="$prnr"/>
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- uncomment apply[Proposition] if not used explicit descent -->
  <!-- constant arising from "Given" are treated as if they came from "Consider" -->
  <!-- Let typing is treated as an assumption, the rest of typings are derived, -->
  <!-- in case of Consider (and thus also Given) by an ND argument -->
  <xsl:template match="Let|Given|TakeAsVar|Consider|Set">
    <xsl:variable name="cnr" select="@constnr"/>
    <xsl:variable name="pl" select="@plevel"/>
    <xsl:variable name="rnm">
      <xsl:choose>
        <xsl:when test="name() = &quot;Given&quot;">
          <xsl:text>consider</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="name()"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="Typ">
      <xsl:variable name="pos1" select="position()"/>
      <xsl:variable name="nr" select="$cnr + $pos1 - 1"/>
      <xsl:variable name="nm">
        <xsl:text>c</xsl:text>
        <xsl:value-of select="$nr"/>
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="levl">
        <xsl:text>,[</xsl:text>
        <xsl:value-of select="translate($pl,&quot;_&quot;,&quot;,&quot;)"/>
        <xsl:text>],</xsl:text>
      </xsl:variable>
      <xsl:text>fof(dt_</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,</xsl:text>
      <xsl:choose>
        <xsl:when test="$rnm = &quot;let&quot;">
          <xsl:text>assumption</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$derived_lemma"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$srt_s"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select=".">
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:text>)</xsl:text>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$nr"/>
      <xsl:value-of select="$levl"/>
      <xsl:text>constant,position(0,0),[</xsl:text>
      <xsl:value-of select="$rnm"/>
      <xsl:text>,type])</xsl:text>
      <xsl:choose>
        <xsl:when test="($rnm = &quot;takeasvar&quot;) or ($rnm = &quot;set&quot;)">
          <xsl:text>,</xsl:text>
          <xsl:text>inference(mizar_by,[</xsl:text>
          <xsl:value-of select="$rnm"/>
          <xsl:text>],[de_</xsl:text>
          <xsl:value-of select="$nm"/>
          <xsl:text>])</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="($rnm = &quot;consider&quot;)">
            <xsl:text>,</xsl:text>
            <xsl:text>mizar_nd(</xsl:text>
            <xsl:text>inference(</xsl:text>
            <xsl:text>consider</xsl:text>
            <xsl:text>,</xsl:text>
            <xsl:text>[]</xsl:text>
            <xsl:text>,</xsl:text>
            <xsl:text>[</xsl:text>
            <xsl:for-each select="..">
              <xsl:call-template name="get_henkin_axioms">
                <xsl:with-param name="tpos" select="$pos1"/>
              </xsl:call-template>
            </xsl:for-each>
            <xsl:text>,</xsl:text>
            <xsl:for-each select="../Proposition[1]">
              <xsl:call-template name="plname">
                <xsl:with-param name="n" select="@propnr"/>
                <xsl:with-param name="pl" select="@plevel"/>
              </xsl:call-template>
            </xsl:for-each>
            <xsl:text>]))</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>]).
</xsl:text>
      <xsl:if test="($rnm = &quot;takeasvar&quot;) or ($rnm = &quot;set&quot;)">
        <xsl:text>fof(de_</xsl:text>
        <xsl:value-of select="$nm"/>
        <xsl:text>,definition,</xsl:text>
        <xsl:text>( </xsl:text>
        <xsl:value-of select="$nm"/>
        <xsl:value-of select="$eq_s"/>
        <xsl:apply-templates select="../*[not(name() = &quot;Typ&quot;)]">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:apply-templates>
        <xsl:text> )</xsl:text>
        <xsl:text>,file(</xsl:text>
        <xsl:value-of select="$anamelc"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$nm"/>
        <xsl:text>),[mptp_info(</xsl:text>
        <xsl:value-of select="$nr"/>
        <xsl:value-of select="$levl"/>
        <xsl:text>constant,position(0,0),[</xsl:text>
        <xsl:value-of select="$rnm"/>
        <xsl:text>,equality])]).
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- New reconsider has the same type for each term now - this is -->
  <!-- hopefully a compatible way for both new and old. -->
  <!-- The typing is justified by the proposition and the equality def. -->
  <!-- That should be OK for problem creation using mizar_by - the type -->
  <!-- statement will be deleted from the axioms, and the rest of BG are just -->
  <!-- general theorems, nothing specific about the constant. -->
  <xsl:template match="Reconsider">
    <xsl:variable name="cnr" select="@constnr"/>
    <xsl:variable name="pl" select="@plevel"/>
    <xsl:variable name="prop_nm">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="Proposition/@propnr"/>
        <xsl:with-param name="pl" select="Proposition/@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="Var|LocusVar|Const|InfConst|Num|Func|PrivFunc|Fraenkel|
	      QuaTrm|It|ErrorTrm">
      <xsl:variable name="nr" select="$cnr + position() - 1"/>
      <xsl:variable name="nm">
        <xsl:text>c</xsl:text>
        <xsl:value-of select="$nr"/>
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="levl">
        <xsl:text>,[</xsl:text>
        <xsl:value-of select="translate($pl,&quot;_&quot;,&quot;,&quot;)"/>
        <xsl:text>],</xsl:text>
      </xsl:variable>
      <xsl:text>fof(dt_</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$derived_lemma"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$srt_s"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="../Typ[position() = 1]">
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:text>)</xsl:text>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$nr"/>
      <xsl:value-of select="$levl"/>
      <xsl:text>constant,position(0,0),[reconsider,type]),</xsl:text>
      <xsl:text>inference(mizar_by,[reconsider],[de_</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$prop_nm"/>
      <xsl:text>])</xsl:text>
      <xsl:text>]).
</xsl:text>
      <xsl:text>fof(de_</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>,definition,</xsl:text>
      <xsl:text>( </xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:value-of select="$eq_s"/>
      <xsl:apply-templates select=".">
        <xsl:with-param name="pl" select="$pl"/>
      </xsl:apply-templates>
      <xsl:text> )</xsl:text>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$nr"/>
      <xsl:value-of select="$levl"/>
      <xsl:text>constant,position(0,0),[reconsider,equality])]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- The argument types of scheme functors are forgotten by Mizar -->
  <!-- so we do not use them either and use $true. -->
  <!-- The proof level is just [], to be compatible with scheme -->
  <!-- proof level. The scheme to which this belongs is remembered -->
  <!-- instead in the Item_Arguments. -->
  <xsl:template match="SchemeFuncDecl">
    <xsl:variable name="pl" select="@plevel"/>
    <xsl:variable name="schnr" select="../@schemenr"/>
    <!-- $levl = { ",["; `translate($pl,"_",",")`; "],"; } -->
    <xsl:variable name="levl">
      <xsl:text>,[],</xsl:text>
    </xsl:variable>
    <xsl:variable name="sname" select="concat(&apos;s&apos;,$schnr,&apos;_&apos;,$anamelc)"/>
    <!-- $nm   =  { "f"; `@nr`; addp(#pl=$pl); } -->
    <xsl:variable name="nm">
      <xsl:call-template name="sch_fpname">
        <xsl:with-param name="k">
          <xsl:text>f</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="schnr" select="../@schemenr"/>
        <xsl:with-param name="aid" select="$aname"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="l" select="count(ArgTypes/Typ)"/>
    <xsl:text>fof(dt_</xsl:text>
    <xsl:value-of select="$nm"/>
    <xsl:text>,axiom,</xsl:text>
    <xsl:if test="$l &gt; 0">
      <xsl:text>![</xsl:text>
      <xsl:for-each select="ArgTypes/Typ">
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="position()"/>
        </xsl:call-template>
        <xsl:text> : $true</xsl:text>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>]: </xsl:text>
    </xsl:if>
    <xsl:value-of select="$srt_s"/>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$nm"/>
    <xsl:if test="$l &gt; 0">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="Typ">
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:text>,file(</xsl:text>
    <xsl:value-of select="$anamelc"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$nm"/>
    <xsl:text>),[mptp_info(</xsl:text>
    <xsl:value-of select="@nr"/>
    <xsl:value-of select="$levl"/>
    <xsl:text>functor,position(0,0),[scheme,type,</xsl:text>
    <xsl:value-of select="$sname"/>
    <xsl:text>])]).
</xsl:text>
  </xsl:template>

  <!-- "M" | "L" | "V" | "R" | "K" | "U" | "G" -->
  <!-- ###TODO: add the inference, do the properties -->
  <xsl:template match="Constructor">
    <xsl:variable name="lkind">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="@kind"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- the type hierarchy formula for "M" | "L" | "K" | "U" | "G" -->
    <xsl:if test="(@kind=&apos;M&apos;) or (@kind=&apos;L&apos;) or (@kind=&apos;K&apos;) or 
        (@kind=&apos;U&apos;) or (@kind=&apos;G&apos;)">
      <xsl:text>fof(dt_</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$derived_lemma"/>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:variable name="l" select="1 + count(ArgTypes/Typ)"/>
      <xsl:choose>
        <xsl:when test="(@kind=&apos;M&apos;) or (@kind=&apos;L&apos;)">
          <xsl:text>![</xsl:text>
          <xsl:call-template name="ploci">
            <xsl:with-param name="nr" select="$l"/>
          </xsl:call-template>
          <xsl:text> : </xsl:text>
          <xsl:text>$true</xsl:text>
          <xsl:text>]: (</xsl:text>
          <xsl:value-of select="$srt_s"/>
          <xsl:text>(</xsl:text>
          <xsl:call-template name="ploci">
            <xsl:with-param name="nr" select="$l"/>
          </xsl:call-template>
          <xsl:text>,</xsl:text>
          <xsl:call-template name="absc1">
            <xsl:with-param name="el" select="."/>
          </xsl:call-template>
          <xsl:if test="$l &gt; 1">
            <xsl:text>(</xsl:text>
            <xsl:call-template name="arglist">
              <xsl:with-param name="separ">
                <xsl:text>,</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="elems" select="ArgTypes/Typ"/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
          </xsl:if>
          <xsl:text>)</xsl:text>
          <xsl:value-of select="$imp_s"/>
          <xsl:if test="count(Typ) = 0">
            <xsl:value-of select="$srt_s"/>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$l"/>
            </xsl:call-template>
            <xsl:text>,$true)</xsl:text>
          </xsl:if>
          <xsl:if test="count(Typ) &gt; 1">
            <xsl:text>(</xsl:text>
          </xsl:if>
          <xsl:for-each select="Typ">
            <xsl:value-of select="$srt_s"/>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$l"/>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
            <xsl:apply-templates select="."/>
            <xsl:text>)</xsl:text>
            <xsl:if test="not(position()=last())">
              <xsl:value-of select="$and_s"/>
            </xsl:if>
          </xsl:for-each>
          <xsl:if test="count(Typ) &gt; 1">
            <xsl:text>)</xsl:text>
          </xsl:if>
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="(@kind=&apos;K&apos;) or (@kind=&apos;U&apos;) or (@kind=&apos;G&apos;)">
            <xsl:value-of select="$srt_s"/>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="absc1">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
            <xsl:if test="$l &gt; 1">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="arglist">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="ArgTypes/Typ"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>,</xsl:text>
            <xsl:apply-templates select="Typ"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>,file(</xsl:text>
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="@aid"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>,[],</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,position(0,0),[ctype])]).
</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="Properties">
      <xsl:with-param name="el" select="."/>
    </xsl:apply-templates>
    <xsl:if test="@kind=&apos;G&apos;">
      <xsl:call-template name="free_prop">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="(@kind=&apos;M&apos;) or (@kind=&apos;L&apos;)">
      <xsl:call-template name="existence">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@redefnr &gt; 0">
      <xsl:call-template name="redefinition">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="existence">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:variable name="lkind">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@kind"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>fof(existence_</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$derived_lemma"/>
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:variable name="l" select="1 + count(ArgTypes/Typ)"/>
      <xsl:text>? [</xsl:text>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$l"/>
      </xsl:call-template>
      <xsl:text> : </xsl:text>
      <xsl:text>$true</xsl:text>
      <xsl:text>]: </xsl:text>
      <xsl:value-of select="$srt_s"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$l"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:if test="$l &gt; 1">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="arglist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="ArgTypes/Typ"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>)</xsl:text>
      <xsl:text>,file(</xsl:text>
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="@aid"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>,[],</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,position(0,0),[existence])]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- ##GRM: Redef_Info : "redefinition(" Redefined_Constr_Nr "," -->
  <!-- Redefined_Constr_Kind "," Redefined_Constr_Aid "," -->
  <!-- Redefined_Constr_Name ")" . -->
  <xsl:template name="redefinition">
    <xsl:param name="el"/>
    <xsl:variable name="lkind">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@kind"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="redaid">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@redefaid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="absn">
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="$el"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="n" select="$el/@nr"/>
    <xsl:variable name="f">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@aid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="s" select="@superfluous"/>
    <xsl:for-each select="$el">
      <xsl:text>fof(redefinition_</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>,definition,</xsl:text>
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:variable name="l0" select="count(ArgTypes/Typ)"/>
      <xsl:choose>
        <xsl:when test="(@kind = &apos;K&apos;) or (@kind = &apos;R&apos;)">
          <xsl:text>( </xsl:text>
          <xsl:call-template name="absc1">
            <xsl:with-param name="el" select="."/>
          </xsl:call-template>
          <xsl:if test="$l0 &gt; 0">
            <xsl:text>(</xsl:text>
            <xsl:call-template name="arglist">
              <xsl:with-param name="separ">
                <xsl:text>,</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="elems" select="ArgTypes/Typ"/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@kind = &apos;K&apos;">
              <xsl:value-of select="$eq_s"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$equiv_s"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="(@kind=&apos;R&apos;) and (@absredefnr=1) and (@redefaid=&quot;HIDDEN&quot;)">
              <xsl:text>( </xsl:text>
              <xsl:call-template name="ploci">
                <xsl:with-param name="nr" select="$l0 - 1"/>
              </xsl:call-template>
              <xsl:value-of select="$eq_s"/>
              <xsl:call-template name="ploci">
                <xsl:with-param name="nr" select="$l0"/>
              </xsl:call-template>
              <xsl:text> )</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="absredef">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
              <xsl:if test="$l0 &gt; $s">
                <xsl:text>(</xsl:text>
                <xsl:call-template name="arglist">
                  <xsl:with-param name="separ">
                    <xsl:text>,</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="elems" select="ArgTypes/Typ[position() &gt; $s]"/>
                  <xsl:with-param name="s" select="$s"/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="(@kind = &apos;V&apos;) or (@kind = &apos;M&apos;)">
            <xsl:variable name="l">
              <xsl:choose>
                <xsl:when test="@kind = &apos;V&apos;">
                  <xsl:value-of select="$l0"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$l0 + 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="@kind = &apos;M&apos;">
              <xsl:text>![</xsl:text>
              <xsl:call-template name="ploci">
                <xsl:with-param name="nr" select="$l"/>
              </xsl:call-template>
              <xsl:text>: </xsl:text>
              <!-- This is too strong, the original type can hardly get -->
              <!-- the redefinition's result type -->
              <!-- apply[Typ]; -->
              <xsl:text>$true</xsl:text>
              <xsl:text>]: </xsl:text>
            </xsl:if>
            <xsl:text>( </xsl:text>
            <xsl:value-of select="$srt_s"/>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$l"/>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
            <xsl:call-template name="absc1">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
            <xsl:if test="$l&gt;1">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="arglist">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="ArgTypes/Typ[position() &lt; $l]"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>)</xsl:text>
            <xsl:value-of select="$equiv_s"/>
            <xsl:value-of select="$srt_s"/>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$l"/>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
            <xsl:call-template name="absredef">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
            <xsl:if test="($l - $s) &gt; 1">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="arglist">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="ArgTypes/Typ[(position() &gt; $s) 
                                  and (position() &lt; $l)]"/>
                <xsl:with-param name="s" select="$s"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>))</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$f"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$n"/>
      <xsl:text>,[],</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,position(0,0),[redefinition(</xsl:text>
      <xsl:value-of select="@absredefnr"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$redaid"/>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absredef">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>)])]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- free property - this is rather definition than theorem -->
  <!-- g(x1,x2) = g(x3,x4) implies (x1 = x2 and x3 = x4) -->
  <xsl:template name="free_prop">
    <xsl:param name="el"/>
    <xsl:variable name="lkind">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@kind"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="absn">
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="$el"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="n" select="$el/@nr"/>
    <xsl:variable name="f">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@aid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$el">
      <xsl:text>fof(free_</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>,definition,</xsl:text>
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:variable name="s" select="count(ArgTypes/Typ)"/>
      <xsl:text>![</xsl:text>
      <xsl:for-each select="ArgTypes/Typ">
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="position() + $s"/>
        </xsl:call-template>
        <xsl:text> : $true</xsl:text>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>]: </xsl:text>
      <xsl:text>(( </xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$eq_s"/>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
        <xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
      <xsl:text>))</xsl:text>
      <xsl:value-of select="$imp_s"/>
      <xsl:text>( </xsl:text>
      <xsl:for-each select="ArgTypes/Typ">
        <xsl:variable name="p" select="position()"/>
        <xsl:text>( </xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$p"/>
        </xsl:call-template>
        <xsl:value-of select="$eq_s"/>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$p+$s"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        <xsl:if test="not($p=last())">
          <xsl:value-of select="$and_s"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>))</xsl:text>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$f"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$n"/>
      <xsl:text>,[],</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,position(0,0),[property(free)])]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Properties">
    <xsl:param name="el"/>
    <xsl:variable name="a1" select="@propertyarg1"/>
    <xsl:variable name="a2" select="@propertyarg2"/>
    <xsl:variable name="lkind">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@kind"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="absn">
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="$el"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="n" select="$el/@nr"/>
    <xsl:variable name="f">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$el/@aid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="*">
      <xsl:variable name="nm">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="name()"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>fof(</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>,theorem,</xsl:text>
      <xsl:apply-templates select=".">
        <xsl:with-param name="el" select="$el"/>
        <xsl:with-param name="arg1" select="$a1"/>
        <xsl:with-param name="arg2" select="$a2"/>
      </xsl:apply-templates>
      <xsl:text>,file(</xsl:text>
      <xsl:value-of select="$f"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$absn"/>
      <xsl:text>),[mptp_info(</xsl:text>
      <xsl:value-of select="$n"/>
      <xsl:text>,[],</xsl:text>
      <xsl:value-of select="$lkind"/>
      <xsl:text>,position(0,0),[property(</xsl:text>
      <xsl:value-of select="$nm"/>
      <xsl:text>)])]).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="UnexpectedProp">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:text>$true</xsl:text>
  </xsl:template>

  <xsl:template name="symmetry">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:param name="anti"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>( </xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$imp_s"/>
      <xsl:if test="$anti=1">
        <xsl:value-of select="$not_s"/>
      </xsl:if>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="nr2" select="$arg2"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
      </xsl:call-template>
      <xsl:text>))</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Symmetry">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:call-template name="symmetry">
      <xsl:with-param name="el" select="$el"/>
      <xsl:with-param name="arg1" select="$arg1"/>
      <xsl:with-param name="arg2" select="$arg2"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Antisymmetry">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:call-template name="symmetry">
      <xsl:with-param name="el" select="$el"/>
      <xsl:with-param name="arg1" select="$arg1"/>
      <xsl:with-param name="arg2" select="$arg2"/>
      <xsl:with-param name="anti">
        <xsl:text>1</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="reflexivity">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:param name="anti"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:if test="$anti=1">
        <xsl:value-of select="$not_s"/>
      </xsl:if>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="nr2" select="$arg2"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
        <xsl:with-param name="same">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Reflexivity">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:call-template name="reflexivity">
      <xsl:with-param name="el" select="$el"/>
      <xsl:with-param name="arg1" select="$arg1"/>
      <xsl:with-param name="arg2" select="$arg2"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Irreflexivity">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:call-template name="reflexivity">
      <xsl:with-param name="el" select="$el"/>
      <xsl:with-param name="arg1" select="$arg1"/>
      <xsl:with-param name="arg2" select="$arg2"/>
      <xsl:with-param name="anti">
        <xsl:text>1</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Connectedness">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>( </xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$or_s"/>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="nr2" select="$arg2"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
      </xsl:call-template>
      <xsl:text>))</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Commutativity">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>( </xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="arglist">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="ArgTypes/Typ"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$eq_s"/>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="nr2" select="$arg2"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
      </xsl:call-template>
      <xsl:text>))</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Idempotence">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="nr2" select="$arg2"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
        <xsl:with-param name="same">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$eq_s"/>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$arg1"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Involutiveness">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:variable name="trm">
        <xsl:call-template name="absc1">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="arglist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="ArgTypes/Typ"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:variable>
      <xsl:call-template name="argsinsert">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="arg" select="$trm"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$eq_s"/>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$arg1"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Projectivity">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:variable name="trm">
        <xsl:call-template name="absc1">
          <xsl:with-param name="el" select="."/>
        </xsl:call-template>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="arglist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="ArgTypes/Typ"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:variable>
      <xsl:call-template name="argsinsert">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr1" select="$arg1"/>
        <xsl:with-param name="arg" select="$trm"/>
        <xsl:with-param name="lim" select="count(ArgTypes/Typ)"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$eq_s"/>
      <xsl:value-of select="$trm"/>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- This needs fixing for structures "over" - then the -->
  <!-- functor has more args than just the fields! - seems fixed now -->
  <xsl:template match="Abstractness">
    <xsl:param name="el"/>
    <xsl:param name="arg1"/>
    <xsl:param name="arg2"/>
    <xsl:for-each select="$el">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:variable name="l" select="count(ArgTypes/Typ)"/>
      <xsl:variable name="lasttyp" select="ArgTypes/Typ[position() = last()]"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$srt_s"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$l"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="absc1">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
      <xsl:if test="$l &gt; 1">
        <xsl:text>(</xsl:text>
        <xsl:call-template name="arglist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="ArgTypes/Typ[position() &lt; last()]"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>)</xsl:text>
      <xsl:value-of select="$imp_s"/>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="$l"/>
      </xsl:call-template>
      <xsl:value-of select="$eq_s"/>
      <xsl:choose>
        <xsl:when test="key(&apos;G&apos;,$lasttyp/@absnr)">
          <xsl:for-each select="key(&apos;G&apos;,$lasttyp/@absnr)">
            <xsl:call-template name="absc1">
              <xsl:with-param name="el" select="."/>
            </xsl:call-template>
            <xsl:text>(</xsl:text>
            <!-- print the "over" args first -->
            <xsl:if test="$l &gt; 1">
              <xsl:call-template name="ft_list">
                <xsl:with-param name="f">
                  <xsl:text>1</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="t" select="$l - 1"/>
                <xsl:with-param name="sep">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="l">
                  <xsl:text>1</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:for-each select="Fields/Field">
              <xsl:call-template name="absc">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
              <xsl:text>(</xsl:text>
              <!-- the selector might have been defined earlier, without some -->
              <!-- hidden args - $f is the difference in arities -->
              <xsl:variable name="f" select="1 + $l - @arity"/>
              <xsl:call-template name="ft_list">
                <xsl:with-param name="f" select="$f"/>
                <xsl:with-param name="t" select="$l"/>
                <xsl:with-param name="sep">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="l">
                  <xsl:text>1</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
              <xsl:if test="not(position()=last())">
                <xsl:text>,</xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>))</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- tpl [Abstractness](#el,#arg1,#arg2) { for-each [$el] { -->
  <!-- apply[ArgTypes]; -->
  <!-- $l = `count(ArgTypes/Typ)`; -->
  <!-- $lasttyp = `ArgTypes/Typ[position() = last()]`; -->
  <!-- "(";  $srt_s; "("; ploci(#nr=$l); ","; absc1(#el=`.`); -->
  <!-- if [$l > 1] { -->
  <!-- "("; arglist(#separ=",",#elems=`ArgTypes/Typ[position() < last()]`); ")"; -->
  <!-- } -->
  <!-- ")"; $imp_s; "("; ploci(#nr=$l); $eq_s; -->
  <!-- if [key('L',$lasttyp/@absnr)] { -->
  <!-- for-each [key('L',$lasttyp/@absnr)] { -->
  <!-- "g"; `@nr`; "_"; lc(#s=`@aid`); -->
  <!-- "("; -->
  <!-- absref(#elems=`key($k,$nr)`,#r=$r); } -->
  <!-- "("; -->
  <!-- $srt_s; "("; -->
  <!-- apply[*[position() = last()]](#i=$i,#pl=$pl); ","; absc(#el=`.`); -->
  <!-- if [count(*)>1] { -->
  <!-- "("; ilist(#separ=",", #elems=`*[position() < last()]`, #i=$i,#pl=$pl); -->
  <!-- ")"; } -->
  <!-- ")"; } -->
  <xsl:template match="CCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:text>fof(</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>cc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>,theorem,</xsl:text>
        <xsl:variable name="l" select="1 + count(ArgTypes/Typ)"/>
        <xsl:apply-templates select="ArgTypes"/>
        <xsl:text>![</xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$l"/>
        </xsl:call-template>
        <xsl:text> : </xsl:text>
        <xsl:apply-templates select="Typ"/>
        <xsl:text>]: (</xsl:text>
        <xsl:variable name="ante">
          <xsl:value-of select="count(*[2]/*)"/>
        </xsl:variable>
        <xsl:variable name="succ">
          <xsl:value-of select="count(*[4]/*)"/>
        </xsl:variable>
        <xsl:value-of select="$srt_s"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$l"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:choose>
          <xsl:when test="$ante = 0">
            <xsl:text>$true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$ante = 1">
                <xsl:apply-templates select="*[2]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="*[2]"/>
                <xsl:text> )</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
        <xsl:value-of select="$imp_s"/>
        <xsl:value-of select="$srt_s"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$l"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:choose>
          <xsl:when test="$succ = 0">
            <xsl:text>$true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$succ = 1">
                <xsl:apply-templates select="*[4]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="*[4]"/>
                <xsl:text> )</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>))</xsl:text>
        <xsl:text>,file(</xsl:text>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>cc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>),[mptp_info(</xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>,[],ccluster,position(0,0),[</xsl:text>
        <xsl:if test="$mml=&quot;0&quot;">
          <xsl:text>proof_level([</xsl:text>
          <xsl:value-of select="translate(../@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
          <xsl:text>]),</xsl:text>
          <xsl:call-template name="cluster_correctness_conditions">
            <xsl:with-param name="el" select="../*[position() = last()]"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- sufficient proof refs can be collected from its coherence -->
  <!-- (correctness) proof (the corr_conds are therefore written here, -->
  <!-- with the proposition given as argument) -->
  <!-- generalization of the local consts is however needed for small-step -->
  <!-- proof export, and the local consts can be re-used for other clusters -->
  <!-- inside this block; so then their henkin axiom will generally be a conjunction -->
  <!-- ##GRM: Cluster_Info: "proof_level(" Level ")" "," ( Correctness_Info | By_Inference ) . -->
  <!-- ##GRM: Correctness_Info: "correctness_conditions(" "[" Correctness_Proposition+ "]" ")" . -->
  <!-- ##GRM: Correctness_Proposition: Correctness_Condition_Name "(" Proposition_Ref ")" . -->
  <!-- ##GRM: Correctness_Condition_Name: "unknowncorrcond" | "coherence" | "compatibility" | -->
  <!-- ##GRM:                             "consistency" | "existence" | "uniqueness" | "correctness" . -->
  <xsl:template match="FCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:text>fof(</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>fc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>,theorem,</xsl:text>
        <xsl:apply-templates select="ArgTypes"/>
        <xsl:variable name="succ">
          <xsl:value-of select="count(Cluster[1]/*)"/>
        </xsl:variable>
        <xsl:value-of select="$srt_s"/>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="*[2]"/>
        <xsl:text>,</xsl:text>
        <xsl:choose>
          <xsl:when test="$succ = 0">
            <xsl:text>$true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$succ = 1">
                <xsl:apply-templates select="Cluster[1]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="Cluster[1]"/>
                <xsl:text> )</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
        <xsl:text>,file(</xsl:text>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>fc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>),[mptp_info(</xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>,[],fcluster,position(0,0),[</xsl:text>
        <xsl:if test="$mml=&quot;0&quot;">
          <xsl:text>proof_level([</xsl:text>
          <xsl:value-of select="translate(../@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
          <xsl:text>]),</xsl:text>
          <xsl:call-template name="cluster_correctness_conditions">
            <xsl:with-param name="el" select="../*[position() &gt; 1]"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- private for clusters -->
  <xsl:template name="cluster_correctness_conditions">
    <xsl:param name="el"/>
    <xsl:text>correctness_conditions([</xsl:text>
    <xsl:for-each select="$el">
      <xsl:variable name="corr_nm" select="name()"/>
      <xsl:choose>
        <xsl:when test="Proposition">
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="$corr_nm"/>
          </xsl:call-template>
          <xsl:text>(</xsl:text>
          <xsl:call-template name="plname">
            <xsl:with-param name="n" select="Proposition/@propnr"/>
            <xsl:with-param name="pl" select="Proposition/@plevel"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>])</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- ##NOTE: We need to deal with the RCluster coming from structurel -->
  <!-- definitions (attribute "strict") specially, since the existence -->
  <!-- is never proved in Mizar. The current choice is to forge the justification -->
  <!-- by the type declaration of the appropriate -->
  <!-- aggregate functor (which is defined to be "strict"). -->
  <xsl:template match="RCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:text>fof(</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>rc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>,theorem,</xsl:text>
        <xsl:variable name="l" select="1 + count(ArgTypes/Typ)"/>
        <xsl:apply-templates select="ArgTypes"/>
        <xsl:text>?[</xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$l"/>
        </xsl:call-template>
        <xsl:text> : </xsl:text>
        <xsl:apply-templates select="Typ"/>
        <xsl:text>]: </xsl:text>
        <xsl:variable name="succ">
          <xsl:value-of select="count(Cluster[1]/*)"/>
        </xsl:variable>
        <xsl:value-of select="$srt_s"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$l"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:choose>
          <xsl:when test="$succ = 0">
            <xsl:text>$true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$succ = 1">
                <xsl:apply-templates select="Cluster[1]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="Cluster[1]"/>
                <xsl:text> )</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
        <xsl:text>,file(</xsl:text>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>rc</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>),[mptp_info(</xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>,[],rcluster,position(0,0),[</xsl:text>
        <xsl:if test="$mml=&quot;0&quot;">
          <xsl:text>proof_level([</xsl:text>
          <xsl:value-of select="translate(../@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
          <xsl:text>]),</xsl:text>
          <!-- forge the correctness of structural "strict" registrations -->
          <xsl:choose>
            <xsl:when test="name(../..) = &quot;Definition&quot;">
              <xsl:choose>
                <xsl:when test="not(../../Constructor[@kind = &quot;G&quot;])">
                  <xsl:value-of select="$fail"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>inference(mizar_by,[strict],[dt_</xsl:text>
                  <xsl:call-template name="absc1">
                    <xsl:with-param name="el" select="../../Constructor[@kind = &quot;G&quot;]"/>
                  </xsl:call-template>
                  <xsl:text>])</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="cluster_correctness_conditions">
                <xsl:with-param name="el" select="../*[position() = last()]"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- sufficient proof refs done as for clusters -->
  <!-- ##GRM: IdentifyExp_Name : "ie" Number "_" Aid . -->
  <xsl:template match="IdentifyWithExp">
    <xsl:choose>
      <xsl:when test="ErrorIdentify"/>
      <xsl:otherwise>
        <xsl:text>fof(</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>ie</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>,theorem,</xsl:text>
        <xsl:if test="Typ">
          <xsl:text>![</xsl:text>
          <xsl:for-each select="Typ">
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="position()"/>
            </xsl:call-template>
            <xsl:text> : </xsl:text>
            <xsl:apply-templates select="."/>
            <xsl:if test="not(position()=last())">
              <xsl:text>,</xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:text>]: </xsl:text>
        </xsl:if>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="Func[1]"/>
        <xsl:value-of select="$eq_s"/>
        <!-- the next/last one should be Func too, but just for safety: -->
        <xsl:apply-templates select="*[position() = last()]"/>
        <xsl:text>)</xsl:text>
        <xsl:text>,file(</xsl:text>
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="absk">
          <xsl:with-param name="el" select="."/>
          <xsl:with-param name="kind">
            <xsl:text>ie</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>),[mptp_info(</xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>,[],identifyexp,position(0,0),[</xsl:text>
        <xsl:if test="$mml=&quot;0&quot;">
          <xsl:text>proof_level([</xsl:text>
          <xsl:value-of select="translate(../@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
          <xsl:text>]),</xsl:text>
          <xsl:call-template name="cluster_correctness_conditions">
            <xsl:with-param name="el" select="../*[position() &gt; 1]"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ArgTypes">
    <xsl:if test="Typ">
      <xsl:text>![</xsl:text>
      <xsl:for-each select="Typ">
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="position()"/>
        </xsl:call-template>
        <xsl:text> : </xsl:text>
        <xsl:apply-templates select="."/>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>]: </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="pvar">
    <xsl:param name="nr"/>
    <xsl:text>B</xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <xsl:template name="pconst">
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:text>c</xsl:text>
    <xsl:call-template name="absconst">
      <xsl:with-param name="nr" select="$nr"/>
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="ploci">
    <xsl:param name="nr"/>
    <xsl:text>A</xsl:text>
    <xsl:value-of select="$nr"/>
  </xsl:template>

  <xsl:template name="plab">
    <xsl:param name="nr"/>
    <xsl:element name="i">
      <xsl:element name="font">
        <xsl:attribute name="color">
          <xsl:value-of select="$labcolor"/>
        </xsl:attribute>
        <xsl:text>E</xsl:text>
        <xsl:value-of select="@nr"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- absolute constructor names (use $fail for debugging absnrs) -->
  <xsl:template name="absc">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@absnr and @aid">
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="concat(@kind,@absnr,&apos;_&apos;,@aid)"/>
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

  <!-- absolute redefinition names (use $fail for debugging absnrs) -->
  <xsl:template name="absredef">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@redefaid and @absredefnr">
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="concat(@kind,@absredefnr,&apos;_&apos;,@redefaid)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="@kind"/>
          </xsl:call-template>
          <xsl:value-of select="@redefnr"/>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="absc1">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@aid and @nr">
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

  <!-- absolute reference names (use $fail for debugging absnrs) -->
  <!-- also used for From to get the scheme name -->
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

  <!-- absolute cluster and scheme names -->
  <xsl:template name="absk">
    <xsl:param name="el"/>
    <xsl:param name="kind"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@nr and @aid">
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="concat($kind,@nr,&apos;_&apos;,@aid)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="lc">
            <xsl:with-param name="s" select="$kind"/>
          </xsl:call-template>
          <xsl:value-of select="@nr"/>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- List utilities -->
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

  <!-- argument list -->
  <xsl:template name="arglist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:param name="s"/>
    <xsl:for-each select="$elems">
      <xsl:choose>
        <xsl:when test="$s &gt; 0">
          <xsl:call-template name="ploci">
            <xsl:with-param name="nr" select="position() + $s"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="ploci">
            <xsl:with-param name="nr" select="position()"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- add numbers starting at #j+1 between #sep1 and #sep2 - now with constants -->
  <xsl:template name="jlist">
    <xsl:param name="j"/>
    <xsl:param name="sep1"/>
    <xsl:param name="sep2"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$sep1"/>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="$j+position()"/>
        </xsl:call-template>
        <xsl:value-of select="$sep2"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- from-to list of variables starting numbering at $f ending at $t -->
  <!-- $l ouiputs loci vars -->
  <xsl:template name="ft_list">
    <xsl:param name="f"/>
    <xsl:param name="t"/>
    <xsl:param name="sep"/>
    <xsl:param name="l"/>
    <xsl:choose>
      <xsl:when test="$f = $t">
        <xsl:choose>
          <xsl:when test="$l=1">
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$f"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pvar">
              <xsl:with-param name="nr" select="$f"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$f &lt; $t">
          <xsl:choose>
            <xsl:when test="$l=1">
              <xsl:call-template name="ploci">
                <xsl:with-param name="nr" select="$f"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="pvar">
                <xsl:with-param name="nr" select="$f"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="$sep"/>
          <xsl:call-template name="ft_list">
            <xsl:with-param name="f" select="$f+1"/>
            <xsl:with-param name="t" select="$t"/>
            <xsl:with-param name="sep" select="$sep"/>
            <xsl:with-param name="l" select="$l"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- $same is used for reflexivity -->
  <xsl:template name="switchedargs">
    <xsl:param name="nr"/>
    <xsl:param name="nr1"/>
    <xsl:param name="nr2"/>
    <xsl:param name="lim"/>
    <xsl:param name="same"/>
    <xsl:choose>
      <xsl:when test="$nr = $nr2">
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$nr1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$nr = $nr1">
            <xsl:choose>
              <xsl:when test="$same=1">
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="$nr1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="$nr2"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="ploci">
              <xsl:with-param name="nr" select="$nr"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$nr &lt; $lim">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="switchedargs">
        <xsl:with-param name="nr" select="$nr+1"/>
        <xsl:with-param name="nr1" select="$nr1"/>
        <xsl:with-param name="nr2" select="$nr2"/>
        <xsl:with-param name="lim" select="$lim"/>
        <xsl:with-param name="same" select="$same"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- $same is used for reflexivity -->
  <xsl:template name="argsinsert">
    <xsl:param name="nr"/>
    <xsl:param name="nr1"/>
    <xsl:param name="arg"/>
    <xsl:param name="lim"/>
    <xsl:choose>
      <xsl:when test="$nr = $nr1">
        <xsl:value-of select="$arg"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$nr &lt; $lim">
      <xsl:text>,</xsl:text>
      <xsl:call-template name="argsinsert">
        <xsl:with-param name="nr" select="$nr+1"/>
        <xsl:with-param name="nr1" select="$nr1"/>
        <xsl:with-param name="arg" select="$arg"/>
        <xsl:with-param name="lim" select="$lim"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- find the constant with #nr on level #pl or higher, -->
  <!-- rpint @constnr "_" $pl -->
  <xsl:template name="absconst">
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="key(&quot;C&quot;,$pl)[@nr=$nr]">
        <xsl:value-of select="key(&quot;C&quot;,$pl)[@nr=$nr]/@constnr"/>
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="key(&quot;C&quot;,$pl)[@nr &lt; $nr]">
            <xsl:for-each select="key(&quot;C&quot;,$pl)[@nr &lt; $nr]">
              <xsl:if test="position() = last()">
                <xsl:variable name="n1">
                  <xsl:call-template name="getcnr">
                    <xsl:with-param name="el" select="."/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="lastnr" select="@nr + $n1 - 1"/>
                <xsl:choose>
                  <xsl:when test="$lastnr &gt;= $nr">
                    <xsl:value-of select="@constnr + ($nr - @nr)"/>
                    <xsl:call-template name="addp">
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$fail"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="string-length($pl)&gt;0">
                <xsl:variable name="ss" select="exsl-str:tokenize($pl,&apos;_&apos;)[position() &lt; last()]"/>
                <xsl:variable name="pl1">
                  <xsl:call-template name="mjoin">
                    <xsl:with-param name="el" select="$ss"/>
                    <xsl:with-param name="s">
                      <xsl:text>_</xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:variable>
                <!-- "bb"; $pl1; "bb"; -->
                <xsl:call-template name="absconst">
                  <xsl:with-param name="nr" select="$nr"/>
                  <xsl:with-param name="pl" select="$pl1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$fail"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mjoin">
    <xsl:param name="el"/>
    <xsl:param name="s"/>
    <xsl:for-each select="$el">
      <xsl:value-of select="string(.)"/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$s"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- count local constants introduced in the current element - -->
  <!-- this asssumes Let | Given | TakeAsVar | Consider | Set | Reconsider -->
  <xsl:template name="getcnr">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(name() = &quot;Reconsider&quot;)">
          <xsl:value-of select="count(Var|LocusVar|Const|InfConst|
		  Num|Func|PrivFunc|Fraenkel|QuaTrm|It|ErrorTrm)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(Typ)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="refname">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@kind = &quot;T&quot;) or (@kind = &quot;D&quot;)">
          <xsl:call-template name="absr">
            <xsl:with-param name="el" select="$el"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="privname">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="pl" select="$pl"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="polyeval_name">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:for-each select="$el">
      <xsl:value-of select="Requirement/@reqname"/>
      <xsl:text>__</xsl:text>
      <xsl:call-template name="absc">
        <xsl:with-param name="el" select="Requirement"/>
      </xsl:call-template>
      <xsl:text>__</xsl:text>
      <xsl:if test="Requirement/@value = &quot;false&quot;">
        <xsl:text>false__</xsl:text>
      </xsl:if>
      <xsl:for-each select="*[position() &gt; 1]">
        <xsl:choose>
          <xsl:when test="(name() = &quot;RationalNr&quot;) or (name() = &quot;ComplexNr&quot;)">
            <xsl:apply-templates select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name()"/>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
          <xsl:text>_</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- this produces m 2.964693601e+09 for pepin at 2058,54; so we use -->
  <!-- string replacement instead -->
  <xsl:template name="encode_minus_bad">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &lt; 0">
        <xsl:text>m</xsl:text>
        <xsl:value-of select="0 - $n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="encode_minus">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &lt; 0">
        <xsl:value-of select="translate($n,&quot;-&quot;,&quot;m&quot;)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="RationalNr">
    <xsl:text>r</xsl:text>
    <xsl:choose>
      <xsl:when test="@denominator = &quot;1&quot;">
        <xsl:call-template name="encode_minus">
          <xsl:with-param name="n" select="@numerator"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>n</xsl:text>
        <xsl:call-template name="encode_minus">
          <xsl:with-param name="n" select="@numerator"/>
        </xsl:call-template>
        <xsl:text>d</xsl:text>
        <xsl:call-template name="encode_minus">
          <xsl:with-param name="n" select="@denominator"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ComplexNr">
    <xsl:text>c</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="top_propname">
    <xsl:param name="el"/>
    <xsl:for-each select="$el/..">
      <xsl:choose>
        <xsl:when test="(name() = &quot;DefTheorem&quot;) or (name() = &quot;JustifiedTheorem&quot;)">
          <xsl:call-template name="absr">
            <xsl:with-param name="el" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="k1" select="concat($el/@nr,&quot;:&quot;)"/>
          <xsl:call-template name="lemmaname">
            <xsl:with-param name="n" select="key(&quot;E&quot;,$k1)/@propnr"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- name of private reference - name of the proposition -->
  <!-- this differs from `plname` in that the #pl is not the -->
  <!-- proof level to print, but the proof level used to start the -->
  <!-- search for the reference -->
  <xsl:template name="privname">
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:variable name="k1" select="concat($nr,&quot;:&quot;,$pl)"/>
    <xsl:choose>
      <xsl:when test="key(&quot;E&quot;,$k1)">
        <xsl:choose>
          <xsl:when test="not(string-length($pl)&gt;0)">
            <xsl:call-template name="top_propname">
              <xsl:with-param name="el" select="key(&quot;E&quot;,$k1)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="propname">
              <xsl:with-param name="n" select="key(&quot;E&quot;,$k1)/@propnr"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="string-length($pl)&gt;0">
            <xsl:variable name="ss" select="exsl-str:tokenize($pl,&apos;_&apos;)[position() &lt; last()]"/>
            <xsl:variable name="pl1">
              <xsl:call-template name="mjoin">
                <xsl:with-param name="el" select="$ss"/>
                <xsl:with-param name="s">
                  <xsl:text>_</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="privname">
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="pl" select="$pl1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- name of scheme functor (#k='f') or predicate (#k='p') -->
  <xsl:template name="sch_fpname">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="schnr"/>
    <xsl:param name="aid"/>
    <xsl:choose>
      <xsl:when test="$k and $nr and $aid and $schnr">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="concat($k,$nr,&apos;_s&apos;,$schnr,&apos;_&apos;,$aid)"/>
        </xsl:call-template>
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

  <!-- name of scheme functor (#k='f') or predicate (#k='p') -->
  <xsl:template name="abs_fp">
    <xsl:param name="k"/>
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:call-template name="sch_fpname">
        <xsl:with-param name="k" select="$k"/>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="schnr" select="@schemenr"/>
        <xsl:with-param name="aid" select="@aid"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- definition of private functor (#k='pf') or predicate (#k='pp'); -->
  <!-- either a term with LocusVars or a formula with LocusVars -->
  <!-- the list of arguments is printed first, to know their order -->
  <xsl:template name="priv_def">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:variable name="k1" select="concat($nr,&quot;:&quot;,$pl)"/>
    <xsl:choose>
      <xsl:when test="key($k,$k1)">
        <xsl:for-each select="key($k,$k1)">
          <xsl:text>[</xsl:text>
          <xsl:call-template name="arglist">
            <xsl:with-param name="separ">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="ArgTypes/Typ"/>
          </xsl:call-template>
          <xsl:text>] : </xsl:text>
          <xsl:apply-templates select="*[position() = 2]">
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="string-length($pl)&gt;0">
            <xsl:variable name="ss" select="exsl-str:tokenize($pl,&apos;_&apos;)[position() &lt; last()]"/>
            <xsl:variable name="pl1">
              <xsl:call-template name="mjoin">
                <xsl:with-param name="el" select="$ss"/>
                <xsl:with-param name="s">
                  <xsl:text>_</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="priv_def">
              <xsl:with-param name="k" select="$k"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="pl" select="$pl1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fail"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- hack for .bex1 file, it's the same as Typ, but uses upper cluster -->
  <!-- instead of lower cluster; maybe the lower cluster should be fixed -->
  <!-- to a more proper value in iocorrel.pas -->
  <xsl:template match="ByExplanations">
    <xsl:param name="i"/>
    <xsl:param name="pl"/>
    <xsl:for-each select="Typ">
      <xsl:if test="position() = 2">
        <xsl:text>non</xsl:text>
      </xsl:if>
      <xsl:text>zerotyp(</xsl:text>
      <xsl:value-of select="$anamelc"/>
      <xsl:text>,</xsl:text>
      <xsl:choose>
        <xsl:when test="@kind=&apos;errortyp&apos;">
          <xsl:text>errortyp</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;L&quot;)">
              <xsl:variable name="radix">
                <xsl:choose>
                  <xsl:when test="(@aid = &quot;HIDDEN&quot;) and (@kind=&quot;M&quot;) and (@nr=&quot;1&quot;)">
                    <xsl:text>0</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="adjectives">
                <xsl:value-of select="count(*[2]/*)"/>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="($adjectives + $radix) = 0">
                  <xsl:text>$true</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="($adjectives + $radix) &gt; 1">
                    <xsl:text>( </xsl:text>
                  </xsl:if>
                  <xsl:if test="$adjectives &gt; 0">
                    <xsl:apply-templates select="*[2]">
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pl" select="$pl"/>
                    </xsl:apply-templates>
                    <xsl:if test="$radix &gt; 0">
                      <xsl:value-of select="$and_s"/>
                    </xsl:if>
                  </xsl:if>
                  <xsl:if test="($radix &gt; 0)">
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
                  </xsl:if>
                  <xsl:if test="($adjectives + $radix) &gt; 1">
                    <xsl:text> )</xsl:text>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$fail"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>).
</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mml=&quot;0&quot;">
        <xsl:apply-templates select="//Proposition|//Now|//IterEquality|
	     //Let|//Given|//TakeAsVar|//Consider|//Set|
	     //Reconsider|//SchemeFuncDecl|//SchemeBlock|
	     //CCluster|//FCluster|//RCluster|//IdentifyWithExp|//Thesis|//PerCasesReasoning|/ByExplanations"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
