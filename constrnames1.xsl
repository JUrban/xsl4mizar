<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet -->
  <!-- producing the pretty-printing names for constructor -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL constrnames1.xsltxt >constrnames1.xsl -->
  <!-- Than run e.g. this way: -->
  <!-- xsltproc constrnames1.xsl xboole_0.xml > xboole_0.nam -->
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>
  <!-- keys for fast constructor lookup -->
  <xsl:key name="M" match="Constructor[@kind=&apos;M&apos;]" use="@relnr"/>
  <xsl:key name="L" match="Constructor[@kind=&apos;L&apos;]" use="@relnr"/>
  <xsl:key name="V" match="Constructor[@kind=&apos;V&apos;]" use="@relnr"/>
  <xsl:key name="R" match="Constructor[@kind=&apos;R&apos;]" use="@relnr"/>
  <xsl:key name="K" match="Constructor[@kind=&apos;K&apos;]" use="@relnr"/>
  <xsl:key name="U" match="Constructor[@kind=&apos;U&apos;]" use="@relnr"/>
  <xsl:key name="G" match="Constructor[@kind=&apos;G&apos;]" use="@relnr"/>
  <xsl:key name="F" match="Format" use="@nr"/>
  <xsl:key name="D_G" match="Symbol[@kind=&apos;G&apos;]" use="@nr"/>
  <xsl:key name="D_K" match="Symbol[@kind=&apos;K&apos;]" use="@nr"/>
  <xsl:key name="D_J" match="Symbol[@kind=&apos;J&apos;]" use="@nr"/>
  <xsl:key name="D_L" match="Symbol[@kind=&apos;L&apos;]" use="@nr"/>
  <xsl:key name="D_M" match="Symbol[@kind=&apos;M&apos;]" use="@nr"/>
  <xsl:key name="D_O" match="Symbol[@kind=&apos;O&apos;]" use="@nr"/>
  <xsl:key name="D_R" match="Symbol[@kind=&apos;R&apos;]" use="@nr"/>
  <xsl:key name="D_U" match="Symbol[@kind=&apos;U&apos;]" use="@nr"/>
  <xsl:key name="D_V" match="Symbol[@kind=&apos;V&apos;]" use="@nr"/>
  <xsl:variable name="lcletters">
    <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
  </xsl:variable>
  <xsl:variable name="ucletters">
    <xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:text>
  </xsl:variable>
  <!-- name of current article (upper case) -->
  <xsl:param name="aname">
    <xsl:value-of select="string(/*/@aid)"/>
  </xsl:param>
  <!-- name of current article (lower case) -->
  <xsl:param name="anamelc">
    <xsl:value-of select="translate($aname, $ucletters, $lcletters)"/>
  </xsl:param>
  <!-- .frx file with all (both imported and article's) formats -->
  <xsl:param name="formats">
    <xsl:value-of select="concat($anamelc, &apos;.frx&apos;)"/>
  </xsl:param>
  <!-- .dcx file with vocabulary -->
  <xsl:param name="vocs">
    <xsl:value-of select="concat($anamelc, &apos;.dcx&apos;)"/>
  </xsl:param>

  <xsl:template match="/">
    <xsl:apply-templates select="//Pattern"/>
  </xsl:template>

  <xsl:template match="Pattern">
    <!-- avoids expandable modes -->
    <xsl:if test="(@constrnr&gt;0)">
      <!-- checks that the constructor is from this article -->
      <xsl:if test="key(@constrkind,@constrnr)">
        <!-- ignores other than first notation -->
        <xsl:variable name="k1" select="@constrkind"/>
        <xsl:variable name="nr1" select="@constrnr"/>
        <xsl:if test="not(preceding-sibling::Pattern[(@constrnr=$nr1) and (@constrkind=$k1)])">
          <xsl:for-each select="key(@constrkind,@constrnr)">
            <xsl:value-of select="translate(concat(@kind,@nr,&apos;_&apos;,@aid),$ucletters,$lcletters)"/>
          </xsl:for-each>
          <xsl:text> </xsl:text>
          <xsl:call-template name="abs1">
            <xsl:with-param name="k" select="@constrkind"/>
            <xsl:with-param name="nr" select="@constrnr"/>
            <xsl:with-param name="fnr1" select="@formatnr"/>
          </xsl:call-template>
          <xsl:text>
</xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- return first symbol corresponding to constructor; -->
  <!-- if nothing found, just concat #k and #nr; #r says to look for -->
  <!-- right bracket instead of left or fail if the format is not bracket -->
  <xsl:template name="abs1">
    <xsl:param name="k"/>
    <xsl:param name="nr"/>
    <xsl:param name="fnr1"/>
    <!-- DEBUG    "abs1:"; $k; ":"; $fnr; ":"; -->
    <xsl:for-each select="document($formats,/)">
      <xsl:choose>
        <xsl:when test="not(key(&apos;F&apos;,$fnr1))">
          <xsl:value-of select="concat($k,$nr,&quot;ERRORERROR&quot;)"/>
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
            <xsl:choose>
              <xsl:when test="($sk=&apos;K&apos;)">
                <xsl:value-of select="@argnr"/>
                <xsl:text>:circumfix </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="@leftargnr">
                    <xsl:value-of select="@leftargnr"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="@argnr -  @leftargnr"/>
                    <xsl:text> </xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="@argnr"/>
                    <xsl:text> </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="document($vocs,/)">
              <xsl:choose>
                <xsl:when test="key($dkey,$snr)">
                  <xsl:for-each select="key($dkey,$snr)">
                    <xsl:value-of select="@name"/>
                    <xsl:if test="($sk=&apos;K&apos;)">
                      <xsl:text> </xsl:text>
                      <xsl:for-each select="key(&apos;D_L&apos;,$rsnr)">
                        <xsl:value-of select="@name"/>
                      </xsl:for-each>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;M&apos;)">
                      <xsl:text>set</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;R&apos;)">
                      <xsl:text>=</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;1&apos;) and ($sk=&apos;K&apos;)">
                      <xsl:text>[ ]</xsl:text>
                    </xsl:when>
                    <xsl:when test="($snr=&apos;2&apos;) and ($sk=&apos;K&apos;)">
                      <xsl:text>{ }</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat($k,$nr,&quot;ERRORERROR&quot;)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
