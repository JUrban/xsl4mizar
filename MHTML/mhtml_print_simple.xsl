<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:include href="mhtml_params.xsl"/>
  <xsl:include href="mhtml_keys.xsl"/>

  <!-- $Revision: 1.7 $ -->
  <!--  -->
  <!-- File: print_simple.xsltxt - html-ization of Mizar XML, simple printing funcs -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- pretty print variables and labels -->
  <!-- ##TODO: link variables and consts to their introduction? -->
  <!-- private - look up the name of id -->
  <xsl:template name="get_vid_name">
    <xsl:param name="vid"/>
    <xsl:for-each select="document($ids, /)">
      <xsl:for-each select="key(&apos;D_I&apos;, $vid)">
        <xsl:value-of select="@name"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="pqvar">
    <xsl:param name="nr"/>
    <xsl:param name="vid"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($vid &gt; 0)">
        <xsl:variable name="nm">
          <xsl:call-template name="get_vid_name">
            <xsl:with-param name="vid" select="$vid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$colored = &quot;1&quot;">
            <xsl:element name="font">
              <xsl:attribute name="color">
                <xsl:value-of select="$varcolor"/>
              </xsl:attribute>
              <xsl:if test="$titles=&quot;1&quot;">
                <xsl:attribute name="title">
                  <xsl:value-of select="concat(&quot;b&quot;,$nr)"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$nm"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nm"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pvar">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pvar">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$varcolor"/>
          </xsl:attribute>
          <xsl:text>b</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>b</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pconst">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$constcolor"/>
          </xsl:attribute>
          <xsl:text>c</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>c</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #pl gives the optional proof level -->
  <xsl:template name="ppconst">
    <xsl:param name="nr"/>
    <xsl:param name="vid"/>
    <xsl:param name="pl"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($vid &gt; 0)">
        <xsl:variable name="ctarget">
          <xsl:choose>
            <xsl:when test="($const_links&gt;0) and  ($pl)">
              <xsl:text>c</xsl:text>
              <xsl:value-of select="$nr"/>
              <xsl:call-template name="addp">
                <xsl:with-param name="pl" select="$pl"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(&quot;c&quot;,$nr)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nm">
          <xsl:call-template name="get_vid_name">
            <xsl:with-param name="vid" select="$vid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="($const_links=2)">
            <xsl:element name="a">
              <xsl:attribute name="class">
                <xsl:text>txt</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="href">
                <xsl:value-of select="concat(&quot;#&quot;,$ctarget)"/>
              </xsl:attribute>
              <xsl:element name="font">
                <xsl:attribute name="color">
                  <xsl:value-of select="$constcolor"/>
                </xsl:attribute>
                <xsl:if test="$titles=&quot;1&quot;">
                  <xsl:attribute name="title">
                    <xsl:value-of select="$ctarget"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$nm"/>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$colored = &quot;1&quot;">
                <xsl:element name="font">
                  <xsl:attribute name="color">
                    <xsl:value-of select="$constcolor"/>
                  </xsl:attribute>
                  <xsl:if test="$titles=&quot;1&quot;">
                    <xsl:attribute name="title">
                      <xsl:value-of select="$ctarget"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$nm"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nm"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pploci">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="($print_identifiers &gt; 0) and ($proof_links&gt;0)">
        <xsl:variable name="pl">
          <xsl:call-template name="get_nearest_level">
            <xsl:with-param name="el" select=".."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="absconst">
          <xsl:with-param name="nr" select="@nr"/>
          <xsl:with-param name="pl" select="$pl"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="pconst">
          <xsl:with-param name="nr" select="@nr"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ploci">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$locicolor"/>
          </xsl:attribute>
          <xsl:text>a</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>a</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pschpvar">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$schpcolor"/>
          </xsl:attribute>
          <xsl:text>P</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>P</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pschfvar">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$schfcolor"/>
          </xsl:attribute>
          <xsl:text>F</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>F</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pppred">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$ppcolor"/>
          </xsl:attribute>
          <xsl:text>S</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>S</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ppfunc">
    <xsl:param name="nr"/>
    <xsl:choose>
      <xsl:when test="$colored=&quot;1&quot;">
        <xsl:element name="font">
          <xsl:attribute name="color">
            <xsl:value-of select="$pfcolor"/>
          </xsl:attribute>
          <xsl:text>H</xsl:text>
          <xsl:element name="sub">
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>H</xsl:text>
        <xsl:element name="sub">
          <xsl:value-of select="$nr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pplab">
    <xsl:param name="nr"/>
    <xsl:param name="vid"/>
    <xsl:param name="txt"/>
    <xsl:choose>
      <xsl:when test="($print_lab_identifiers &gt; 0) and ($vid &gt; 0)">
        <xsl:variable name="nm">
          <xsl:call-template name="get_vid_name">
            <xsl:with-param name="vid" select="$vid"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="i">
          <xsl:choose>
            <xsl:when test="$colored = &quot;1&quot;">
              <xsl:element name="font">
                <xsl:attribute name="color">
                  <xsl:value-of select="$labcolor"/>
                </xsl:attribute>
                <xsl:if test="$titles=&quot;1&quot;">
                  <xsl:attribute name="title">
                    <xsl:value-of select="concat(&quot;E&quot;,$nr)"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$nm"/>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$nm"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$txt">
            <xsl:call-template name="plab1">
              <xsl:with-param name="nr" select="$nr"/>
              <xsl:with-param name="txt" select="$txt"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="plab">
              <xsl:with-param name="nr" select="$nr"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="plab">
    <xsl:param name="nr"/>
    <xsl:element name="i">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$labcolor"/>
            </xsl:attribute>
            <xsl:text>E</xsl:text>
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>E</xsl:text>
          <xsl:value-of select="$nr"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="plab1">
    <xsl:param name="nr"/>
    <xsl:param name="txt"/>
    <xsl:element name="i">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$labcolor"/>
            </xsl:attribute>
            <xsl:value-of select="$txt"/>
            <xsl:value-of select="$nr"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$txt"/>
          <xsl:value-of select="$nr"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pkeyword">
    <xsl:param name="str"/>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>kw</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="$str"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pcomment0">
    <xsl:param name="str"/>
    <xsl:element name="i">
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$commentcolor"/>
            </xsl:attribute>
            <xsl:text>:: </xsl:text>
            <xsl:value-of select="$str"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>:: </xsl:text>
          <xsl:value-of select="$str"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="pcomment">
    <xsl:param name="str"/>
    <xsl:call-template name="pcomment0">
      <xsl:with-param name="str" select="$str"/>
    </xsl:call-template>
    <xsl:element name="br"/>
  </xsl:template>

  <!-- argument list -->
  <xsl:template name="arglist">
    <xsl:param name="separ"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:call-template name="ploci">
        <xsl:with-param name="nr" select="position()"/>
      </xsl:call-template>
      <xsl:if test="not(position() = last())">
        <xsl:value-of select="$separ"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- like jlist, but with loci -->
  <xsl:template name="alist">
    <xsl:param name="j"/>
    <xsl:param name="sep1"/>
    <xsl:param name="sep2"/>
    <xsl:param name="elems"/>
    <xsl:for-each select="$elems">
      <xsl:apply-templates select="."/>
      <xsl:if test="not(position() = last())">
        <xsl:value-of select="$sep1"/>
        <xsl:call-template name="ploci">
          <xsl:with-param name="nr" select="$j+position()"/>
        </xsl:call-template>
        <xsl:value-of select="$sep2"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
