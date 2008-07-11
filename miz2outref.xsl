<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="exsl exsl-str xt" xmlns:exsl="http://exslt.org/common" xmlns:exsl-str="http://exslt.org/strings" xmlns:xt="http://www.jclark.com/xt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.1 $ -->
  <!--  -->
  <!-- File: miz2outref.xsltxt - stylesheet translating Mizar XML syntax to MML Query outref files -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL miz2outref.xsltxt >miz2outref.xsl -->
  <!-- ##TODO: cleanup - this is crudely adapted from mizpl.xsltxt -->
  <xsl:strip-space elements="*"/>
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

  <xsl:template match="SchemeBlock">
    <xsl:value-of select="$aname"/>
    <xsl:text>:</xsl:text>
    <xsl:call-template name="refkind">
      <xsl:with-param name="kind">
        <xsl:text>S</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@schemenr"/>
    <xsl:text>=(</xsl:text>
    <xsl:variable name="r1">
      <xsl:call-template name="try_inference">
        <xsl:with-param name="el" select="*[position() = (last() - 1)]"/>
        <xsl:with-param name="pl" select="@newlevel"/>
        <xsl:with-param name="nl">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ss" select="exsl-str:tokenize($r1,&apos;,&apos;)"/>
    <xsl:call-template name="mjoin">
      <xsl:with-param name="el" select="$ss"/>
      <xsl:with-param name="s">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="JustifiedTheorem/Proposition">
    <!-- `../@aid`; ":"; refkind(#kind = `../@kind`); " "; `../@nr`; -->
    <xsl:call-template name="absr">
      <xsl:with-param name="el" select=".."/>
    </xsl:call-template>
    <xsl:text>=(</xsl:text>
    <xsl:variable name="r1">
      <xsl:call-template name="try_inference">
        <xsl:with-param name="el" select="../*[2]"/>
        <xsl:with-param name="pl" select="@plevel"/>
        <xsl:with-param name="prnr" select="@propnr"/>
        <xsl:with-param name="nl">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ss" select="exsl-str:tokenize($r1,&apos;,&apos;)"/>
    <xsl:call-template name="mjoin">
      <xsl:with-param name="el" select="$ss"/>
      <xsl:with-param name="s">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>)
</xsl:text>
  </xsl:template>

  <xsl:template match="Definition">
    <xsl:if test="@nr">
      <xsl:variable name="cnt1" select="1 + count(preceding-sibling::Definition[@nr])"/>
      <xsl:variable name="defnr" select="../following-sibling::Definiens[position() = $cnt1]/@defnr"/>
      <xsl:value-of select="$aname"/>
      <xsl:text>:</xsl:text>
      <xsl:call-template name="refkind">
        <xsl:with-param name="kind">
          <xsl:text>D</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$defnr"/>
      <xsl:text>=(</xsl:text>
      <xsl:variable name="r1">
        <xsl:for-each select="Coherence|Compatibility|Consistency|Existence|Uniqueness|Correctness|JustifiedProperty">
          <xsl:if test="Proposition">
            <xsl:call-template name="try_inference">
              <xsl:with-param name="el" select="*[2]"/>
              <xsl:with-param name="pl" select="Proposition/@plevel"/>
              <xsl:with-param name="prnr" select="Proposition/@propnr"/>
              <xsl:with-param name="nl">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="ss" select="exsl-str:tokenize($r1,&apos;,&apos;)"/>
      <xsl:call-template name="mjoin">
        <xsl:with-param name="el" select="$ss"/>
        <xsl:with-param name="s">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>)
</xsl:text>
    </xsl:if>
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
  </xsl:template>

  <!-- ##GRM: By_Inference: "inference(" "mizar_by" "," "[" "]" "," "[" References "]" ")". -->
  <!-- assumes By -->
  <xsl:template name="byinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:for-each select="$el">
      <xsl:call-template name="refs">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="pl" select="$pl"/>
        <xsl:with-param name="prnr" select="$prnr"/>
      </xsl:call-template>
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
      <xsl:call-template name="refs">
        <xsl:with-param name="el" select="."/>
        <xsl:with-param name="pl" select="$pl"/>
        <xsl:with-param name="prnr" select="$prnr"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- assumes Proof, Now or IterEquality, -->
  <!-- selects all references (no matter what their level is) used for -->
  <!-- justifying anything inside the proof (so e.g. assumption, which -->
  <!-- is never used to justify anything willnot be listed). -->
  <xsl:template name="proofinfer">
    <xsl:param name="el"/>
    <xsl:param name="pl"/>
    <xsl:param name="prnr"/>
    <xsl:param name="nl"/>
    <xsl:for-each select="$el">
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
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="CCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:value-of select="@aid"/>
        <xsl:text>:condreg </xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>=(</xsl:text>
        <xsl:call-template name="cluster_correctness_conditions">
          <xsl:with-param name="el" select="../*[position() = last()]"/>
        </xsl:call-template>
        <xsl:text>)
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- sufficient proof refs can be collected from its coherence -->
  <xsl:template match="FCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:value-of select="@aid"/>
        <xsl:text>:funcreg </xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>=(</xsl:text>
        <xsl:call-template name="cluster_correctness_conditions">
          <xsl:with-param name="el" select="../*[position() &gt; 1]"/>
        </xsl:call-template>
        <xsl:text>)
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- private for clusters -->
  <xsl:template name="cluster_correctness_conditions">
    <xsl:param name="el"/>
    <!-- "correctness_conditions(["; -->
    <xsl:for-each select="$el">
      <xsl:variable name="corr_nm" select="name()"/>
      <xsl:choose>
        <xsl:when test="Proposition">
          <!-- lc(#s = $corr_nm); "("; -->
          <!-- plname(#n=`Proposition/@propnr`, #pl=`Proposition/@plevel`); -->
          <xsl:variable name="r1">
            <xsl:call-template name="try_inference">
              <xsl:with-param name="el" select="*[2]"/>
              <xsl:with-param name="pl" select="Proposition/@plevel"/>
              <xsl:with-param name="prnr" select="Proposition/@propnr"/>
              <xsl:with-param name="nl">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="ss" select="exsl-str:tokenize($r1,&apos;,&apos;)"/>
          <xsl:call-template name="mjoin">
            <xsl:with-param name="el" select="$ss"/>
            <xsl:with-param name="s">
              <xsl:text>,</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fail"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ##NOTE: We need to deal with the RCluster coming from structurel -->
  <!-- definitions (attribute "strict") specially, since the existence -->
  <!-- is never proved in Mizar. The current MPTP choice is to forge the justification -->
  <!-- by the type declaration of the appropriate -->
  <!-- aggregate functor (which is defined to be "strict"). -->
  <!-- Nothing is done for MML Query right now -->
  <xsl:template match="RCluster">
    <xsl:choose>
      <xsl:when test="ErrorCluster"/>
      <xsl:otherwise>
        <xsl:value-of select="@aid"/>
        <xsl:text>:exreg </xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>=(</xsl:text>
        <!-- nothing for structural "strict" registrations -->
        <xsl:choose>
          <xsl:when test="name(../..) = &quot;Definition&quot;"/>
          <xsl:otherwise>
            <xsl:call-template name="cluster_correctness_conditions">
              <xsl:with-param name="el" select="../*[position() = last()]"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- sufficient proof refs done as for clusters -->
  <xsl:template match="IdentifyWithExp">
    <xsl:choose>
      <xsl:when test="ErrorIdentify"/>
      <xsl:otherwise>
        <xsl:value-of select="@aid"/>
        <xsl:text>:idreg </xsl:text>
        <xsl:value-of select="@nr"/>
        <xsl:text>=(</xsl:text>
        <xsl:call-template name="cluster_correctness_conditions">
          <xsl:with-param name="el" select="../*[position() &gt; 1]"/>
        </xsl:call-template>
        <xsl:text>)
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- absolute reference names (use $fail for debugging absnrs) -->
  <!-- also used for From to get the scheme name -->
  <xsl:template name="absr">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@nr and @aid and @kind">
          <xsl:value-of select="@aid"/>
          <xsl:text>:</xsl:text>
          <xsl:call-template name="refkind">
            <xsl:with-param name="kind" select="@kind"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@nr"/>
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

  <xsl:template match="/">
    <xsl:apply-templates select="//JustifiedTheorem/Proposition|//SchemeBlock|
	     //CCluster|//FCluster|//RCluster|//IdentifyWithExp|//Definition"/>
  </xsl:template>
</xsl:stylesheet>
