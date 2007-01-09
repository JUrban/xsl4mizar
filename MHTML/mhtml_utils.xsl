<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_print_simple.xsl"/>
  <!-- $Revision: 1.3 $ -->
  <!--  -->
  <!-- File: utils.xsltxt - html-ization of Mizar XML, various utility functions -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
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
  <!-- means that "not" will not be used -->
  <xsl:template name="is_positive">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(name()=&quot;Not&quot;)">
          <xsl:choose>
            <xsl:when test="Pred[(@kind=&apos;V&apos;) or (@kind=&apos;R&apos;)]">
              <xsl:variable name="pi">
                <xsl:call-template name="patt_info">
                  <xsl:with-param name="k" select="*[1]/@kind"/>
                  <xsl:with-param name="nr" select="*[1]/@nr"/>
                  <xsl:with-param name="pid" select="*[1]/@pid"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="antonym">
                <xsl:call-template name="cadr">
                  <xsl:with-param name="l" select="$pi"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:value-of select="$antonym mod 2"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="(name()=&quot;Pred&quot;) and ((@kind=&apos;V&apos;) or (@kind=&apos;R&apos;))">
              <xsl:variable name="pi">
                <xsl:call-template name="patt_info">
                  <xsl:with-param name="k" select="@kind"/>
                  <xsl:with-param name="nr" select="@nr"/>
                  <xsl:with-param name="pid" select="@pid"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="antonym">
                <xsl:call-template name="cadr">
                  <xsl:with-param name="l" select="$pi"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:value-of select="($antonym + 1) mod 2"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="is_negative">
    <xsl:param name="el"/>
    <xsl:variable name="pos">
      <xsl:call-template name="is_positive">
        <xsl:with-param name="el" select="$el"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="1 - $pos"/>
  </xsl:template>

  <xsl:template name="count_positive">
    <xsl:param name="els"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$nr &gt; 0">
        <xsl:variable name="el1" select="$els[position()=$nr]"/>
        <xsl:variable name="res1">
          <xsl:call-template name="is_positive">
            <xsl:with-param name="el" select="$els[position()=$nr]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="res2">
          <xsl:call-template name="count_positive">
            <xsl:with-param name="els" select="$els"/>
            <xsl:with-param name="nr" select="$nr - 1"/>
          </xsl:call-template>
        </xsl:variable>
        <!-- DEBUG       `concat($res1,":",$res2)`; -->
        <xsl:value-of select="$res1 + $res2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- if $neg, then put negative, striping the negation -->
  <xsl:template name="put_positive">
    <xsl:param name="separ"/>
    <xsl:param name="els"/>
    <xsl:param name="nr"/>
    <xsl:param name="neg"/>
    <xsl:param name="i"/>
    <xsl:if test="$nr &gt; 0">
      <xsl:variable name="el1" select="$els[position()=1]"/>
      <xsl:variable name="pos">
        <xsl:call-template name="is_positive">
          <xsl:with-param name="el" select="$el1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="pos1">
        <xsl:choose>
          <xsl:when test="$neg=&quot;1&quot;">
            <xsl:value-of select="($neg + $pos) mod 2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$pos"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$pos1=&quot;1&quot;">
        <xsl:variable name="nm" select="name($el1)"/>
        <xsl:choose>
          <xsl:when test="$neg=&quot;1&quot;">
            <!-- change this if is_positive changes! -->
            <xsl:choose>
              <xsl:when test="$nm=&quot;Not&quot;">
                <xsl:apply-templates select="$el1/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:when test="$nm=&quot;Pred&quot;">
                <xsl:apply-templates select="$el1">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="not">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$dbgmsg"/>
                <xsl:value-of select="$nm"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$nm=&quot;Not&quot;">
                <xsl:apply-templates select="$el1/*[1]">
                  <xsl:with-param name="i" select="$i"/>
                  <xsl:with-param name="not">
                    <xsl:text>1</xsl:text>
                  </xsl:with-param>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$el1">
                  <xsl:with-param name="i" select="$i"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$nr &gt; 1">
          <xsl:value-of select="$separ"/>
        </xsl:if>
      </xsl:if>
      <xsl:call-template name="put_positive">
        <xsl:with-param name="separ" select="$separ"/>
        <xsl:with-param name="els" select="$els[position() &gt; 1]"/>
        <xsl:with-param name="nr" select="$nr - $pos1"/>
        <xsl:with-param name="neg" select="$neg"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

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

  <!-- now also used when included "or" ate the implicant -->
  <xsl:template name="is_or1">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="((@pid=$pid_Or) or (@pid=$pid_Impl)) 
        and (*[1][@pid=$pid_Or_And]) and (count(*[1]/*)&gt;=2)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- used when is_or failed -->
  <xsl:template name="is_or3">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Or) 
        and (*[1][@pid=$pid_Or_And]) and (count(*[1]/*)=2)">
          <xsl:variable name="neg1">
            <xsl:call-template name="is_negative">
              <xsl:with-param name="el" select="*[1]/*[1]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="neg2">
            <xsl:call-template name="is_negative">
              <xsl:with-param name="el" select="*[1]/*[2]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$neg1 * $neg2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- used when is_or3 failed -->
  <xsl:template name="is_or4">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Or) 
        and (*[1][@pid=$pid_Or_And]) and (count(*[1]/*)=2)">
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
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;=2)">
          <xsl:choose>
            <xsl:when test="*[1]/*[@pid=$pid_Impl_RightNot]">
              <xsl:text>2</xsl:text>
            </xsl:when>
            <xsl:when test="name(*[1]/*[position()=last()]) = &quot;For&quot;">
              <xsl:text>4</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="neg1">
                <xsl:call-template name="is_negative">
                  <xsl:with-param name="el" select="*[1]/*[position()=last()]"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$neg1 = &quot;1&quot;">
                  <xsl:text>3</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>5</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
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
	and ((*[1]/*[@pid=$pid_Impl_RightNot]))">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- used when is_impl2 failed -->
  <xsl:template name="is_impl3">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;=2)">
          <xsl:call-template name="is_negative">
            <xsl:with-param name="el" select="*[1]/*[position()=last()]"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- used when is_impl3 failed -->
  <xsl:template name="is_impl4">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;=2)
	and (name(*[1]/*[position()=last()]) = &quot;For&quot;)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- used when is_impl4 failed -->
  <xsl:template name="is_impl5">
    <xsl:param name="el"/>
    <xsl:for-each select="$el">
      <xsl:choose>
        <xsl:when test="(@pid=$pid_Impl) 
        and (*[1][@pid=$pid_Impl_And]) and (count(*[1]/*)&gt;=2)">
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

  <!-- recursive equality on subnodes and attributes upto the @vid attribute -->
  <xsl:template name="are_equal_vid">
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
            <xsl:if test="not(name()=&quot;div&quot;)">
              <xsl:value-of select="string()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="s2">
          <xsl:for-each select="$el2/@*">
            <xsl:if test="not(name()=&quot;div&quot;)">
              <xsl:value-of select="string()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="not($s1=$s2)">
            <xsl:text>0</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="are_equal_many_vid">
              <xsl:with-param name="els1" select="$el1/*"/>
              <xsl:with-param name="els2" select="$el2/*"/>
              <xsl:with-param name="nr" select="count($el1/*)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="are_equal_many_vid">
    <xsl:param name="els1"/>
    <xsl:param name="els2"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$nr &gt; 0">
        <xsl:variable name="el1" select="$els1[position()=$nr]"/>
        <xsl:variable name="el2" select="$els2[position()=$nr]"/>
        <xsl:variable name="res1">
          <xsl:call-template name="are_equal_vid">
            <xsl:with-param name="el1" select="$el1"/>
            <xsl:with-param name="el2" select="$el2"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$res1=&quot;1&quot;">
            <xsl:call-template name="are_equal_many_vid">
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

  <xsl:template name="lc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $ucletters, $lcletters)"/>
  </xsl:template>

  <xsl:template name="uc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $lcletters, $ucletters)"/>
  </xsl:template>

  <!-- utilities for adding lemma names -->
  <xsl:template name="addp">
    <xsl:param name="pl"/>
    <xsl:if test="string-length($pl)&gt;0">
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$pl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="propname">
    <xsl:param name="n"/>
    <xsl:param name="pl"/>
    <xsl:text>E</xsl:text>
    <xsl:value-of select="$n"/>
    <xsl:call-template name="addp">
      <xsl:with-param name="pl" select="$pl"/>
    </xsl:call-template>
  </xsl:template>
  <!-- poor man's data structure, aka "colon-list" -->
  <xsl:param name="nil">
    <xsl:text/>
  </xsl:param>

  <xsl:template name="cons">
    <xsl:param name="h"/>
    <xsl:param name="t"/>
    <xsl:value-of select="concat($h,&quot;:&quot;,$t)"/>
  </xsl:template>

  <xsl:template name="car">
    <xsl:param name="l"/>
    <xsl:value-of select="substring-before($l,&quot;:&quot;)"/>
  </xsl:template>

  <xsl:template name="cdr">
    <xsl:param name="l"/>
    <xsl:value-of select="substring-after($l,&quot;:&quot;)"/>
  </xsl:template>

  <xsl:template name="cadr">
    <xsl:param name="l"/>
    <xsl:call-template name="car">
      <xsl:with-param name="l">
        <xsl:call-template name="cdr">
          <xsl:with-param name="l" select="$l"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cddr">
    <xsl:param name="l"/>
    <xsl:call-template name="cdr">
      <xsl:with-param name="l">
        <xsl:call-template name="cdr">
          <xsl:with-param name="l" select="$l"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="third">
    <xsl:param name="l"/>
    <xsl:call-template name="car">
      <xsl:with-param name="l">
        <xsl:call-template name="cddr">
          <xsl:with-param name="l" select="$l"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="cdddr">
    <xsl:param name="l"/>
    <xsl:call-template name="cdr">
      <xsl:with-param name="l">
        <xsl:call-template name="cddr">
          <xsl:with-param name="l" select="$l"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- poor man's 0-based integer arrays (integer is non-negative and four digits long now) -->
  <!-- the biggest identifier number is 1061 for jordan7 in MML 758 -->
  <xsl:param name="int_size">
    <xsl:text>4</xsl:text>
  </xsl:param>

  <!-- #index must be 0-based -->
  <xsl:template name="arr_ref">
    <xsl:param name="array"/>
    <xsl:param name="index"/>
    <xsl:variable name="beg" select="$int_size * $index"/>
    <xsl:value-of select="number(substring($array, $beg, $beg + $int_size))"/>
  </xsl:template>

  <xsl:template name="apush">
    <xsl:param name="array"/>
    <xsl:param name="obj"/>
    <xsl:variable name="obj1">
      <xsl:call-template name="arr_pad_obj">
        <xsl:with-param name="obj"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($array, $obj1)"/>
  </xsl:template>

  <xsl:template name="arr_set">
    <xsl:param name="array"/>
    <xsl:param name="index"/>
    <xsl:param name="obj"/>
    <xsl:variable name="obj1">
      <xsl:call-template name="arr_pad_obj">
        <xsl:with-param name="obj"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="beg" select="$int_size * $index"/>
    <xsl:variable name="end" select="$beg + $int_size"/>
    <xsl:variable name="prefix" select="substring($array, 0, $beg)"/>
    <xsl:variable name="postfix" select="substring($array, $end)"/>
    <xsl:value-of select="concat($prefix, $obj1, $postfix)"/>
  </xsl:template>

  <!-- explicit for speed -->
  <xsl:template name="arr_zeros">
    <xsl:param name="l"/>
    <xsl:choose>
      <xsl:when test="$l = 0">
        <xsl:text/>
      </xsl:when>
      <xsl:when test="$l = 1">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:when test="$l = 2">
        <xsl:text>00</xsl:text>
      </xsl:when>
      <xsl:when test="$l = 3">
        <xsl:text>000</xsl:text>
      </xsl:when>
      <xsl:when test="$l = 4">
        <xsl:text>0000</xsl:text>
      </xsl:when>
      <xsl:when test="$l = 5">
        <xsl:text>00000</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="arr_pad_obj">
    <xsl:param name="obj"/>
    <xsl:variable name="length" select="$int_size - string-length($obj)"/>
    <xsl:variable name="padding">
      <xsl:call-template name="arr_zeros">
        <xsl:with-param name="l" select="$length"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($padding, $obj)"/>
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

  <!-- List utility with additional arg - now only used for formula lists -->
  <xsl:template name="ilist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:param name="i"/>
    <xsl:param name="pr"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select=".">
        <xsl:with-param name="i" select="$i"/>
        <xsl:with-param name="pr" select="$pr"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- newlined list -->
  <xsl:template name="nlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:element name="br"/>
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- newlined andlist -->
  <xsl:template name="andlist">
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:element name="b">
          <xsl:text>and </xsl:text>
        </xsl:element>
        <xsl:element name="br"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:element name="div">
        <xsl:apply-templates select="."/>
        <xsl:if test="not(position()=last())">
          <xsl:value-of select="$separ"/>
        </xsl:if>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <!-- Pretty print constants with their types. -->
  <!-- This now assumes that all #elems are Typ. -->
  <!-- For subseries of consts with the same Typ, -->
  <!-- the Typ is printed only once. -->
  <!-- #sep2 is now either "be " or "being ", -->
  <!-- comma is added automatically. -->
  <xsl:template name="jtlist">
    <xsl:param name="j"/>
    <xsl:param name="sep2"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:call-template name="ppconst">
        <xsl:with-param name="nr" select="$j+position()"/>
        <xsl:with-param name="vid" select="@vid"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="position()=last()">
          <xsl:value-of select="$sep2"/>
          <xsl:apply-templates select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="eq1">
            <xsl:call-template name="are_equal_vid">
              <xsl:with-param name="el1" select="."/>
              <xsl:with-param name="el2" select="following-sibling::*[1]"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:if test="$eq1=&quot;0&quot;">
            <xsl:value-of select="$sep2"/>
            <xsl:apply-templates select="."/>
          </xsl:if>
          <xsl:text>, </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
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

  <!-- return first symbol corresponding to a constructor ($,$nr); -->
  <!-- sometimes we know the $pid or even the formatnr ($fnr) precisely; -->
  <!-- if nothing found, just concat #k and #nr; #r says to look for -->
  <!-- right bracket instead of left or fail if the format is not bracket -->
  <xsl:template name="abs1">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="r"/>
    <xsl:param name="fnr"/>
    <xsl:param name="pid"/>
    <!-- DEBUG    "abs1:"; $k; ":"; $fnr; ":"; -->
    <xsl:variable name="fnr1">
      <xsl:choose>
        <xsl:when test="$fnr">
          <xsl:value-of select="$fnr"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="formt_nr">
            <xsl:with-param name="k" select="$k"/>
            <xsl:with-param name="nr" select="$nr"/>
            <xsl:with-param name="pid" select="$pid"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="document($formats,/)">
      <xsl:choose>
        <xsl:when test="not(key(&apos;F&apos;,$fnr1))">
          <xsl:value-of select="concat($k,$nr)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="key(&apos;F&apos;,$fnr1)">
            <xsl:variable name="snr" select="@symbolnr"/>
            <xsl:variable name="sk1" select="@kind"/>
            <xsl:variable name="sk">
              <xsl:choose>
                <xsl:when test="$sk1=&quot;L&quot;">
                  <xsl:text>G</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$sk1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="dkey" select="concat(&apos;D_&apos;,$sk)"/>
            <xsl:variable name="rsnr">
              <xsl:if test="$sk=&apos;K&apos;">
                <xsl:value-of select="@rightsymbolnr"/>
              </xsl:if>
            </xsl:variable>
            <!-- return nothing if right bracket of nonbracket symbol is asked -->
            <!-- shouldn't it be an error? -->
            <xsl:if test="not($r=&apos;1&apos;) or ($sk=&apos;K&apos;)">
              <xsl:for-each select="document($vocs,/)">
                <xsl:choose>
                  <xsl:when test="key($dkey,$snr)">
                    <xsl:for-each select="key($dkey,$snr)">
                      <xsl:choose>
                        <xsl:when test="($sk=&apos;K&apos;) and ($r=&apos;1&apos;)">
                          <xsl:for-each select="key(&apos;D_L&apos;,$rsnr)">
                            <xsl:value-of select="@name"/>
                          </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="@name"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </xsl:when>
                  <!-- try the built-in symbols -->
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;M&apos;)">
                        <xsl:text>set</xsl:text>
                      </xsl:when>
                      <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;R&apos;)">
                        <xsl:text>=</xsl:text>
                      </xsl:when>
                      <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;K&apos;)">
                        <xsl:choose>
                          <xsl:when test="$r=&apos;1&apos;">
                            <xsl:text>]</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>[</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:when test="($snr=&apos;2&apos;) and ($sk=&apos;K&apos;)">
                        <xsl:choose>
                          <xsl:when test="$r=&apos;1&apos;">
                            <xsl:text>}</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>{</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat($k,$nr)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- private for abs1 -->
  <xsl:template name="formt_nr">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="pid"/>
    <xsl:call-template name="car">
      <xsl:with-param name="l">
        <xsl:call-template name="patt_info">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="pid" select="$pid"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- private for patt_info -->
  <xsl:template name="mk_vis_list">
    <xsl:param name="els"/>
    <xsl:for-each select="$els">
      <xsl:value-of select="@x"/>
      <xsl:text>:</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- private for patt_info - -->
  <!-- assumes we already are inside the right pattern -->
  <xsl:template name="encode_std_pattern">
    <xsl:param name="k"/>
    <xsl:variable name="shift0">
      <xsl:choose>
        <xsl:when test="@antonymic">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="shift">
      <xsl:choose>
        <xsl:when test="($k=&quot;V&quot;) and (@kind=&quot;R&quot;)">
          <xsl:value-of select="2 + $shift0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$shift0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="plink">
      <xsl:choose>
        <xsl:when test="@redefnr&gt;0">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vis">
      <xsl:call-template name="mk_vis_list">
        <xsl:with-param name="els" select="Visible/Int"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="cons">
      <xsl:with-param name="h" select="@formatnr"/>
      <xsl:with-param name="t">
        <xsl:call-template name="cons">
          <xsl:with-param name="h" select="$shift"/>
          <xsl:with-param name="t">
            <xsl:call-template name="cons">
              <xsl:with-param name="h" select="$plink"/>
              <xsl:with-param name="t" select="$vis"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- this is a small hack to minimize chasing patterns -->
  <!-- returns list [formatnr, antonymic or expandable (+2 if attrpred), -->
  <!-- redefinition | visiblelist] -->
  <xsl:template name="patt_info">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="pid"/>
    <xsl:variable name="k1">
      <xsl:choose>
        <xsl:when test="$k=&quot;L&quot;">
          <xsl:text>G</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$k"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="typ" select="($k1 = &quot;G&quot;) or ($k1=&quot;M&quot;)"/>
    <xsl:variable name="pkey" select="concat(&apos;P_&apos;,$k1)"/>
    <xsl:choose>
      <xsl:when test="$pid&gt;0">
        <xsl:variable name="doc">
          <xsl:choose>
            <xsl:when test="($typ and key(&apos;EXP&apos;,$pid)) 
		     or (key($pkey,$nr)[$pid=@relnr])">
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$patts"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($doc,/)">
          <xsl:choose>
            <xsl:when test="$typ and key(&apos;EXP&apos;,$pid)">
              <xsl:for-each select="key(&apos;EXP&apos;,$pid)">
                <xsl:variable name="vis">
                  <xsl:call-template name="mk_vis_list">
                    <xsl:with-param name="els" select="Visible/Int"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="cons">
                  <xsl:with-param name="h" select="@formatnr"/>
                  <xsl:with-param name="t">
                    <xsl:call-template name="cons">
                      <xsl:with-param name="h">
                        <xsl:text>1</xsl:text>
                      </xsl:with-param>
                      <xsl:with-param name="t">
                        <xsl:call-template name="cons">
                          <xsl:with-param name="h">
                            <xsl:text>0</xsl:text>
                          </xsl:with-param>
                          <xsl:with-param name="t" select="$vis"/>
                        </xsl:call-template>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="key($pkey,$nr)[$pid=@relnr]">
                  <xsl:for-each select="key($pkey,$nr)[$pid=@relnr]">
                    <xsl:call-template name="encode_std_pattern">
                      <xsl:with-param name="k" select="$k"/>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>failedpid:</xsl:text>
                  <xsl:value-of select="$k1"/>
                  <xsl:text>:</xsl:text>
                  <xsl:value-of select="$nr"/>
                  <xsl:text>:</xsl:text>
                  <xsl:value-of select="$pid"/>
                  <xsl:text>:</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="doc">
          <xsl:choose>
            <xsl:when test="key($pkey,$nr)">
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$patts"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($doc,/)">
          <xsl:for-each select="key($pkey,$nr)[position()=1]">
            <xsl:call-template name="encode_std_pattern">
              <xsl:with-param name="k" select="$k"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- the string length #ls does not change; -->
  <!-- test if the #n-th position in #pl from back is underscore, -->
  <!-- if so, cut it and what follows it, -->
  <!-- otherwise try with n+1 -->
  <!-- called externally with #n=1; -->
  <!-- $n<10 is probably needed to guard the recursion - limits us -->
  <!-- to nine digit numbers of previous blocks - seems safe now -->
  <xsl:template name="get_parent_level">
    <xsl:param name="pl"/>
    <xsl:param name="ls"/>
    <xsl:param name="n"/>
    <xsl:variable name="p">
      <xsl:value-of select="$ls - $n"/>
    </xsl:variable>
    <xsl:variable name="p1">
      <xsl:value-of select="$ls - ($n + 1)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring($pl, $p, 1) = &apos;_&apos;">
        <xsl:value-of select="substring($pl, 1, $p1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$n &lt; 10">
          <xsl:call-template name="get_parent_level">
            <xsl:with-param name="pl" select="$pl"/>
            <xsl:with-param name="ls" select="$ls"/>
            <xsl:with-param name="n" select="$n+1"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add_hs_attrs">
    <xsl:attribute name="class">
      <xsl:text>txt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="onclick">
      <xsl:text>hs(this)</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:text>javascript:()</xsl:text>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="add_hs2_attrs">
    <xsl:attribute name="class">
      <xsl:text>txt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="onclick">
      <xsl:text>hs2(this)</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:text>javascript:()</xsl:text>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="add_hsNdiv_attrs">
    <xsl:attribute name="class">
      <xsl:text>txt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="onclick">
      <xsl:text>hsNdiv(this)</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:text>javascript:()</xsl:text>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="add_ajax_attrs">
    <xsl:param name="u"/>
    <xsl:attribute name="class">
      <xsl:text>txt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="onclick">
      <xsl:value-of select="concat(&quot;makeRequest(this,&apos;&quot;,$u,&quot;&apos;)&quot;)"/>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:text>javascript:()</xsl:text>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
