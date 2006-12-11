<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <!-- $Revision: 1.1 $ -->
  <!--  -->
  <!-- File: keys.xsltxt - html-ization of Mizar XML, definition of keys (indexes) -->
  <!--  -->
  <!-- Author: Josef Urban -->
  <!--  -->
  <!-- License: GPL (GNU GENERAL PUBLIC LICENSE) -->
  <!-- keys for fast constructor and reference lookup -->
  <xsl:key name="M" match="Constructor[@kind=&apos;M&apos;]" use="@relnr"/>
  <xsl:key name="L" match="Constructor[@kind=&apos;L&apos;]" use="@relnr"/>
  <xsl:key name="V" match="Constructor[@kind=&apos;V&apos;]" use="@relnr"/>
  <xsl:key name="R" match="Constructor[@kind=&apos;R&apos;]" use="@relnr"/>
  <xsl:key name="K" match="Constructor[@kind=&apos;K&apos;]" use="@relnr"/>
  <xsl:key name="U" match="Constructor[@kind=&apos;U&apos;]" use="@relnr"/>
  <xsl:key name="G" match="Constructor[@kind=&apos;G&apos;]" use="@relnr"/>
  <xsl:key name="T" match="/Theorems/Theorem[@kind=&apos;T&apos;]" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="D" match="/Theorems/Theorem[@kind=&apos;D&apos;]" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="S" match="/Schemes/Scheme" use="concat(@articlenr,&apos;:&apos;,@nr)"/>
  <xsl:key name="DF" match="Definiens" use="@relnr"/>
  <!-- patterns are slightly tricky, since a predicate pattern -->
  <!-- may be linked to an attribute constructor; hence the -->
  <!-- indexing is done according to @constrkind and not @kind -->
  <!-- TODO: the attribute<->predicate change should propagate to usage -->
  <!-- of "is" -->
  <!-- Expandable modes have all @constrkind='M' and @constrnr=0, -->
  <!-- they are indexed separately only on their @relnr (@pid) -->
  <xsl:key name="P_M" match="Pattern[(@constrkind=&apos;M&apos;) and (@constrnr&gt;0)]" use="@constrnr"/>
  <xsl:key name="P_L" match="Pattern[@constrkind=&apos;L&apos;]" use="@constrnr"/>
  <xsl:key name="P_V" match="Pattern[@constrkind=&apos;V&apos;]" use="@constrnr"/>
  <xsl:key name="P_R" match="Pattern[@constrkind=&apos;R&apos;]" use="@constrnr"/>
  <xsl:key name="P_K" match="Pattern[@constrkind=&apos;K&apos;]" use="@constrnr"/>
  <xsl:key name="P_U" match="Pattern[@constrkind=&apos;U&apos;]" use="@constrnr"/>
  <xsl:key name="P_G" match="Pattern[@constrkind=&apos;G&apos;]" use="@constrnr"/>
  <xsl:key name="EXP" match="Pattern[(@constrkind=&apos;M&apos;) and (@constrnr=0)]" use="@relnr"/>
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
  <!-- identifiers -->
  <xsl:key name="D_I" match="Symbol[@kind=&apos;I&apos;]" use="@nr"/>
  <!-- keys for absolute linkage inside proofs; -->
  <!-- requires preprocessing by addabsrefs, otherwise wrong results, -->
  <!-- so commented now (could be uncommented using conditional include probably) -->
  <!-- lookup for local constants -->
  <xsl:key name="C" match="Let|Given|TakeAsVar|Consider|Set|Reconsider" use="@plevel"/>
  <!-- lookup for propositions -->
  <xsl:key name="E" match="Proposition|IterEquality|Now" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <!-- lookup for scheme functors and predicates -->
  <xsl:key name="f" match="SchemeFuncDecl" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <xsl:key name="p" match="SchemePredDecl" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <!-- lookup for private functors and predicates -->
  <xsl:key name="pf" match="DefFunc" use="concat(@nr,&quot;:&quot;,@plevel)"/>
  <xsl:key name="pp" match="DefPred" use="concat(@nr,&quot;:&quot;,@plevel)"/>
</xsl:stylesheet>
