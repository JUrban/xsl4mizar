<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_print_complex.xsl"/>

  <!-- $Revision: 1.5 $ -->
  <!--  -->
  <!-- File: frmtrm.xsltxt - html-ization of Mizar XML, code for terms, formulas, and types -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- Formulas -->
  <!-- #i is nr of the bound variable, 0 by default -->
  <!-- #k is start of the sequence of vars with the same type, $i by default -->
  <!-- we now output only one typing for such sequences -->
  <!-- #ex tells that we should print it as existential statement, -->
  <!-- i.e. also omitting the first descending Not (the caller -->
  <!-- should guarantee that there _is_ a Not after the block of For-s) -->
  <!-- #pr tells to put the formula in paranthesis -->
  <xsl:template match="For">
    <xsl:param name="i"/>
    <xsl:param name="k"/>
    <xsl:param name="ex"/>
    <xsl:param name="pr"/>
    <xsl:variable name="j">
      <xsl:choose>
        <xsl:when test="$i">
          <xsl:value-of select="$i"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="l">
      <xsl:choose>
        <xsl:when test="$k">
          <xsl:value-of select="$k"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$j"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$l = $j">
      <!-- print initial quantifier if at the beginning of var segment -->
      <xsl:if test="$pr">
        <xsl:text>( </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$ex=&quot;1&quot;">
          <xsl:text> ex </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>for </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:call-template name="pqvar">
      <xsl:with-param name="nr" select="$j + 1"/>
      <xsl:with-param name="vid" select="@vid"/>
    </xsl:call-template>
    <xsl:variable name="nm">
      <xsl:value-of select="name(*[2])"/>
    </xsl:variable>
    <xsl:variable name="eq1">
      <xsl:choose>
        <xsl:when test="($nm = &quot;For&quot;) and (*[1]/@nr = *[2]/*[1]/@nr)">
          <xsl:call-template name="are_equal">
            <xsl:with-param name="el1" select="*[1]"/>
            <xsl:with-param name="el2" select="*[2]/*[1]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$eq1=&quot;1&quot;">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="*[2]">
          <xsl:with-param name="i" select="$j+1"/>
          <xsl:with-param name="k" select="$l"/>
          <xsl:with-param name="ex" select="$ex"/>
          <xsl:with-param name="pr" select="$pr"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$ex=&quot;1&quot;">
            <xsl:text> being</xsl:text>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="i" select="$j + 1"/>
            </xsl:apply-templates>
            <xsl:choose>
              <xsl:when test="$nm = &quot;For&quot;">
                <xsl:apply-templates select="*[2]">
                  <xsl:with-param name="i" select="$j+1"/>
                  <xsl:with-param name="ex" select="$ex"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> st </xsl:text>
                <!-- $nm; -->
                <xsl:if test="($nm = &quot;And&quot;) or (name(Not/*[1]) = &quot;And&quot;) or (name(Not/*[1]) = &quot;For&quot;)">
                  <xsl:element name="br"/>
                </xsl:if>
                <xsl:apply-templates select="Not/*[1]">
                  <xsl:with-param name="i" select="$j+1"/>
                </xsl:apply-templates>
                <xsl:choose>
                  <xsl:when test="Pred|PrivPred|Is|Verum|ErrorFrm">
                    <!-- " PREDFOR "; -->
                    <xsl:apply-templates select="*[2]">
                      <xsl:with-param name="i" select="$j+1"/>
                      <xsl:with-param name="not">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:apply-templates>
                  </xsl:when>
                  <!-- for antonymous Preds -->
                  <xsl:otherwise>
                    <xsl:if test="And">
                      <xsl:text>( </xsl:text>
                      <xsl:choose>
                        <xsl:when test="And[@pid=$pid_Or_And]">
                          <xsl:for-each select="*[2]/*">
                            <xsl:if test="position()&gt;1">
                              <xsl:text> or </xsl:text>
                            </xsl:if>
                            <xsl:variable name="neg1">
                              <xsl:call-template name="is_negative">
                                <xsl:with-param name="el" select="."/>
                              </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                              <xsl:when test="$neg1 = &quot;1&quot;">
                                <xsl:choose>
                                  <xsl:when test="name() = &quot;Not&quot;">
                                    <xsl:apply-templates select="*[1]">
                                      <xsl:with-param name="i" select="$j+1"/>
                                    </xsl:apply-templates>
                                  </xsl:when>
                                  <!-- now Pred, which is antonymous -->
                                  <xsl:otherwise>
                                    <xsl:apply-templates select=".">
                                      <xsl:with-param name="i" select="$j+1"/>
                                      <xsl:with-param name="not">
                                        <xsl:text>1</xsl:text>
                                      </xsl:with-param>
                                    </xsl:apply-templates>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:choose>
                                  <xsl:when test="name() = &quot;For&quot;">
                                    <xsl:apply-templates select=".">
                                      <xsl:with-param name="i" select="$j+1"/>
                                      <xsl:with-param name="ex">
                                        <xsl:text>1</xsl:text>
                                      </xsl:with-param>
                                    </xsl:apply-templates>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text> not </xsl:text>
                                    <xsl:apply-templates select=".">
                                      <xsl:with-param name="i" select="$j+1"/>
                                    </xsl:apply-templates>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                          <!-- pretend this is an impl -->
                          <xsl:call-template name="ilist">
                            <xsl:with-param name="separ">
                              <xsl:text> &amp; </xsl:text>
                            </xsl:with-param>
                            <xsl:with-param name="elems" select="*[2]/*[position()&lt;last()]"/>
                            <xsl:with-param name="i" select="$j+1"/>
                            <xsl:with-param name="pr">
                              <xsl:text>1</xsl:text>
                            </xsl:with-param>
                          </xsl:call-template>
                          <xsl:text> implies </xsl:text>
                          <xsl:choose>
                            <xsl:when test="*[2]/*[@pid=$pid_Impl_RightNot]">
                              <xsl:apply-templates select="*[2]/*[@pid=$pid_Impl_RightNot]/*[1]">
                                <xsl:with-param name="i" select="$j+1"/>
                              </xsl:apply-templates>
                            </xsl:when>
                            <xsl:when test="name(*[2]/*[position()=last()]) = &quot;For&quot;">
                              <xsl:apply-templates select="*[2]/*[position()=last()]">
                                <xsl:with-param name="i" select="$j+1"/>
                                <xsl:with-param name="ex">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:variable name="neg1">
                                <xsl:call-template name="is_negative">
                                  <xsl:with-param name="el" select="*[2]/*[position()=last()]"/>
                                </xsl:call-template>
                              </xsl:variable>
                              <xsl:choose>
                                <xsl:when test="$neg1 = &quot;1&quot;">
                                  <xsl:choose>
                                    <xsl:when test="name(*[2]/*[position()=last()]) = &quot;Not&quot;">
                                      <xsl:apply-templates select="*[2]/*[position()=last()]/*[1]">
                                        <xsl:with-param name="i" select="$j+1"/>
                                      </xsl:apply-templates>
                                    </xsl:when>
                                    <!-- now Pred, which is antonymous -->
                                    <xsl:otherwise>
                                      <xsl:apply-templates select="*[2]/*[position()=last()]">
                                        <xsl:with-param name="i" select="$j+1"/>
                                        <xsl:with-param name="not">
                                          <xsl:text>1</xsl:text>
                                        </xsl:with-param>
                                      </xsl:apply-templates>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:text> not </xsl:text>
                                  <xsl:apply-templates select="*[2]/*[position()=last()]">
                                    <xsl:with-param name="i" select="$j+1"/>
                                  </xsl:apply-templates>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text> )</xsl:text>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> being</xsl:text>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="i" select="$j + 1"/>
            </xsl:apply-templates>
            <xsl:if test="not(($nm = &quot;For&quot;) or ($nm=&quot;Not&quot;))">
              <xsl:text> holds </xsl:text>
            </xsl:if>
            <xsl:if test="($nm = &quot;And&quot;) or ($nm=&quot;For&quot;)">
              <xsl:element name="br"/>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$nm=&quot;Not&quot;">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="*[2]">
                  <xsl:with-param name="i" select="$j+1"/>
                  <xsl:with-param name="st">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="*[2]">
                  <xsl:with-param name="i" select="$j+1"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$pr">
          <xsl:text> )</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [And/For] { <div {"for B being"; apply[*[1]]; -->
  <!-- " holds "; <div { @class="add";  apply[*[2]]; } } } -->
  <!-- return 1 if this is a Not-ended sequence of For-s -->
  <xsl:template name="check_for_not">
    <xsl:param name="el"/>
    <xsl:choose>
      <xsl:when test="(name($el)=&quot;Not&quot;) or (name($el)=&quot;Pred&quot;)">
        <xsl:call-template name="is_negative">
          <xsl:with-param name="el" select="$el"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="(name($el)=&quot;And&quot;) and (($el/@pid = $pid_Or_And) or ($el/@pid = $pid_Impl_And))">
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Not">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="st"/>
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
          <xsl:with-param name="ex">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="Pred|Is|PrivPred|Verum|ErrorFrm">
            <xsl:if test="$st=&quot;1&quot;">
              <xsl:text> holds </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="not">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="i3">
              <xsl:call-template name="is_impl1">
                <xsl:with-param name="el" select="."/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$i3 &gt; 0">
                <!-- " IMPL1 "; $i3; -->
                <xsl:choose>
                  <xsl:when test="$st=&quot;1&quot;">
                    <xsl:text> st </xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>( </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="$i3=2">
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ">
                        <xsl:text> &amp; </xsl:text>
                      </xsl:with-param>
                      <xsl:with-param name="elems" select="*[1]/*[not(@pid=$pid_Impl_RightNot)]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                      <xsl:when test="$st=&quot;1&quot;">
                        <xsl:text> holds </xsl:text>
                        <xsl:element name="br"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text> implies </xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[1]/*[@pid=$pid_Impl_RightNot]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ">
                        <xsl:text> &amp; </xsl:text>
                      </xsl:with-param>
                      <xsl:with-param name="elems" select="*[1]/*[position()&lt;last()]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                      <xsl:when test="$st=&quot;1&quot;">
                        <xsl:text> holds </xsl:text>
                        <xsl:element name="br"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text> implies </xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="$i3=3">
                        <xsl:choose>
                          <xsl:when test="name(*[1]/*[position()=last()]) = &quot;Not&quot;">
                            <xsl:apply-templates select="*[1]/*[position()=last()]/*[1]">
                              <xsl:with-param name="i" select="$i"/>
                            </xsl:apply-templates>
                          </xsl:when>
                          <!-- now Pred, which is antonymous -->
                          <xsl:otherwise>
                            <xsl:apply-templates select="*[1]/*[position()=last()]">
                              <xsl:with-param name="i" select="$i"/>
                              <xsl:with-param name="not">
                                <xsl:text>1</xsl:text>
                              </xsl:with-param>
                            </xsl:apply-templates>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:when test="$i3=4">
                        <xsl:apply-templates select="*[1]/*[position()=last()]">
                          <xsl:with-param name="i" select="$i"/>
                          <xsl:with-param name="ex">
                            <xsl:text>1</xsl:text>
                          </xsl:with-param>
                        </xsl:apply-templates>
                      </xsl:when>
                      <xsl:when test="$i3=5">
                        <xsl:text> not </xsl:text>
                        <xsl:apply-templates select="*[1]/*[position()=last()]">
                          <xsl:with-param name="i" select="$i"/>
                        </xsl:apply-templates>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not($st=&quot;1&quot;)">
                  <xsl:text> )</xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$st=&quot;1&quot;">
                  <xsl:text> holds </xsl:text>
                  <xsl:element name="br"/>
                </xsl:if>
                <xsl:variable name="i1_1">
                  <xsl:call-template name="is_or1">
                    <xsl:with-param name="el" select="."/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="i1">
                  <xsl:choose>
                    <xsl:when test="$i1_1=&quot;1&quot;">
                      <xsl:text>1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- artifficially system-constructed complex fla, try some reconstruction -->
                      <xsl:choose>
                        <xsl:when test="not(@pid) and (name(*[1])=&quot;And&quot;) and (count(*[1]/*)&gt;=2)">
                          <xsl:text>1</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>0</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$i1=&quot;1&quot;">
                    <xsl:text>( </xsl:text>
                    <!-- " OR1 "; -->
                    <xsl:for-each select="*[1]/*">
                      <xsl:if test="position()&gt;1">
                        <xsl:text> or </xsl:text>
                      </xsl:if>
                      <xsl:variable name="neg1">
                        <xsl:call-template name="is_negative">
                          <xsl:with-param name="el" select="."/>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="$neg1 = &quot;1&quot;">
                          <xsl:choose>
                            <xsl:when test="name() = &quot;Not&quot;">
                              <xsl:apply-templates select="*[1]">
                                <xsl:with-param name="i" select="$i"/>
                              </xsl:apply-templates>
                            </xsl:when>
                            <!-- now Pred, which is antonymous -->
                            <xsl:otherwise>
                              <xsl:apply-templates select=".">
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="not">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:apply-templates>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:choose>
                            <xsl:when test="name() = &quot;For&quot;">
                              <xsl:apply-templates select=".">
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="ex">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text> not </xsl:text>
                              <xsl:apply-templates select=".">
                                <xsl:with-param name="i" select="$i"/>
                              </xsl:apply-templates>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                    <xsl:text> )</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>not </xsl:text>
                    <xsl:if test="@pid">
                      <xsl:comment>
                        <xsl:text>HUMANRECFAILED</xsl:text>
                      </xsl:comment>
                    </xsl:if>
                    <!-- else {"NOPID  ";} -->
                    <xsl:apply-templates select="*[1]">
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:apply-templates>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- this was too AI, mizar is much simpler -->
  <!-- $cnt=`count(*[1]/*)`; -->
  <!-- $pcnt1 = { if [$i3="1"] { count_positive(#els=`*[1]/*`,#nr=$cnt); } else {"10000";} } -->
  <!-- $pcnt = $pcnt1; -->
  <!-- // $pcnt1; ":"; $cnt; ":"; $i3; -->
  <!-- if [($pcnt>0) and ($pcnt<$cnt)] { -->
  <!-- // "hhhhhhhhhhhh"; -->
  <!-- "( "; put_positive(#separ=" & ",#els=`*[1]/*`,#nr=$pcnt,#i=$i); " implies "; -->
  <!-- put_positive(#separ=" or ",#els=`*[1]/*`,#nr=`$cnt - $pcnt`,#neg="1",#i=$i); ")"; -->
  <!-- } -->
  <!-- else { if [($i3="1") and ($pcnt=0)] { "( "; put_positive(#separ=" or ",#els=`*[1]/*`,#nr=$cnt,#neg="1",#i=$i); ")"; } -->
  <!-- if [$i3="1"  and (*[1]/*[not(name()="Not")]) and (*[1]/Not)] { "( ( "; -->
  <!-- ilist(#separ=" & ", #elems=`*[1]/*[not(name()="Not")]`, #i=$i,#pr="1"); -->
  <!-- " )"; " implies "; -->
  <!-- "( "; ilist(#separ=" or ", #elems=`*[1]/Not/*[1]`, #i=$i,#pr="1"); " ) )"; } -->
  <xsl:template match="And">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:variable name="e1">
      <xsl:call-template name="is_equiv">
        <xsl:with-param name="el" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$e1=&quot;1&quot;">
        <xsl:text>( </xsl:text>
        <xsl:apply-templates select="*[1]/*[1]/*[1]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pr">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:text> iff </xsl:text>
        <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
          <xsl:with-param name="i" select="$i"/>
        </xsl:apply-templates>
        <xsl:text> )</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- a bit risky -->
        <xsl:choose>
          <xsl:when test="(@pid=$pid_Iff) and (count(*)=2)">
            <xsl:variable name="i1">
              <xsl:call-template name="is_impl">
                <xsl:with-param name="el" select="*[1]"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$i1=&quot;1&quot;">
                <xsl:text>( </xsl:text>
                <xsl:apply-templates select="*[1]/*[1]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pr">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
                <xsl:text> iff </xsl:text>
                <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                </xsl:apply-templates>
                <xsl:text> )</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="i2">
                  <xsl:call-template name="is_impl">
                    <xsl:with-param name="el" select="*[2]"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$i2=&quot;1&quot;">
                    <xsl:text>( </xsl:text>
                    <xsl:apply-templates select="*[2]/*[1]/*[2]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:text> iff </xsl:text>
                    <xsl:apply-templates select="*[2]/*[1]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:apply-templates>
                    <xsl:text> )</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="i3">
                      <xsl:call-template name="is_impl1">
                        <xsl:with-param name="el" select="*[1]"/>
                      </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="i4">
                      <xsl:call-template name="is_impl1">
                        <xsl:with-param name="el" select="*[2]"/>
                      </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="($i3 &gt; 0) or ($i4 &gt; 0)">
                        <!-- select better impl - no, prefer the first -->
                        <xsl:variable name="which">
                          <xsl:choose>
                            <xsl:when test="($i3 = 0)">
                              <xsl:text>2</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text>1</xsl:text>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <!-- if [($i4 = 0)] { "1"; } else { -->
                        <!-- if [$i3 > $i4] { "2"; } else { "1"; }}}} -->
                        <xsl:variable name="i5">
                          <xsl:choose>
                            <xsl:when test="$which=1">
                              <xsl:value-of select="$i3"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="$i4"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:for-each select="*[position()=$which]">
                          <!-- " IFF2: "; $which; -->
                          <xsl:text>( </xsl:text>
                          <xsl:choose>
                            <xsl:when test="$i5=2">
                              <xsl:call-template name="ilist">
                                <xsl:with-param name="separ">
                                  <xsl:text> &amp; </xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="elems" select="*[1]/*[not(@pid=$pid_Impl_RightNot)]"/>
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="pr">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:call-template>
                              <xsl:text> iff </xsl:text>
                              <xsl:apply-templates select="*[1]/*[@pid=$pid_Impl_RightNot]/*[1]">
                                <xsl:with-param name="i" select="$i"/>
                              </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="ilist">
                                <xsl:with-param name="separ">
                                  <xsl:text> &amp; </xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="elems" select="*[1]/*[position()&lt;last()]"/>
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="pr">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:call-template>
                              <xsl:text> iff </xsl:text>
                              <xsl:choose>
                                <xsl:when test="$i5=3">
                                  <xsl:choose>
                                    <xsl:when test="name(*[1]/*[position()=last()]) = &quot;Not&quot;">
                                      <xsl:apply-templates select="*[1]/*[position()=last()]/*[1]">
                                        <xsl:with-param name="i" select="$i"/>
                                      </xsl:apply-templates>
                                    </xsl:when>
                                    <!-- now Pred, which is antonymous -->
                                    <xsl:otherwise>
                                      <xsl:apply-templates select="*[1]/*[position()=last()]">
                                        <xsl:with-param name="i" select="$i"/>
                                        <xsl:with-param name="not">
                                          <xsl:text>1</xsl:text>
                                        </xsl:with-param>
                                      </xsl:apply-templates>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$i5=4">
                                  <xsl:apply-templates select="*[1]/*[position()=last()]">
                                    <xsl:with-param name="i" select="$i"/>
                                    <xsl:with-param name="ex">
                                      <xsl:text>1</xsl:text>
                                    </xsl:with-param>
                                  </xsl:apply-templates>
                                </xsl:when>
                                <xsl:when test="$i5=5">
                                  <xsl:text> not </xsl:text>
                                  <xsl:apply-templates select="*[1]/*[position()=last()]">
                                    <xsl:with-param name="i" select="$i"/>
                                  </xsl:apply-templates>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:text> )</xsl:text>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>( </xsl:text>
                        <xsl:comment>
                          <xsl:text>HUMANRECFAILED</xsl:text>
                        </xsl:comment>
                        <xsl:call-template name="ilist">
                          <xsl:with-param name="separ">
                            <xsl:text> &amp; </xsl:text>
                          </xsl:with-param>
                          <xsl:with-param name="elems" select="*"/>
                          <xsl:with-param name="i" select="$i"/>
                          <xsl:with-param name="pr">
                            <xsl:text>1</xsl:text>
                          </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text> )</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>( </xsl:text>
            <!-- if[not(@pid)] { " NOPID ";} -->
            <xsl:call-template name="ilist">
              <xsl:with-param name="separ">
                <xsl:text> &amp; </xsl:text>
              </xsl:with-param>
              <xsl:with-param name="elems" select="*"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pr">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text> )</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:param name="not"/>
    <xsl:param name="pr"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;P&apos;">
        <xsl:call-template name="pschpvar">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
        <xsl:text>[</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="(@kind=&apos;V&apos;) or (@kind=&apos;R&apos;)">
        <xsl:variable name="pi">
          <xsl:call-template name="patt_info">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="pid" select="@pid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="fnr">
          <xsl:call-template name="car">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="antonym">
          <xsl:call-template name="cadr">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="plink">
          <xsl:call-template name="third">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="pid">
          <xsl:choose>
            <xsl:when test="$plink=&quot;1&quot;">
              <xsl:value-of select="@pid"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="predattr">
          <xsl:choose>
            <xsl:when test="$antonym&gt;1">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="neg">
          <xsl:choose>
            <xsl:when test="$not=&quot;1&quot;">
              <xsl:value-of select="($antonym + $not) mod 2"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$antonym mod 2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$neg=&quot;1&quot;">
          <xsl:text>not </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="(@kind=&apos;V&apos;) and ($predattr=&quot;0&quot;)">
            <xsl:apply-templates select="*[position() = last()]">
              <xsl:with-param name="i" select="$i"/>
            </xsl:apply-templates>
            <xsl:text> is </xsl:text>
            <xsl:call-template name="abs">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="sym">
                <xsl:call-template name="abs1">
                  <xsl:with-param name="k" select="@kind"/>
                  <xsl:with-param name="nr" select="@nr"/>
                  <xsl:with-param name="fnr" select="$fnr"/>
                  <xsl:with-param name="pid" select="$pid"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pp">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="args" select="*"/>
              <xsl:with-param name="pid" select="@pid"/>
              <xsl:with-param name="i" select="$i"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ,#sym1=abs(#k=`@kind`, #nr=`@nr`, #sym=abs1(#k=`@kind`, #nr=`@nr`))); }} -->
  <!-- "[ "; list(#separ=",", #elems=`*`); "]"; } -->
  <xsl:template match="PrivPred">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:if test="$not=&quot;1&quot;">
      <xsl:text> not </xsl:text>
    </xsl:if>
    <xsl:call-template name="pppred">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*[position() &lt; last()]"/>
      <xsl:with-param name="i" select="$i"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="Is">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="i" select="$i"/>
    </xsl:apply-templates>
    <xsl:text> is </xsl:text>
    <xsl:if test="$not=&quot;1&quot;">
      <xsl:text> not </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*[2]">
      <xsl:with-param name="i" select="$i"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Verum">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:choose>
      <xsl:when test="$not=&quot;1&quot;">
        <xsl:text>contradiction</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>verum</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ErrorFrm">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:if test="$not=&quot;1&quot;">
      <xsl:text> not </xsl:text>
    </xsl:if>
    <xsl:text>errorfrm</xsl:text>
  </xsl:template>

  <!-- Terms -->
  <!-- #p is the parenthesis count -->
  <!-- #i is the size of the var stack -->
  <xsl:template match="Var">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="$print_identifiers &gt; 0">
        <xsl:variable name="vid">
          <xsl:call-template name="get_vid">
            <xsl:with-param name="up" select="$i - @nr"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="pqvar">
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="vid" select="$vid"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pvar">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- search parent For and Fraenkel for #nr, return its vid -->
  <!-- #bound says how many vars ( -1) are currently quantified -->
  <!-- (depth of the quantifier stack), so we need to go -->
  <!-- #bound - #nr times up (this is now passed just as #up) -->
  <xsl:template name="get_vid">
    <xsl:param name="up"/>
    <xsl:choose>
      <xsl:when test="name() = &quot;For&quot;">
        <xsl:choose>
          <xsl:when test="$up = &quot;0&quot;">
            <xsl:value-of select="@vid"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="..">
              <xsl:call-template name="get_vid">
                <xsl:with-param name="up" select="$up - 1"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="(name() = &quot;Typ&quot;) and (name(..) = &quot;Fraenkel&quot;)">
            <!-- the case for var inside fraenkel typ - -->
            <!-- only previous lamdaargs are available -->
            <xsl:variable name="tnr" select="count(preceding-sibling::Typ)"/>
            <xsl:choose>
              <xsl:when test="$up &lt; $tnr">
                <xsl:value-of select="preceding-sibling::Typ[position() = (last() - $up)]/@vid"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="../..">
                  <xsl:call-template name="get_vid">
                    <xsl:with-param name="up" select="$up - $tnr"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="name() = &quot;Fraenkel&quot;">
                <!-- the case for var inside lambdaterm and lambdaformula - -->
                <!-- all lamdaargs are available -->
                <xsl:variable name="tnr" select="count(Typ)"/>
                <xsl:choose>
                  <xsl:when test="$up &lt; $tnr">
                    <xsl:value-of select="Typ[position() = (last() - $up)]/@vid"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="..">
                      <xsl:call-template name="get_vid">
                        <xsl:with-param name="up" select="$up - $tnr"/>
                      </xsl:call-template>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="..">
                  <xsl:call-template name="get_vid">
                    <xsl:with-param name="up" select="$up"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- trickery to translate loci to constants and identifiers when needed -->
  <!-- this unfortunately does not work for IdentifyRegistration, so that's -->
  <!-- dealt with by looking at the compatibility fla now :-( -->
  <!-- ###TODO: also the constructor types -->
  <xsl:template match="LocusVar">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <!-- try definienda possibly containing "it" -->
    <xsl:choose>
      <xsl:when test="($mml=&quot;0&quot;) and (ancestor::DefMeaning)">
        <xsl:variable name="it_possible">
          <xsl:choose>
            <xsl:when test="(ancestor::Definiens[(@constrkind=&quot;M&quot;) or (@constrkind=&quot;K&quot;)])">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxnr">
          <xsl:for-each select="ancestor::Definiens">
            <xsl:value-of select="count(Typ)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="(@nr = $maxnr) and ($it_possible=&quot;1&quot;)">
            <xsl:element name="b">
              <xsl:text>it</xsl:text>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="@nr &lt;= $maxnr">
                <xsl:variable name="nr" select="@nr"/>
                <!-- preceding-sibling written this way selects in reverse document order -->
                <xsl:for-each select="ancestor::Definiens">
                  <xsl:variable name="argtypes" select="preceding-sibling::DefinitionBlock[1]/Let/Typ"/>
                  <xsl:call-template name="ppconst">
                    <xsl:with-param name="nr" select="$nr"/>
                    <xsl:with-param name="vid" select="$argtypes[position() = $nr]/@vid"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="@nr"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- note that the Constructor may come from different document here -->
        <!-- even if $mml = 0, but that can be handled above, because this is -->
        <!-- only used for result types which in that case shouldn't have changed -->
        <!-- Exapnsion used for expandable mode defs -->
        <xsl:choose>
          <xsl:when test="($mml=&quot;0&quot;) and ((ancestor::Constructor) or (ancestor::Expansion)) and (ancestor::Definition)">
            <xsl:variable name="nr" select="@nr"/>
            <xsl:variable name="argtypes" select="ancestor::DefinitionBlock/Let/Typ"/>
            <xsl:call-template name="ppconst">
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="vid" select="$argtypes[position() = $nr]/@vid"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="($mml=&quot;0&quot;) and (ancestor::Registration)">
                <xsl:variable name="nr" select="@nr"/>
                <xsl:variable name="argtypes" select="ancestor::RegistrationBlock/Let/Typ"/>
                <xsl:call-template name="ppconst">
                  <xsl:with-param name="nr" select="$nr"/>
                  <xsl:with-param name="vid" select="$argtypes[position() = $nr]/@vid"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="($mml=&quot;0&quot;) and ((ancestor::DefPred) or (ancestor::DefFunc))">
                    <xsl:text>$</xsl:text>
                    <xsl:value-of select="@nr"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ploci">
                      <xsl:with-param name="nr" select="@nr"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="FreeVar">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:text>X</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Const">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0)  and ((@vid&gt;0) or ($proof_links&gt;0))">
        <xsl:choose>
          <xsl:when test="@vid &gt; 0">
            <xsl:call-template name="ppconst">
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="vid" select="@vid"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="pl">
              <xsl:call-template name="get_nearest_level">
                <xsl:with-param name="el" select=".."/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="absconst">
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="pl" select="$pl"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="InfConst">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:text>D</xsl:text>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Num">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:value-of select="@nr"/>
  </xsl:template>

  <xsl:template match="Func">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="@kind=&apos;F&apos;">
        <xsl:call-template name="pschfvar">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="@kind=&apos;U&apos;">
        <xsl:text>the </xsl:text>
        <xsl:call-template name="abs">
          <xsl:with-param name="k" select="@kind"/>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="sym">
            <xsl:call-template name="abs1">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@nr"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text> of </xsl:text>
        <xsl:apply-templates select="*[position() = last()]">
          <xsl:with-param name="p" select="$p"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="par">
          <xsl:choose>
            <xsl:when test="$p&gt;0">
              <xsl:value-of select="$p+1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="name(..)=&apos;Func&apos;">
                  <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="pp">
          <xsl:with-param name="k" select="@kind"/>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="args" select="*"/>
          <xsl:with-param name="parenth" select="$par"/>
          <xsl:with-param name="pid" select="@pid"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="PrivFunc">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:call-template name="ppfunc">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*[position()&gt;1]"/>
      <xsl:with-param name="i" select="$i"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="ErrorTrm">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:text>errortrm</xsl:text>
  </xsl:template>

  <xsl:template match="Fraenkel">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:variable name="j">
      <xsl:choose>
        <xsl:when test="$i">
          <xsl:value-of select="$i"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="par">
      <xsl:choose>
        <xsl:when test="$p&gt;0">
          <xsl:value-of select="$p+1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="inc">
      <xsl:value-of select="count(*) - 2"/>
    </xsl:variable>
    <!-- number of vars introduced here -->
    <xsl:variable name="paren_color" select="$par mod $pcolors_nr"/>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:value-of select="concat(&quot;p&quot;,$paren_color)"/>
      </xsl:attribute>
      <xsl:text>{</xsl:text>
      <xsl:element name="span">
        <xsl:attribute name="class">
          <xsl:text>default</xsl:text>
        </xsl:attribute>
        <xsl:text> </xsl:text>
        <!-- first display the term -->
        <xsl:apply-templates select="*[position() = last() - 1]">
          <xsl:with-param name="p" select="$par"/>
          <xsl:with-param name="i" select="$j + $inc"/>
        </xsl:apply-templates>
        <!-- then the var types -->
        <xsl:if test="count(*)&gt;2">
          <xsl:text> where </xsl:text>
          <xsl:for-each select="*[position() &lt; last() - 1]">
            <xsl:call-template name="pqvar">
              <xsl:with-param name="nr" select="$j + position()"/>
              <xsl:with-param name="vid" select="@vid"/>
            </xsl:call-template>
            <xsl:variable name="eq1">
              <xsl:choose>
                <xsl:when test="position()=last()">
                  <xsl:text>0</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="are_equal_vid">
                    <xsl:with-param name="el1" select="."/>
                    <xsl:with-param name="el2" select="following-sibling::*[1]"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$eq1=&quot;0&quot;">
              <xsl:text> is </xsl:text>
              <xsl:apply-templates select=".">
                <xsl:with-param name="i" select="$j + position() - 1"/>
              </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="not(position()=last())">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
        <!-- then the formula -->
        <xsl:text> : </xsl:text>
        <xsl:apply-templates select="*[position() = last()]">
          <xsl:with-param name="i" select="$j + $inc"/>
        </xsl:apply-templates>
        <xsl:text> </xsl:text>
      </xsl:element>
      <xsl:text>}</xsl:text>
    </xsl:element>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Types -->
  <!-- element Typ { -->
  <!-- attribute kind { "M" | "G" | "L" | "errortyp" }, -->
  <!-- attribute nr { xsd:integer }?, -->
  <!-- ( attribute absnr { xsd:integer }, -->
  <!-- attribute aid { xsd:string } )?, -->
  <!-- attribute pid { xsd:integer }?, -->
  <!-- Cluster*, -->
  <!-- Term* -->
  <!-- } -->
  <xsl:template match="Typ">
    <xsl:param name="i"/>
    <xsl:text> </xsl:text>
    <xsl:if test="count(*)&gt;0">
      <xsl:apply-templates select="*[1]">
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;G&quot;) or (@kind=&quot;L&quot;)">
        <xsl:variable name="pi">
          <xsl:call-template name="patt_info">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="pid" select="@pid"/>
          </xsl:call-template>
        </xsl:variable>
        <!-- DEBUG ":"; `@pid`; ":"; $pi; ":"; -->
        <xsl:variable name="fnr">
          <xsl:call-template name="car">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="expand">
          <xsl:call-template name="cadr">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="plink">
          <xsl:call-template name="third">
            <xsl:with-param name="l" select="$pi"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="k1">
          <xsl:choose>
            <xsl:when test="@kind = &quot;M&quot;">
              <xsl:text>M</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>L</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="($expand=&quot;0&quot;) or not(@pid)">
            <xsl:call-template name="pp">
              <xsl:with-param name="k" select="$k1"/>
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="args" select="*[not(name()=&quot;Cluster&quot;)]"/>
              <xsl:with-param name="pid" select="@pid"/>
              <xsl:with-param name="i" select="$i"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="sym">
              <xsl:call-template name="abs1">
                <xsl:with-param name="k" select="@kind"/>
                <xsl:with-param name="nr" select="@nr"/>
                <xsl:with-param name="fnr" select="$fnr"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="vis">
              <xsl:call-template name="cdddr">
                <xsl:with-param name="l" select="$pi"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="el" select="."/>
            <!-- DEBUG ":"; `@pid`; ":"; $pi; ":"; -->
            <xsl:variable name="pid" select="@pid"/>
            <xsl:variable name="doc">
              <xsl:choose>
                <xsl:when test="key(&apos;EXP&apos;,$pid)">
                  <xsl:text/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$patts"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="c1">
              <xsl:choose>
                <xsl:when test="($doc = &quot;&quot;) and ($mml = &quot;0&quot;)">
                  <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="document($doc,/)">
              <xsl:call-template name="absref">
                <xsl:with-param name="elems" select="key(&apos;EXP&apos;,$pid)"/>
                <xsl:with-param name="c" select="$c1"/>
                <xsl:with-param name="sym" select="$sym"/>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
              <xsl:if test="not($vis = &quot;&quot;)">
                <xsl:text> of </xsl:text>
                <xsl:for-each select="key(&apos;EXP&apos;,$pid)">
                  <xsl:call-template name="descent_many_vis">
                    <xsl:with-param name="patt" select="Expansion/Typ"/>
                    <xsl:with-param name="fix" select="$el"/>
                    <xsl:with-param name="vis" select="Visible/Int"/>
                    <xsl:with-param name="i" select="$i"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@kind"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- gets two Typ, and list of Visible/Int; -->
  <!-- tries to find and print the terms in #fix corresponding -->
  <!-- to the visible loci; #patt is structurally similar to -->
  <!-- #fix, up to the loci -->
  <!-- the handling of #i is potentially incorrect if there is a Fraenkel as -->
  <!-- a param of the type -->
  <xsl:template name="descent_many_vis">
    <xsl:param name="patt"/>
    <xsl:param name="fix"/>
    <xsl:param name="vis"/>
    <xsl:param name="i"/>
    <xsl:if test="$vis">
      <xsl:variable name="v1" select="$vis[position()=1]/@x"/>
      <xsl:variable name="v2" select="$vis[position()&gt;1]"/>
      <!-- DEBUG    "descen:"; $v1; ":"; apply[$patt]; ":"; -->
      <xsl:call-template name="descent_many">
        <xsl:with-param name="patts" select="$patt/*[not(name()=&quot;Cluster&quot;)]"/>
        <xsl:with-param name="fixs" select="$fix/*[not(name()=&quot;Cluster&quot;)]"/>
        <xsl:with-param name="lnr" select="$v1"/>
        <xsl:with-param name="nr" select="count($patt/*[not(name()=&quot;Cluster&quot;)])"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:call-template>
      <xsl:if test="$v2">
        <xsl:text>,</xsl:text>
        <xsl:call-template name="descent_many_vis">
          <xsl:with-param name="patt" select="$patt"/>
          <xsl:with-param name="fix" select="$fix"/>
          <xsl:with-param name="vis" select="$vis[position()&gt;1]"/>
          <xsl:with-param name="i" select="$i"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="descent_many">
    <xsl:param name="patts"/>
    <xsl:param name="fixs"/>
    <xsl:param name="lnr"/>
    <xsl:param name="nr"/>
    <xsl:param name="i"/>
    <xsl:if test="$nr &gt; 0">
      <xsl:variable name="patt" select="$patts[position()=$nr]"/>
      <xsl:variable name="fix" select="$fixs[position()=$nr]"/>
      <!-- DEBUG "desone:"; $nr; ":"; `name($patt)`; ":"; `name($fix)`; ":"; -->
      <xsl:choose>
        <xsl:when test="(name($patt)=&quot;LocusVar&quot;) and ($patt/@nr=$lnr)">
          <!-- DEBUG    $lnr; ":"; `$patt/@nr`; ":";  "fff"; -->
          <xsl:for-each select="$top">
            <xsl:apply-templates select="$fix">
              <xsl:with-param name="p">
                <xsl:text>0</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="i" select="$i"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:when>
        <!-- the duplication here is needed to generated the html properly; -->
        <!-- it does not cause any visible slowdown in practice -->
        <xsl:otherwise>
          <xsl:variable name="res">
            <xsl:choose>
              <xsl:when test="name($patt) = name($fix)">
                <xsl:call-template name="descent_many">
                  <xsl:with-param name="patts" select="$patt/*"/>
                  <xsl:with-param name="fixs" select="$fix/*"/>
                  <xsl:with-param name="lnr" select="$lnr"/>
                  <xsl:with-param name="nr" select="count($patt/*)"/>
                  <xsl:with-param name="i" select="$i"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$res and not($res=&quot;&quot;)">
              <!-- DEBUG [and contains($res,"fff")] -->
              <xsl:call-template name="descent_many">
                <xsl:with-param name="patts" select="$patt/*"/>
                <xsl:with-param name="fixs" select="$fix/*"/>
                <xsl:with-param name="lnr" select="$lnr"/>
                <xsl:with-param name="nr" select="count($patt/*)"/>
                <xsl:with-param name="i" select="$i"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="descent_many">
                <xsl:with-param name="patts" select="$patts"/>
                <xsl:with-param name="fixs" select="$fixs"/>
                <xsl:with-param name="lnr" select="$lnr"/>
                <xsl:with-param name="nr" select="$nr - 1"/>
                <xsl:with-param name="i" select="$i"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Clusters -->
  <!-- only attributes with pid are now printed, others are results of -->
  <!-- cluster mechanisms - this holds in the current article -->
  <!-- (.xml file) only, environmental files do not have the @pid -->
  <!-- info (yet), so we print everything for them -->
  <xsl:template match="Cluster">
    <xsl:param name="i"/>
    <xsl:choose>
      <xsl:when test="$print_all_attrs = 1">
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text> </xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="list">
          <xsl:with-param name="separ">
            <xsl:text> </xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*[@pid]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Adjective -->
  <!-- element Adjective { -->
  <!-- attribute nr { xsd:integer }, -->
  <!-- attribute value { xsd:boolean }?, -->
  <!-- ( attribute absnr { xsd:integer }, -->
  <!-- attribute aid { xsd:string } )?, -->
  <!-- attribute kind { "V" }?, -->
  <!-- attribute pid { xsd:integer }?, -->
  <!-- Term* -->
  <!-- } -->
  <xsl:template match="Adjective">
    <xsl:param name="i"/>
    <xsl:variable name="pi">
      <xsl:call-template name="patt_info">
        <xsl:with-param name="k">
          <xsl:text>V</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nr" select="@nr"/>
        <xsl:with-param name="pid" select="@pid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fnr">
      <xsl:call-template name="car">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="anto">
      <xsl:call-template name="cadr">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="plink">
      <xsl:call-template name="third">
        <xsl:with-param name="l" select="$pi"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pid">
      <xsl:choose>
        <xsl:when test="$plink=&quot;1&quot;">
          <xsl:value-of select="@pid"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="neg">
      <xsl:choose>
        <xsl:when test="@value=&quot;false&quot;">
          <xsl:value-of select="($anto + 1) mod 2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$anto mod 2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$neg=&quot;1&quot;">
      <xsl:text>non </xsl:text>
    </xsl:if>
    <xsl:call-template name="abs">
      <xsl:with-param name="k">
        <xsl:text>V</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="sym">
        <xsl:call-template name="abs1">
          <xsl:with-param name="k">
            <xsl:text>V</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="fnr" select="$fnr"/>
          <xsl:with-param name="pid" select="$pid"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="pid" select="$pid"/>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
