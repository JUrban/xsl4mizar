<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" extension-element-prefixes="dc" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <!-- $Revision: 1.8 $ -->
  <!--  -->
  <!-- File: mhtml_main.xsltxt - html-ization of Mizar XML, main file -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- XSLTXT (https://xsltxt.dev.java.net/) stylesheet taking -->
  <!-- XML terms, formulas and types to less verbose format. -->
  <!-- To produce standard XSLT from this do e.g.: -->
  <!-- java -jar xsltxt.jar toXSL miz.xsltxt | sed -e 's/<!\-\- *\(<\/*xsl:document.*\) *\-\->/\1/g' >miz.xsl -->
  <!-- (the sed hack is there because xsl:document is not yet supported by xsltxtx) -->
  <!-- Then e.g.: xsltproc miz.xsl ordinal2.pre >ordinal2.pre1 -->
  <!-- TODO: number B vars in fraenkel - done since 1.72 -->
  <!-- handle F and H parenthesis as K parenthesis -->
  <!-- article numbering in Ref? -->
  <!-- absolute definiens numbers for thesisExpansions? - done -->
  <!-- do not display BlockThesis for Proof? - done, should but should be optional for Now -->
  <!-- add @nr to canceled -->
  <!-- Constructor should know its serial number! - needed in defs -->
  <!-- possibly also article? -->
  <!-- change globally 'G' to 'L' for types? -> then change the -->
  <!-- hacks here and in emacs.el -->
  <!-- display definiens? - done -->
  <!-- NOTES: constructor disambiguation is done using the absolute numbers -->
  <!-- (attribute 'nr' and 'aid' of the Constructor element. -->
  <!-- This info for Constructors not defined in the article is -->
  <!-- taken from the .atr file (see variable $constrs) -->
  <xsl:include href="mhtml_block_top.xsl"/>

  <!-- ##INCLUDE HERE -->
  <!-- Default -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$generate_items = &quot;1&quot;">
        <xsl:apply-templates select="/*/JustifiedTheorem|/*/DefTheorem|/*/SchemeBlock"/>
        <xsl:apply-templates select="//RCluster|//CCluster|//FCluster|//Definition|//IdentifyWithExp"/>
        <!-- top-level lemmas -->
        <xsl:for-each select="/*/Proposition">
          <xsl:document href="proofhtml/lemma/{$anamelc}.{@propnr}" format="html"> 
          <xsl:apply-templates select="."/>
          </xsl:document> 
          <xsl:variable name="bogus" select="1"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$body_only = &quot;0&quot;">
            <xsl:element name="html">
              <xsl:attribute name="prefix">
                <xsl:text>oo: http://omdoc.org/ontology# owl: http://www.w3.org/2002/07/owl#</xsl:text>
              </xsl:attribute>
              <!-- output the css defaults for div and p (for indenting) -->
              <xsl:element name="style">
                <xsl:attribute name="type">
                  <xsl:text>text/css</xsl:text>
                </xsl:attribute>
                <xsl:text>
div { padding: 0 0 0 0; margin: 0 0 0 0; } 
div.add { padding-left: 3mm; padding-bottom: 0mm;  margin: 0 0 0 0; } 
div.box { border-width:thin; border-color:blue; border-style:solid; }
p { margin: 0 0 0 0; } 
body {font-family: monospace; margin: 0px;}
a {text-decoration:none} a:hover { color: red; } 
a.ref { font-size:x-small; }
a.ref:link { color:green; } 
a.ref:hover { color: red; } 
a.txt:link { color:black; } 
a.txt:hover { color: red; } 
.wikiactions ul { background-color: DarkSeaGreen ; color:blue; margin: 0; padding: 6px; list-style-type: none; border-bottom: 1px solid #000; }
.wikiactions li { display: inline; padding: .2em .4em; }
.wikiactions a {text-decoration:underline;} 
span.kw {font-weight: bold; }
span.lab {font-style: italic; }
span.comment {font-style: italic; }
span.hide { display: none; }
span.p1:hover { color : inherit; background-color : #BAFFFF; } 
span.p2:hover { color : inherit; background-color : #FFCACA; }
span.p3:hover { color : inherit; background-color : #FFFFBA; }
span.p4:hover { color : inherit; background-color : #CACAFF; }
span.p5:hover { color : inherit; background-color : #CAFFCA; }
span.p0:hover { color : inherit; background-color : #FFBAFF; }
.default { background-color: white; color: black; } 
.default:hover { background-color: white; color: black; }
#tt { position:absolute; display:block; font-size: small; background: LightYellow; padding:2px 12px 3px 7px; margin-left:5px;}
:target { background: #5D9BF7; border: solid 1px #aaa;}
</xsl:text>
              </xsl:element>
              <xsl:element name="head">
                <xsl:element name="title">
                  <xsl:choose>
                    <xsl:when test="$mk_header &gt; 0">
                      <xsl:value-of select="$aname"/>
                      <xsl:text>: </xsl:text>
                      <xsl:for-each select="document($hdr,/)/Header/dc:title">
                        <xsl:value-of select="text()"/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$aname"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
                <xsl:element name="script">
                  <xsl:attribute name="type">
                    <xsl:text>text/javascript</xsl:text>
                  </xsl:attribute>
                  <xsl:text>
&lt;!-- 
function hs(obj)
{
// document.getElementById(&apos;myimage&apos;).nextSibling.style.display = &apos;block&apos;;
if (obj.nextSibling.style.display == &apos;inline&apos;)
 { obj.nextSibling.style.display = &apos;none&apos;; }
else { if (obj.nextSibling.style.display == &apos;none&apos;)
 { obj.nextSibling.style.display = &apos;inline&apos;; }
 else { obj.nextSibling.style.display = &apos;inline&apos;;  }}
return false;
}

function hs2(obj)
{
if (obj.nextSibling.style.display == &apos;block&apos;)
 { obj.nextSibling.style.display = &apos;none&apos;; }
else { if (obj.nextSibling.style.display == &apos;none&apos;)
 { obj.nextSibling.style.display = &apos;block&apos;; }
 else { obj.nextSibling.style.display = &apos;none&apos;;  }}
return false;
}
function hsNdiv(obj)
{
var ndiv = obj;
while (ndiv.nextSibling.nodeName != &apos;DIV&apos;) { ndiv = ndiv.nextSibling; }
return hs2(ndiv);
}

// remote request cache - for each url its http_request.responseText
var rrCache= {};
rrCache[0]=&apos;&apos;;

// explorer7 implements XMLHttpRequest in some strange way
// optional tooltip is passed to insertRequest
function makeRequest(obj,url,tooltip) 
{
    // if the result is cached, insert it now
    if (rrCache[url] != null)
    {
	insertRequest(obj,null,url,tooltip);
    }
    else
    {
        var http_request = false;
        if (window.XMLHttpRequest &amp;&amp; !(window.ActiveXObject)) { // Mozilla, Safari,...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
                http_request.overrideMimeType(&apos;text/xml&apos;);
            }
        } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject(&apos;Msxml2.XMLHTTP&apos;);
            } catch (e) {
                try {
                    http_request = new ActiveXObject(&apos;Microsoft.XMLHTTP&apos;);
                } catch (e) {}
            }
        }
        if (!http_request) {
            alert(&apos;Giving up :( Cannot create an XMLHTTP instance&apos;);
            return false;
        }
        http_request.onreadystatechange = function() { insertRequest(obj,http_request,url,tooltip); };
        http_request.open(&apos;GET&apos;, url, true);
        http_request.send(null);
    }
}
// commented the 200 state to have local requests too
// if tooltip nonnil, obj.innerHTML is changed, and the result is put in rrCache
function insertRequest(obj,http_request,url,tooltip) 
{
    var respText = null;
    if(http_request == null) // no request done, we are called with cached result
    {
	respText = rrCache[url];
    }
    else { if (http_request.readyState == 4) { 
	respText = http_request.responseText; 
    }}

    if (respText != null) 
    {
//            if (http_request.status == 200) {
	if(http_request != null) {rrCache[url] = respText;}
	if(tooltip != null)
	{
	    obj.innerHTML = respText;	    
	}
	else
	{
	    var ndiv = obj;
	    while (ndiv.nodeName != &apos;SPAN&apos;) { ndiv = ndiv.nextSibling; }
	    ndiv.innerHTML = respText;
	    obj.onclick = function(){ return hs2(obj) };
	}
    }
}

// simple tooltips
var tooltip=function(){
 var id = &apos;tt&apos;;
 var top = 3;
 var left = 3;
 var maxw = 500;
 var speed = 10;
 var timer = 2;
 var endalpha = 95;
 var alpha = 0;
 var tt,t,c,b,h;
 var ie = document.all ? true : false;
 return{
  show:function(how,v,w){
   if(tt == null){
    tt = document.createElement(&apos;div&apos;);
    tt.setAttribute(&apos;id&apos;,id);
    document.body.appendChild(tt);
    tt.style.opacity = 0;
    tt.style.filter = &apos;alpha(opacity=0)&apos;;
    document.onmousemove = this.pos;
   }

   tt.style.display = &apos;block&apos;;
   if(how == &apos;url&apos;)
   {
       if(rrCache[v]==null) { 
	   tt.innerHTML =&apos;&lt;div&gt;loading...&lt;/div&gt;&apos;; 
	   makeRequest(tt,v,1); 
       } else { 
	   tt.innerHTML = rrCache[v]; 
       }
   }
   else { if ((how == &apos;hs&apos;) || (how == &apos;hs2&apos;)) { tt.innerHTML = v.nextSibling.innerHTML; }
	  else { tt.innerHTML = &apos;&apos;; }
   }

   tt.style.width = w ? w + &apos;px&apos; : &apos;auto&apos;;
   if(!w &amp;&amp; ie){
    tt.style.width = tt.offsetWidth;
   }
  if(tt.offsetWidth &gt; maxw){tt.style.width = maxw + &apos;px&apos;}
  h = parseInt(tt.offsetHeight) + top;
  clearInterval(tt.timer);
  tt.timer = setInterval(function(){tooltip.fade(1)},timer);
  },
  pos:function(e){
   var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
   var l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
   tt.style.top = (u - h) + &apos;px&apos;;
   tt.style.left = (l + left) + &apos;px&apos;;
  },
  fade:function(d){
   var a = alpha;
   if((a != endalpha &amp;&amp; d == 1) || (a != 0 &amp;&amp; d == -1)){
    var i = speed;
   if(endalpha - a &lt; speed &amp;&amp; d == 1){
    i = endalpha - a;
   }else if(alpha &lt; speed &amp;&amp; d == -1){
     i = a;
   }
   alpha = a + (i * d);
   tt.style.opacity = alpha * .01;
   tt.style.filter = &apos;alpha(opacity=&apos; + alpha + &apos;)&apos;;
  }else{
    clearInterval(tt.timer);
     if(d == -1){tt.style.display = &apos;none&apos;}
  }
 },
 hide:function(){tt.style.display  = &apos;none&apos;;}
 };
}();

// End --&gt;
</xsl:text>
                </xsl:element>
                <xsl:if test="$idv&gt;0">
                  <xsl:element name="script">
                    <xsl:attribute name="type">
                      <xsl:text>text/javascript</xsl:text>
                    </xsl:attribute>
                    <xsl:text>
&lt;!--
var tstp_dump;
function openSoTSTP (dump) {
var tstp_url = &apos;http://www.cs.miami.edu/~tptp/cgi-bin/SystemOnTSTP&apos;;
var tstp_browser = window.open(tstp_url, &apos;_blank&apos;);
tstp_dump = dump;
}
function getTSTPDump () {
return tstp_dump;
}
// End --&gt;
</xsl:text>
                  </xsl:element>
                </xsl:if>
                <xsl:element name="base">
                  <xsl:attribute name="target">
                    <xsl:value-of select="$default_target"/>
                  </xsl:attribute>
                </xsl:element>
              </xsl:element>
              <xsl:element name="body">
                <xsl:if test="$wiki_links=1">
                  <xsl:element name="div">
                    <xsl:attribute name="class">
                      <xsl:text>wikiactions</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="ul">
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=edit;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:attribute name="rel">
                            <xsl:text>nofollow</xsl:text>
                          </xsl:attribute>
                          <xsl:text>Edit</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=history;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:text>History</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=blob_plain;f=mml/&quot;,$anamelc,&quot;.miz&quot;)"/>
                          </xsl:attribute>
                          <xsl:attribute name="rel">
                            <xsl:text>nofollow</xsl:text>
                          </xsl:attribute>
                          <xsl:text>Raw</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <!-- <li {  <a { @href=`concat("../discussion/",$anamelc, ".html")`; "Discussion"; } } -->
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="$lmwikiindex"/>
                          </xsl:attribute>
                          <xsl:text>Index</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:element name="li">
                        <xsl:element name="a">
                          <xsl:attribute name="href">
                            <xsl:value-of select="concat($lmwikicgi,&quot;?p=&quot;,$lgitproject,&quot;;a=gitweb&quot;)"/>
                          </xsl:attribute>
                          <xsl:text>Gitweb</xsl:text>
                        </xsl:element>
                      </xsl:element>
                    </xsl:element>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$mk_header &gt; 0">
                  <xsl:apply-templates select="document($hdr,/)/Header/*"/>
                  <xsl:element name="br"/>
                </xsl:if>
                <!-- first read the keys for imported stuff -->
                <!-- apply[document($constrs,/)/Constructors/Constructor]; -->
                <!-- apply[document($thms,/)/Theorems/Theorem]; -->
                <!-- apply[document($schms,/)/Schemes/Scheme]; -->
                <!-- then process the whole document -->
                <xsl:apply-templates/>
              </xsl:element>
            </xsl:element>
          </xsl:when>
          <!-- $body_only > 0 -->
          <xsl:otherwise>
            <xsl:if test="$mk_header &gt; 0">
              <xsl:apply-templates select="document($hdr,/)/Header/*"/>
              <xsl:element name="br"/>
            </xsl:if>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tpl [*] { copy { apply [@*]; apply; } } -->
  <!-- tpl [@*] { copy-of `.`; } -->
  <!-- Header rules -->
  <xsl:template match="dc:title">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:creator">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;by &quot;, text())"/>
    </xsl:call-template>
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str">
        <xsl:text/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:date">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Received &quot;, text())"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="dc:rights">
    <xsl:call-template name="pcomment">
      <xsl:with-param name="str" select="concat(&quot;Copyright &quot;, text())"/>
    </xsl:call-template>
  </xsl:template>

  <!-- comment rules -->
  <xsl:template match="Comment">
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>comment</xsl:text>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$colored=&quot;1&quot;">
          <xsl:element name="font">
            <xsl:attribute name="color">
              <xsl:value-of select="$commentcolor"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CmtLine">
    <xsl:value-of select="text()"/>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template match="CmtLink">
    <xsl:text>:: </xsl:text>
    <xsl:call-template name="add_wp_icon"/>
    <xsl:text> </xsl:text>
    <xsl:for-each select="*">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="text()"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:element name="br"/>
  </xsl:template>

  <xsl:template name="add_wp_icon">
    <xsl:element name="img">
      <xsl:attribute name="src">
        <xsl:value-of select="concat($ltptproot,&quot;WP.ico&quot;)"/>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:text>WP: </xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
