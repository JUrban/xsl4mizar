<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_reasoning.xsl"/>

  <!-- $Revision: 1.19 $ -->
  <!--  -->
  <!-- File: block_top.xsltxt - html-ization of Mizar XML, code for bloc and top elements -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- Registrations -->
  <xsl:template match="RCluster">
    <xsl:choose>
      <xsl:when test="Presentation/RCluster">
        <xsl:apply-templates select="Presentation/RCluster"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="nr1" select="@nr"/>
        <xsl:choose>
          <xsl:when test="$generate_items&gt;0">
            <xsl:document href="proofhtml/exreg/{$anamelc}.{$nr1}" format="html"> 
            <xsl:call-template name="rc"/>
            </xsl:document> 
            <xsl:variable name="bogus" select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="div">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#RC&quot;,$nr1)"/>
              </xsl:attribute>
              <xsl:call-template name="rc"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="rc">
    <xsl:if test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
      <xsl:apply-templates select="ArgTypes"/>
    </xsl:if>
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;RC&quot;,$nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>cluster </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ErrorCluster">
        <xsl:text>errorcluster</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[3]">
          <xsl:with-param name="all">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:if test="$regs_use_for=1">
          <xsl:text> for</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="*[2]"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
    <xsl:if test="$mml=&quot;1&quot;">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="CCluster">
    <xsl:choose>
      <xsl:when test="Presentation/CCluster">
        <xsl:apply-templates select="Presentation/CCluster"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="nr1" select="@nr"/>
        <xsl:choose>
          <xsl:when test="$generate_items&gt;0">
            <xsl:document href="proofhtml/condreg/{$anamelc}.{$nr1}" format="html"> 
            <xsl:call-template name="cc"/>
            </xsl:document> 
            <xsl:variable name="bogus" select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="div">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#CC&quot;,$nr1)"/>
              </xsl:attribute>
              <xsl:call-template name="cc"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cc">
    <xsl:if test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
      <xsl:apply-templates select="ArgTypes"/>
    </xsl:if>
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;CC&quot;,$nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>cluster </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ErrorCluster">
        <xsl:text>errorcluster</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[2]">
          <xsl:with-param name="all">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text> -&gt; </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="*[4]"/>
        <xsl:if test="$regs_use_for=1">
          <xsl:text> for</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="*[3]"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
    <xsl:if test="$mml=&quot;1&quot;">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="FCluster">
    <xsl:choose>
      <xsl:when test="Presentation/FCluster">
        <xsl:apply-templates select="Presentation/FCluster"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="nr1" select="@nr"/>
        <xsl:choose>
          <xsl:when test="$generate_items&gt;0">
            <xsl:document href="proofhtml/funcreg/{$anamelc}.{$nr1}" format="html"> 
            <xsl:call-template name="fc"/>
            </xsl:document> 
            <xsl:variable name="bogus" select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="div">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#FC&quot;,$nr1)"/>
              </xsl:attribute>
              <xsl:call-template name="fc"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fc">
    <xsl:if test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
      <xsl:apply-templates select="ArgTypes"/>
    </xsl:if>
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;FC&quot;,$nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>cluster </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ErrorCluster">
        <xsl:text>errorcluster</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[2]"/>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text> -&gt; </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="*[3]"/>
        <xsl:if test="Typ">
          <xsl:if test="$regs_use_for=1">
            <xsl:text> for</xsl:text>
          </xsl:if>
          <xsl:apply-templates select="Typ"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
    <xsl:if test="$mml=&quot;1&quot;">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="IdentifyWithExp|Identify">
    <xsl:variable name="iname" select="name()"/>
    <!-- to deal with both versions -->
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:choose>
      <xsl:when test="$generate_items&gt;0">
        <xsl:document href="proofhtml/idreg/{$anamelc}.{$nr1}" format="html"> 
        <xsl:call-template name="iy"/>
        </xsl:document> 
        <xsl:variable name="bogus" select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="about">
            <xsl:value-of select="concat(&quot;#IE&quot;,$nr1)"/>
          </xsl:attribute>
          <xsl:call-template name="iy"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="iy">
    <xsl:variable name="iname" select="name()"/>
    <!-- to deal with both versions -->
    <xsl:if test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
      <xsl:call-template name="argtypes">
        <xsl:with-param name="el" select="Typ"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;IY&quot;,$nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>identify </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ErrorIdentify">
        <xsl:text>erroridentify</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
            <xsl:choose>
              <xsl:when test="$iname = &apos;Identify&apos;">
                <xsl:apply-templates select="Func[1]"/>
                <xsl:call-template name="pkeyword">
                  <xsl:with-param name="str">
                    <xsl:text> with </xsl:text>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates select="Func[2]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="*[position() = last() - 1]"/>
                <xsl:call-template name="pkeyword">
                  <xsl:with-param name="str">
                    <xsl:text> with </xsl:text>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates select="*[position() = last()]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="following-sibling::*[1]/Proposition/*[1]">
              <xsl:choose>
                <xsl:when test="name() = &quot;Pred&quot;">
                  <xsl:apply-templates select="*[1]"/>
                  <xsl:call-template name="pkeyword">
                    <xsl:with-param name="str">
                      <xsl:text> with </xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:apply-templates select="*[2]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="name() = &quot;And&quot;">
                      <xsl:variable name="e1">
                        <xsl:call-template name="is_equiv">
                          <xsl:with-param name="el" select="."/>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="$e1=&quot;1&quot;">
                          <xsl:apply-templates select="*[1]/*[1]/*[1]"/>
                          <xsl:call-template name="pkeyword">
                            <xsl:with-param name="str">
                              <xsl:text> with </xsl:text>
                            </xsl:with-param>
                          </xsl:call-template>
                          <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>IDENTIFY DISPLAY FAILED -  PLEASE COMPLAIN!</xsl:text>
                          <xsl:element name="br"/>
                          <xsl:apply-templates select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:variable name="i3">
                        <xsl:call-template name="is_impl1">
                          <xsl:with-param name="el" select="."/>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="not($i3=2)">
                          <xsl:text>IDENTIFY DISPLAY FAILED -  PLEASE COMPLAIN!</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:for-each select="*[1]/*[@pid=$pid_Impl_RightNot]/*[1]">
                            <xsl:choose>
                              <xsl:when test="name() = &quot;Pred&quot;">
                                <xsl:apply-templates select="*[1]"/>
                                <xsl:call-template name="pkeyword">
                                  <xsl:with-param name="str">
                                    <xsl:text> with </xsl:text>
                                  </xsl:with-param>
                                </xsl:call-template>
                                <xsl:apply-templates select="*[2]"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:variable name="e1">
                                  <xsl:call-template name="is_equiv">
                                    <xsl:with-param name="el" select="."/>
                                  </xsl:call-template>
                                </xsl:variable>
                                <xsl:choose>
                                  <xsl:when test="$e1=&quot;1&quot;">
                                    <xsl:apply-templates select="*[1]/*[1]/*[1]"/>
                                    <xsl:call-template name="pkeyword">
                                      <xsl:with-param name="str">
                                        <xsl:text> with </xsl:text>
                                      </xsl:with-param>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text>IDENTIFY DISPLAY FAILED -  PLEASE COMPLAIN!</xsl:text>
                                    <xsl:element name="br"/>
                                    <xsl:apply-templates select="."/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                          <xsl:call-template name="pkeyword">
                            <xsl:with-param name="str">
                              <xsl:text> when </xsl:text>
                            </xsl:with-param>
                          </xsl:call-template>
                          <xsl:call-template name="ilist">
                            <xsl:with-param name="separ">
                              <xsl:text>, </xsl:text>
                            </xsl:with-param>
                            <xsl:with-param name="elems" select="*[1]/*[not(@pid=$pid_Impl_RightNot)]"/>
                          </xsl:call-template>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
    <xsl:if test="$mml=&quot;1&quot;">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Reduction">
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:choose>
      <xsl:when test="$generate_items&gt;0">
        <xsl:document href="proofhtml/redreg/{$anamelc}.{$nr1}" format="html"> 
        <xsl:call-template name="reduce"/>
        </xsl:document> 
        <xsl:variable name="bogus" select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="about">
            <xsl:value-of select="concat(&quot;#RD&quot;,$nr1)"/>
          </xsl:attribute>
          <xsl:call-template name="reduce"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="reduce">
    <xsl:if test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
      <xsl:call-template name="argtypes">
        <xsl:with-param name="el" select="Typ"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="nr1" select="@nr"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;RD&quot;,$nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>reduce </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ErrorReduction">
        <xsl:text>errorreduction</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
            <xsl:apply-templates select="*[position() = last() - 1]"/>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text> to </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[position() = last()]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="following-sibling::*[1]/Proposition/*[1]">
              <xsl:choose>
                <xsl:when test="name() = &quot;Pred&quot;">
                  <xsl:apply-templates select="*[1]"/>
                  <xsl:call-template name="pkeyword">
                    <xsl:with-param name="str">
                      <xsl:text> with </xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:apply-templates select="*[2]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>REDUCE DISPLAY FAILED -  PLEASE COMPLAIN!</xsl:text>
                  <xsl:element name="br"/>
                  <xsl:apply-templates select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
    <xsl:if test="$mml=&quot;1&quot;">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <!-- ignore them -->
  <xsl:template match="Reservation/Typ">
    <xsl:text/>
  </xsl:template>

  <xsl:template match="Definiens/*">
    <xsl:text/>
  </xsl:template>

  <xsl:template name="add_comments">
    <xsl:param name="line"/>
    <xsl:if test="$mk_comments &gt; 0">
      <xsl:variable name="prevline" select="$line - 1"/>
      <xsl:for-each select="document($cmt,/)">
        <xsl:for-each select="key(&apos;CMT&apos;,$prevline)">
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- xsltxt cannot use xsl:document yet, so manually insert it -->
  <!-- (now done by the perl postproc) -->
  <!-- the bogus is there to ensure that the ending xsl:doc element -->
  <!-- is printed by xslxtxt.jar too -->
  <xsl:template match="JustifiedTheorem">
    <xsl:call-template name="add_comments">
      <xsl:with-param name="line" select="@line"/>
    </xsl:call-template>
    <xsl:variable name="nr1" select="1+count(preceding-sibling::JustifiedTheorem)"/>
    <xsl:choose>
      <xsl:when test="$generate_items&gt;0">
        <xsl:document href="proofhtml/th/{$anamelc}.{$nr1}" format="html"> 
        <xsl:call-template name="jt"/>
        </xsl:document> 
        <xsl:variable name="bogus" select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- optional interestingness rating produced by external soft -->
        <xsl:choose>
          <xsl:when test="@interesting &gt; 0">
            <!-- scale red and blue from 0% (green) to 100% (white) -->
            <xsl:variable name="intensity" select="(1 - @interesting) * 100"/>
            <xsl:element name="div">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#T&quot;,$nr1)"/>
              </xsl:attribute>
              <xsl:attribute name="typeof">
                <xsl:text>oo:Theorem</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="style">
                <xsl:value-of select="concat(&quot;background-color:rgb(&quot;,$intensity,&quot;%,100%,&quot;, $intensity, &quot;%);&quot;)"/>
              </xsl:attribute>
              <xsl:call-template name="jt"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="div">
              <xsl:attribute name="about">
                <xsl:value-of select="concat(&quot;#T&quot;,$nr1)"/>
              </xsl:attribute>
              <xsl:attribute name="typeof">
                <xsl:text>oo:Theorem</xsl:text>
              </xsl:attribute>
              <xsl:call-template name="jt"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- private - assumes that is inside JustifiedTheorem -->
  <xsl:template name="jt">
    <xsl:variable name="nr1" select="1+count(preceding-sibling::JustifiedTheorem)"/>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>theorem </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="($proof_links &gt; 0) and ($print_lab_identifiers = 0)">
        <xsl:call-template name="plab1">
          <xsl:with-param name="nr" select="$nr1"/>
          <xsl:with-param name="txt">
            <xsl:text>Th</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="Proposition[@nr &gt; 0]">
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="vid" select="@vid"/>
          </xsl:call-template>
          <xsl:text>: </xsl:text>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;T&quot;, $nr1)"/>
      </xsl:attribute>
      <xsl:call-template name="pcomment0">
        <xsl:with-param name="str" select="concat($aname,&quot;:&quot;, $nr1)"/>
      </xsl:call-template>
      <xsl:if test="@interesting &gt; 0">
        <xsl:text> interestingness: </xsl:text>
        <xsl:value-of select="@interesting"/>
      </xsl:if>
      <xsl:if test="$idv &gt; 0">
        <xsl:call-template name="idv_for_item">
          <xsl:with-param name="k">
            <xsl:text>t</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="nr" select="$nr1"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$wiki_sections = 1">
        <xsl:variable name="endpos">
          <xsl:choose>
            <xsl:when test="Proof">
              <xsl:value-of select="Proof[1]/EndPosition[1]/@line"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="By|From">
                  <xsl:value-of select="*[2]/@line"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$endpos &gt; 0">
          <xsl:text> </xsl:text>
          <xsl:call-template name="wiki_edit_section_for">
            <xsl:with-param name="k">
              <xsl:text>t</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="nr" select="$nr1"/>
            <xsl:with-param name="line1" select="Proposition[1]/@line"/>
            <xsl:with-param name="line2" select="$endpos"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$thms_tptp_links = 1">
        <xsl:call-template name="tptp_for_thm">
          <xsl:with-param name="line" select="Proposition[1]/@line"/>
          <xsl:with-param name="col" select="Proposition[1]/@col"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="add_ar_iconif">
          <xsl:with-param name="line" select="Proposition[1]/@line"/>
          <xsl:with-param name="col" select="Proposition[1]/@col"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="edit_for_thm">
          <xsl:with-param name="line" select="Proposition[1]/@line"/>
          <xsl:with-param name="col" select="Proposition[1]/@col"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:element name="br"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="Proof">
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:text>add</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates select="*[1]/*[1]"/>
        </xsl:element>
        <xsl:if test="not($generate_items&gt;0) or ($generate_items_proofs&gt;0)">
          <xsl:apply-templates select="*[2]"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:text>add</xsl:text>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="Proposition/Verum">
              <xsl:call-template name="pkeyword">
                <xsl:with-param name="str">
                  <xsl:text>canceled; </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="*[1]/*[1]"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="*[2]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="idv_for_item">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:variable name="idv_html">
      <xsl:text>http://www.cs.miami.edu/~tptp/MizarTPTP/</xsl:text>
    </xsl:variable>
    <!-- "http://lipa.ms.mff.cuni.cz/~urban/idvtest/"; -->
    <!-- $idv_html = "file:///home/urban/mptp0.2/idvhtml/"; -->
    <xsl:variable name="tptp_file" select="concat($idv_html,&quot;problems/&quot;,$anamelc,&quot;/&quot;,$anamelc, &quot;__&quot;,$k, $nr, &quot;_&quot;, $anamelc)"/>
    <xsl:text> </xsl:text>
    <xsl:element name="img">
      <xsl:call-template name="add_hs2_attrs"/>
      <xsl:attribute name="src">
        <xsl:text>PalmTree.jpg</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:text>Show IDV graph</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:text>Show IDV graph</xsl:text>
      </xsl:attribute>
    </xsl:element>
    <!-- <a -->
    <!-- { -->
    <!-- //    add_ajax_attrs(#u = $th); -->
    <!-- add_hs2_attrs(); -->
    <!-- @title="Show IDV graph"; -->
    <!-- <b { " IDV graph "; } -->
    <!-- } -->
    <xsl:element name="span">
      <xsl:attribute name="style">
        <xsl:text>display:none</xsl:text>
      </xsl:attribute>
      <xsl:text>:: Showing IDV graph ... (Click the Palm Tree again to close it)</xsl:text>
      <xsl:element name="APPLET">
        <xsl:attribute name="CODE">
          <xsl:text>IDVApplet.class</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="ARCHIVE">
          <xsl:text>http://www.cs.miami.edu/students/strac/test/IDV/IDV.jar,http://www.cs.miami.edu/students/strac/test/IDV/TptpParser.jar,http://www.cs.miami.edu/students/strac/test/IDV/antlr-2.7.5.jar</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="WIDTH">
          <xsl:text>0</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="HEIGHT">
          <xsl:text>0</xsl:text>
        </xsl:attribute>
        <xsl:element name="PARAM">
          <xsl:attribute name="NAME">
            <xsl:text>URL</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="VALUE">
            <xsl:value-of select="$tptp_file"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="tptp_for_thm">
    <xsl:param name="line"/>
    <xsl:param name="col"/>
    <xsl:variable name="tptp_file" select="concat(&quot;problems/&quot;,$anamelc,&quot;/&quot;,$anamelc,&quot;__&quot;,$line,&quot;_&quot;,$col)"/>
    <xsl:text> ::</xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:value-of select="concat($ltmpftptpcgi,&quot;?file=&quot;,$tptp_file,&quot;&amp;tmp=&quot;,$lbytmpdir)"/>
      </xsl:attribute>
      <xsl:attribute name="target">
        <xsl:value-of select="concat(&quot;MizarTPTP&quot;,$lbytmpdir)"/>
      </xsl:attribute>
      <xsl:element name="img">
        <xsl:attribute name="src">
          <xsl:value-of select="concat($ltptproot,&quot;TPTP.gif&quot;)"/>
        </xsl:attribute>
        <xsl:attribute name="height">
          <xsl:text>17</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="width">
          <xsl:text>17</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
          <xsl:text>Show TPTP problem</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:text>Show TPTP problem</xsl:text>
        </xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="add_ar_iconif">
    <xsl:param name="line"/>
    <xsl:param name="col"/>
    <xsl:if test="$linkarproofs&gt;0">
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
        <xsl:variable name="txt">
          <xsl:call-template name="mk_by_title">
            <xsl:with-param name="line" select="$line"/>
            <xsl:with-param name="col" select="$col"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$by_titles&gt;0">
          <xsl:attribute name="title">
            <xsl:call-template name="mk_by_title">
              <xsl:with-param name="line" select="$line"/>
              <xsl:with-param name="col" select="$col"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:if>
        <xsl:element name="img">
          <xsl:attribute name="src">
            <xsl:value-of select="concat($ltptproot,&quot;AR.gif&quot;)"/>
          </xsl:attribute>
          <xsl:attribute name="alt">
            <xsl:value-of select="$txt"/>
          </xsl:attribute>
          <xsl:if test="$by_titles&gt;0">
            <xsl:attribute name="title">
              <xsl:value-of select="$txt"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:element>
        <xsl:text> </xsl:text>
      </xsl:element>
      <xsl:if test="$ajax_by &gt; 0">
        <xsl:element name="span">
          <xsl:text> </xsl:text>
        </xsl:element>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="edit_for_thm">
    <xsl:param name="line"/>
    <xsl:param name="col"/>
    <!-- $tptp_file = `concat($anamelc,".miz")`; -->
    <xsl:variable name="thm_file" select="concat($anamelc,&quot;__&quot;,$line,&quot;_&quot;,$col)"/>
    <xsl:text> ::</xsl:text>
    <xsl:element name="a">
      <!-- @href= `concat($ltmpftptpcgi,"?file=",$tptp_file,"&tmp=",$lbytmpdir,"&pos=",$line)`; -->
      <xsl:attribute name="href">
        <xsl:value-of select="concat($ltmpftptpcgi,&quot;?file=&quot;,$thm_file,&quot;&amp;tmp=&quot;,$lbytmpdir)"/>
      </xsl:attribute>
      <xsl:text>[edit]</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template name="wiki_edit_section_for">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="line1"/>
    <xsl:param name="line2"/>
    <xsl:variable name="section" select="concat($k,$nr,&quot;_&quot;,$line1,&quot;_&quot;,$line2)"/>
    <!-- // <xsl:document href="{$anamelc}__{$k}{$nr}.itm"> -->
    <!-- $bogus=`1`; -->
    <!-- $section; -->
    <!-- // </xsl:document> -->
    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=edit;f=mml/&quot;,$anamelc,&quot;.miz;s=&quot;,$section)"/>
      </xsl:attribute>
      <xsl:attribute name="rel">
        <xsl:text>nofollow</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>edit</xsl:text>
      </xsl:attribute>
      <xsl:text> [edit]</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="DefTheorem">
    <xsl:variable name="nr1" select="1+count(preceding-sibling::DefTheorem)"/>
    <xsl:choose>
      <xsl:when test="$generate_items&gt;0">
        <xsl:document href="proofhtml/def/{$anamelc}.{$nr1}" format="html"> 
        <xsl:call-template name="dt"/>
        </xsl:document> 
        <xsl:variable name="bogus" select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="about">
            <xsl:value-of select="concat(&quot;#DT&quot;,$nr1)"/>
          </xsl:attribute>
          <xsl:call-template name="dt"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- private - assumes that is inside DefTheorem -->
  <xsl:template name="dt">
    <xsl:variable name="nr1" select="1+count(preceding-sibling::DefTheorem)"/>
    <xsl:text>:: </xsl:text>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>deftheorem </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="($proof_links &gt; 0) and ($print_lab_identifiers = 0)">
        <xsl:call-template name="plab1">
          <xsl:with-param name="nr" select="$nr1"/>
          <xsl:with-param name="txt">
            <xsl:text>Def</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="Proposition[@nr &gt; 0]">
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="vid" select="@vid"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <!-- <a { @NAME=`concat("D",$nr1)`; -->
    <xsl:if test="@constrkind">
      <xsl:text>  defines </xsl:text>
      <xsl:call-template name="abs">
        <xsl:with-param name="k" select="@constrkind"/>
        <xsl:with-param name="nr" select="@constrnr"/>
        <xsl:with-param name="sym">
          <xsl:call-template name="abs1">
            <xsl:with-param name="k" select="@constrkind"/>
            <xsl:with-param name="nr" select="@constrnr"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="onclick">
        <xsl:text>hs(this)</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="href">
        <xsl:text>javascript:()</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="concat($aname, &quot;:def &quot;, $nr1)"/>
      <xsl:text> : </xsl:text>
      <xsl:element name="br"/>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>hide</xsl:text>
      </xsl:attribute>
      <!-- ##NOTE: div is not allowed inside span -->
      <!-- <div -->
      <!-- { -->
      <!-- @class = "add"; -->
      <xsl:choose>
        <xsl:when test="Proposition/Verum">
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>canceled; </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[1]/*[1]"/>
          <xsl:text>;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <!-- } -->
      <xsl:element name="br"/>
    </xsl:element>
  </xsl:template>

  <!-- Property, elProposition, Justification -->
  <xsl:template match="JustifiedProperty">
    <xsl:variable name="nm">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="name(*[1])"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="a">
      <xsl:call-template name="add_hs_attrs"/>
      <xsl:choose>
        <xsl:when test="$nm = &quot;antisymmetry&quot;">
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>asymmetry</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str" select="$nm"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>hide</xsl:text>
      </xsl:attribute>
      <xsl:element name="br"/>
      <xsl:apply-templates select="*[2]"/>
    </xsl:element>
    <xsl:apply-templates select="*[position()&gt;2]"/>
  </xsl:template>

  <!-- Formula | ( elProposition, Justification ) -->
  <xsl:template match="UnknownCorrCond|Coherence|Compatibility|Consistency|Existence|Reducibility|Uniqueness">
    <xsl:element name="a">
      <xsl:call-template name="add_hs_attrs"/>
      <xsl:variable name="nm">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="name()"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str" select="$nm"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>hide</xsl:text>
      </xsl:attribute>
      <xsl:element name="br"/>
      <xsl:apply-templates select="*[1]"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="count(*)&gt;1">
        <xsl:apply-templates select="*[position()&gt;1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- CorrectnessCondition*, elProposition, Justification -->
  <xsl:template match="Correctness">
    <xsl:element name="a">
      <xsl:call-template name="add_hs_attrs"/>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>correctness </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
    <!-- apply to subconditions , skip their conjunction -->
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>hide</xsl:text>
      </xsl:attribute>
      <xsl:element name="br"/>
      <xsl:apply-templates select="*[position()&lt;(last()-1)]"/>
    </xsl:element>
    <xsl:apply-templates select="*[position()=last()]"/>
  </xsl:template>

  <xsl:template match="Canceled">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>canceled;</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="SchemeFuncDecl">
    <xsl:call-template name="pschfvar">
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
    <xsl:apply-templates select="*[2]"/>
  </xsl:template>

  <xsl:template match="SchemePredDecl">
    <xsl:call-template name="pschpvar">
      <xsl:with-param name="nr" select="@nr"/>
    </xsl:call-template>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="list">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="ArgTypes/Typ"/>
    </xsl:call-template>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- ( elSchemeFuncDecl | elSchemePredDecl )*, -->
  <!-- element elSchemePremises { elProposition* }, -->
  <!-- elProposition, Justification, elEndPosition -->
  <xsl:template match="SchemeBlock">
    <xsl:call-template name="add_comments">
      <xsl:with-param name="line" select="@line"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$generate_items&gt;0">
        <xsl:document href="proofhtml/sch/{$anamelc}.{@schemenr}" format="html"> 
        <xsl:call-template name="sd"/>
        </xsl:document> 
        <xsl:variable name="bogus" select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="div">
          <xsl:attribute name="about">
            <xsl:value-of select="concat(&quot;#S&quot;,@schemenr)"/>
          </xsl:attribute>
          <xsl:call-template name="sd"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="sd">
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:attribute name="NAME">
          <xsl:value-of select="concat(&quot;S&quot;,@schemenr)"/>
        </xsl:attribute>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>scheme  </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="pcomment">
          <xsl:with-param name="str" select="concat($aname,&quot;:sch &quot;,@schemenr)"/>
        </xsl:call-template>
      </xsl:element>
      <!-- "s"; `@schemenr`; -->
      <xsl:choose>
        <xsl:when test="($proof_links &gt; 0) and ($print_lab_identifiers = 0)">
          <xsl:call-template name="plab1">
            <xsl:with-param name="nr" select="@schemenr"/>
            <xsl:with-param name="txt">
              <xsl:text>Sch</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="pplab">
            <xsl:with-param name="nr" select="@schemenr"/>
            <xsl:with-param name="vid" select="@vid"/>
            <xsl:with-param name="txt">
              <xsl:text>Sch</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>{ </xsl:text>
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>, </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="SchemeFuncDecl|SchemePredDecl"/>
      </xsl:call-template>
      <xsl:text> } :</xsl:text>
      <xsl:element name="br"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="Proposition"/>
      </xsl:element>
      <xsl:if test="SchemePremises/Proposition">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>provided</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:text>add</xsl:text>
          </xsl:attribute>
          <xsl:call-template name="andlist">
            <xsl:with-param name="elems" select="SchemePremises/Proposition"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not($generate_items&gt;0)">
        <xsl:apply-templates select="*[position() = last() - 1]"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- ( ( CorrectnessCondition*, elCorrectness?, -->
  <!-- elJustifiedProperty*, elConstructor?, elPattern? ) -->
  <!-- | ( elConstructor, elConstructor, elConstructor+, -->
  <!-- elRegistration, CorrectnessCondition*, -->
  <!-- elCorrectness?, elPattern+ )) -->
  <!-- ##TODO: commented registration and strict attr for defstruct -->
  <xsl:template match="Definition">
    <xsl:call-template name="add_comments">
      <xsl:with-param name="line" select="@line"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@expandable = &quot;true&quot;">
        <xsl:variable name="argtypes" select="../Let/Typ"/>
        <xsl:variable name="loci">
          <xsl:choose>
            <xsl:when test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>2</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="Pattern">
          <xsl:element name="a">
            <xsl:attribute name="NAME">
              <xsl:value-of select="concat(&quot;NM&quot;, @nr)"/>
            </xsl:attribute>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text>mode </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="abs1">
              <xsl:with-param name="k">
                <xsl:text>M</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="fnr" select="@formatnr"/>
            </xsl:call-template>
            <xsl:if test="Visible/Int">
              <xsl:text> of </xsl:text>
              <xsl:for-each select="Visible/Int">
                <xsl:variable name="x" select="@x"/>
                <xsl:choose>
                  <xsl:when test="$loci=&quot;2&quot;">
                    <xsl:call-template name="ppconst">
                      <xsl:with-param name="nr" select="$x"/>
                      <xsl:with-param name="vid" select="$argtypes[position()=$x]/@vid"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ploci">
                      <xsl:with-param name="nr" select="$x"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(position()=last())">
                  <xsl:text>,</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text> is </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:element>
          <xsl:apply-templates select="Expansion/Typ"/>
          <xsl:text>;</xsl:text>
          <xsl:element name="br"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- @nr is present iff Definiens is present; it can be 0 if -->
        <!-- the definiens is not labeled, otherwise it is the proposition number -->
        <!-- of its deftheorem -->
        <xsl:choose>
          <xsl:when test="@nr and ($generate_items&gt;0)">
            <xsl:variable name="cnt1" select="1 + count(preceding-sibling::Definition[@nr])"/>
            <xsl:variable name="defnr" select="../following-sibling::Definiens[position() = $cnt1]/@defnr"/>
            <xsl:document href="proofhtml/dfs/{$anamelc}.{$defnr}" format="html"> 
            <xsl:call-template name="dfs"/>
            </xsl:document> 
            <xsl:variable name="bogus" select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="@nr">
                <xsl:element name="div">
                  <xsl:attribute name="about">
                    <xsl:value-of select="concat(&quot;#D&quot;,@nr)"/>
                  </xsl:attribute>
                  <xsl:call-template name="dfs"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="dfs"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="*[not((name()=&apos;Constructor&apos;) or (name()=&apos;Pattern&apos;) 
                or (name()=&apos;Registration&apos;))]"/>
  </xsl:template>

  <xsl:template name="dfs">
    <xsl:variable name="nl">
      <xsl:choose>
        <xsl:when test="@nr">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="argtypes" select="../Let/Typ"/>
    <!-- Constructor may be missing, if this is a redefinition -->
    <!-- that does not change its types. In that case, the Constructor needs -->
    <!-- to be retrieved from the Definiens - see below. -->
    <xsl:if test="not(@nr)">
      <!-- for generate_items, we have to take loci from the constructor here -->
      <xsl:variable name="indef1">
        <xsl:choose>
          <xsl:when test="($generate_items &gt; 0)">
            <xsl:text>0</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>1</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="Constructor">
        <xsl:with-param name="indef" select="$indef1"/>
        <xsl:with-param name="nl" select="$nl"/>
        <xsl:with-param name="argt" select="$argtypes"/>
      </xsl:apply-templates>
    </xsl:if>
    <!-- @nr is present iff Definiens is present; it can be 0 if -->
    <!-- the deiniens is not labeled, otherwise it is the proposition number -->
    <!-- of its deftheorem -->
    <xsl:if test="@nr">
      <xsl:variable name="nr1" select="@nr"/>
      <xsl:variable name="vid" select="@vid"/>
      <xsl:variable name="cnt1" select="1 + count(preceding-sibling::Definition[@nr])"/>
      <xsl:variable name="cnstr" select="count(Constructor)"/>
      <xsl:if test="($generate_items &gt; 0)">
        <!-- Definiens is better than Constructor for loci display, -->
        <!-- since Constructor may be missing for redefinitions. -->
        <xsl:for-each select="../following-sibling::Definiens[position() = $cnt1]">
          <xsl:call-template name="argtypes">
            <xsl:with-param name="el" select="Typ"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates select="Constructor">
        <xsl:with-param name="indef">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="nl" select="$nl"/>
        <xsl:with-param name="argt" select="$argtypes"/>
      </xsl:apply-templates>
      <xsl:for-each select="../following-sibling::Definiens[position() = $cnt1]">
        <xsl:variable name="ckind" select="@constrkind"/>
        <xsl:variable name="cnr" select="@constrnr"/>
        <xsl:if test="$cnstr = 0">
          <!-- here the redefined constructor is retrieved from definiens -->
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>redefine </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:variable name="doc">
            <xsl:choose>
              <xsl:when test="key($ckind, $cnr)">
                <xsl:text/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$constrs"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:for-each select="document($doc, /)">
            <xsl:apply-templates select="key($ckind, $cnr)">
              <xsl:with-param name="indef">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="nl" select="$nl"/>
              <xsl:with-param name="argt" select="$argtypes"/>
              <xsl:with-param name="nrt">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="old">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="DefMeaning/@kind = &apos;e&apos;">
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text> equals </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text> means </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$nr1 &gt; 0">
          <xsl:text>:</xsl:text>
          <xsl:choose>
            <xsl:when test="($proof_links &gt; 0) and ($print_lab_identifiers = 0)">
              <xsl:call-template name="plab1">
                <xsl:with-param name="nr" select="@defnr"/>
                <xsl:with-param name="txt">
                  <xsl:text>Def</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="pplab">
                <xsl:with-param name="nr" select="$nr1"/>
                <xsl:with-param name="vid" select="$vid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:element name="a">
          <xsl:attribute name="NAME">
            <xsl:value-of select="concat(&quot;D&quot;, @defnr)"/>
          </xsl:attribute>
          <xsl:call-template name="pcomment">
            <xsl:with-param name="str" select="concat($aname, &quot;:def &quot;, @defnr)"/>
          </xsl:call-template>
        </xsl:element>
        <!-- note that loci below can be translated to constants and identifiers -->
        <!-- - see definition of LocusVar -->
        <xsl:for-each select="DefMeaning/PartialDef">
          <xsl:apply-templates select="*[1]"/>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text> if </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates select="*[2]"/>
          <xsl:element name="br"/>
        </xsl:for-each>
        <xsl:if test="(DefMeaning/PartialDef) 
	    and (DefMeaning/*[(position() = last()) 
		and not(name()=&quot;PartialDef&quot;)])">
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text> otherwise </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="DefMeaning/*[(position() = last()) and not(name()=&quot;PartialDef&quot;)]"/>
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- ( elLet | elAssume | elGiven | AuxiliaryItem | -->
  <!-- elCanceled | elDefinition )*, elEndPosition -->
  <xsl:template match="DefinitionBlock">
    <xsl:call-template name="add_comments">
      <xsl:with-param name="line" select="@line"/>
    </xsl:call-template>
    <xsl:element name="div">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>definition</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(name()=&apos;EndPosition&apos;)]"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- ( elRCluster | elFCluster | elCCluster ), -->
  <!-- CorrectnessCondition*, elCorrectness? -->
  <xsl:template match="Registration">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- elIdentifyWithExp, CorrectnessCondition*, elCorrectness? -->
  <xsl:template match="IdentifyRegistration">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ReductionRegistration">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ( elLet | AuxiliaryItem | elRegistration | elCanceled )+, elEndPosition -->
  <xsl:template match="RegistrationBlock">
    <xsl:call-template name="add_comments">
      <xsl:with-param name="line" select="@line"/>
    </xsl:call-template>
    <xsl:element name="div">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>registration</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(name()=&apos;EndPosition&apos;)]"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="NotationBlock">
    <xsl:element name="div">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>notation</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(name()=&apos;EndPosition&apos;)]"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- Blocks -->
  <xsl:template match="BlockThesis"/>

  <!-- "blockthesis: "; apply; ";"; <br; } -->
  <!-- (  ( elBlockThesis, elCase, elThesis, Reasoning ) -->
  <!-- |  ( elCase, Reasoning, elBlockThesis ) ) -->
  <xsl:template match="CaseBlock">
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:call-template name="add_hsNdiv_attrs"/>
        <xsl:if test="$proof_links&gt;0">
          <xsl:attribute name="title">
            <xsl:value-of select="@newlevel"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>case </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <xsl:apply-templates select="Case"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(name()=&apos;Case&apos;)]"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="SupposeBlock">
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:call-template name="add_hsNdiv_attrs"/>
        <xsl:if test="$proof_links&gt;0">
          <xsl:attribute name="title">
            <xsl:value-of select="@newlevel"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>suppose </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <xsl:apply-templates select="Suppose"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="*[not(name()=&apos;Suppose&apos;)]"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- (  ( elBlockThesis, ( elCaseBlock+ | elSupposeBlock+ ), -->
  <!-- elPerCases, elThesis, elEndPosition  ) -->
  <!-- |  ( ( elCaseBlock+ | elSupposeBlock+ ), -->
  <!-- elPerCases, elEndPosition, elBlockThesis ) ) -->
  <xsl:template match="PerCasesReasoning">
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:call-template name="add_hsNdiv_attrs"/>
        <xsl:if test="$proof_links&gt;0">
          <xsl:attribute name="title">
            <xsl:value-of select="@newlevel"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>per </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <xsl:apply-templates select="PerCases"/>
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="BlockThesis"/>
        <xsl:apply-templates select="Thesis"/>
        <xsl:apply-templates select="CaseBlock | SupposeBlock"/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- elBlockThesis, Reasoning -->
  <!-- the Proof is done in two parts, as a preparation for printing -->
  <!-- top proofs into separate documents, and their loading via AJAX -->
  <!-- this is a non-top-level proof -->
  <xsl:template match="Proof/Proof | Now/Proof | Conclusion/Proof | CaseBlock/Proof | SupposeBlock/Proof">
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:call-template name="add_hs2_attrs"/>
        <xsl:if test="$proof_links&gt;0">
          <xsl:attribute name="title">
            <xsl:value-of select="@newlevel"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>proof </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <!-- add_ar_iconif(#line=`EndPosition[1]/@line`, #col=`EndPosition[1]/@col`); -->
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:text>add</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- hence the rest is a top-level proof -->
  <!-- xsltxt cannot use xsl:document yet, so manually insert -->
  <!-- (now done as perl postproc) -->
  <!-- if you want ajax_proofs -->
  <xsl:template match="Proof">
    <xsl:variable name="nm0" select="concat($ajax_proof_dir,&quot;/&quot;,$anamelc,&quot;/&quot;,@newlevel)"/>
    <xsl:variable name="nm">
      <xsl:choose>
        <xsl:when test="$ajax_proofs=3">
          <xsl:value-of select="concat($ltmpftptpcgi,&quot;?tmp=&quot;,$lbytmpdir,&quot;&amp;raw=1&quot;,&quot;&amp;file=&quot;,$nm0)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$nm0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:element name="a">
        <xsl:choose>
          <xsl:when test="($ajax_proofs=1) or ($ajax_proofs=3)">
            <xsl:call-template name="add_ajax_attrs">
              <xsl:with-param name="u" select="$nm"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="add_hs2_attrs"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$proof_links&gt;0">
          <xsl:attribute name="title">
            <xsl:value-of select="@newlevel"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>proof </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:element>
      <!-- add_ar_iconif(#line=`EndPosition[1]/@line`, #col=`EndPosition[1]/@col`); -->
      <xsl:choose>
        <xsl:when test="$ajax_proofs&gt;0">
          <xsl:element name="span">
            <xsl:if test="$ajax_proofs=2">
              <xsl:attribute name="filebasedproofinsert">
                <xsl:value-of select="@newlevel"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:element>
          <xsl:document href="{$ajax_proof_dir}/{$anamelc}/{@newlevel}" format="html"> 
          <xsl:element name="div">
            <xsl:attribute name="class">
              <xsl:text>add</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
          </xsl:document> 
          <xsl:variable name="bogus" select="1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="div">
            <xsl:attribute name="class">
              <xsl:text>add</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>end;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!-- Reasoning, elBlockThesis -->
  <!-- #nkw tells not to print the keyword (used if hereby was printed above) -->
  <!-- ###TODO: fix for generating items (see Proposition) -->
  <xsl:template match="Now">
    <xsl:param name="nkw"/>
    <xsl:choose>
      <xsl:when test="not($nkw=&quot;1&quot;)">
        <xsl:element name="div">
          <xsl:if test="@nr&gt;0">
            <xsl:call-template name="pplab">
              <xsl:with-param name="nr" select="@nr"/>
              <xsl:with-param name="vid" select="@vid"/>
            </xsl:call-template>
            <xsl:text>: </xsl:text>
          </xsl:if>
          <xsl:element name="a">
            <xsl:call-template name="add_hs2_attrs"/>
            <xsl:if test="$proof_links&gt;0">
              <xsl:attribute name="title">
                <xsl:value-of select="@newlevel"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="pkeyword">
              <xsl:with-param name="str">
                <xsl:text>now </xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="($display_thesis = 1)">
              <xsl:for-each select=" BlockThesis">
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
                  <xsl:apply-templates select="*[position()=last()]"/>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
          </xsl:element>
          <xsl:call-template name="now_body"/>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>end;</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="now_body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="now_body">
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>add</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="BlockThesis"/>
      <xsl:apply-templates select="*[not(name()=&apos;BlockThesis&apos;)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="idv_for_top">
    <xsl:variable name="idv_html">
      <xsl:text>http://lipa.ms.mff.cuni.cz/~urban/idvtest/</xsl:text>
    </xsl:variable>
    <!-- $idv_html = "file:///home/urban/mptp0.2/idvhtml/"; -->
    <xsl:variable name="tptp_file" select="concat($idv_html,&quot;top/&quot;,$anamelc,&quot;.top.rated&quot;)"/>
    <xsl:text> </xsl:text>
    <xsl:element name="img">
      <xsl:call-template name="add_hs2_attrs"/>
      <xsl:attribute name="src">
        <xsl:text>hammock.jpg</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:text>Show IDV graph for whole article</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:text>Show IDV graph for whole article</xsl:text>
      </xsl:attribute>
    </xsl:element>
    <!-- <a -->
    <!-- { -->
    <!-- //    add_ajax_attrs(#u = $th); -->
    <!-- add_hs2_attrs(); -->
    <!-- @title="Show IDV graph"; -->
    <!-- <b { " IDV graph "; } -->
    <!-- } -->
    <xsl:element name="span">
      <xsl:attribute name="style">
        <xsl:text>display:none</xsl:text>
      </xsl:attribute>
      <xsl:text>:: Showing IDV graph ... (Click the Palm Trees again to close it)</xsl:text>
      <xsl:element name="APPLET">
        <xsl:attribute name="CODE">
          <xsl:text>IDVApplet.class</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="ARCHIVE">
          <xsl:text>IDV.jar,TptpParser.jar,antlr-2.7.5.jar</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="WIDTH">
          <xsl:text>0</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="HEIGHT">
          <xsl:text>0</xsl:text>
        </xsl:attribute>
        <xsl:element name="PARAM">
          <xsl:attribute name="NAME">
            <xsl:text>URL</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="VALUE">
            <xsl:value-of select="$tptp_file"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- tpl [Now](#nkw) { -->
  <!-- <div { <b { if [not($nkw="1")] { "now ";} } -->
  <!-- <div { @class="add"; apply[BlockThesis]; -->
  <!-- apply[*[not(name()='BlockThesis')]]; } -->
  <!-- pkeyword(#str="end;"); } } -->
  <!-- separate top-level items by additional newline -->
  <xsl:template match="Article">
    <xsl:element name="div">
      <xsl:if test="not($mk_header &gt; 0)">
        <xsl:call-template name="pcomment0">
          <xsl:with-param name="str" select="concat($aname, &quot;  semantic presentation&quot;)"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$idv &gt; 0">
        <xsl:call-template name="idv_for_top"/>
      </xsl:if>
    </xsl:element>
    <xsl:element name="br"/>
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:if test="(not(name()=&apos;Definiens&apos;)) and (not(name()=&apos;Reservation&apos;))">
        <xsl:element name="br"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Section">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>begin</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- processing of imported documents -->
  <xsl:template match="Theorem">
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text>theorem </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="mkref">
      <xsl:with-param name="aid" select="@aid"/>
      <xsl:with-param name="nr" select="@nr"/>
      <xsl:with-param name="k" select="@kind"/>
    </xsl:call-template>
    <xsl:element name="br"/>
    <xsl:choose>
      <xsl:when test="Verum">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str">
            <xsl:text>canceled; </xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="br"/>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- now used only when #mml=1 - in article the block has them -->
  <xsl:template match="ArgTypes">
    <xsl:call-template name="argtypes">
      <xsl:with-param name="el" select="*"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="argtypes">
    <xsl:param name="el"/>
    <xsl:if test="$el">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>let </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text> be </xsl:text>
      <xsl:call-template name="alist">
        <xsl:with-param name="j">
          <xsl:text>1</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="sep1">
          <xsl:text>, </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="sep2">
          <xsl:text> be </xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="$el"/>
      </xsl:call-template>
      <xsl:text>;</xsl:text>
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <!-- #indef tells not to use Argtypes (we are inside Definition) -->
  <!-- note that this can also be used for displaying -->
  <!-- environmental constructors, or constructor retrieved from other file -->
  <!-- #argt is explicit list of argument types, useful for -->
  <!-- getting the @vid (identifier numbers) of loci -->
  <!-- #nrt tells not to show the result type(s) -->
  <!-- #old says that the constructor is from a redefinition and not new, -->
  <!-- so an anchor should not be created -->
  <xsl:template match="Constructor">
    <xsl:param name="indef"/>
    <xsl:param name="nl"/>
    <xsl:param name="argt"/>
    <xsl:param name="nrt"/>
    <xsl:param name="old"/>
    <xsl:variable name="loci">
      <xsl:choose>
        <xsl:when test="($mml=&quot;1&quot;) or ($generate_items&gt;0)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>2</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($indef=&quot;1&quot;)">
      <xsl:apply-templates select="ArgTypes"/>
    </xsl:if>
    <xsl:if test="@redefnr&gt;0">
      <xsl:call-template name="pcomment0">
        <xsl:with-param name="str">
          <xsl:text>original: </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="abs">
        <xsl:with-param name="k" select="@kind"/>
        <xsl:with-param name="nr" select="@redefnr"/>
        <xsl:with-param name="sym">
          <xsl:call-template name="abs1">
            <xsl:with-param name="k" select="@kind"/>
            <xsl:with-param name="nr" select="@redefnr"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:element name="br"/>
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text>redefine </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="mk">
      <xsl:call-template name="mkind">
        <xsl:with-param name="kind" select="@kind"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$old=&quot;1&quot;">
        <xsl:call-template name="pkeyword">
          <xsl:with-param name="str" select="$mk"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="a">
          <xsl:attribute name="NAME">
            <xsl:value-of select="concat(@kind,@nr)"/>
          </xsl:attribute>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str" select="$mk"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@kind=&quot;G&quot;">
        <xsl:call-template name="abs">
          <xsl:with-param name="k" select="@kind"/>
          <xsl:with-param name="nr" select="@relnr"/>
          <xsl:with-param name="sym">
            <xsl:call-template name="abs1">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@relnr"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>(# </xsl:text>
        <xsl:for-each select="Fields/Field">
          <xsl:call-template name="abs">
            <xsl:with-param name="k">
              <xsl:text>U</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="nr" select="@nr"/>
            <xsl:with-param name="sym">
              <xsl:call-template name="abs1">
                <xsl:with-param name="k">
                  <xsl:text>U</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="nr" select="@nr"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text> #)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@kind=&apos;V&apos;">
            <xsl:variable name="nr1" select="count(ArgTypes/Typ)"/>
            <xsl:choose>
              <xsl:when test="$loci = 1">
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="$nr1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="ppconst">
                  <xsl:with-param name="nr" select="$nr1"/>
                  <xsl:with-param name="vid" select="$argt[position() = $nr1]/@vid"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> is </xsl:text>
            <xsl:call-template name="pp">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@relnr"/>
              <xsl:with-param name="args" select="$argt[position() &lt; last()]"/>
              <xsl:with-param name="loci" select="$loci"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="pp">
              <xsl:with-param name="k" select="@kind"/>
              <xsl:with-param name="nr" select="@relnr"/>
              <xsl:with-param name="args" select="$argt"/>
              <xsl:with-param name="loci" select="$loci"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not($nrt = 1) and 
        ((@kind = &apos;M&apos;) or (@kind = &apos;K&apos;) or (@kind= &apos;G&apos;) 
         or (@kind= &apos;U&apos;) or (@kind= &apos;L&apos;))">
      <xsl:call-template name="pkeyword">
        <xsl:with-param name="str">
          <xsl:text> -&gt; </xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <!-- note that loci in Typs here can be translated to constants and identifiers -->
      <!-- - see definition of LocusVar -->
      <xsl:call-template name="list">
        <xsl:with-param name="separ">
          <xsl:text>,</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="elems" select="Typ"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not($indef=&quot;1&quot;)">
        <xsl:text>;</xsl:text>
        <xsl:element name="br"/>
        <xsl:element name="br"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$nl=&quot;1&quot;">
          <xsl:text>;</xsl:text>
          <xsl:element name="br"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- display synonym and antonym definiiotns -->
  <xsl:template match="NotationBlock/Pattern">
    <!-- pp1(#k=`@constrkind`,#nr=`@constrnr`,#vis=`Visible/Int`, -->
    <!-- #fnr=`@formatnr`, #loci="1"); <br; -->
    <xsl:variable name="loci">
      <xsl:choose>
        <xsl:when test="$mml=&quot;1&quot;">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>2</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="argtypes" select="../Let/Typ"/>
    <xsl:element name="a">
      <xsl:attribute name="NAME">
        <xsl:value-of select="concat(&quot;N&quot;,@kind,@nr)"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@antonymic">
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>antonym </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>synonym </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="pp1">
        <xsl:with-param name="k" select="@constrkind"/>
        <xsl:with-param name="nr" select="@constrnr"/>
        <xsl:with-param name="args" select="$argtypes"/>
        <xsl:with-param name="vis" select="Visible/Int"/>
        <xsl:with-param name="fnr" select="@formatnr"/>
        <xsl:with-param name="loci" select="$loci"/>
      </xsl:call-template>
    </xsl:element>
    <xsl:call-template name="pkeyword">
      <xsl:with-param name="str">
        <xsl:text> for </xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="pp">
      <xsl:with-param name="k" select="@constrkind"/>
      <xsl:with-param name="nr" select="@constrnr"/>
      <xsl:with-param name="args" select="$argtypes"/>
      <xsl:with-param name="pid" select="@redefnr"/>
      <xsl:with-param name="loci" select="$loci"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- ignore forgetful functors - unhandled yet -->
  <xsl:template match="Notations/Pattern">
    <!-- pp1(#k=`@constrkind`,#nr=`@constrnr`,#vis=`Visible/Int`, -->
    <!-- #fnr=`@formatnr`, #loci="1"); <br; -->
    <xsl:if test="not(@kind = &quot;J&quot;)">
      <xsl:apply-templates select="ArgTypes"/>
      <xsl:choose>
        <xsl:when test="Expansion">
          <!-- $alc = lc(#s=`@aid`); -->
          <xsl:variable name="sym">
            <xsl:call-template name="abs1">
              <xsl:with-param name="k">
                <xsl:text>M</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="fnr" select="@formatnr"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text>mode </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="absref">
            <xsl:with-param name="elems" select="."/>
            <xsl:with-param name="c">
              <xsl:text>0</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="sym" select="$sym"/>
            <xsl:with-param name="pid" select="@relnr"/>
          </xsl:call-template>
          <!-- <a -->
          <!-- { -->
          <!-- @href=`concat($alc, ".", $ext, "#","NM",@nr)`; -->
          <!-- if [$titles="1"] { @title=`concat(@aid,":","NM",".",@nr)`; } -->
          <!-- abs1(#k = "M", #fnr = `@formatnr`); -->
          <!-- } -->
          <xsl:if test="Visible/Int">
            <xsl:text> of </xsl:text>
            <xsl:for-each select="Visible/Int">
              <xsl:call-template name="ploci">
                <xsl:with-param name="nr" select="@x"/>
              </xsl:call-template>
              <xsl:if test="not(position()=last())">
                <xsl:text>,</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str">
              <xsl:text> is </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates select="Expansion/Typ"/>
          <xsl:text>;</xsl:text>
          <xsl:element name="br"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="loci">
            <xsl:choose>
              <xsl:when test="$mml=&quot;1&quot;">
                <xsl:text>1</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>2</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="mk">
            <xsl:call-template name="mkind">
              <xsl:with-param name="kind" select="@kind"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="pkeyword">
            <xsl:with-param name="str" select="$mk"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
          <xsl:call-template name="pp1">
            <xsl:with-param name="k" select="@constrkind"/>
            <xsl:with-param name="nr" select="@constrnr"/>
            <xsl:with-param name="vis" select="Visible/Int"/>
            <xsl:with-param name="fnr" select="@formatnr"/>
            <xsl:with-param name="loci">
              <xsl:text>1</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:element name="br"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:template>

  <!-- ignore normal Patterns now -->
  <xsl:template match="Pattern"/>
</xsl:stylesheet>
