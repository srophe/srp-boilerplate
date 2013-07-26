<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0" 
 xmlns:s="http://syriaca.org"
 xmlns:saxon="http://saxon.sf.net/" 
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s saxon" version="2.0">

 <!-- ================================================================== 
       Copyright 2013 New York University
       
       This file is part of the Syriac Reference Portal Places Application.
       
       The Syriac Reference Portal Places Application is free software: 
       you can redistribute it and/or modify it under the terms of the GNU 
       General Public License as published by the Free Software Foundation, 
       either version 3 of the License, or (at your option) any later 
       version.
       
       The Syriac Reference Portal Places Application is distributed in 
       the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
       even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
       PARTICULAR PURPOSE.  See the GNU General Public License for more 
       details.
       
       You should have received a copy of the GNU General Public License
       along with the Syriac Reference Portal Places Application.  If not,
       see (http://www.gnu.org/licenses/).
       
       ================================================================== --> 
 
 <!-- ================================================================== 
       placepage.xsl
       
       This XSLT transforms places xml (TEI) files to HTML. It builds the
       guts of the website, in effect.
       
       parameters:
       
       assumptions and dependencies:
        + transform has been tested with Saxon PE 9.4.0.6 with initial
          template (-it) option set to "do-index" (i.e., there is no 
          single input file)
        
       code by: 
        + Tom Elliott (http://www.paregorios.org) 
          for the Institute for the Study of the Ancient World, New York
          University, under contract to Vanderbilt University for the
          NEH-funded Syriac Reference Portal project.
          
       funding provided by:
        + National Endowment for the Humanities (http://www.neh.gov). Any 
          views, findings, conclusions, or recommendations expressed in 
          this code do not necessarily reflect those of the National 
          Endowment for the Humanities.
       
       ================================================================== -->
 <!-- =================================================================== -->
 <!-- import component stylesheets for HTML page portions -->
 <!-- =================================================================== -->

 <xsl:import href="bibliography.xsl"/>
 <xsl:import href="boilerplate-head.xsl"/>
 <xsl:import href="boilerplate-bottom.xsl"/>
 <xsl:import href="boilerplate-badbrowser.xsl"/>
 <xsl:import href="boilerplate-nav.xsl"/>
 <xsl:import href="citation.xsl"/>
 <xsl:import href="collations.xsl"/>
 <xsl:import href="langattr.xsl"/>
 <xsl:import href="link-icons.xsl"/>
 <xsl:import href="log.xsl"/>
 <xsl:import href="normalization.xsl"/>
 <xsl:import href="place-title-std.xsl"/>
 

 <!-- =================================================================== -->
 <!-- set output so we get (mostly) indented HTML -->
 <!-- =================================================================== -->

 <xsl:output name="html" encoding="UTF-8" method="html" indent="yes"/>

 <!-- =================================================================== -->
 <!-- initialize top-level variables and transform parameters -->
 <!--  sourcedir: where to look for XML files to summarize/link to -->
 <!--  description: a meta description for the HTML page we will output -->
 <!--  name-app: name of the application (for use in head/title) -->
 <!--  name-page-short: short name of the page (for use in head/title) -->
 <!--  colquery: constructed variable with query for collection fn. -->
 <!-- =================================================================== -->

 <xsl:param name="idxdir">../places/</xsl:param> 
 <xsl:param name="sourcedir">../../places/xml/</xsl:param>
 <xsl:param name="biblsourcedir">../../bibl/xml/</xsl:param>
 <xsl:param name="destdir">../places/</xsl:param>
 <xsl:param name="name-app">The Syriac Gazetteer</xsl:param>
 <xsl:param name="copyright-holders">CHANGE THE COPYRIGHT HOLDERS PARAMETER</xsl:param>
 <xsl:param name="copyright-year">2013</xsl:param>
 <xsl:param name="xmlbase">https://github.com/srophe/places/blob/master/xml/</xsl:param>
 <xsl:param name="uribase">http://syriaca.org/place/</xsl:param>
 <xsl:param name="normalization">NFKC</xsl:param>
 <xsl:param name="placeslevel">places/</xsl:param>
 <xsl:param name="base">http://srophe.github.io/srp-places-app/</xsl:param>
 <xsl:param name="teiuripostfix">tei</xsl:param>
 <xsl:param name="htmluripostfix">html</xsl:param>
 

 <xsl:variable name="idxquery"><xsl:value-of select="$idxdir"/>index.xml</xsl:variable>
 

 <!-- =================================================================== -->
 <!-- TEMPLATES -->
 <!-- =================================================================== -->


 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->
 <!-- |||| do-places: creates all individual place pages -->
 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->

 <xsl:template name="do-places">
  
  <xsl:variable name="idx" select="document($idxquery)"/>
  <!-- loop through all page XML and write a corresponding HTML page -->
  <xsl:for-each select="$idx/descendant-or-self::t:place">
   
   <!-- determine descriptions and page names -->
   <xsl:variable name="description">
    <xsl:choose>
     <xsl:when test="t:desc[@type='abstract'][1]">
      <xsl:apply-templates select="t:desc[@type='abstract'][1]" mode="text-normal"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>no description available</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="name-page-short">
    <xsl:choose>
     <xsl:when test="t:placeName[@xml:lang='en']">
      <xsl:value-of select="t:placeName[@xml:lang='en']"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>Place no. </xsl:text>
      <xsl:value-of select="t:idno[@type='placeId']"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   
   <!-- load frequently needed info into convenient variables -->
   <xsl:variable name="placenum" select="t:idno[@type='placeID'][1]"/>
   <xsl:variable name="placeid" select="./@xml:id"/>
   <xsl:variable name="placeuri" select="t:idno[@type='SRP'][1]"/>
   <xsl:variable name="htmluri">
    <xsl:value-of select="$placeuri"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$htmluripostfix"/>
   </xsl:variable>
   <xsl:variable name="sourcefilepath">
    <xsl:value-of select="$sourcedir"/>
    <xsl:value-of select="$placenum"/>
    <xsl:text>.xml</xsl:text>
   </xsl:variable>
   <xsl:variable name="sourcedoc" select="document($sourcefilepath)/descendant-or-self::t:TEI"/>
   <xsl:variable name="outfilename">
    <xsl:value-of select="$placenum"/>
    <xsl:text>.html</xsl:text>
   </xsl:variable>   
   
   <!-- check for and warn on undesirable or unexpected conditions in data -->
   <xsl:if test="count($idx/descendant::t:place[@xml:id=$placeid])&gt; 1">
    <xsl:call-template name="log">
     <xsl:with-param name="msg">index file contains more than one place with an xml:id attribute value of <xsl:value-of select="$placeid"/>
     </xsl:with-param>
    </xsl:call-template>
   </xsl:if>
   <xsl:if test="count($idx/descendant::t:place[t:idno[@type='placeID']=$placenum])&gt; 1">
    <xsl:call-template name="log">
     <xsl:with-param name="msg">index file contains more than one place with an placeID value of <xsl:value-of select="$placenum"/></xsl:with-param>
    </xsl:call-template>
   </xsl:if>
    <xsl:if test="count($idx/descendant::t:place[t:idno[@type='SRP']=$placeuri])&gt; 1">
     <xsl:call-template name="log">
      <xsl:with-param name="msg">index file contains more than one place with an SRP URI value of <xsl:value-of select="$placeuri"/></xsl:with-param>
     </xsl:call-template>
   </xsl:if>
    
    <!-- if we have a proper placeid, then write the page; otherwise warn -->
   <xsl:choose>
    <xsl:when test="matches($placenum, '^\d+$')">
     
     <!-- open a new output document for writing -->
     <xsl:result-document format="html" href="{$destdir}{$outfilename}">
      
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
        <xsl:with-param name="basepath">..</xsl:with-param>
        <xsl:with-param name="titleStmt" select="$sourcedoc/descendant-or-self::t:titleStmt"/>
       </xsl:call-template>
    
       <!-- write the body element and its contents -->
       <body xml:lang="en" lang="en">
        
        <!-- add an upgrade urging for users of old IE versions -->
        <xsl:call-template name="boilerplate-badbrowser"/>
        
        <xsl:call-template name="boilerplate-nav">
         <xsl:with-param name="active">browse</xsl:with-param>
         <xsl:with-param name="app-name" select="$name-app"/>
         <xsl:with-param name="basepath">..</xsl:with-param>
        </xsl:call-template>
        
        <!-- create the main content portion of the page -->
        <div class="container-fluid">
         <div class="row-fluid">
          <div class="span7" xml:id="place-content">
           
           <!-- create the main heading in the page body -->
           <h2><xsl:call-template name="place-title-std"/></h2>
           
           <!-- create any appropriate link icons -->
           <xsl:call-template name="link-icons"/>
           
           <!-- emit place URI and associated help links -->
           <xsl:for-each select="t:idno[@type='SRP']">
            <div>
             <a href="../help/terms.html#place-uri" title="Click to read more about Place URIs"><div class="helper circle">
              <p>i</p>
             </div></a>
            <p><span class="label label-info">Place URI</span>
             <xsl:text>: </xsl:text><xsl:value-of select="."/></p>
            </div>
           </xsl:for-each>
           <xsl:for-each select="t:desc[@type='abstract' or starts-with(@xml:id, 'abstract-en')][1]">
            <p><xsl:apply-templates mode="cleanout"/></p>
           </xsl:for-each>
    
           <!-- core page content -->
            <xsl:for-each select="$sourcedoc/descendant::t:place[1]">
              <div id="{@xml:id}">
               <xsl:apply-templates select=".">
                <xsl:with-param name="idx" select="$idx"/>
               </xsl:apply-templates>
              </div>
            </xsl:for-each>
          </div>
         </div>
         
         <!-- footer -->
         <hr />
         <footer>
          <div id="citation">
           <h3>How to Cite This Entry</h3>
           <div id="citation-note">
            <h4>Note:</h4>
            <xsl:apply-templates select="$sourcedoc/descendant::t:titleStmt" mode="cite-foot">
             <xsl:with-param name="htmluri" select="$htmluri"/>
            </xsl:apply-templates>
           </div>
           <div id="citation-bibliography">
            <h4>Bibliography:</h4>
            <xsl:apply-templates select="$sourcedoc/descendant::t:titleStmt" mode="cite-biblist">
             <xsl:with-param name="htmluri" select="$htmluri"/>
            </xsl:apply-templates>
           </div>
          </div>
          <div id="about">
           <h3>About this Entry</h3>
           <xsl:apply-templates select="$sourcedoc/descendant::t:titleStmt" mode="about">
            <xsl:with-param name="htmluri" select="$htmluri"/>
           </xsl:apply-templates>
          </div> 
          <div id="license">
           <h3>Copyright and License for Reuse</h3>
           <p>
            <xsl:text>Except otherwise noted, this page is © </xsl:text>
            <xsl:value-of select="format-date(xs:date($sourcedoc/descendant::t:publicationStmt/t:date[1]), '[Y]')"/>.</p>
           <xsl:apply-templates select="$sourcedoc/descendant::t:publicationStmt/t:availability/t:licence"/>
          </div>
         </footer>
         
        </div>
    
        <!-- write scripts etc. that belong at the bottom of the body -->
        <xsl:call-template name="boilerplate-bottom">
         <xsl:with-param name="basepath">..</xsl:with-param>
        </xsl:call-template>
       </body>
      </html>
     </xsl:result-document>
     
    </xsl:when>
    <xsl:otherwise>
     <xsl:message>WARNING: placepage.xsl didn't find proper place id in file <xsl:value-of select="document-uri(.)"/></xsl:message>
    </xsl:otherwise>
   </xsl:choose>
   
  </xsl:for-each>
 </xsl:template>
 
 <xsl:template match="t:place">
  <xsl:param name="idx"/>
  <xsl:variable name="thistype" select="@type"/>
  <xsl:variable name="thisid" select="@xml:id"/>
  <xsl:variable name="thisuri" select="$idx/descendant::t:place[@xml:id=$thisid]/t:idno[@type='SRP']"/>
  <div id="placenames">
   <h3>Names</h3>
   <ul>
    <xsl:apply-templates select="t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='syr']" mode="list">
     <xsl:with-param name="idx" select="$idx"/>
     <xsl:sort lang="syr" select="."/>
    </xsl:apply-templates>
    <xsl:apply-templates select="t:placeName[@syriaca-tags='#syriaca-headword' and @xml:lang='en']" mode="list">
     <xsl:with-param name="idx" select="$idx"/>
     <xsl:sort collation="mixed" select="."/>
    </xsl:apply-templates>
    <xsl:apply-templates select="t:placeName[(not(@syriaca-tags) or @syriaca-tags!='#syriaca-headword') and starts-with(@xml:lang, 'syr')]" mode="list">
     <xsl:with-param name="idx" select="$idx"/>
     <xsl:sort lang="syr" select="."/>
    </xsl:apply-templates>
    <xsl:apply-templates select="t:placeName[starts-with(@xml:lang, 'ar')]" mode="list">
     <xsl:with-param name="idx" select="$idx"/>
     <xsl:sort lang="ar" select="."/>     
    </xsl:apply-templates>
    <xsl:apply-templates select="t:placeName[(not(@syriaca-tags) or @syriaca-tags!='#syriaca-headword') and not(starts-with(@xml:lang, 'syr') or starts-with(@xml:lang, 'ar'))]" mode="list">
     <xsl:with-param name="idx" select="$idx"/>
     <xsl:sort collation="mixed" select="."/>
    </xsl:apply-templates>
   </ul>
  </div>
  <div id="type">
   <h3>Place Type</h3>
   <ul>
    <li><xsl:value-of select="$thistype"/></li>
   </ul>
  </div>
  <div id="location">
   <h3>Location</h3>
   <ul><xsl:apply-templates select="t:location"/></ul>
  </div>
  <div id="description">
   <h3>Description</h3>
   <ul>
    <xsl:for-each-group select="t:desc" group-by="if (contains(@xml:lang, '-')=true()) then substring-before(@xml:lang, '-') else @xml:lang">
     <xsl:sort collation="languages" select="if (contains(@xml:lang, '-')=true()) then substring-before(@xml:lang, '-') else @xml:lang"/>
     <xsl:for-each select="current-group()">
      <xsl:sort lang="{current-grouping-key()}" select="normalize-space(.)"/>
      <xsl:apply-templates select="."/>
     </xsl:for-each>
    </xsl:for-each-group>
   </ul>
  </div>
  <xsl:if test="$idx/descendant::t:location[@type='geopolitical']/t:*[@ref=$thisuri]">
   <div id="contents">
    <h3>Contains</h3>
    <ul>
     <xsl:for-each select="$idx/descendant::t:region[@ref=$thisuri]/ancestor::t:place">
      <xsl:sort collation="mixed" select="t:placeName[@xml:lang='en'][1]/@reg"/>
      <li><a href="{t:idno[@type='placeID']}.html"><xsl:call-template name="place-title-std"/></a></li>
     </xsl:for-each>
    </ul>
   </div>
  </xsl:if>
  <div id="sources">
   <h3>Sources</h3>
   <ul>
    <xsl:apply-templates select="t:bibl" mode="footnote"/>
   </ul>
  </div>
 </xsl:template>
 
 <xsl:template match="t:location[@type='geopolitical' or @type='relative']">
  <li><xsl:apply-templates/>
  <xsl:call-template name="do-refs"/></li>
 </xsl:template>
 
 <xsl:template match="t:location[@type='gps' and t:geo]">
  <li>Coordinates: <xsl:value-of select="t:geo"/><xsl:call-template name="do-refs"/></li>
 </xsl:template>
 
 <xsl:template match="t:offset | t:measure">
  <xsl:apply-templates select="." mode="out-normal"/>
 </xsl:template>
 
 <xsl:template match="t:desc[not(starts-with(@xml:id, 'abstract-en'))]">
  <li>
   <xsl:call-template name="langattr"/>
   <xsl:apply-templates/>
  </li>
 </xsl:template>
 
 <xsl:template match="t:quote">
  <xsl:text>“</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>”</xsl:text>
  <xsl:call-template name="do-refs"/>
 </xsl:template>
 
 <xsl:template match="t:placeName | t:region | t:settlement">
  <xsl:choose>
   <xsl:when test="@ref">
    <xsl:choose>
     <xsl:when test="starts-with(@ref, $uribase)">
      <a class="placeName" href="{substring-after(@ref, $uribase)}.html">
       <xsl:call-template name="langattr"/>
       <xsl:apply-templates mode="cleanout"/></a>
     </xsl:when>
     <xsl:otherwise>
      <a class="placeName" href="{@ref}">
       <xsl:call-template name="langattr"/>
       <xsl:apply-templates mode="cleanout"/></a>
      <xsl:call-template name="log">
       <xsl:with-param name="msg">ref attribute value (<xsl:value-of select="@ref"/>) on element didn't start with '<xsl:value-of select="$uribase"/>' so just linked to it as is</xsl:with-param>
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
    <span class="placeName">
     <xsl:call-template name="langattr"/>
     <xsl:apply-templates mode="cleanout"/>
    </span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="t:placeName"  mode="list">
  <xsl:param name="idx"/>
  <li dir="ltr">
   
   <!-- write out the placename itself, with appropriate language and directionality indicia -->
   <span class="placeName">
    <xsl:call-template name="langattr"/>
    <xsl:apply-templates select="." mode="out-normal"/>
   </span>
      
   <xsl:call-template name="do-refs"/>
  </li>
 </xsl:template>
 
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of the licence element in the tei header
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
 <xsl:template match="t:licence">
  <xsl:if test="@target">
   <xsl:variable name="licenserev" select="tokenize(@target, '/')[last()-1]"/>
   <xsl:variable name="licensetype" select="tokenize(substring-before(@target, $licenserev), '/')[last()-1]"/>
   <a rel="license" href="{@target}"><img
    alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/{$licensetype}/{$licenserev}/80x15.png"
   /></a>
  </xsl:if>
  <xsl:apply-templates />
 </xsl:template>
 
 
 
 <xsl:template name="do-refs">
  <!-- credit sources for data -->
  <xsl:if test="@source">
   <xsl:variable name="root" select="ancestor::t:TEI" as="node()"/>
   <xsl:variable name="biblids" select="tokenize(@source, ' ')"/>
   <xsl:variable name="last" select="$biblids[last()]"/>
   <bdi class="footnote-refs" dir="ltr">
    <xsl:if test="ancestor::t:*[@xml:lang][1][@xml:lang!='en']">
     <xsl:attribute name="lang">en</xsl:attribute>
     <xsl:attribute name="xml:lang">en</xsl:attribute>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:for-each select="$biblids">
     <xsl:variable name="sought" select="substring-after(., '#')"/>
     <xsl:apply-templates select="$root/descendant::t:bibl[@xml:id=$sought]" mode="footnote-ref">
      <xsl:with-param name="footnote-number" select="substring-after(., '-')"/>
     </xsl:apply-templates>
     <xsl:if test="count($biblids) &gt; 1 and . != $last">
      <xsl:text>,</xsl:text>
     </xsl:if>
    </xsl:for-each>
   </bdi>
  </xsl:if>
 </xsl:template>

 <xsl:template name="get-headword-ele" as="element()*">
  <xsl:choose>
   <xsl:when test="./descendant-or-self::t:listPlace/t:place/t:placeName[@syriaca-tags='#syriaca-headword']">
    <xsl:sequence select="./descendant-or-self::t:listPlace/t:place/t:placeName[@syriaca-tags='#syriaca-headword']"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>WARNING: placepage.xsl unable to find placeName tagged with '#syriaca-headword' in <xsl:value-of select="document-uri(.)"/></xsl:message>
    <xsl:sequence select="./descendant-or-self::t:listPlace/t:place/t:placeName[1]"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template name="get-description-ele" as="element()*">
  <xsl:choose>
   <xsl:when test="./descendant-or-self::t:listPlace/t:place/t:desc[starts-with(@xml:id, 'abstract-en')]">
    <xsl:sequence select="./descendant-or-self::t:listPlace/t:place/t:desc[starts-with(@xml:id, 'abstract-en')]"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>WARNING: placepage.xsl unable to find desc with id that starts with 'abstract-en' in <xsl:value-of select="document-uri(.)"/></xsl:message>
    <xsl:sequence select="./descendant-or-self::t:listPlace/t:place/t:desc[1]"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template match="t:placeName[local-name(..)='desc']" mode="cleanout">
  <xsl:apply-templates select="."/>
 </xsl:template>
 
 <xsl:template match="text()" mode="cleanout">
  <xsl:value-of select="."/>
 </xsl:template>
 
 <xsl:template match="t:*" mode="cleanout">
  <xsl:apply-templates mode="cleanout"/>
  <xsl:call-template name="log">
   <xsl:with-param name="msg">
    <xsl:text>untrapped element for mode="cleanout" passed through</xsl:text>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->
 <!-- |||| match=t:*: suppress all TEI elements not otherwise handled -->
 <!-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| -->
 
 <xsl:template match="t:*">
  <xsl:call-template name="log">
   <xsl:with-param name="msg">
    <xsl:text>untrapped element suppressed</xsl:text>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>
 
 
</xsl:stylesheet>
