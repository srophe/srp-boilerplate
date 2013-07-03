<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0" 
 xmlns:s="http://syriaca.org"
 xmlns:saxon="http://saxon.sf.net/" 
 xmlns:ipse="urn.ipsens"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s saxon ipse" version="2.0">

 <!-- =================================================================== -->
 <!-- import component stylesheets for HTML page portions -->
 <!-- =================================================================== -->

 <xsl:import href="boilerplate-head.xsl"/>
 <xsl:import href="boilerplate-bottom.xsl"/>
 <xsl:import href="boilerplate-badbrowser.xsl"/>
 <xsl:import href="boilerplate-nav.xsl"/>
 <xsl:import href="boilerplate-footer.xsl"/>
 <xsl:import href="langattr.xsl"/>
 <xsl:import href="normalization.xsl"/>


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
 <xsl:param name="destdir">./places/</xsl:param>
 <xsl:param name="description">Listings of places registered in the Syriac Gazetteer.</xsl:param>
 <xsl:param name="description-page">Listings of places registered in the Syriac Gazetteer.</xsl:param>
 <xsl:param name="name-app">The Syriac Gazetteer</xsl:param>
 <xsl:param name="name-page-short">Browse</xsl:param>
 <xsl:param name="name-page-long">Browse Lists</xsl:param>
 <xsl:param name="copyright-holders">CHANGE THE COPYRIGHT HOLDERS PARAMETER</xsl:param>
 <xsl:param name="copyright-year">2013</xsl:param>
 <xsl:param name="xmlbase">https://github.com/srophe/places/blob/master/xml/</xsl:param>
 <xsl:param name="uribase">http://syriaca.org/place/</xsl:param>
 <xsl:param name="normalization">NFKC</xsl:param>
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

       <div class="tabbable">
        <ul class="nav nav-tabs" id="nametabs">
         <li class="active"><a href="#english" data-toggle="tab">english</a></li>
         <li><a href="#syriac" data-toggle="tab" xml:lang="syr" lang="syr" dir="ltr" title="syriac">ܠܫܢܐ ܣܘܪܝܝܐ</a></li>
         <li><a href="#number" data-toggle="tab">syriac gazetter number</a></li>
        </ul>
        <div class="tab-content">
         <div class="tab-pane active" id="english">
          <xsl:call-template name="do-list-english"/>
         </div>
         <div class="tab-pane" id="syriac" dir="rtl">
          <xsl:call-template name="do-list-syriac"/>
         </div>
         <div class="tab-pane" id="number">
          <xsl:call-template name="do-list-number"/>
         </div>
        </div>
       </div>
      </div>
     </div>
     
     <!-- write the standard page footer -->
     <xsl:call-template name="boilerplate-footer">
      <xsl:with-param name="copyright-year" select="$copyright-year"/>
      <xsl:with-param name="copyright-holders" select="$copyright-holders"/>
     </xsl:call-template>
     
    </div>

    <!-- write scripts etc. that belong at the bottom of the body -->
    <xsl:call-template name="boilerplate-bottom"/>    
   </body>
  </html>
 </xsl:template>

