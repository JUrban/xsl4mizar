<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="exsl exsl-str xt" xmlns:exsl="http://exslt.org/common" xmlns:exsl-str="http://exslt.org/strings" xmlns:xt="http://www.jclark.com/xt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.1 $ -->
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
        <xsl:call-template name="lemmaname">
          <xsl:with-param name="n" select="$n"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- SchemePremises implies SchemeThesis -->
  <!-- the proof might rather be 'implication intro' -->
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
    </xsl:call-template>
    <xsl:text>]).
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
    <xsl:text>]</xsl:text>
    <xsl:text>)]).
</xsl:text>
  </xsl:template>

  <xsl:template match="Proposition">
    <xsl:variable name="pname">
      <xsl:call-template name="plname">
        <xsl:with-param name="n" select="@propnr"/>
        <xsl:with-param name="pl" select="@plevel"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>fof(</xsl:text>
    <xsl:value-of select="$pname"/>
    <xsl:text>,</xsl:text>
    <xsl:choose>
      <xsl:when test="following-sibling::*[1][name() = &quot;By&quot; or name() = &quot;From&quot; or
      name() = &quot;Proof&quot;]">
        <xsl:text>lemma-derived,</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>unknown,</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:text>])</xsl:text>
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="following-sibling::*[1]"/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
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
    <xsl:text>lemma-derived,</xsl:text>
    <xsl:apply-templates select="BlockThesis/*">
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
    <xsl:text>]),</xsl:text>
    <xsl:call-template name="proofinfer">
      <xsl:with-param name="el" select="."/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
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
    <xsl:text>lemma-derived,</xsl:text>
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
    <xsl:text>]),</xsl:text>
    <xsl:call-template name="proofinfer">
      <xsl:with-param name="el" select="."/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
    <xsl:apply-templates select="IterStep"/>
  </xsl:template>

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
    <xsl:text>lemma-derived,</xsl:text>
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
    <xsl:text>])</xsl:text>
    <xsl:call-template name="try_inference">
      <xsl:with-param name="el" select="*[2]"/>
      <xsl:with-param name="pl" select="@plevel"/>
      <xsl:with-param name="prnr" select="@propnr"/>
    </xsl:call-template>
    <xsl:text>]).
</xsl:text>
  </xsl:template>

  <xsl:template name="try_inference">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
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
                  </xsl:call-template>
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

  <!-- assumes By -->
  <xsl:template name="byinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:text>inference(mizar_by,[],[</xsl:text>
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
          <xsl:if test="Ref">
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
            <xsl:if test="Ref">
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
      <xsl:text>inference(mizar_from,[scheme_instance(</xsl:text>
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
  <!-- ##GRM: Proof_Inference : -->
  <!-- "inference(mizar_proof,[proof_level(" Level ")], -->
  <!-- [ References ] ")" . -->
  <xsl:template name="proofinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:text>inference(mizar_proof,[proof_level([</xsl:text>
      <xsl:choose>
        <xsl:when test="not(@newlevel)">
          <xsl:value-of select="$fail"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@newlevel,&quot;_&quot;,&quot;,&quot;)"/>
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
  <xsl:template match="Let|Given|TakeAsVar|Consider|Set">
    <xsl:variable name="cnr" select="@constnr"/>
    <xsl:variable name="pl" select="@plevel"/>
    <xsl:variable name="rnm">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="name()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="Typ">
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
      <xsl:text>,sort,</xsl:text>
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
      <xsl:text>,type])]).
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

  <!-- new reconsider has the same type for each term now - this is -->
  <!-- hopefully a compatible way for both new and old -->
  <xsl:template match="Reconsider">
    <xsl:variable name="cnr" select="@constnr"/>
    <xsl:variable name="pl" select="@plevel"/>
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
      <xsl:text>,sort,</xsl:text>
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
      <xsl:text>constant,position(0,0),[reconsider,type])]).
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
  <!-- so we do not use them either and use $true -->
  <xsl:template match="SchemeFuncDecl">
    <xsl:variable name="pl" select="@plevel"/>
    <!-- $nm =  { "f"; `@nr`; addp(#pl=$pl); } -->
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
    <xsl:variable name="levl">
      <xsl:text>,[</xsl:text>
      <xsl:value-of select="translate($pl,&quot;_&quot;,&quot;,&quot;)"/>
      <xsl:text>],</xsl:text>
    </xsl:variable>
    <xsl:variable name="l" select="count(ArgTypes/Typ)"/>
    <xsl:text>fof(dt_</xsl:text>
    <xsl:value-of select="$nm"/>
    <xsl:text>,sort,</xsl:text>
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
    <xsl:text>functor,position(0,0),[scheme,type])]).
</xsl:text>
  </xsl:template>

  <!-- "M" | "L" | "V" | "R" | "K" | "U" | "G" -->
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
      <xsl:text>,sort,</xsl:text>
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
      <xsl:text>,lemma-derived,</xsl:text>
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
  <!-- functor has more args than just the fields! -->
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
        <xsl:text>,sort,</xsl:text>
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
          <xsl:text>])</xsl:text>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
        <xsl:text>,sort,</xsl:text>
        <xsl:apply-templates select="ArgTypes"/>
        <xsl:variable name="succ">
          <xsl:value-of select="count(Cluster/*)"/>
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
                <xsl:apply-templates select="Cluster"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="Cluster"/>
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
          <xsl:text>])</xsl:text>
        </xsl:if>
        <xsl:text>])]).
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
        <xsl:text>,sort,</xsl:text>
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
          <xsl:value-of select="count(Cluster/*)"/>
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
                <xsl:apply-templates select="Cluster"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="Cluster"/>
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
          <xsl:text>])</xsl:text>
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

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mml=&quot;0&quot;">
        <xsl:apply-templates select="//Proposition|//Now|//IterEquality|
	     //Let|//Given|//TakeAsVar|//Consider|//Set|
	     //Reconsider|//SchemeFuncDecl|//SchemeBlock|
	     //CCluster|//FCluster|//RCluster"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
