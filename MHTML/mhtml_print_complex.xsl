<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_utils.xsl"/>

  <!-- $Revision: 1.14 $ -->
  <!--  -->
  <!-- File: print_complex.xsltxt - html-ization of Mizar XML, more complex printing stuff -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- ##TODO: try some unification of mkref and absref -->
  <!--  -->
  <!-- theorem, definition and scheme references -->
  <!-- add the reference's href, $c tells if it is from current article -->
  <!-- $nm passes the explicit text to be displayed -->
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
    <xsl:element name="a">
      <xsl:attribute name="class">
        <xsl:text>ref</xsl:text>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="($linking = &apos;q&apos;) or (($linking = &apos;m&apos;) and not($c))">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($mmlq,$aid,&quot;:&quot;,$mk,&quot;.&quot;,$nr)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="($c = 1) and (($linking = &apos;m&apos;) or ($linking = &apos;l&apos;))">
                <xsl:value-of select="concat(&quot;#&quot;,$k, $nr)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($mizhtml,$alc, &quot;.&quot;,$ext, &quot;#&quot;,$k, $nr)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="$c = &quot;1&quot;">
            <xsl:attribute name="target">
              <xsl:text>_self</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$titles=&quot;1&quot;">
        <xsl:attribute name="title">
          <xsl:value-of select="concat($aid,&quot;:&quot;,$mk,&quot;.&quot;,$nr)"/>
        </xsl:attribute>
      </xsl:if>
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
    </xsl:element>
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
      <xsl:element name="a">
        <xsl:choose>
          <xsl:when test="($linking = &apos;q&apos;) or (($linking = &apos;m&apos;) and not($c = &quot;1&quot;))">
            <xsl:attribute name="href">
              <xsl:value-of select="concat($mmlq,@aid,&quot;:&quot;,$mk,&quot;.&quot;,@nr)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="($c = 1) and (($linking = &apos;m&apos;) or ($linking = &apos;l&apos;))">
                  <xsl:value-of select="concat(&quot;#&quot;, $n1, @kind, @nr)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($mizhtml,$alc, &quot;.&quot;,$ext, &quot;#&quot;, $n1, @kind, @nr)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <!-- this is probably needed if $mml = 1 -->
            <xsl:if test="($c = &quot;1&quot;) and not($linking = &quot;s&quot;)">
              <xsl:attribute name="target">
                <xsl:text>_self</xsl:text>
              </xsl:attribute>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$titles=&quot;1&quot;">
          <xsl:variable name="t1">
            <xsl:choose>
              <xsl:when test="$pid &gt; 0">
                <xsl:value-of select="@kind"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$mk"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="title">
            <xsl:value-of select="concat(@aid, &quot;:&quot;, $n1, $t1, &quot;.&quot;, @nr)"/>
          </xsl:attribute>
        </xsl:if>
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
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <!-- look up and link the constructor/pattern with kind #k and #nr; -->
  <!-- #sym is optionally forces the given Mizar symbol -->
  <!-- #pid links to  patterns instead of constructors -->
  <!-- note that we can be inside a Notation document here already (see pp), -->
  <!-- so the $doc = "" test does not have to mean that we are inside -->
  <!-- the article (could be probably fixed in pp, don't know about expnadable modes though) -->
  <xsl:template name="abs">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="sym"/>
    <xsl:param name="pid"/>
    <xsl:choose>
      <xsl:when test="$pid&gt;0">
        <xsl:variable name="k1" select="concat(&apos;P_&apos;,$k)"/>
        <xsl:variable name="doc">
          <xsl:choose>
            <xsl:when test="key($k1,$nr)[$pid=@relnr]">
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$patts"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($doc,/)">
          <xsl:variable name="c1">
            <xsl:choose>
              <xsl:when test="(name(/*) = &quot;Article&quot;) and ($mml = &quot;0&quot;)">
                <xsl:text>1</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>0</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="absref">
            <xsl:with-param name="elems" select="key($k1,$nr)[$pid=@relnr]"/>
            <xsl:with-param name="c" select="$c1"/>
            <xsl:with-param name="sym" select="$sym"/>
            <xsl:with-param name="pid" select="$pid"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="doc">
          <xsl:choose>
            <xsl:when test="key($k,$nr)">
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$constrs"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($doc,/)">
          <xsl:variable name="c1">
            <xsl:choose>
              <xsl:when test="(name(/*) = &quot;Article&quot;) and ($mml = &quot;0&quot;)">
                <xsl:text>1</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>0</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="absref">
            <xsl:with-param name="elems" select="key($k,$nr)"/>
            <xsl:with-param name="c" select="$c1"/>
            <xsl:with-param name="sym" select="$sym"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- pretty printer - gets arguments, visibility info from pattern, -->
  <!-- format telling arities, the linked symbol and optionally right bracket -->
  <!-- parenth hints to put the whole expression in parentheses, but this -->
  <!-- is overrriden if the expression uses functor brackets -->
  <!-- #loci tells to print loci instead of arguments -->
  <!-- #i is the bound var nbr -->
  <xsl:template name="pp">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="args"/>
    <xsl:param name="parenth"/>
    <xsl:param name="pid"/>
    <xsl:param name="loci"/>
    <xsl:param name="i"/>
    <xsl:variable name="pkey" select="concat(&apos;P_&apos;,$k)"/>
    <!-- pattern number given -->
    <xsl:choose>
      <xsl:when test="$pid&gt;0">
        <xsl:variable name="doc">
          <xsl:choose>
            <xsl:when test="key($pkey,$nr)[$pid=@relnr]">
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$patts"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($doc,/)">
          <xsl:choose>
            <xsl:when test="key($pkey,$nr)[$pid=@relnr]">
              <xsl:for-each select="key($pkey,$nr)[$pid=@relnr]">
                <xsl:variable name="npid">
                  <xsl:if test="@redefnr&gt;0">
                    <xsl:value-of select="$pid"/>
                  </xsl:if>
                </xsl:variable>
                <!-- $vis = { if [$k = "V"] { `Visible/Int[position() < last()]`; } else { `Visible/Int`; } } -->
                <xsl:choose>
                  <xsl:when test="$k = &quot;V&quot;">
                    <xsl:call-template name="pp1">
                      <xsl:with-param name="k" select="$k"/>
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="args" select="$args"/>
                      <xsl:with-param name="vis" select="Visible/Int[position() &lt; last()]"/>
                      <xsl:with-param name="fnr" select="@formatnr"/>
                      <xsl:with-param name="parenth" select="$parenth"/>
                      <xsl:with-param name="loci" select="$loci"/>
                      <xsl:with-param name="pid" select="$npid"/>
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="pp1">
                      <xsl:with-param name="k" select="$k"/>
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="args" select="$args"/>
                      <xsl:with-param name="vis" select="Visible/Int"/>
                      <xsl:with-param name="fnr" select="@formatnr"/>
                      <xsl:with-param name="parenth" select="$parenth"/>
                      <xsl:with-param name="loci" select="$loci"/>
                      <xsl:with-param name="pid" select="$npid"/>
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <!-- failure, print in absolute notation -->
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
              </xsl:call-template>
              <xsl:text>(</xsl:text>
              <xsl:call-template name="list">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="$args"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <!-- pattern number not given - take first suitable -->
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
          <xsl:choose>
            <xsl:when test="key($pkey,$nr)">
              <xsl:for-each select="key($pkey,$nr)[position()=1]">
                <xsl:variable name="npid">
                  <xsl:if test="@redefnr&gt;0">
                    <xsl:value-of select="@relnr"/>
                  </xsl:if>
                </xsl:variable>
                <!-- $vis = { if [$k = "V"] { `Visible/Int[position() < last()]`; } else { `Visible/Int`; } } -->
                <xsl:choose>
                  <xsl:when test="$k = &quot;V&quot;">
                    <xsl:call-template name="pp1">
                      <xsl:with-param name="k" select="$k"/>
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="args" select="$args"/>
                      <xsl:with-param name="vis" select="Visible/Int[position() &lt; last()]"/>
                      <xsl:with-param name="fnr" select="@formatnr"/>
                      <xsl:with-param name="parenth" select="$parenth"/>
                      <xsl:with-param name="loci" select="$loci"/>
                      <xsl:with-param name="pid" select="$npid"/>
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="pp1">
                      <xsl:with-param name="k" select="$k"/>
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="args" select="$args"/>
                      <xsl:with-param name="vis" select="Visible/Int"/>
                      <xsl:with-param name="fnr" select="@formatnr"/>
                      <xsl:with-param name="parenth" select="$parenth"/>
                      <xsl:with-param name="loci" select="$loci"/>
                      <xsl:with-param name="pid" select="$npid"/>
                      <xsl:with-param name="i" select="$i"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <!-- failure, print in absolute notation -->
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
              </xsl:call-template>
              <xsl:text>(</xsl:text>
              <xsl:call-template name="list">
                <xsl:with-param name="separ">
                  <xsl:text>,</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="elems" select="$args"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- it is legal to pass only #loci instead of #args here -->
  <!-- #pid is passed to abs, causes linking to patterns -->
  <!-- #i is the bound var nbr -->
  <xsl:template name="pp1">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="args"/>
    <xsl:param name="vis"/>
    <xsl:param name="fnr"/>
    <xsl:param name="parenth"/>
    <xsl:param name="loci"/>
    <xsl:param name="pid"/>
    <xsl:param name="i"/>
    <xsl:variable name="la">
      <xsl:choose>
        <xsl:when test="($k=&apos;M&apos;) or ($k=&apos;G&apos;) or ($k=&apos;L&apos;)">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="document($formats,/)">
            <xsl:for-each select="key(&apos;F&apos;,$fnr)">
              <xsl:choose>
                <xsl:when test="@kind=&quot;V&quot;">
                  <xsl:value-of select="@argnr - 1"/>
                </xsl:when>
                <xsl:when test="@leftargnr">
                  <xsl:value-of select="@leftargnr"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- try if right bracket - returns '' if not -->
    <xsl:variable name="rsym">
      <xsl:if test="($k=&apos;K&apos;) and ($la=&apos;0&apos;)">
        <xsl:call-template name="abs1">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="fnr" select="$fnr"/>
          <xsl:with-param name="r">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="np">
      <xsl:choose>
        <xsl:when test="not($vis) or ($k=&apos;G&apos;)">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$parenth&gt;0">
              <xsl:value-of select="$parenth"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="not($rsym=&apos;&apos;)">
                  <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="paren_color" select="$np mod $pcolors_nr"/>
    <!-- print spanned paranthesis or left bracket -->
    <xsl:choose>
      <xsl:when test="($parenspans = 1) and ($np &gt; 0)">
        <xsl:element name="span">
          <xsl:attribute name="class">
            <xsl:value-of select="concat(&quot;p&quot;,$paren_color)"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>(</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym">
                  <xsl:call-template name="abs1">
                    <xsl:with-param name="k" select="$k"/>
                    <xsl:with-param name="nr" select="$nr"/>
                    <xsl:with-param name="fnr" select="$fnr"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:element name="span">
            <xsl:attribute name="class">
              <xsl:text>default</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="pp2">
              <xsl:with-param name="k" select="$k"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="i" select="$i"/>
              <xsl:with-param name="vis" select="$vis"/>
              <xsl:with-param name="la" select="$la"/>
              <xsl:with-param name="loci" select="$loci"/>
              <xsl:with-param name="args" select="$args"/>
              <xsl:with-param name="np" select="$np"/>
              <xsl:with-param name="rsym" select="$rsym"/>
              <xsl:with-param name="parenth" select="$parenth"/>
              <xsl:with-param name="fnr" select="$fnr"/>
              <xsl:with-param name="pid" select="$pid"/>
            </xsl:call-template>
          </xsl:element>
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym" select="$rsym"/>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="($np &gt; 0)">
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>(</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym">
                  <xsl:call-template name="abs1">
                    <xsl:with-param name="k" select="$k"/>
                    <xsl:with-param name="nr" select="$nr"/>
                    <xsl:with-param name="fnr" select="$fnr"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="pp2">
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="i" select="$i"/>
          <xsl:with-param name="vis" select="$vis"/>
          <xsl:with-param name="la" select="$la"/>
          <xsl:with-param name="loci" select="$loci"/>
          <xsl:with-param name="args" select="$args"/>
          <xsl:with-param name="np" select="$np"/>
          <xsl:with-param name="rsym" select="$rsym"/>
          <xsl:with-param name="parenth" select="$parenth"/>
          <xsl:with-param name="fnr" select="$fnr"/>
          <xsl:with-param name="pid" select="$pid"/>
        </xsl:call-template>
        <xsl:if test="($np &gt; 0)">
          <xsl:choose>
            <xsl:when test="$rsym=&apos;&apos;">
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="abs">
                <xsl:with-param name="k" select="$k"/>
                <xsl:with-param name="nr" select="$nr"/>
                <xsl:with-param name="sym" select="$rsym"/>
                <xsl:with-param name="pid" select="$pid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pp2">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="i"/>
    <xsl:param name="vis"/>
    <xsl:param name="la"/>
    <xsl:param name="loci"/>
    <xsl:param name="args"/>
    <xsl:param name="np"/>
    <xsl:param name="rsym"/>
    <xsl:param name="parenth"/>
    <xsl:param name="fnr"/>
    <xsl:param name="pid"/>
    <xsl:variable name="visnr" select="count($vis)"/>
    <xsl:variable name="dofuncbrackets">
      <xsl:choose>
        <xsl:when test="($rsym=&apos;&apos;) and ($mizar_brackets &gt; 0) and ($k = &quot;K&quot;)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>0</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="($dofuncbrackets&gt;0) and ($la&gt;1)">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <!-- print left args -->
    <xsl:for-each select="$vis">
      <xsl:if test="position() &lt;= $la">
        <xsl:variable name="x" select="@x"/>
        <xsl:choose>
          <xsl:when test="$loci&gt;0">
            <xsl:choose>
              <xsl:when test="$loci=&quot;2&quot;">
                <xsl:call-template name="ppconst">
                  <xsl:with-param name="nr" select="$x"/>
                  <xsl:with-param name="vid" select="$args[position()=$x]/@vid"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="$x"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$args[position() = $x]">
              <xsl:with-param name="p" select="$np"/>
              <xsl:with-param name="i" select="$i"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() &lt; $la">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="($dofuncbrackets&gt;0) and ($la&gt;1)">
      <xsl:text>)</xsl:text>
    </xsl:if>
    <!-- print symbol -->
    <xsl:if test="$rsym=&apos;&apos;">
      <xsl:if test="not($parenth&gt;0) or ($la&gt;0)">
        <!-- do not print space if either: -->
        <!-- opening parenth was printed and no left args exist -->
        <!-- or -->
        <!-- $la>1 and we do func brackets (that means a closing bracket of args was printed) -->
        <xsl:if test="not(($k=&apos;K&apos;) and ($funcs_no_spaces&gt;0) and ($parenth&gt;0) and ($la=0)) 
      	  and not(($dofuncbrackets&gt;0) and ($la&gt;1))">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:call-template name="abs">
        <xsl:with-param name="k" select="$k"/>
        <xsl:with-param name="nr" select="$nr"/>
        <xsl:with-param name="sym">
          <xsl:call-template name="abs1">
            <xsl:with-param name="k" select="$k"/>
            <xsl:with-param name="nr" select="$nr"/>
            <xsl:with-param name="fnr" select="$fnr"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="pid" select="$pid"/>
      </xsl:call-template>
      <xsl:if test="$k=&apos;G&apos;">
        <xsl:text>(#</xsl:text>
      </xsl:if>
      <!-- do not print space if either: -->
      <!-- closing parenth will be printed and no right args exist -->
      <!-- or -->
      <!-- $ra>1 and we do func brackets (that means an opening bracket of args will be printed) -->
      <xsl:if test="not(($k=&apos;K&apos;) and ($funcs_no_spaces&gt;0) and ($parenth&gt;0) and (($visnr - $la)=0))) 
          and not(($dofuncbrackets&gt;0) and (($visnr - $la)&gt;1))">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="($dofuncbrackets&gt;0) and (($visnr - $la)&gt;1)">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <!-- print right args preceded by "of" for types -->
    <xsl:for-each select="$vis">
      <xsl:if test="(position() = 1) and (($k=&apos;M&apos;) or ($k=&apos;L&apos;))">
        <xsl:text>of </xsl:text>
      </xsl:if>
      <xsl:if test="position() &gt; $la">
        <xsl:variable name="x" select="@x"/>
        <xsl:choose>
          <xsl:when test="$loci&gt;0">
            <xsl:choose>
              <xsl:when test="$loci=&quot;2&quot;">
                <xsl:call-template name="ppconst">
                  <xsl:with-param name="nr" select="$x"/>
                  <xsl:with-param name="vid" select="$args[position()=$x]/@vid"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="ploci">
                  <xsl:with-param name="nr" select="$x"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$args[position()  = $x]">
              <xsl:with-param name="p" select="$np"/>
              <xsl:with-param name="i" select="$i"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() &lt; last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="$k=&apos;G&apos;">
      <xsl:text> #)</xsl:text>
    </xsl:if>
    <xsl:if test="($dofuncbrackets&gt;0) and (($visnr - $la)&gt;1)">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- theorem, definition and scheme references -->
  <xsl:template name="getref">
    <xsl:param name="k"/>
    <xsl:param name="anr"/>
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$anr&gt;0">
        <xsl:variable name="refdoc">
          <xsl:choose>
            <xsl:when test="$k=&quot;S&quot;">
              <xsl:value-of select="$schms"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$thms"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="document($refdoc,/)">
          <xsl:for-each select="key($k,concat($anr,&apos;:&apos;,$nr))[position()=1]">
            <xsl:call-template name="mkref">
              <xsl:with-param name="aid" select="@aid"/>
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="k" select="$k"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mkref">
          <xsl:with-param name="aid" select="$aname"/>
          <xsl:with-param name="nr" select="$nr"/>
          <xsl:with-param name="k" select="$k"/>
          <xsl:with-param name="c">
            <xsl:text>1</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- find the constant with #nr on level #pl or higher, -->
  <!-- and pretty print it -->
  <!-- now assumes that proof levels are available, which is only through -->
  <!-- addabsrefs preprocessing -->
  <xsl:template name="absconst">
    <xsl:param name="nr"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="key(&quot;C&quot;,$pl)[@nr = $nr]">
        <xsl:for-each select="key(&quot;C&quot;,$pl)[@nr = $nr]">
          <xsl:call-template name="ppconst">
            <xsl:with-param name="nr" select="$nr"/>
            <xsl:with-param name="vid" select="Typ[position() = 1]/@vid"/>
          </xsl:call-template>
        </xsl:for-each>
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
                <xsl:variable name="n2" select="@nr"/>
                <xsl:choose>
                  <xsl:when test="$lastnr &gt;= $nr">
                    <xsl:call-template name="ppconst">
                      <xsl:with-param name="nr" select="$nr"/>
                      <xsl:with-param name="vid" select="Typ[position() = ($nr - $n2 + 1)]/@vid"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$dbgmsg"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="ls" select="string-length($pl)"/>
            <xsl:choose>
              <xsl:when test="$ls&gt;0">
                <xsl:variable name="pl1">
                  <xsl:call-template name="get_parent_level">
                    <xsl:with-param name="pl" select="$pl"/>
                    <xsl:with-param name="ls" select="$ls"/>
                    <xsl:with-param name="n">
                      <xsl:text>1</xsl:text>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="absconst">
                  <xsl:with-param name="nr" select="$nr"/>
                  <xsl:with-param name="pl" select="$pl1"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$dbgmsg"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