<xsl:template name="do-list-english">
 <!-- write a sorted, linked list of all the place titles in the gazetteer -->
 <ul>
  <xsl:for-each select="collection($colquery)">
   <xsl:sort collation="mixed" select="ipse:ensort(./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en'][1])"/>
   <xsl:variable name="placenum" select="normalize-space(substring-after(./descendant-or-self::t:listPlace/t:place[1]/@xml:id, 'place-'))"/>
   <xsl:choose>
    <xsl:when test="matches($placenum, '^\d+$')">
     <xsl:variable name="htmlurl">
      <xsl:value-of select="$destdir"/>
      <xsl:value-of select="$placenum"/>
      <xsl:text>.html</xsl:text>
     </xsl:variable>
     <li>
      <a href="{$htmlurl}">
       <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en'][1]"/>
       <bdi dir="ltr" xml:lang="en" lang="en">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="./descendant-or-self::t:place[1]/@type"/>
        <xsl:text>)</xsl:text>
       </bdi>       
       <xsl:if test="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1]">
       <bdi dir="ltr"><xsl:text> — </xsl:text></bdi>
       <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1]"/>
       </xsl:if>
      </a>
     </li>
    </xsl:when>
    <xsl:otherwise>
     
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </ul>
</xsl:template>
 
 <xsl:template name="do-list-syriac">
  <!-- write a sorted, linked list of all the place titles in the gazetteer -->
  <ul>
   <xsl:for-each select="collection($colquery)">
    <xsl:sort lang="syr" select="ipse:syrsort(./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1])"/>
    <xsl:variable name="placenum" select="normalize-space(substring-after(./descendant-or-self::t:listPlace/t:place[1]/@xml:id, 'place-'))"/>
    <xsl:choose>
     <xsl:when test="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'] and matches($placenum, '^\d+$')">
      <xsl:variable name="htmlurl">
       <xsl:value-of select="$destdir"/>
       <xsl:value-of select="$placenum"/>
       <xsl:text>.html</xsl:text>
      </xsl:variable>
      <li>
       <a href="{$htmlurl}">
        <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1]"/>
        <xsl:if test="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en'][1]">
         <bdi dir="rtl"><xsl:text> — </xsl:text></bdi>
         <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en'][1]"/>
        </xsl:if>
       </a>
      </li>
     </xsl:when>
     <xsl:otherwise>
      
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </ul>
 </xsl:template>

 <xsl:template name="do-list-number">
  <!-- write a sorted, linked list of all the place titles in the gazetteer -->
  <ul>
   <xsl:for-each select="collection($colquery)">
    <xsl:sort select="xs:integer(ipse:numsort(substring-after(./descendant-or-self::t:listPlace/t:place[1]/@xml:id, '-')))"/>
    <xsl:variable name="placenum" select="normalize-space(substring-after(./descendant-or-self::t:listPlace/t:place[1]/@xml:id, 'place-'))"/>
    <xsl:choose>
     <xsl:when test="matches($placenum, '^\d+$')">
      <xsl:variable name="htmlurl">
       <xsl:value-of select="$destdir"/>
       <xsl:value-of select="$placenum"/>
       <xsl:text>.html</xsl:text>
      </xsl:variable>
      <li>
       <a href="{$htmlurl}"><xsl:value-of select="$placenum"/><xsl:text>: </xsl:text>
        <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en'][1]"/>
        <bdi dir="ltr" xml:lang="en" lang="en">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="./descendant-or-self::t:place[1]/@type"/>
         <xsl:text>)</xsl:text>
        </bdi>
        <xsl:if test="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1]">
         <bdi dir="ltr"><xsl:text> — </xsl:text></bdi>
         <xsl:apply-templates select="./descendant-or-self::t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang!='en'][1]"/>
        </xsl:if>
       </a>
      </li>
     </xsl:when>
     <xsl:otherwise>
      
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </ul>
 </xsl:template>
 
 <xsl:template match="t:placeName">
  <span class="placeName">
   <xsl:call-template name="langattr"/>
   <xsl:apply-templates select="." mode="out-normal"/>
  </span>
 </xsl:template>
 
 <xsl:function name="ipse:numsort">
  <xsl:param name="instring"></xsl:param>
  <xsl:variable name="norm" select="normalize-space($instring)"/>
  <xsl:choose>
   <xsl:when test="$norm = ''">
    <xsl:text>0</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$norm"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:function>
 
 <xsl:function name="ipse:syrsort">
  <xsl:param name="instring"></xsl:param>
  <xsl:variable name="norm">
   <xsl:apply-templates select="$instring" mode="out-normal"/>
  </xsl:variable>
  <xsl:value-of select="$norm"/>
 </xsl:function>
 
 <xsl:function name="ipse:ensort">
  <xsl:param name="instring"></xsl:param>
  <xsl:variable name="norm">
   <xsl:apply-templates select="$instring" mode="out-normal"/>
  </xsl:variable>
  <xsl:call-template name="syrtrip">
   <xsl:with-param name="instring" select="$norm"/>
  </xsl:call-template>
 </xsl:function>
 
 <xsl:template name="syrtrip">
  <xsl:param name="instring"/>
  <xsl:choose>
   <xsl:when test="starts-with($instring, ' ')">
    <xsl:call-template name="syrtrip">
     <xsl:with-param name="instring" select="substring($instring, 2)"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($instring, 'al-')">
    <xsl:call-template name="syrtrip">
     <xsl:with-param name="instring" select="substring-after($instring, 'al-')"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="starts-with($instring, '&#703;')">
    <xsl:call-template name="syrtrip">
     <xsl:with-param name="instring" select="substring-after($instring, '&#703;')"/>
    </xsl:call-template>    
   </xsl:when>
   <xsl:when test="starts-with($instring, '‘') and ends-with($instring, '’')">
    <xsl:call-template name="syrtrip">
     <xsl:with-param name="instring" select="substring-before(substring-after($instring, '‘'), '’')"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="normalize-space($instring)"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <!-- =================================================================== -->
 <!-- define custom collation for sorting the list of names -->
 <!-- =================================================================== -->
 
 <saxon:collation name="mixed" rules="&lt; a,A &lt; b,B &lt; c,C &lt; d,D &lt; e,E &lt; f,F &lt; g,G &lt; h,H &lt; i,I &lt; j,J &lt; k,K &lt; l,L &lt; m,M &lt; n,N &lt; o,O &lt; p,P &lt; q,Q &lt; r,R &lt; s,S &lt; t,T &lt; u,U &lt; v,V &lt; w,W &lt; x,X &lt; y,Y &lt; z,Z &amp; OE = Œ &amp; A = Ẵ &amp; E = Ễ &amp; A = Ằ &amp; D = Đ &amp; A = Ā &amp; S = Š &amp; U = Ū &amp; H = Ḥ &amp; S = Ṣ &amp; T = Ṭ &amp; I = Ī" ignore-case="yes" ignore-modifiers="yes" ignore-symbols="yes"/>
</xsl:stylesheet>
