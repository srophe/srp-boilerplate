<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0" 
 xmlns:s="http://syriaca.org"
 xmlns:saxon="http://saxon.sf.net/" 
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s" version="2.0">

 <!-- =================================================================== -->
 <!-- import component stylesheets for HTML page portions -->
 <!-- =================================================================== -->

 <xsl:import href="boilerplate-head.xsl"/>
 <xsl:import href="boilerplate-bottom.xsl"/>
 <xsl:import href="boilerplate-badbrowser.xsl"/>
 <xsl:import href="boilerplate-nav.xsl"/>


 <!-- =================================================================== -->
 <!-- set output so we get (mostly) indented HTML -->
 <!-- =================================================================== -->

 <xsl:output encoding="UTF-8" method="html" indent="yes"/>


 <!-- =================================================================== -->
 <!-- initialize top-level variables and transform parameters -->
 <!--  sourcedir: where to look for XML files to summarize/link to -->
 <!--  description: a meta description for the HTML page we will output -->
 <!--  name-app: name of the application (for use in head/title) -->
 <!--  name-page-short: short name of the page (for use in head/title) -->
 <!--  colquery: constructed variable with query for collection fn. -->
 <!-- =================================================================== -->

 <xsl:param name="sourcedir">../../places/xml/</xsl:param>
 <xsl:param name="description">A complete listing, by English name, of all places registered in the Syriac
  Gazetteer.</xsl:param>
 <xsl:param name="description-page">A complete listing, by English name, of all places registered in the Syriac
  Gazetteer.</xsl:param>
 <xsl:param name="name-app">The Syriac Gazetteer</xsl:param>
 <xsl:param name="name-page-short">Browse</xsl:param>
 <xsl:param name="name-page-long">Browseable List of Places</xsl:param>
 <xsl:param name="copyright-holders">CHANGE THE COPYRIGHT HOLDERS PARAMETER</xsl:param>
 <xsl:param name="copyright-year">2013</xsl:param>
 <xsl:param name="xmlbase">https://github.com/srophe/places/blob/master/xml/</xsl:param>
 <xsl:param name="uribase">http://syriaca.org/place/</xsl:param>
 <xsl:variable name="colquery"><xsl:value-of select="$sourcedir"/>?select=*.xml</xsl:variable>


 <!-- =================================================================== -->
 <!-- TEMPLATES -->
 <!-- =================================================================== -->


 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->
 <!-- |||| do-list: creates the entire browselisting page -->
 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->

 <xsl:template name="do-list">

  <!-- write the opening of the HTML page -->
  <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
  <xsl:comment>[if lt IE 7]>      &lt;html class="no-js lt-ie9 lt-ie8 lt-ie7"> &lt;![endif]</xsl:comment>
  <xsl:comment>[if IE 7]>         &lt;html class="no-js lt-ie9 lt-ie8"> &lt;![endif]</xsl:comment>
  <xsl:comment>[if IE 8]>         &lt;html class="no-js lt-ie9"> &lt;![endif]</xsl:comment>
  <xsl:comment>[if gt IE 8]></xsl:comment>
  <html class="no-js">
   <xsl:comment>&lt;![endif]</xsl:comment>

   <!-- write the page head element and its contents -->
   <xsl:call-template name="boilerplate-head">
    <xsl:with-param name="description" select="$description"/>
    <xsl:with-param name="name-app" select="$name-app"/>
    <xsl:with-param name="name-page-short" select="$name-page-short"/>
   </xsl:call-template>

   <!-- write the body element and its contents -->
   <body>
    
    <!-- add an upgrade urging for users of old IE versions -->
    <xsl:call-template name="boilerplate-badbrowser"/>
    
    <xsl:call-template name="boilerplate-nav">
     <xsl:with-param name="active">browse</xsl:with-param>
     <xsl:with-param name="app-name" select="$name-app"/>
    </xsl:call-template>
    
    <!-- create the main content portion of the page -->
    <div class="container-fluid">
     <div class="row-fluid">
      <div class="span7">
       <h2>
        <i><xsl:value-of select="$name-app"/>:</i>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$name-page-long"/>
       </h2>
       <p><xsl:value-of select="$description-page"/></p>

       <!-- write a sorted, linked list of all the place titles in the gazetteer -->
       <ul>
        <xsl:for-each select="collection($colquery)">
         <xsl:sort collation="mixed" select="replace(replace(normalize-unicode(./descendant-or-self::t:TEI/t:teiHeader/descendant::t:titleStmt/t:title[ancestor-or-self::*[@xml:lang]/@xml:lang='en'][1], 'NFC'), '‘', ''), 'ʿ', '')"/>
         <xsl:variable name="xmlurl">
          <xsl:for-each select="./descendant::t:place[1]/t:idno[@type='URI' and starts-with(., $uribase)][1]">
           <xsl:value-of select="$xmlbase"/>
           <xsl:value-of select="substring-after(., $uribase)"/>
           <xsl:text>.xml</xsl:text>
          </xsl:for-each>
         </xsl:variable>
         <li>
          <xsl:apply-templates select="./descendant-or-self::t:TEI/t:teiHeader/descendant::t:titleStmt/t:title[ancestor-or-self::*[@xml:lang]/@xml:lang='en'][1]"/>
          <xsl:text>: </xsl:text>
          <a href="{$xmlurl}">tei xml</a>
         </li>
        </xsl:for-each>
       </ul>
      </div>
     </div>

     <hr/>

     <footer>
      <p><a rel="license" href="http://creativecommons.org/licenses/by/3.0/deed.en_US"><img
         alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/80x15.png"
        /></a><br/>This work is licensed under a <a rel="license"
        href="http://creativecommons.org/licenses/by/3.0/deed.en_US">Creative Commons Attribution 3.0 Unported
        License</a>. <br/>Copyright <xsl:value-of select="$copyright-holders"/>
       <xsl:value-of select="$copyright-year"/>.</p>. </footer>
    </div>
    <!-- write scripts etc. that belong at the bottom of the body -->
    <xsl:call-template name="boilerplate-bottom"/> 
   </body>
  </html>
 </xsl:template>

 <xsl:template match="t:title">
   <xsl:value-of select="normalize-space(normalize-unicode(., 'NFC'))"/>
 </xsl:template>
 
 <saxon:collation name="mixed" rules="&lt; a,A &lt; b,B &lt; c,C &lt; d,D &lt; e,E &lt; f,F &lt; g,G &lt; h,H &lt; i,I &lt; j,J &lt; k,K &lt; l,L &lt; m,M &lt; n,N &lt; o,O &lt; p,P &lt; q,Q &lt; r,R &lt; s,S &lt; t,T &lt; u,U &lt; v,V &lt; w,W &lt; x,X &lt; y,Y &lt; z,Z &amp; OE = Œ &amp; A = Ẵ &amp; E = Ễ &amp; A = Ằ &amp; D = Đ &amp; A = Ā &amp; S = Š &amp; U = Ū &amp; H = Ḥ &amp; S = Ṣ &amp; T = Ṭ &amp; I = Ī" ignore-case="yes" ignore-modifiers="yes" ignore-symbols="yes"/>
</xsl:stylesheet>
