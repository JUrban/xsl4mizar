<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_frmtrm.xsl"/>

  <!-- $Revision: 1.37 $ -->
  <!--  -->
  <!-- File: reasoning.xsltxt - html-ization of Mizar XML, code for reasoning items -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <xsl:template match="Proposition">
    <xsl:if test="$proof_links&gt;0">
      <xsl:element name="a">
        <xsl:attribute name="NAME">
          <xsl:call-template name="propname">
            <xsl:with-param name="n" select="@propnr"/>
            <xsl:with-param name="pl" select="@plevel"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:if test="following-sibling::*[1][(name()=&quot;By&quot;) and (@linked=&quot;true&quot;)]">
      <xsl:if test="not((name(..) = &quot;Consider&quot;) or (name(..) = &quot;Reconsider&quot;) 
           or (name(..) = &quot;Conclusion&quot;))">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>then </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@nr&gt;0">
      <xsl:choose>
        <xsl:when test="($proof_links&gt;0) and ($print_lab_identifiers = 0) 
            and not(string-length(@plevel)&gt;0)">
          <xsl:call-template name="plab1">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="txt">
              <xsl:text>Lemma</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="vid" select="@vid"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>: </xsl:text>
    </xsl:if>
    <!-- ###TODO: include the possible link when generating items -->
    <xsl:choose>
      <xsl:when test="($generate_items&gt;0) and not(string-length(@plevel)&gt;0)">
        <xsl:choose>
          <xsl:when test="name(..) = &quot;SchemeBlock&quot;">
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(name(..) = &quot;SchemePremises&quot;)">
              <xsl:call-template name="pcomment">
                <xsl:with-param name="str" select="concat($aname, &quot;:lemma &quot;, @propnr)"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
            <xsl:if test="($generate_items_proofs&gt;0) and
	      (following-sibling::*[1][(name()=&quot;By&quot;) or (name()=&quot;From&quot;) or (name()=&quot;Proof&quot;)])">
              <xsl:apply-templates select="following-sibling::*[1]"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- we can only say that this is a lemma if it is a toplevel proposition -->
      <!-- nontoplevel could be assumptions, etc. - this is a ##TODO -->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="not(string-length(@plevel)&gt;0)">
            <xsl:element name="span">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#E&quot;,@propnr)"/>
              </xsl:attribute>
              <xsl:attribute name="typeof">
                <xsl:text>oo:Lemma</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
              <xsl:text> </xsl:text>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mk_by_title">
    <xsl:param name="line"/>
    <xsl:param name="col"/>
    <xsl:value-of select="concat(&quot;Explain line &quot;, $line, &quot; column &quot;, $col)"/>
  </xsl:template>

  <!-- Justifications -->
  <xsl:template name="linkbyif">
    <xsl:param name="line"/>
    <xsl:param name="col"/>
    <xsl:param name="by"/>
    <xsl:choose>
      <xsl:when test="$linkby&gt;0">
        <xsl:variable name="byurl">
          <xsl:choose>
            <xsl:when test="$linkby=1">
              <xsl:value-of select="concat($lbydir,$anamelc,&quot;/&quot;,$line,&quot;_&quot;,$col,&quot;.html&quot;)"/>
            </xsl:when>
            <xsl:when test="$linkby=2">
              <xsl:value-of select="concat($lbydlicgipref,$anamelc,&quot;/&quot;,$line,&quot;_&quot;,$col,&quot;.dli&quot;)"/>
            </xsl:when>
            <xsl:when test="$linkby=3">
              <xsl:value-of select="concat($lbytptpcgi,&quot;?article=&quot;,$anamelc,&quot;&amp;lc=&quot;,$line,&quot;_&quot;,$col,&quot;&amp;tmp=&quot;,$lbytmpdir,$lbycgiparams)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="a">
          <xsl:choose>
            <xsl:when test="$ajax_by &gt; 0">
              <xsl:call-template name="add_ajax_attrs">
                <xsl:with-param name="u" select="$byurl"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="href">
                <xsl:value-of select="$byurl"/>
              </xsl:attribute>
              <xsl:attribute name="class">
                <xsl:text>txt</xsl:text>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="$linkbytoself &gt; 0">
                  <xsl:attribute name="target">
                    <xsl:text>_self</xsl:text>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="target">
                    <xsl:text>byATP</xsl:text>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="$by_titles&gt;0">
            <xsl:attribute name="title">
              <xsl:call-template name="mk_by_title">
                <xsl:with-param name="line" select="$line"/>
                <xsl:with-param name="col" select="$col"/>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str" select="$by"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:element>
        <xsl:if test="$ajax_by &gt; 0">
          <xsl:element name="span">
            <xsl:text> </xsl:text>
          </xsl:element>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str" select="$by"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- if #nbr=1 then no <br; is put in the end -->
  <!-- (used e.g. for conclusions, where definitional -->
  <!-- expansions are handled on the same line) -->
  <xsl:template match="By	">
    <xsl:param name="nbr"/>
    <xsl:choose>
      <xsl:when test="(count(Ref)&gt;0)">
        <xsl:call-template name="linkbyif">
          <xsl:with-param name="line" select="@line"/>
          <xsl:with-param name="col" select="@col"/>
          <xsl:with-param name="by">
            <xsl:text>by</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:element name="span">
          <xsl:attribute name="class">
            <xsl:text>lab</xsl:text>
          </xsl:attribute>
          <xsl:call-template name="list">
            <xsl:with-param name="separ">
              <xsl:text>, </xsl:text>
            </xsl:with-param>
            <xsl:with-param name="elems" select="Ref"/>
          </xsl:call-template>
        </xsl:element>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$linkby&gt;0">
            <xsl:call-template name="linkbyif">
              <xsl:with-param name="line" select="@line"/>
              <xsl:with-param name="col" select="@col"/>
              <xsl:with-param name="by">
                <xsl:text>;</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not($nbr = &quot;1&quot;)">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IterStep/By">
    <xsl:if test="(count(Ref)&gt;0)">
      <xsl:call-template name="linkbyif">
        <xsl:with-param name="line" select="@line"/>
        <xsl:with-param name="col" select="@col"/>
        <xsl:with-param name="by">
          <xsl:text>by</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="span">
        <xsl:attribute name="class">
          <xsl:text>lab</xsl:text>
        </xsl:attribute>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text>, </xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="Ref"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="From">
    <xsl:param name="nbr"/>
    <xsl:call-template name="linkbyif">
      <xsl:with-param name="line" select="@line"/>
      <xsl:with-param name="col" select="@col"/>
      <xsl:with-param name="by">
        <xsl:text>from</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>lab</xsl:text>
      </xsl:attribute>
      <xsl:call-template name="getref">
        <xsl:with-param name="k">
          <xsl:text>S</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="anr" select="@articlenr"/>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>, </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Ref"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
      <xsl:text>;</xsl:text>
      <xsl:if test="not($nbr=&quot;1&quot;)">
        <xsl:element name="br"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="IterStep/From">
    <xsl:call-template name="linkbyif">
      <xsl:with-param name="line" select="@line"/>
      <xsl:with-param name="col" select="@col"/>
      <xsl:with-param name="by">
        <xsl:text>from</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>lab</xsl:text>
      </xsl:attribute>
      <xsl:call-template name="getref">
        <xsl:with-param name="k">
          <xsl:text>S</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="anr" select="@articlenr"/>
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>, </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Ref"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:element>
  </xsl:template>

  <!-- ##REQUIRE: the following two can be called only if $proof_links>0 -->
  <xsl:template name="top_propname">
    <xsl:param name="el"/>
    <xsl:for-each select="$el/..">
      <xsl:choose>
        <xsl:when test="(name() = &quot;DefTheorem&quot;) or (name() = &quot;JustifiedTheorem&quot;)">
          <xsl:variable name="k">
            <xsl:choose>
              <xsl:when test="@kind=&apos;D&apos;">
                <xsl:text>Def</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Th</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="nm">
            <xsl:choose>
              <xsl:when test="($print_lab_identifiers &gt; 0) and ($el/@vid &gt; 0)">
                <xsl:call-template name="get_vid_name">
                  <xsl:with-param name="vid" select="$el/@vid"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($k,@nr)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="mkref">
            <xsl:with-param name="aid" select="$aname"/>
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="c">
              <xsl:text>1</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="nm" select="$nm"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="k1" select="concat($el/@nr,&quot;:&quot;)"/>
          <xsl:variable name="k2" select="key(&quot;E&quot;,$k1)/@propnr"/>
          <xsl:element name="a">
            <xsl:attribute name="class">
              <xsl:text>txt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="href">
              <xsl:value-of select="concat($anamelc, &quot;.&quot;, $ext, &quot;#&quot;,&quot;E&quot;,$k2)"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="($print_lab_identifiers &gt; 0) and ($el/@vid &gt; 0)">
                <xsl:call-template name="pplab">
                  <xsl:with-param name="nr" select="$el/@nr"/>
                  <xsl:with-param name="vid" select="$el/@vid"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="plab1">
                  <xsl:with-param name="nr" select="$el/@nr"/>
                  <xsl:with-param name="txt">
                    <xsl:text>Lemma</xsl:text>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
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
        <xsl:for-each select="key(&quot;E&quot;,$k1)">
          <xsl:choose>
            <xsl:when test="not(string-length($pl)&gt;0)">
              <xsl:call-template name="top_propname">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="txt">
                <xsl:call-template name="propname">
                  <xsl:with-param name="n" select="@propnr"/>
                  <xsl:with-param name="pl" select="$pl"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:element name="a">
                <xsl:attribute name="class">
                  <xsl:text>txt</xsl:text>
                </xsl:attribute>
                <!-- @href  = `concat($anamelc, ".", $ext, "#",$txt)`; -->
                <xsl:attribute name="href">
                  <xsl:value-of select="concat(&quot;#&quot;,$txt)"/>
                </xsl:attribute>
                <xsl:call-template name="pplab">
                  <xsl:with-param name="nr" select="@nr"/>
                  <xsl:with-param name="vid" select="@vid"/>
                </xsl:call-template>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="ls" select="string-length($pl)"/>
        <xsl:if test="$ls&gt;0">
          <xsl:variable name="pl1">
            <xsl:call-template name="get_parent_level">
              <xsl:with-param name="pl" select="$pl"/>
              <xsl:with-param name="ls" select="$ls"/>
              <xsl:with-param name="n">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="privname">
            <xsl:with-param name="nr" select="$nr"/>
            <xsl:with-param name="pl" select="$pl1"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- count local constants introduced in the current element - -->
  <!-- this asssumes Let | Given | TakeAsVar | Consider | Set | Reconsider -->
  <xsl:template name="getcnr">
    <xsl:param name="el"/>
    <xsl:value-of select="count($el/Typ)"/>
  </xsl:template>

  <!-- relies on addabsrefs preprocessing -->
  <xsl:template name="get_nearest_level">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="@newlevel">
          <xsl:value-of select="@newlevel"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="get_nearest_level">
            <xsl:with-param name="el" select=".."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Ref">
    <xsl:choose>
      <xsl:when test="not(@articlenr)">
        <xsl:choose>
          <xsl:when test="$proof_links = 0">
            <!-- experimental!! -->
            <xsl:variable name="n1" select="@nr"/>
            <xsl:variable name="vid">
              <xsl:choose>
                <xsl:when test="@vid">
                  <xsl:value-of select="@vid"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$print_lab_identifiers &gt; 0">
                      <!-- for-each [preceding::*[((name()="Proposition") or (name()="Now") or (name()="IterEquality")) and (@nr=$n1)][1]] -->
                      <!-- this seems to be reasonably fast -->
                      <xsl:for-each select="(preceding::Proposition[@nr=$n1]|preceding::Now[@nr=$n1]
                           |preceding::IterEquality[@nr=$n1])[last()]">
                        <xsl:value-of select="@vid"/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="pplab">
              <xsl:with-param name="nr" select="$n1"/>
              <xsl:with-param name="vid" select="$vid"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="pl">
              <xsl:call-template name="get_nearest_level">
                <xsl:with-param name="el" select=".."/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="privname">
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="getref">
          <xsl:with-param name="k" select="@kind"/>
          <xsl:with-param name="anr" select="@articlenr"/>
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ErrorInf">
    <xsl:param name="nbr"/>
    <xsl:text>errorinference;</xsl:text>
    <xsl:if test="not($nbr=&quot;1&quot;)">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IterStep/ErrorInf">
    <xsl:text>errorinference</xsl:text>
  </xsl:template>

  <xsl:template match="SkippedProof">
    <xsl:param name="nbr"/>
    <xsl:if test="$ajax_proofs=2">
      <xsl:element name="span">
        <xsl:attribute name="filebasedproofinsert">
          <xsl:value-of select="@newlevel"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>@proof .. end;</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="not($nbr=&quot;1&quot;)">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IterStep/SkippedProof">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>@proof .. end;</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Term, elIterStep+ -->
  <xsl:template match="IterEquality">
    <xsl:param name="nbr"/>
    <xsl:if test="IterStep[1]/By[@linked=&quot;true&quot;]">
      <xsl:if test="not(name(..)=&quot;Conclusion&quot;)">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>then </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@nr&gt;0">
      <xsl:call-template name="pplab">
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="vid" select="@vid"/>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> = </xsl:text>
    <xsl:call-template name="nlist">
      <xsl:with-param name="separ">
        <xsl:text>.= </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="IterStep"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <xsl:if test="not($nbr=&quot;1&quot;)">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IterStep">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Skeleton steps -->
  <!-- tpl [Let] { $j=`@nr`; pkeyword(#str="let "); pconst(#nr=$j); -->
  <!-- " be "; -->
  <!-- jlist(#j=$j, #sep2=" be ", #elems=`*`); -->
  <!-- ";"; try_th_exps(); <br; } -->
  <!-- #fst tells to process in a sequence of Let's -->
  <!-- #beg is the beginning of const. sequence numbers -->
  <xsl:template match="Let">
    <xsl:param name="fst"/>
    <xsl:param name="beg"/>
    <xsl:variable name="has_thesis">
      <xsl:choose>
        <xsl:when test="following-sibling::*[1][name()=&quot;Thesis&quot;]">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="it_step">
      <xsl:choose>
        <xsl:when test="$has_thesis=&quot;1&quot;">
          <xsl:text>2</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not($fst=&quot;1&quot;) and (preceding-sibling::*[position()=$it_step][name()=&quot;Let&quot;])"/>
      <xsl:otherwise>
        <!-- try next Let for the same type - we cannot deal with thesis here -->
        <xsl:variable name="next">
          <xsl:choose>
            <xsl:when test="(count(Typ)=1) and 
         (following-sibling::*[position()=$it_step][name()=&quot;Let&quot;][count(Typ)=1]) and
	 (($has_thesis=&quot;0&quot;) or 
	  ((following-sibling::*[1][name()=&quot;Thesis&quot;][not(ThesisExpansions/Pair)])
	   and
	   (following-sibling::*[3][name()=&quot;Thesis&quot;][not(ThesisExpansions/Pair)])))">
              <xsl:call-template name="are_equal_vid">
                <xsl:with-param name="el1" select="./Typ"/>
                <xsl:with-param name="el2" select="following-sibling::*[position()=$it_step]/Typ"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$beg">
            <xsl:text>, </xsl:text>
            <xsl:if test="$const_links&gt;0">
              <xsl:variable name="addpl">
                <xsl:call-template name="addp">
                  <xsl:with-param name="pl" select="@plevel"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:element name="a">
                <xsl:attribute name="NAME">
                  <xsl:value-of select="concat(&quot;c&quot;,@nr,$addpl)"/>
                </xsl:attribute>
              </xsl:element>
            </xsl:if>
            <xsl:call-template name="ppconst">
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="vid" select="Typ/@vid"/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="$next=&quot;1&quot;">
                <xsl:apply-templates select="following-sibling::*[position()=$it_step]">
                  <xsl:with-param name="fst">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="beg" select="$beg"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> be </xsl:text>
                <xsl:apply-templates select="Typ"/>
                <xsl:text>;</xsl:text>
                <xsl:call-template name="try_th_exps"/>
                <xsl:element name="br"/>
                <xsl:apply-templates select="following-sibling::*[position()=$it_step][name()=&quot;Let&quot;]">
                  <xsl:with-param name="fst">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text>let </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="$next=&quot;1&quot;">
                <xsl:if test="$const_links&gt;0">
                  <xsl:variable name="addpl">
                    <xsl:call-template name="addp">
                      <xsl:with-param name="pl" select="@plevel"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:element name="a">
                    <xsl:attribute name="NAME">
                      <xsl:value-of select="concat(&quot;c&quot;,@nr,$addpl)"/>
                    </xsl:attribute>
                  </xsl:element>
                </xsl:if>
                <xsl:call-template name="ppconst">
                  <xsl:with-param name="nr" select="@nr"/>
                  <xsl:with-param name="vid" select="Typ/@vid"/>
                </xsl:call-template>
                <xsl:apply-templates select="following-sibling::*[position()=$it_step]">
                  <xsl:with-param name="fst">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="beg" select="@nr"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="jtlist">
                  <xsl:with-param name="j" select="@nr - 1"/>
                  <xsl:with-param name="sep2">
                    <xsl:text> be </xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="elems" select="Typ"/>
                  <xsl:with-param name="pl" select="@plevel"/>
                </xsl:call-template>
                <xsl:text>;</xsl:text>
                <xsl:call-template name="try_th_exps"/>
                <xsl:element name="br"/>
                <xsl:apply-templates select="following-sibling::*[position()=$it_step][name()=&quot;Let&quot;]">
                  <xsl:with-param name="fst">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Assume">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>assume </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="count(*)&gt;1">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>that </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="br"/>
    </xsl:if>
    <xsl:call-template name="andlist">
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <xsl:call-template name="try_th_exps"/>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- should handle both the new version with the existential statement -->
  <!-- at the first position, and also the old version without it -->
  <xsl:template match="Given">
    <xsl:variable name="j" select="@nr - 1"/>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>given </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="jtlist">
      <xsl:with-param name="j" select="$j"/>
      <xsl:with-param name="sep2">
        <xsl:text> being </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="Typ"/>
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:call-template>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text> such that </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="andlist">
      <xsl:with-param name="elems" select="*[(name()=&quot;Proposition&quot;) and (position() &gt; 1)]"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <xsl:call-template name="try_th_exps"/>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="Take">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>take </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:text>;</xsl:text>
    <xsl:call-template name="try_th_exps"/>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="TakeAsVar">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>take </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$const_links&gt;0">
      <xsl:variable name="addpl">
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:element name="a">
        <xsl:attribute name="NAME">
          <xsl:value-of select="concat(&quot;c&quot;,@nr,$addpl)"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:call-template name="ppconst">
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="vid" select="Typ[1]/@vid"/>
    </xsl:call-template>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>;</xsl:text>
    <xsl:call-template name="try_th_exps"/>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="Conclusion">
    <xsl:choose>
      <xsl:when test="(By[@linked = &quot;true&quot;]) or 
       (IterEquality/IterStep[1]/By[@linked = &quot;true&quot;])">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>hence </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="*[not(name() = &quot;By&quot;)]"/>
        <xsl:apply-templates select="By">
          <xsl:with-param name="nbr">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:call-template name="try_th_exps"/>
        <xsl:element name="br"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="Now">
            <xsl:element name="div">
              <xsl:call-template name="pkeyword">
                <xsl:with-param name="str">
                  <xsl:text>hereby </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="try_th_exps"/>
              <xsl:apply-templates>
                <xsl:with-param name="nkw">
                  <xsl:text>1</xsl:text>
                </xsl:with-param>
              </xsl:apply-templates>
              <xsl:call-template name="pkeyword">
                <xsl:with-param name="str">
                  <xsl:text>end;</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text>thus </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="Proof">
                <xsl:apply-templates select="Proposition"/>
                <xsl:call-template name="try_th_exps"/>
                <xsl:apply-templates select="Proof"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="Proposition"/>
                <xsl:apply-templates select=" IterEquality|By|From|ErrorInf|SkippedProof">
                  <xsl:with-param name="nbr">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
                <xsl:call-template name="try_th_exps"/>
                <xsl:element name="br"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Auxiliary items -->
  <!-- First comes the reconstructed existential statement -->
  <!-- and its justification, then the new local constants -->
  <!-- and zero or more propositions about them. -->
  <!-- For easier presentation, nr optionally contains the number -->
  <!-- of the first local constant created here. -->
  <!--  -->
  <!-- element Consider { -->
  <!-- attribute nr { xsd:integer }?, -->
  <!-- Proposition, Justification, -->
  <!-- Typ+, Proposition* -->
  <!-- } -->
  <xsl:template match="Consider">
    <xsl:variable name="j" select="@nr - 1"/>
    <xsl:if test="By[@linked=&quot;true&quot;]">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>then </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>consider </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="jtlist">
      <xsl:with-param name="j" select="$j"/>
      <xsl:with-param name="sep2">
        <xsl:text> being </xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="Typ"/>
      <xsl:with-param name="pl" select="@plevel"/>
    </xsl:call-template>
    <xsl:if test="count(Proposition) &gt; 1">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text> such that </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="br"/>
      <xsl:call-template name="andlist">
        <xsl:with-param name="elems" select="Proposition[position() &gt; 1]"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <!-- First comes the series of target types and reconsidered terms. -->
  <!-- For all these terms a new local variable with its target type -->
  <!-- is created, and its equality to the corresponding term is remembered. -->
  <!-- Finally the proposition about the typing is given and justified. -->
  <!-- For easier presentation, atNr optionally contains the number -->
  <!-- of the first local constant created here. -->
  <!-- Each type may optionally have presentational info about -->
  <!-- the variable (atVid) inside. -->
  <!-- element elReconsider { -->
  <!-- attribute atNr { xsd:integer }?, -->
  <!-- (elTyp, Term)+, -->
  <!-- elProposition, Justification -->
  <!-- } -->
  <xsl:template match="Reconsider">
    <xsl:variable name="j" select="@nr"/>
    <xsl:if test="By[@linked=&quot;true&quot;]">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>then </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>reconsider </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="addpl">
      <xsl:if test="$const_links&gt;0">
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <!-- should work both for old and new reconsider -->
    <xsl:for-each select="*[(not(name() = &quot;Typ&quot;)) and (position() &lt; (last() - 1))]">
      <xsl:variable name="p1" select="position()"/>
      <xsl:variable name="nr1" select="$j + $p1 - 1"/>
      <xsl:if test="$const_links&gt;0">
        <xsl:element name="a">
          <xsl:attribute name="NAME">
            <xsl:value-of select="concat(&quot;c&quot;,$nr1,$addpl)"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
      <xsl:call-template name="ppconst">
        <xsl:with-param name="nr" select="$nr1"/>
        <xsl:with-param name="vid" select="../Typ[$p1]/@vid"/>
      </xsl:call-template>
      <xsl:text> = </xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:if test="not($p1=last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <!-- ppconst(#nr=$j, #vid = `Typ[1]/@vid`); " = "; -->
    <!-- jlist(#j=$j, #sep2=" = ", #elems=`*[(not(name() = "Typ")) -->
    <!-- and (position() < (last() - 1))]`); -->
    <xsl:text> as </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="*[last()]"/>
  </xsl:template>

  <xsl:template match="Set">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>set </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$const_links&gt;0">
      <xsl:variable name="addpl">
        <xsl:call-template name="addp">
          <xsl:with-param name="pl" select="@plevel"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:element name="a">
        <xsl:attribute name="NAME">
          <xsl:value-of select="concat(&quot;c&quot;,@nr,$addpl)"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:call-template name="ppconst">
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="vid" select="Typ/@vid"/>
    </xsl:call-template>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="DefFunc">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>deffunc </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="ppfunc">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>) </xsl:text>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>-&gt; </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="*[3]"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="DefPred">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>defpred </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="pppred">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>] </xsl:text>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>means </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- Thesis after skeleton item, with definiens numbers -->
  <!-- forbid as default -->
  <xsl:template match="Thesis"/>

  <xsl:template name="do_thesis">
    <xsl:param name="nd"/>
    <xsl:apply-templates select="ThesisExpansions"/>
    <xsl:if test="($display_thesis = 1) and (not($nd = 1))">
      <xsl:text> </xsl:text>
      <xsl:element name="a">
        <xsl:call-template name="add_hs_attrs"/>
        <xsl:call-template name="pcomment0">
          <xsl:with-param name="str">
            <xsl:text> thesis: </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <xsl:element name="span">
        <xsl:attribute name="class">
          <xsl:text>hide</xsl:text>
        </xsl:attribute>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="*[1]"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="try_th_exps_old">
    <xsl:apply-templates select="./following-sibling::*[1][name()=&quot;Thesis&quot;]/ThesisExpansions"/>
  </xsl:template>

  <!-- #nd overrides the $display_thesis parameter in do_thesis, -->
  <!-- used to supress the incorrect PerCases thesis now -->
  <xsl:template name="try_th_exps">
    <xsl:param name="nd"/>
    <xsl:choose>
      <xsl:when test="./following-sibling::*[1][name()=&quot;Thesis&quot;]">
        <xsl:for-each select="./following-sibling::*[1][name()=&quot;Thesis&quot;]">
          <xsl:call-template name="do_thesis">
            <xsl:with-param name="nd" select="$nd"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="((name(..) = &quot;Now&quot;) or (name(..) = &quot;CaseBlock&quot;) or (name(..) = &quot;SupposeBlock&quot;))
              and (../BlockThesis/Thesis)">
          <xsl:variable name="prev_thesis_changes" select="count(./preceding-sibling::*[(name()=&quot;Let&quot;) or (name()=&quot;Take&quot;) 
	                               or (name()=&quot;TakeAsVar&quot;) or (name()=&quot;Assume&quot;)
	                               or (name()=&quot;Case&quot;) or (name()=&quot;Suppose&quot;)
				       or (name()=&quot;Given&quot;) or (name()=&quot;Conclusion&quot;)])"/>
          <xsl:for-each select=" ../BlockThesis/Thesis[$prev_thesis_changes + 1]">
            <xsl:call-template name="do_thesis">
              <xsl:with-param name="nd" select="$nd"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ThesisExpansions">
    <xsl:if test="Pair">
      <xsl:text> </xsl:text>
      <xsl:call-template name="pcomment0">
        <xsl:with-param name="str">
          <xsl:text>according to </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Pair[@x]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ThesisExpansions/Pair">
    <xsl:variable name="x" select="@x"/>
    <xsl:variable name="doc">
      <xsl:choose>
        <xsl:when test="key(&apos;DF&apos;,$x)">
          <xsl:text/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$dfs"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="current">
      <xsl:choose>
        <xsl:when test="$doc=&quot;&quot;">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="document($doc,/)">
      <xsl:for-each select="key(&apos;DF&apos;,$x)">
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="@aid"/>
          <xsl:with-param name="nr" select="@defnr"/>
          <xsl:with-param name="k">
            <xsl:text>D</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="c" select="$current"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- special block skeleton items -->
  <!-- element Suppose { Proposition+ } -->
  <!-- element Case { Proposition+ } -->
  <xsl:template match="Case|Suppose">
    <xsl:if test="count(*)&gt;1">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>that </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="andlist">
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <!-- this will break the thesis display in diffuse statements -->
    <!-- for earlier kernel (analyzer v. < 1.94) - mea culpa, -->
    <!-- the only reasonable backward-compatibility fix would be to -->
    <!-- keep the kernel version as a parameter and check it here -->
    <xsl:call-template name="try_th_exps"/>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- element PerCases { Proposition, Inference } -->
  <xsl:template match="PerCases">
    <xsl:element name="a">
      <xsl:call-template name="add_hs_attrs"/>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>cases </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>hide</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*[1]"/>
    </xsl:element>
    <xsl:apply-templates select="*[position()&gt;1]"/>
    <!-- thesis after per cases is broken yet and would have -->
    <!-- to be reconstructed from subblocks' theses; -->
    <!-- don't display it, only display the expansions -->
    <xsl:call-template name="try_th_exps">
      <xsl:with-param name="nd">
        <xsl:text>1</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
