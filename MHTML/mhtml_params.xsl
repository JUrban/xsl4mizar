<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <!-- $Revision: 1.24 $ -->
  <!--  -->
  <!-- File: params.xsltxt - html-ization of Mizar XML, top-level parameters -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- The following are user-customizable -->
  <!-- mmlquery address -->
  <xsl:param name="mmlq">
    <xsl:text>http://merak.pb.bialystok.pl/mmlquery/fillin.php?entry=</xsl:text>
  </xsl:param>
  <!-- #mmlq= {"";} -->
  <!-- linking methods: -->
  <!-- "q" - query, everything is linked to mmlquery -->
  <!-- "s" - self, everything is linked to these xml/html files -->
  <!-- "m" - mizaring and mmlquery, current article's constructs are linked to self, -->
  <!-- the rest is linked to mmlquery -->
  <!-- "l" - local mizaring, current article's constructs are linked to self, -->
  <!-- the rest to $MIZFILES/html -->
  <xsl:param name="linking">
    <xsl:text>l</xsl:text>
  </xsl:param>
  <!-- needed for local linking, document("") gives the sylesheet as a document -->
  <xsl:param name="mizfiles">
    <xsl:value-of select="string(/*/@mizfiles)"/>
  </xsl:param>
  <xsl:param name="mizhtml">
    <xsl:value-of select="concat(&quot;file://&quot;,$mizfiles,&quot;html/&quot;)"/>
  </xsl:param>
  <!-- extension for linking to other articles - either xml or html -->
  <xsl:param name="ext">
    <xsl:text>html</xsl:text>
  </xsl:param>
  <!-- extension for linking to other articles - either xml or html -->
  <xsl:param name="selfext">
    <xsl:choose>
      <xsl:when test="$linking = &quot;l&quot;">
        <xsl:text>xml</xsl:text>
      </xsl:when>
      <xsl:when test="$linking = &quot;s&quot;">
        <xsl:value-of select="$ext"/>
      </xsl:when>
      <xsl:when test="$linking = &quot;m&quot;">
        <xsl:text>xml</xsl:text>
      </xsl:when>
      <xsl:when test="$linking = &quot;q&quot;">
        <xsl:text>html</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <!-- default target frame for links -->
  <xsl:param name="default_target">
    <xsl:choose>
      <xsl:when test="$linking = &quot;s&quot;">
        <xsl:text>_self</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>mmlquery</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- put titles to links or not -->
  <xsl:param name="titles">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- coloured output or not -->
  <xsl:param name="colored">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- print identifiers (like in JFM) instead of normalized names -->
  <xsl:variable name="print_identifiers">
    <xsl:text>1</xsl:text>
  </xsl:variable>
  <!-- new brackets: trying to print brackets as mizar does - -->
  <!-- when two or more arguments of a functor - now default -->
  <xsl:param name="mizar_brackets">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- no spaces around functor symbols -->
  <xsl:param name="funcs_no_spaces">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- print label identifiers  instead of normalized names -->
  <!-- this is kept separate from $print_identifiers, because -->
  <!-- it should be turned off for item generating -->
  <xsl:variable name="print_lab_identifiers">
    <xsl:text>1</xsl:text>
  </xsl:variable>
  <!-- print "for" in registrations - newly in version 1132 -->
  <xsl:param name="regs_use_for">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- tells whether relative or absolute names are shown -->
  <xsl:param name="relnames">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- link by (now also from) inferences to ATP solutions rendered by MMLQuery; experimental - off -->
  <!-- 1 - static linking (to pre-generated html) -->
  <!-- 2 - dynamic linking to MML Query (static dli sent to MMLQuery DLI-processor) -->
  <!-- 3 - dynamic linking to the TPTP-processor CGI ($lbytptpcgi) -->
  <xsl:param name="linkby">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- if non zero, add icons for atp exlpanation calls to theorems and proofs in the same way as to by's -->
  <xsl:param name="linkarproofs">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- if > 0, call the mk_by_title function to create a title for by|from|; -->
  <xsl:param name="by_titles">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- If 1, the target frame for by explanations is _self -->
  <xsl:param name="linkbytoself">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- directory with by ATP solutions in HTML; each article in its own subdir -->
  <xsl:param name="lbydir">
    <xsl:text>_by/</xsl:text>
  </xsl:param>
  <!-- directory with by ATP solutions in DLI; each article in its own subdir -->
  <!-- now whole url for the CGI script -->
  <xsl:param name="lbydliurl">
    <xsl:text>http://lipa.ms.mff.cuni.cz/~urban/xmlmml/html.930/_by_dli/</xsl:text>
  </xsl:param>
  <!-- URL of the DLI-processor CGI -->
  <xsl:param name="lbydlicgi">
    <xsl:text>http://mmlquery.mizar.org/cgi-bin/mmlquery/dli</xsl:text>
  </xsl:param>
  <!-- complete prefix of the DLI-processor CGI request -->
  <xsl:variable name="lbydlicgipref">
    <xsl:value-of select="concat($lbydlicgi,&quot;?url=&quot;,$lbydliurl)"/>
  </xsl:variable>
  <!-- URL of the MizAR root dir -->
  <!-- #ltptproot= { "http://octopi.mizar.org/~mptp/"; } -->
  <xsl:param name="ltptproot">
    <xsl:text>http://mws.cs.ru.nl/~mptp/</xsl:text>
  </xsl:param>
  <!-- URL of the TPTP-processor CGI -->
  <xsl:param name="ltptpcgi">
    <xsl:value-of select="concat($ltptproot,&quot;cgi-bin/&quot;)"/>
  </xsl:param>
  <!-- URL of the showby CGI -->
  <xsl:param name="lbytptpcgi">
    <xsl:value-of select="concat($ltptpcgi,&quot;showby.cgi&quot;)"/>
  </xsl:param>
  <!-- URL of the showtmpfile CGI -->
  <xsl:param name="ltmpftptpcgi">
    <xsl:value-of select="concat($ltptpcgi,&quot;showtmpfile.cgi&quot;)"/>
  </xsl:param>
  <!-- tells if by action is fetched through AJAX; default is off -->
  <xsl:param name="ajax_by">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- temporary dir with  the tptp by files, needs to be passed as a param -->
  <xsl:param name="lbytmpdir">
    <xsl:text/>
  </xsl:param>
  <!-- additional params for lbytptpcgi, needs to be passed as a param -->
  <xsl:param name="lbycgiparams">
    <xsl:text/>
  </xsl:param>
  <!-- add links to tptp files for thms -->
  <xsl:param name="thms_tptp_links">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- add editing, history, and possibly other links for wiki -->
  <!-- the namespace for the scripts is taken from #ltptproot -->
  <xsl:param name="wiki_links">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- add buttons for editing wiki sections -->
  <xsl:param name="wiki_sections">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- domain name of the "wiki" server -->
  <xsl:param name="lwikihost">
    <xsl:text>mws.cs.ru.nl</xsl:text>
  </xsl:param>
  <!-- URL of the "wiki" server -->
  <xsl:param name="lwikiserver">
    <xsl:value-of select="concat(&quot;http://&quot;,$lwikihost)"/>
  </xsl:param>
  <!-- URL of the "mwiki" cgi, used for mwiki actions -->
  <xsl:param name="lmwikicgi">
    <xsl:value-of select="concat($lwikiserver,&quot;/cgi-bin/mwiki/mwiki.cgi&quot;)"/>
  </xsl:param>
  <!-- name of the index page for wiki -->
  <xsl:param name="lmwikiindex">
    <xsl:text>00INDEX.html</xsl:text>
  </xsl:param>
  <!-- URL of the "wiki" raw cgi, showing the raw file -->
  <xsl:param name="lrawcgi">
    <xsl:value-of select="concat($lwikiserver,&quot;/cgi-bin/mwiki/raw.cgi&quot;)"/>
  </xsl:param>
  <!-- URL of the "gitweb" cgi, showing git history -->
  <xsl:param name="lgitwebcgi">
    <xsl:value-of select="concat($lwikiserver,&quot;:1234/&quot;)"/>
  </xsl:param>
  <!-- name of the git repository (project) in which this page is contained - -->
  <!-- used for gitweb history -->
  <xsl:param name="lgitproject">
    <xsl:text>mw1.git</xsl:text>
  </xsl:param>
  <!-- git clone address used for wiki cloning -->
  <xsl:param name="lgitclone">
    <xsl:value-of select="concat(&quot;git://&quot;,$lwikihost,&quot;/git/&quot;, $lgitproject)"/>
  </xsl:param>
  <!-- http clone address used for wiki cloning -->
  <xsl:param name="lhttpclone">
    <xsl:value-of select="concat(&quot;http://&quot;,$lwikihost,&quot;/git/&quot;, $lgitproject)"/>
  </xsl:param>
  <!-- tells if linkage of proof elements is done; default is off -->
  <xsl:param name="proof_links">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- tells if linkage of constants is done; default is 0 (off), -->
  <!-- 1 tells to only create the anchors, 2 tells to also link constants -->
  <!-- ##TODO: 2 is implement incorrectly and should not be used now, -->
  <!-- it should be done like privname (via the C key, not like now) -->
  <xsl:param name="const_links">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- tells if proofs are fetched through AJAX; default is off -->
  <!-- value 2 tells to produce the proofs, but not to insert the ajax calls, -->
  <!-- and instead insert tags for easy regexp-based post-insertion of files -->
  <!-- value 3 uses the ltmpftptpcgi to fetch the proof in the ajax request - like for by -->
  <xsl:param name="ajax_proofs">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- tells if ajax-able clicking requests (like proofs) are -->
  <!-- executed already on mouseover; default is on, but this -->
  <!-- will only work of $ajax_proofs>0 -->
  <xsl:param name="ajax_tooltips">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- the dir with proofs that are fetched through AJAX -->
  <xsl:param name="ajax_proof_dir">
    <xsl:text>proofs</xsl:text>
  </xsl:param>
  <!-- tells to display thesis after skeleton items -->
  <xsl:param name="display_thesis">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- tooltips wherever the corresponding hide/show functions apply -->
  <xsl:param name="hs_tooltips">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <xsl:param name="hs2_tooltips">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- tooltips for references -->
  <xsl:param name="ref_tooltips">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- tells if only selected items are generated to subdirs; default is off -->
  <xsl:param name="generate_items">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- put ajax for references (theorems, defs, schems) to $ajax_refs_dir -->
  <!-- seems to be wanted in the same situations as $ajax_proofs, so it is linked to them -->
  <xsl:param name="mk_ajax_refs">
    <xsl:value-of select="$ajax_proofs"/>
  </xsl:param>
  <!-- the dir with refs that can be fetched by AJAX -->
  <xsl:param name="ajax_refs_dir">
    <xsl:text>refs</xsl:text>
  </xsl:param>
  <!-- relevant only if $generate_items>0 -->
  <!-- tells if proofs of selected items are generated to subdirs; default is off -->
  <xsl:param name="generate_items_proofs">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- add IDV links and icons -->
  <xsl:param name="idv">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- create header info from .hdr file -->
  <xsl:param name="mk_header">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- include comment info from .cmt file -->
  <xsl:param name="mk_comments">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- include environ info from .evl file -->
  <xsl:param name="mk_environ">
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- Suppress the header and trailer of the final document. -->
  <!-- Thus, you can insert the resulting document into a larger one. -->
  <xsl:param name="body_only">
    <xsl:text>0</xsl:text>
  </xsl:param>
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
  <!-- this needs to be set to 1 for processing MML files -->
  <xsl:param name="mml">
    <xsl:choose>
      <xsl:when test="/Article">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- nr. of clusters in Typ -->
  <!-- this is set to 1 for processing MML files -->
  <xsl:param name="cluster_nr">
    <xsl:choose>
      <xsl:when test="$mml = &quot;0&quot;">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- whether we print all attributes (not just those with @pid) -->
  <!-- this is set to 1 for processing MML files -->
  <xsl:param name="print_all_attrs">
    <xsl:value-of select="$mml"/>
  </xsl:param>
  <!-- .atr file with imported constructors -->
  <xsl:param name="constrs">
    <xsl:value-of select="concat($anamelc, &apos;.atr&apos;)"/>
  </xsl:param>
  <!-- .eth file with imported theorems -->
  <xsl:param name="thms">
    <xsl:value-of select="concat($anamelc, &apos;.eth&apos;)"/>
  </xsl:param>
  <!-- .esh file with imported schemes -->
  <xsl:param name="schms">
    <xsl:value-of select="concat($anamelc, &apos;.esh&apos;)"/>
  </xsl:param>
  <!-- .eno file with imported patterns -->
  <xsl:param name="patts">
    <xsl:value-of select="concat($anamelc, &apos;.eno&apos;)"/>
  </xsl:param>
  <!-- .frx file with all (both imported and article's) formats -->
  <xsl:param name="formats">
    <xsl:value-of select="concat($anamelc, &apos;.frx&apos;)"/>
  </xsl:param>
  <!-- .dcx file with vocabulary -->
  <xsl:param name="vocs">
    <xsl:value-of select="concat($anamelc, &apos;.dcx&apos;)"/>
  </xsl:param>
  <!-- .idx file with identifier names -->
  <xsl:param name="ids">
    <xsl:value-of select="concat($anamelc, &apos;.idx&apos;)"/>
  </xsl:param>
  <!-- .dfs file with imported definientia -->
  <xsl:param name="dfs">
    <xsl:value-of select="concat($anamelc, &apos;.dfs&apos;)"/>
  </xsl:param>
  <!-- .hdr file with header info (done by mkxmlhdr.pl) -->
  <xsl:param name="hdr">
    <xsl:value-of select="concat($anamelc, &apos;.hdr&apos;)"/>
  </xsl:param>
  <!-- .cmt file with comments info (done by MizComments.pl) -->
  <xsl:param name="cmt">
    <xsl:value-of select="concat($anamelc, &apos;.cmt&apos;)"/>
  </xsl:param>
  <!-- .evl file with environ info -->
  <xsl:param name="evl">
    <xsl:value-of select="concat($anamelc, &apos;.evl&apos;)"/>
  </xsl:param>
  <xsl:param name="varcolor">
    <xsl:text>Olive</xsl:text>
  </xsl:param>
  <xsl:param name="constcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="locicolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="schpcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="schfcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="ppcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="pfcolor">
    <xsl:text>Maroon</xsl:text>
  </xsl:param>
  <xsl:param name="labcolor">
    <xsl:text>Green</xsl:text>
  </xsl:param>
  <xsl:param name="commentcolor">
    <xsl:text>firebrick</xsl:text>
  </xsl:param>
  <!-- use spans for brackets -->
  <xsl:param name="parenspans">
    <xsl:text>1</xsl:text>
  </xsl:param>
  <!-- number of parenthesis colors (see the stylesheet in the bottom) -->
  <xsl:param name="pcolors_nr">
    <xsl:text>6</xsl:text>
  </xsl:param>
  <!-- top level element instead of top-level document, which is hard to -->
  <!-- know -->
  <xsl:param name="top" select="/"/>
  <!-- debugging message -->
  <xsl:param name="dbgmsg">
    <xsl:text>zzzzzzzzz</xsl:text>
  </xsl:param>
  <!-- relative nr of the first expandable mode -->
  <!-- #first_exp = { `//Pattern[(@constrkind='M') and (@constrnr=0)][1]/@relnr`; } -->
  <!-- symbols, should be overloaded with different (eg tex, mathml) presentations -->
  <xsl:param name="for_s">
    <xsl:text> for </xsl:text>
  </xsl:param>
  <xsl:param name="ex_s">
    <xsl:text> ex </xsl:text>
  </xsl:param>
  <xsl:param name="not_s">
    <xsl:text> not </xsl:text>
  </xsl:param>
  <xsl:param name="non_s">
    <xsl:text> non </xsl:text>
  </xsl:param>
  <xsl:param name="and_s">
    <xsl:text> &amp; </xsl:text>
  </xsl:param>
  <xsl:param name="imp_s">
    <xsl:text> implies </xsl:text>
  </xsl:param>
  <xsl:param name="equiv_s">
    <xsl:text> iff </xsl:text>
  </xsl:param>
  <xsl:param name="or_s">
    <xsl:text> or </xsl:text>
  </xsl:param>
  <xsl:param name="holds_s">
    <xsl:text> holds </xsl:text>
  </xsl:param>
  <xsl:param name="being_s">
    <xsl:text> being </xsl:text>
  </xsl:param>
  <xsl:param name="be_s">
    <xsl:text> be </xsl:text>
  </xsl:param>
  <xsl:param name="st_s">
    <xsl:text> st </xsl:text>
  </xsl:param>
  <xsl:param name="is_s">
    <xsl:text> is </xsl:text>
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
    <xsl:text> of </xsl:text>
  </xsl:param>
  <xsl:param name="of_typ_s">
    <xsl:text> of </xsl:text>
  </xsl:param>
  <xsl:param name="the_sel_s">
    <xsl:text> the </xsl:text>
  </xsl:param>
  <xsl:param name="choice_s">
    <xsl:text> the </xsl:text>
  </xsl:param>
  <xsl:param name="lbracket_s">
    <xsl:text>(</xsl:text>
  </xsl:param>
  <xsl:param name="rbracket_s">
    <xsl:text>)</xsl:text>
  </xsl:param>
  <xsl:param name="top_proof_end">
    <xsl:text>end;</xsl:text>
  </xsl:param>
  <!-- the javascript that we are so reluctant to outsource -->
  <xsl:param name="mizjs1">
    <xsl:text>
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
   else { if (how == &apos;txt&apos;) { tt.innerHTML = v; }
	  else { tt.innerHTML = &apos;&apos;; }
	}
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

// reference show/hide - shortened because frequent, just a wrapper to tooltip.show/hide
function rs(ref) { tooltip.show(&apos;url&apos;, mizhtm + &apos;refs/&apos; + ref); }
function rh() { tooltip.hide(); } 

// End --&gt;
</xsl:text>
  </xsl:param>
</xsl:stylesheet>
