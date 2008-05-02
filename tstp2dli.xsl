<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <!-- $Revision: 1.3 $ -->
  <!--  -->
  <!-- File: mizpl.xsltxt - stylesheet translating TSTP XML solutions to MML Query DLI syntax -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- TSTP XML solutions to MML Query DLI syntax -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL tstp2dli.xsltxt >tstp2dli.xsl -->
  <xsl:strip-space elements="*"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>
  <!-- directory with articles in html; we assume it is one level up -->
  <!-- #baseurl= { "http://lipa.ms.mff.cuni.cz/~urban/xmlmml/html.930/"; } -->
  <xsl:param name="baseurl">
    <xsl:text>../</xsl:text>
  </xsl:param>
  <!-- name of article from which this by-explanation comes; -->
  <!-- needs to be passed as a parameter!! -->
  <xsl:param name="anamelc">
    <xsl:text>current_article</xsl:text>
  </xsl:param>

  <xsl:template name="lc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $ucletters, $lcletters)"/>
  </xsl:template>

  <xsl:template name="uc">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, $lcletters, $ucletters)"/>
  </xsl:template>

  <!-- MML Query needs numbers for proper display of indeces, -->
  <!-- hence this poor-man's numberization of proof-levels -->
  <xsl:template name="usto0">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s, &quot;_&quot;, &quot;0&quot;)"/>
  </xsl:template>

  <xsl:template match="tstp">
    <xsl:text>:: &lt;h3&gt;&lt;center&gt;&lt;a href=&quot;http://mmlquery.mizar.org&quot;&gt;MML Query&lt;/a&gt; rendering of ATP proof steps&lt;/center&gt;&lt;/h3&gt;&lt;br/&gt;
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="formula">
    <xsl:text>:: </xsl:text>
    <xsl:text>&lt;a name=&quot;</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&quot;/&gt; </xsl:text>
    <xsl:choose>
      <xsl:when test="source/non-logical-data[@name=&apos;file&apos;]">
        <xsl:value-of select="@status"/>
        <xsl:text>: </xsl:text>
        <xsl:for-each select="source/non-logical-data[@name=&apos;file&apos;]/*[2]">
          <xsl:call-template name="get_mizar_url">
            <xsl:with-param name="nm" select="@name"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="source/non-logical-data[@name=&apos;inference&apos;]">
          <xsl:text>inference: </xsl:text>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lt;br/&gt;
