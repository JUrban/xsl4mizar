<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- the import directive is useful because anything -->
  <!-- imported can be later overrriden - we'll use it for -->
  <!-- the pretty-printing funcs -->
  <xsl:import href="../MHTML/mhtml_block_top.xsl"/>
  <!-- ##INCLUDE HERE -->
  <xsl:output method="html"/>
  <!-- $Revision: 1.4 $ -->
  <!--  -->
  <!-- File: fm_main.xsltxt - TeX-ization of Mizar XML, main file -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- XML terms, formulas and types to FM format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar ../xsltxt.jar toXSL fm_html.xsltxt >fm_html.xsl -->
  <!-- include fm_print_complex.xsl; -->
  <!-- include mhtml_block_top.xsl;  // ##INCLUDE HERE -->
  <!-- the FM specific code: -->
  <!-- XML file containing FM formats -->
  <xsl:param name="fmformats">
    <xsl:text>file:///home/urban/gr/xsl4mizar/FM/fm_formats.fmx</xsl:text>
  </xsl:param>
  <!-- .bxx file with the bibtex info in xml (see article_bib.rnc) -->
  <xsl:param name="bibtex">
    <xsl:value-of select="concat($anamelc, &apos;.bbx&apos;)"/>
  </xsl:param>
  <!-- lookup of the FMFormat based on the symbol, kind,argnr and leftargnr - -->
  <!-- TODO: add the rightsymbol too (otherwise probably not unique) -->
  <xsl:key name="FM" match="FMFormatMap" use="concat( @symbol, &quot;::&quot;, @kind, &apos;:&apos;, @argnr, &apos;:&apos;, @leftargnr)"/>
  <!-- symbols, overloaded for tex presentation -->
  <xsl:param name="for_s">
    <xsl:text> \forall </xsl:text>
  </xsl:param>
  <xsl:param name="ex_s">
    <xsl:text> \exists </xsl:text>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:text> \lnot </xsl:text>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:text> \: non \: </xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text> \&amp; </xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text> \Rightarrow </xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text> \Leftrightarrow </xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text> \lor </xsl:text>
  </xsl:param>
  <xsl:param name="holds_s">
    <xsl:text> \: holds \: </xsl:text>
  </xsl:param>
  <xsl:param name="being_s">
    <xsl:text> : </xsl:text>
  </xsl:param>
  <xsl:param name="be_s">
    <xsl:text> be </xsl:text>
  </xsl:param>
  <xsl:param name="st_s">
    <xsl:text> \: st \: </xsl:text>
  </xsl:param>
  <xsl:param name="is_s">
    <xsl:text> \: is \: </xsl:text>
  </xsl:param>
  <xsl:param name="dots_s">
    <xsl:text> ... </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_start">
    <xsl:text> { </xsl:text>
  </xsl:param>
  <xsl:param name="fraenkel_end">
    <xsl:text> } </xsl:text>
  </xsl:param>
  <xsl:param name="of_sel_s">
    <xsl:text> \: of \: </xsl:text>
  </xsl:param>
  <xsl:param name="of_typ_s">
    <xsl:text> \: of \: </xsl:text>
  </xsl:param>
  <xsl:param name="the_sel_s">
    <xsl:text> \: the \: </xsl:text>
  </xsl:param>
  <xsl:param name="choice_s">
    <xsl:text> \: the \: </xsl:text>
  </xsl:param>
  <xsl:param name="lbracket_s">
    <xsl:text>(</xsl:text>
  </xsl:param>
  <xsl:param name="rbracket_s">
    <xsl:text>)</xsl:text>
  </xsl:param>

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
        <xsl:copy-of select="$lbracket_s"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$ex=&quot;1&quot;">
          <xsl:copy-of select="$ex_s"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$for_s"/>
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
            <xsl:copy-of select="$being_s"/>
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
                <xsl:copy-of select="$st_s"/>
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
                      <xsl:copy-of select="$lbracket_s"/>
                      <xsl:text> </xsl:text>
                      <xsl:choose>
                        <xsl:when test="And[@pid=$pid_Or_And]">
                          <xsl:for-each select="*[2]/*">
                            <xsl:if test="position()&gt;1">
                              <xsl:copy-of select="$or_s"/>
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
                            <xsl:with-param name="separ" select="$and_s"/>
                            <xsl:with-param name="elems" select="*[2]/*[position()&lt;last()]"/>
                            <xsl:with-param name="i" select="$j+1"/>
                            <xsl:with-param name="pr">
                              <xsl:text>1</xsl:text>
                            </xsl:with-param>
                          </xsl:call-template>
                          <xsl:copy-of select="$imp_s"/>
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
                                  <xsl:copy-of select="$not_s"/>
                                  <xsl:apply-templates select="*[2]/*[position()=last()]">
                                    <xsl:with-param name="i" select="$j+1"/>
                                  </xsl:apply-templates>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text> </xsl:text>
                      <xsl:copy-of select="$rbracket_s"/>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$being_s"/>
            <xsl:apply-templates select="*[1]">
              <xsl:with-param name="i" select="$j + 1"/>
            </xsl:apply-templates>
            <xsl:if test="not(($nm = &quot;For&quot;) or ($nm=&quot;Not&quot;))">
              <xsl:copy-of select="$holds_s"/>
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
          <xsl:text> </xsl:text>
          <xsl:copy-of select="$rbracket_s"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [And/For] { <div {"for B being"; apply[*[1]]; -->
  <!-- copy-of $holds_s; <div { @class="add";  apply[*[2]]; } } } -->
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
              <xsl:copy-of select="$holds_s"/>
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
                    <xsl:copy-of select="$st_s"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$lbracket_s"/>
                    <xsl:text> </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="$i3=2">
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ" select="$and_s"/>
                      <xsl:with-param name="elems" select="*[1]/*[not(@pid=$pid_Impl_RightNot)]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                      <xsl:when test="$st=&quot;1&quot;">
                        <xsl:copy-of select="$holds_s"/>
                        <xsl:element name="br"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="$imp_s"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[1]/*[@pid=$pid_Impl_RightNot]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="ilist">
                      <xsl:with-param name="separ" select="$and_s"/>
                      <xsl:with-param name="elems" select="*[1]/*[position()&lt;last()]"/>
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                      <xsl:when test="$st=&quot;1&quot;">
                        <xsl:copy-of select="$holds_s"/>
                        <xsl:element name="br"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="$imp_s"/>
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
                        <xsl:copy-of select="$not_s"/>
                        <xsl:apply-templates select="*[1]/*[position()=last()]">
                          <xsl:with-param name="i" select="$i"/>
                        </xsl:apply-templates>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not($st=&quot;1&quot;)">
                  <xsl:text> </xsl:text>
                  <xsl:copy-of select="$rbracket_s"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$st=&quot;1&quot;">
                  <xsl:copy-of select="$holds_s"/>
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
                    <xsl:copy-of select="$lbracket_s"/>
                    <xsl:text> </xsl:text>
                    <!-- " OR1 "; -->
                    <xsl:for-each select="*[1]/*">
                      <xsl:if test="position()&gt;1">
                        <xsl:copy-of select="$or_s"/>
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
                              <xsl:copy-of select="$not_s"/>
                              <xsl:apply-templates select=".">
                                <xsl:with-param name="i" select="$i"/>
                              </xsl:apply-templates>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                    <xsl:text> </xsl:text>
                    <xsl:copy-of select="$rbracket_s"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$not_s"/>
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
  <!-- copy-of $lbracket_s; " "; put_positive(#separ=copy-of $and_s,#els=`*[1]/*`,#nr=$pcnt,#i=$i); copy-of $imp_s; -->
  <!-- put_positive(#separ=copy-of $or_s,#els=`*[1]/*`,#nr=`$cnt - $pcnt`,#neg="1",#i=$i); copy-of $rbracket_s; -->
  <!-- } -->
  <!-- else { if [($i3="1") and ($pcnt=0)] { copy-of $lbracket_s; " "; put_positive(#separ=copy-of $or_s,#els=`*[1]/*`,#nr=$cnt,#neg="1",#i=$i); copy-of $rbracket_s; } -->
  <!-- if [$i3="1"  and (*[1]/*[not(name()="Not")]) and (*[1]/Not)] { "( ( "; -->
  <!-- ilist(#separ=$and_s, #elems=`*[1]/*[not(name()="Not")]`, #i=$i,#pr="1"); -->
  <!-- " "; copy-of $rbracket_s; copy-of $imp_s; -->
  <!-- copy-of $lbracket_s; " "; ilist(#separ=$or_s, #elems=`*[1]/Not/*[1]`, #i=$i,#pr="1"); " ) )"; } -->
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
        <xsl:copy-of select="$lbracket_s"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="*[1]/*[1]/*[1]">
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="pr">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
        <xsl:copy-of select="$equiv_s"/>
        <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
          <xsl:with-param name="i" select="$i"/>
        </xsl:apply-templates>
        <xsl:text> </xsl:text>
        <xsl:copy-of select="$rbracket_s"/>
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
                <xsl:copy-of select="$lbracket_s"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="*[1]/*[1]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="pr">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
                <xsl:copy-of select="$equiv_s"/>
                <xsl:apply-templates select="*[1]/*[1]/*[2]/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                </xsl:apply-templates>
                <xsl:text> </xsl:text>
                <xsl:copy-of select="$rbracket_s"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="i2">
                  <xsl:call-template name="is_impl">
                    <xsl:with-param name="el" select="*[2]"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$i2=&quot;1&quot;">
                    <xsl:copy-of select="$lbracket_s"/>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="*[2]/*[1]/*[2]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                      <xsl:with-param name="pr">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:copy-of select="$equiv_s"/>
                    <xsl:apply-templates select="*[2]/*[1]/*[1]">
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:apply-templates>
                    <xsl:text> </xsl:text>
                    <xsl:copy-of select="$rbracket_s"/>
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
                          <xsl:copy-of select="$lbracket_s"/>
                          <xsl:text> </xsl:text>
                          <xsl:choose>
                            <xsl:when test="$i5=2">
                              <xsl:call-template name="ilist">
                                <xsl:with-param name="separ" select="$and_s"/>
                                <xsl:with-param name="elems" select="*[1]/*[not(@pid=$pid_Impl_RightNot)]"/>
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="pr">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:call-template>
                              <xsl:copy-of select="$equiv_s"/>
                              <xsl:apply-templates select="*[1]/*[@pid=$pid_Impl_RightNot]/*[1]">
                                <xsl:with-param name="i" select="$i"/>
                              </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="ilist">
                                <xsl:with-param name="separ" select="$and_s"/>
                                <xsl:with-param name="elems" select="*[1]/*[position()&lt;last()]"/>
                                <xsl:with-param name="i" select="$i"/>
                                <xsl:with-param name="pr">
                                  <xsl:text>1</xsl:text>
                                </xsl:with-param>
                              </xsl:call-template>
                              <xsl:copy-of select="$equiv_s"/>
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
                                  <xsl:copy-of select="$not_s"/>
                                  <xsl:apply-templates select="*[1]/*[position()=last()]">
                                    <xsl:with-param name="i" select="$i"/>
                                  </xsl:apply-templates>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:text> </xsl:text>
                          <xsl:copy-of select="$rbracket_s"/>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="$lbracket_s"/>
                        <xsl:text> </xsl:text>
                        <xsl:comment>
                          <xsl:text>HUMANRECFAILED</xsl:text>
                        </xsl:comment>
                        <xsl:call-template name="ilist">
                          <xsl:with-param name="separ" select="$and_s"/>
                          <xsl:with-param name="elems" select="*"/>
                          <xsl:with-param name="i" select="$i"/>
                          <xsl:with-param name="pr">
                            <xsl:text>1</xsl:text>
                          </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                        <xsl:copy-of select="$rbracket_s"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$lbracket_s"/>
            <xsl:text> </xsl:text>
            <!-- if[not(@pid)] { " NOPID ";} -->
            <xsl:call-template name="ilist">
              <xsl:with-param name="separ" select="$and_s"/>
              <xsl:with-param name="elems" select="*"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="pr">
                <xsl:text>1</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:copy-of select="$rbracket_s"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Pred">
    <xsl:param name="i"/>
    <xsl:param name="not"/>
    <xsl:param name="pr"/>
    <xsl:element name="Pred">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@kind=&apos;P&apos;">
          <xsl:apply-templates>
            <xsl:with-param name="p" select="$p"/>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
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
            <xsl:copy-of select="$not_s"/>
          </xsl:if>
          <xsl:attribute name="formatnr">
            <xsl:value-of select="$fnr"/>
          </xsl:attribute>
          <xsl:attribute name="neg">
            <xsl:value-of select="$neg"/>
          </xsl:attribute>
          <xsl:apply-templates>
            <xsl:with-param name="i" select="$i"/>
            <xsl:with-param name="pr" select="$pr"/>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- ,#sym1=abs(#k=`@kind`, #nr=`@nr`, #sym=abs1(#k=`@kind`, #nr=`@nr`))); }} -->
  <!-- "[ "; list(#separ=",", #elems=`*`); "]"; } -->
  <xsl:template match="PrivPred">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:element name="PrivPred">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$not=&quot;1&quot;">
        <xsl:attribute name="neg">
          <xsl:value-of select="$neg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pr" select="$pr"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Is">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:element name="Is">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$not=&quot;1&quot;">
        <xsl:attribute name="neg">
          <xsl:value-of select="$neg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pr" select="$pr"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Verum">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:element name="Verum">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$not=&quot;1&quot;">
        <xsl:attribute name="neg">
          <xsl:value-of select="$neg"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ErrorFrm">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:element name="ErrorFrm">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$not=&quot;1&quot;">
        <xsl:attribute name="neg">
          <xsl:value-of select="$neg"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="FlexFrm">
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:param name="not"/>
    <xsl:element name="FlexFrm">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$not=&quot;1&quot;">
        <xsl:attribute name="neg">
          <xsl:value-of select="$neg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="pr" select="$pr"/>
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="not" select="$not"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <!-- Terms -->
  <!-- #p is the parenthesis count -->
  <!-- #i is the size of the var stack -->
  <xsl:template match="Var">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Var">
      <xsl:copy-of select="@*"/>
      <xsl:if test="$print_identifiers &gt; 0">
        <xsl:variable name="vid">
          <xsl:call-template name="get_vid">
            <xsl:with-param name="up" select="$i - @nr"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:attribute name="varname">
          <xsl:value-of select="$vid"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
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
    <xsl:element name="LocusVar">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="FreeVar">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="FreeVar">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Const">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Const">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="InfConst">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="InfConst">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Num">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Num">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Func">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Func">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@kind=&apos;F&apos;">
          <xsl:apply-templates>
            <xsl:with-param name="p" select="$p"/>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
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
          <xsl:attribute name="formatnr">
            <xsl:value-of select="$fnr"/>
          </xsl:attribute>
          <xsl:apply-templates>
            <xsl:with-param name="p" select="$p"/>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="PrivFunc">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="PrivFunc">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ErrorTrm">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="ErrorTrm">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Choice">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Choice">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Fraenkel">
    <xsl:param name="p"/>
    <xsl:param name="i"/>
    <xsl:element name="Fraenkel">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="p" select="$p"/>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
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
    <xsl:choose>
      <xsl:when test="(@kind=&quot;M&quot;) or (@kind=&quot;G&quot;) or (@kind=&quot;L&quot;)">
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
        <xsl:element name="Typ">
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="formatnr">
            <xsl:value-of select="$fnr"/>
          </xsl:attribute>
          <xsl:attribute name="expandable">
            <xsl:value-of select="$expand"/>
          </xsl:attribute>
          <xsl:apply-templates>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="Typ">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Clusters -->
  <!-- only attributes with pid are now printed, unless %all=1; -->
  <!-- others are results of -->
  <!-- cluster mechanisms - this holds in the current article -->
  <!-- (.xml file) only, environmental files do not have the @pid -->
  <!-- info (yet), so we print everything for them -->
  <xsl:template match="Cluster">
    <xsl:param name="i"/>
    <xsl:param name="all"/>
    <xsl:element name="Cluster">
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="($print_all_attrs = 1) or ($all = 1)">
          <xsl:apply-templates>
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[@pid]">
            <xsl:with-param name="i" select="$i"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
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
    <xsl:element name="Adjective">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="formatnr">
        <xsl:value-of select="$fnr"/>
      </xsl:attribute>
      <xsl:attribute name="neg">
        <xsl:value-of select="$neg"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="i" select="$i"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <!-- kill proofs -->
  <xsl:template match="Proof"/>

  <xsl:template match="Proposition">
    <xsl:if test="following-sibling::*[1][(name()=&quot;By&quot;) and (@linked=&quot;true&quot;)]">
      <xsl:if test="not((name(..) = &quot;Consider&quot;) or (name(..) = &quot;Reconsider&quot;) 
           or (name(..) = &quot;Conclusion&quot;))">
        <xsl:text>then </xsl:text>
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
    <xsl:text>$</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
    <xsl:text>$</xsl:text>
  </xsl:template>

  <xsl:template name="add_hs_attrs"/>

  <xsl:template name="add_hs2_attrs"/>

  <xsl:template name="add_hsNdiv_attrs"/>

  <xsl:template name="add_ajax_attrs">
    <xsl:param name="u"/>
  </xsl:template>

  <xsl:template name="mkref">
    <xsl:param name="aid"/>
    <xsl:param name="nr"/>
    <xsl:param name="k"/>
    <xsl:param name="c"/>
    <xsl:param name="nm"/>
    <xsl:variable name="mk">
      <xsl:call-template name="refkind">
        <xsl:with-param name="kind" select="$k"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="alc">
      <xsl:call-template name="lc">
        <xsl:with-param name="s" select="$aid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$nm">
        <xsl:value-of select="$nm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$aid"/>
        <xsl:text>:</xsl:text>
        <xsl:if test="not($k=&quot;T&quot;)">
          <xsl:value-of select="$mk"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="$nr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- add the constructor/pattern href, $c tells if it is from current article -->
  <!-- #sym is optional Mizar symbol -->
  <!-- #pid links to  patterns instead of constructors -->
  <xsl:template name="absref">
    <xsl:param name="elems"/>
    <xsl:param name="c"/>
    <xsl:param name="sym"/>
    <xsl:param name="pid"/>
    <xsl:variable name="n1">
      <xsl:choose>
        <xsl:when test="($pid &gt; 0)">
          <xsl:text>N</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$elems">
      <xsl:variable name="mk0">
        <xsl:call-template name="mkind">
          <xsl:with-param name="kind" select="@kind"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="mk">
        <xsl:choose>
          <xsl:when test="($pid &gt; 0)">
            <xsl:value-of select="concat($mk0, &quot;not&quot;)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$mk0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="alc">
        <xsl:call-template name="lc">
          <xsl:with-param name="s" select="@aid"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$sym">
          <xsl:value-of select="$sym"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$relnames &gt; 0">
              <xsl:value-of select="$n1"/>
              <xsl:value-of select="@kind"/>
              <xsl:value-of select="@relnr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$n1"/>
              <xsl:value-of select="@kind"/>
              <xsl:value-of select="@nr"/>
              <xsl:text>_</xsl:text>
              <xsl:value-of select="@aid"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="AUTHOR|TITLE|ACKNOWLEDGEMENT|SUMMARY|NOTE|ADDRESS">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="text()"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="DATE">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Received &quot;, @month,&quot; &quot;, @day, &quot;, &quot;, @year)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ARTICLE_BIB">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Default -->
  <xsl:template match="/">
    <xsl:for-each select="document($bibtex,/)">
      <xsl:apply-templates select="ARTICLE_BIB"/>
    </xsl:for-each>
    <!-- first read the keys for imported stuff -->
    <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
    <!-- apply[document($thms,/)/Theorems/Theorem]; -->
    <!-- apply[document($schms,/)/Schemes/Scheme]; -->
    <!-- then process the whole document -->
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