</xsl:text>
    <xsl:text>A:step </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>=</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="quantifier/variable">
    <xsl:text>$for(</xsl:text>
    <xsl:call-template name="pvar">
      <xsl:with-param name="nm" select="@name"/>
    </xsl:call-template>
    <xsl:text>,$type(HIDDEN:mode 1),</xsl:text>
  </xsl:template>

  <xsl:template match="variable">
    <xsl:call-template name="pvar">
      <xsl:with-param name="nm" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="quantifier">
    <xsl:choose>
      <xsl:when test="@type=&apos;existential&apos;">
        <xsl:text>$not(</xsl:text>
        <xsl:apply-templates select="variable"/>
        <xsl:text>$not(</xsl:text>
        <xsl:apply-templates select="*[position() = last()]"/>
        <xsl:text>))</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="variable">
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="negation|">
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="function|predicate">
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:variable name="tc">
      <xsl:call-template name="transl_constr">
        <xsl:with-param name="nm" select="@name"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($tc, &quot;:attr&quot;) or contains($tc, &quot;:mode&quot;)  or contains($tc, &quot;:struct&quot;)">
        <xsl:text>$is(</xsl:text>
        <xsl:apply-templates select="*[1]"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$tc"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*[position()&gt;1]"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$tc"/>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="conjunction">
    <xsl:text>$and(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="disjunction">
    <xsl:text>$not($and(</xsl:text>
    <xsl:call-template name="notlist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>))</xsl:text>
  </xsl:template>

  <xsl:template match="implication">
    <xsl:text>$not($and(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)))</xsl:text>
  </xsl:template>

  <xsl:template match="equivalence">
    <xsl:text>$and(</xsl:text>
    <xsl:text>$not($and(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)))</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>$not($and(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>,</xsl:text>
    <xsl:text>$not(</xsl:text>
    <xsl:apply-templates select="*[1]"/>
    <xsl:text>)))</xsl:text>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;equal&apos;]">
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:call-template name="transl_constr">
      <xsl:with-param name="nm">
        <xsl:text>r1_hidden</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>(</xsl:text>
    <xsl:call-template name="ilist">
      <xsl:with-param name="separ">
        <xsl:text>,</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="elems" select="*"/>
    </xsl:call-template>
    <xsl:text>)</xsl:text>
    <xsl:if test="name(..)=&quot;quantifier&quot;">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;false&apos;]">
    <xsl:text>$not($verum)</xsl:text>
  </xsl:template>

  <xsl:template match="defined-predicate[@name=&apos;true&apos;]">
    <xsl:text>$verum</xsl:text>
  </xsl:template>

  <xsl:template match="non-logical-data">
    <!-- there can be embedded inferences -->
    <xsl:choose>
      <xsl:when test="@name=&apos;inference&apos;">
        <xsl:for-each select="*[1]">
          <xsl:value-of select="@name"/>
        </xsl:for-each>
        <xsl:text>(</xsl:text>
        <xsl:call-template name="ilist">
          <xsl:with-param name="separ">
            <xsl:text>,</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="elems" select="*[3]/*[not(@name=&apos;theory&apos;)]"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&lt;a href=&quot;#</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>&quot;&gt;</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>&lt;/a&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="transl_constr">
    <xsl:param name="nm"/>
    <xsl:variable name="pref" select="substring-before($nm,&quot;_&quot;)"/>
    <xsl:choose>
      <xsl:when test="$pref">
        <xsl:variable name="k" select="substring($pref,1,1)"/>
        <xsl:variable name="nr" select="substring($pref,2)"/>
        <xsl:variable name="art" select="substring-after($nm,&quot;_&quot;)"/>
        <!-- test if $nr is digit -->
        <xsl:choose>
          <xsl:when test="$nr &gt;= 0">
            <xsl:choose>
              <xsl:when test="$k=&quot;c&quot;">
                <xsl:variable name="lev" select="substring-before($art,&quot;__&quot;)"/>
                <xsl:text>$</xsl:text>
                <xsl:value-of select="$pref"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="usto0">
                  <xsl:with-param name="s" select="$lev"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="uc">
                  <xsl:with-param name="s" select="$art"/>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
                <xsl:call-template name="mkind">
                  <xsl:with-param name="kind" select="$k"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$nr"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <!-- test for skolem - esk3_4, epred1_2 -->
            <xsl:variable name="esk" select="substring($pref,1,3)"/>
            <xsl:choose>
              <xsl:when test="$esk=&quot;esk&quot; or $esk=&quot;epr&quot;">
                <xsl:text>$</xsl:text>
                <xsl:value-of select="$pref"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$art"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nm"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_mizar_url">
    <xsl:param name="nm"/>
    <xsl:variable name="pref" select="substring-before($nm,&quot;_&quot;)"/>
    <xsl:choose>
      <xsl:when test="$pref">
        <xsl:variable name="k" select="substring($pref,1,1)"/>
        <xsl:variable name="k2" select="substring($pref,2,1)"/>
        <xsl:variable name="nr">
          <xsl:choose>
            <xsl:when test="$k2&gt;0">
              <xsl:value-of select="substring($pref,2)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring($pref,3)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="art" select="substring-after($nm,&quot;_&quot;)"/>
        <xsl:choose>
          <xsl:when test="$k=&quot;t&quot;">
            <xsl:text>&lt;a href=&quot;</xsl:text>
            <xsl:value-of select="$baseurl"/>
            <xsl:value-of select="$art"/>
            <xsl:text>.html#T</xsl:text>
            <xsl:value-of select="$nr"/>
            <xsl:text>&quot;&gt;</xsl:text>
            <xsl:value-of select="$nm"/>
            <xsl:text>&lt;/a&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="$k=&quot;l&quot;">
            <xsl:text>&lt;a href=&quot;</xsl:text>
            <xsl:value-of select="$baseurl"/>
            <xsl:value-of select="$art"/>
            <xsl:text>.html#E</xsl:text>
            <xsl:value-of select="$nr"/>
            <xsl:text>&quot;&gt;</xsl:text>
            <xsl:value-of select="$nm"/>
            <xsl:text>&lt;/a&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="$k=&quot;e&quot;">
            <xsl:text>&lt;a href=&quot;</xsl:text>
            <xsl:value-of select="$baseurl"/>
            <xsl:value-of select="$anamelc"/>
            <xsl:text>.html#E</xsl:text>
            <xsl:value-of select="$nr"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="$art"/>
            <xsl:text>&quot;&gt;</xsl:text>
            <xsl:value-of select="$nm"/>
            <xsl:text>&lt;/a&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="($k=&quot;d&quot;) and ($k2&gt;0)">
            <xsl:text>&lt;a href=&quot;</xsl:text>
            <xsl:value-of select="$baseurl"/>
            <xsl:value-of select="$art"/>
            <xsl:text>.html#D</xsl:text>
            <xsl:value-of select="$nr"/>
            <xsl:text>&quot;&gt;</xsl:text>
            <xsl:value-of select="$nm"/>
            <xsl:text>&lt;/a&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="($k2=&quot;c&quot;) and (($k=&quot;f&quot;) or ($k=&quot;c&quot;) or ($k=&quot;r&quot;))">
            <xsl:text>&lt;a href=&quot;</xsl:text>
            <xsl:value-of select="$baseurl"/>
            <xsl:value-of select="$art"/>
            <xsl:text>.html#</xsl:text>
            <xsl:call-template name="uc">
              <xsl:with-param name="s" select="$pref"/>
            </xsl:call-template>
            <xsl:text>&quot;&gt;</xsl:text>
            <xsl:value-of select="$nm"/>
            <xsl:text>&lt;/a&gt;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nm"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pvar">
    <xsl:param name="nm"/>
    <xsl:variable name="l" select="substring($nm,1,1)"/>
    <xsl:variable name="nr" select="substring($nm,2)"/>
    <!-- test if $nr is digit -->
    <xsl:choose>
      <xsl:when test="$nr &gt;= 0">
        <xsl:text>$</xsl:text>
        <xsl:value-of select="$l"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$nr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ilist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="notlist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:text>$not(</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>)</xsl:text>
      <xsl:if test="not(position()=last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="mkind">
    <xsl:param name="kind"/>
    <xsl:choose>
      <xsl:when test="$kind = &apos;m&apos;">
        <xsl:text>mode</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;v&apos;">
        <xsl:text>attr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;r&apos;">
        <xsl:text>pred</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;k&apos;">
        <xsl:text>func</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;g&apos;">
        <xsl:text>aggr</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;l&apos;">
        <xsl:text>struct</xsl:text>
      </xsl:when>
      <xsl:when test="$kind = &apos;u&apos;">
        <xsl:text>sel</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
