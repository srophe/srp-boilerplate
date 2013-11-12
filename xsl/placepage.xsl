<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0" 
 xmlns:s="http://syriaca.org"
 xmlns:saxon="http://saxon.sf.net/" 
 xmlns:x="http://www.w3.org/1999/xhtml"
 xmlns:local="http://syriaca.org/ns"
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
 <xsl:import href="json-uri.xsl"/>
 <xsl:import href="langattr.xsl"/>
 <xsl:import href="link-icons.xsl"/>
 <xsl:import href="log.xsl"/>
 <xsl:import href="normalization.xsl"/>
 <xsl:import href="place-title-std.xsl"/>
 

 <!-- =================================================================== -->
 <!-- set output so we get (mostly) indented HTML -->
 <!-- =================================================================== -->

 <xsl:output name="html" encoding="UTF-8" method="xhtml" indent="no"/>

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
 <xsl:param name="editorssourcepath">../../syriaca/editors.xml</xsl:param>
 <xsl:param name="editoruriprefix">http://syriaca.org/editors.xml#</xsl:param>

 <xsl:variable name="idxquery"><xsl:value-of select="$idxdir"/>index.xml</xsl:variable>
 <xsl:variable name="editorssourcedoc" select="document($editorssourcepath)"/>

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
        <xsl:with-param name="sourcedoc" select="$sourcedoc"/>
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
           <xsl:apply-templates select="t:desc[@type='abstract' or starts-with(@xml:id, 'abstract-en')][1]" mode="abstract"/>
           
           <!-- The map widget -->
           <xsl:if test="t:location[@type='gps' and t:geo]">
            <div id="map"></div>
           </xsl:if>
           
    
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
  <xsl:if test="$idx/descendant::t:location[@type='nested']/t:*[@ref=$thisuri]">
   <div id="contents">
    <h3>Contains</h3>
    <ul>
     <xsl:for-each select="$idx/descendant::t:*[@ref=$thisuri]/ancestor::t:place">
      <xsl:sort collation="mixed" select="t:placeName[@xml:lang='en'][1]/@reg"/>
      <li><a href="{t:idno[@type='placeID']}.html"><xsl:call-template name="place-title-std"/></a></li>
     </xsl:for-each>
    </ul>
   </div>
  </xsl:if>
  
  <!-- Events without @type="attestation" -->
  <xsl:if test="t:event[not(@type='attestation')]">
   <div id="event">
    <h3>Event<xsl:if test="count(t:event[not(@type='attestation')]) &gt; 1">s</xsl:if></h3>
    <ul>
     <xsl:apply-templates select="t:event[not(@type='attestation')]" mode="event"/>
    </ul>
   </div>   
  </xsl:if> 
  
  <!-- Events with @type="attestation" -->
  <xsl:if test="t:event[@type='attestation']">
   <div id="event">
    <h3>Attestation<xsl:if test="count(t:event[@type='attestation']) &gt; 1">s</xsl:if></h3>
    <ul>
     <!-- Sorts events on dates, checks first for @notBefore and if not present, uses @when -->
     <xsl:for-each select="t:event[@type='attestation']">
      <xsl:sort select="if(exists(@notBefore)) then @notBefore else @when"/>
      <xsl:apply-templates select="." mode="event"/>    
     </xsl:for-each>
    </ul>
   </div>   
  </xsl:if> 
  <xsl:if test="t:state[@type='confession']">
   <div id="description">
    <h3>Known Religious Communities</h3>
    <p style="font-size:small;"><em>This list is not necessarily exhaustive, and the order does not represent importance or proportion of the population.  Instead, the list only represents groups for which Syriac.org has source(s) and dates.</em></p>
    <xsl:call-template name="confessions"/>
   </div>   
  </xsl:if>
  
  <!-- Build related places and people if they exist -->
  <xsl:if test="../t:relation">
   <div id="relations">
    <h3>Related Places</h3>
    <ul>
     <xsl:apply-templates select="../t:relation"/>
    </ul>
   </div>
  </xsl:if>
  
  <!-- Build errata -->
  <xsl:if test="t:note[@type='errata' or @type='deprecation']">
   <div id="errata">
    <h3>Errata</h3>
    <ul>
     <xsl:apply-templates select="t:note[@type='errata']| t:note[@type='deprecation']"/>
    </ul>
   </div>
  </xsl:if> 
  <!-- Add see also -->
  <!-- NOTE: does not work, as link icons relys on index.xml data -->
  <xsl:call-template name="link-icons-text"/>
  
  <!-- Sources -->
  <div id="sources">
   <h3>Sources</h3>
   <p><small>Any information without attribution has been created following the Syriaca.org <a href="http://syriaca.org/documentation/">editorial guidelines</a>.</small></p>
   <ul>
    <xsl:apply-templates select="t:bibl" mode="footnote"/>
   </ul>
  </div>
 
 </xsl:template>
 
 <!-- Template to print out events -->
 <xsl:template match="t:event" mode="event">
  <li> 
   <!-- There are several desc templates, this 'plain' mode ouputs all the child elements with no p or li tags -->
   <xsl:apply-templates select="child::*" mode="plain"/>
   <!-- Adds dates if available -->
   <xsl:sequence select="local:do-dates(.)"/>
   <!-- Adds footnotes if available -->
   <xsl:if test="@source"><xsl:sequence select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/></xsl:if>
  </li>
 </xsl:template>
 <!-- Named template to handle nested confessions -->
 <xsl:template name="confessions">
  <!-- Variable stores all confessions from confessions.xml -->
  <xsl:variable name="confessions" select="document('../../syriaca/confessions.xml')//t:body/t:list"/>
  <xsl:variable name="place-data" select="."/>
  <!-- Variable to store the value of the confessions of current place-->
  <xsl:variable name="current-confessions">
   <xsl:for-each select="t:state[@type='confession']">
    <xsl:variable name="id" select="substring-after(@ref,'#')"/>
    <!-- outputs current confessions as a space seperated list -->
    <xsl:value-of select="concat($confessions//t:item[@xml:id = $id]/@xml:id,' ')"/>
   </xsl:for-each>   
  </xsl:variable>
  <!-- Works through the tree structure in the confessions.xml to output only the relevant confessions -->
  <xsl:for-each select="$confessions">
   <ul>
    <!-- Checks for top level confessions that may have a match or a descendant with a match, supresses any that do not -->
    <xsl:if test="descendant-or-self::t:item[contains($current-confessions,@xml:id)]">
     <!-- Goes through each item to check for a match or a child match -->
     <xsl:for-each select="t:item">
      <xsl:if test="descendant-or-self::t:item[contains($current-confessions,@xml:id)]">
       <!-- output current level -->
       <li>
        <!-- print label -->
        <xsl:apply-templates select="t:label" mode="confessions"/>
        <!-- build dates based on attestation information -->
        <xsl:call-template name="confession-dates">
         <xsl:with-param name="place-data" select="$place-data"/>
         <xsl:with-param name="confession-id" select="@xml:id"/>
        </xsl:call-template>
        <!-- check next level -->
        <xsl:if test="descendant::t:item[contains($current-confessions,@xml:id)]">
         <ul>
          <xsl:for-each select="child::*/t:item">
           <xsl:if test="descendant-or-self::t:item[contains($current-confessions,@xml:id)]">
            <li>
             <xsl:apply-templates select="t:label" mode="confessions"/>
             <!-- build dates based on attestation information -->
             <xsl:call-template name="confession-dates">
              <xsl:with-param name="place-data" select="$place-data"/>
              <xsl:with-param name="confession-id" select="@xml:id"/>
             </xsl:call-template>
             <xsl:if test="descendant::t:item[contains($current-confessions,@xml:id)]">
              <ul>
               <xsl:for-each select="child::*/t:item">
                <xsl:if test="descendant-or-self::t:item[contains($current-confessions,@xml:id)]">
                 <li>
                  <xsl:apply-templates select="t:label" mode="confessions"/>
                  <!-- build dates based on attestation information -->
                  <xsl:call-template name="confession-dates">
                   <xsl:with-param name="place-data" select="$place-data"/>
                   <xsl:with-param name="confession-id" select="@xml:id"/>
                  </xsl:call-template>
                  <xsl:if test="descendant::t:item[contains($current-confessions,@xml:id)]">
                   <ul>
                    <xsl:for-each select="child::*/t:item">
                     <xsl:if test="descendant-or-self::t:item[contains($current-confessions,@xml:id)]">
                      <li>
                       <xsl:apply-templates select="t:label" mode="confessions"/>
                       <!-- build dates based on attestation information -->
                       <xsl:call-template name="confession-dates">
                        <xsl:with-param name="place-data" select="$place-data"/>
                        <xsl:with-param name="confession-id" select="@xml:id"/>
                       </xsl:call-template>
                       
                      </li>
                     </xsl:if>
                    </xsl:for-each>
                   </ul>
                  </xsl:if>
                 </li>
                </xsl:if>
               </xsl:for-each>
              </ul>
             </xsl:if>
            </li>
           </xsl:if>
          </xsl:for-each>
         </ul>
        </xsl:if>
       </li>
      </xsl:if>
     </xsl:for-each>
    </xsl:if>
   </ul>
  </xsl:for-each>
 </xsl:template>
 
 <!-- Create labels for confessions -->
 <xsl:template match="t:label" mode="confessions">
  <xsl:value-of select="."/>
 </xsl:template>
 
 <!-- Named template to build confession dates bassed on attestation dates -->
 <xsl:template name="confession-dates">
  <!-- param passes place data for processing -->
  <xsl:param name="place-data"/>
  <!-- confession id -->
  <xsl:param name="confession-id"/>
  <!-- find confessions in place data using confession-id -->
  <xsl:if test="$place-data//t:state[@type='confession' and substring-after(@ref,'#') = $confession-id]">
   <xsl:for-each select="$place-data//t:state[@type='confession' and substring-after(@ref,'#') = $confession-id]">
    <!-- Build ref id to find attestations -->
    <xsl:variable name="ref-id" select="concat('#',@xml:id)"/>
    <!-- Find attestations with matching confession-id in link/@target  -->
    <xsl:choose>
     <xsl:when test="//t:event[@type='attestation' and child::*[contains(@target,$ref-id)] ]">
      <!-- If there is a match process dates -->
      (<xsl:for-each select="//t:event[@type='attestation' and t:link[contains(@target,$ref-id)] ]">
       <!-- Sort dates -->
       <xsl:sort select="if(exists(@notBefore)) then @notBefore else @when"/>
       <xsl:choose>
        <!-- process @when dates use, local:trim-date function to trim 0 from dates-->
        <xsl:when test="./@when"> 
         <xsl:choose>
          <xsl:when test="position() = 1">attested as early as <xsl:value-of select="local:trim-date(@when)"/></xsl:when>
          <xsl:when test="position()=last()">, as late as <xsl:value-of select="local:trim-date(@when)"/></xsl:when>
          <xsl:otherwise/>
         </xsl:choose>
        </xsl:when>
        <!-- process @notBefore dates -->
        <xsl:when test="./@notBefore">
         <xsl:choose>
          <xsl:when test="position() = 1">
           attested around <xsl:value-of select="local:trim-date(@notBefore)"/>
          </xsl:when>
          <xsl:otherwise>
           attested as early as <xsl:value-of select="local:trim-date(@notBefore)"/>        
          </xsl:otherwise>
         </xsl:choose>
        </xsl:when>
        <!-- process @notAfter dates -->
        <xsl:when test="./@notAfter"><xsl:if test="./@notBefore">, </xsl:if>as late as <xsl:value-of select="local:trim-date(@notAfter)"/></xsl:when>
        <xsl:otherwise/>
       </xsl:choose>
      </xsl:for-each>)
     </xsl:when>
     <!-- If not attestation information -->
     <xsl:otherwise> (no attestations yet recorded)</xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>
 
 <!-- Template for related people and places -->
 <xsl:template match="t:relation">
  <!-- NOTE: there does not seem to be anyway to tell which placeName to use, script assumes first placeName is canonical  -->
  <!-- Substring # out of place id -->
  <xsl:variable name="passive-id" select="substring(@passive,2)"/>
  <!-- Find place name based on place id -->
  <xsl:variable name="passive-name" select="//t:place[@xml:id = $passive-id]/t:placeName[1]"/>
  <!-- Build date output, uses local function do-dates -->
  <xsl:variable name="do-dates" select="local:do-dates(.)"/>
  <!-- Name string for use within tokenize function -->
  <xsl:variable name="name-string">
   <xsl:choose>
    <!-- Differentiates between resided and other name attributes -->
    <xsl:when test="@name='resided'">
     <xsl:value-of select="@name"/> in 
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="@name"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <!-- Footnote string for use within tokenize function -->
  <xsl:variable name="footnote" select="@source"/>
  <!-- Language attribute used by do-refs function -->
  <xsl:variable name="lang" select="ancestor::t:*[@xml:lang][1]"/>
  <!-- Uses tokenize to split out multiple active references -->
  <xsl:for-each select="tokenize(@active,' ')">
   <!-- Find active name using document() to grab name from actual xml file -->
   <!-- Builds filename -->
   <xsl:variable name="filename" select="tokenize(., '/')[last()]"/>
   <xsl:variable name="active-name">
     <xsl:choose>
      <!-- Builds path to place and people xml documents -->
      <xsl:when test="contains(.,'place/')">
       <!-- Grabs place name data from xml document -->
       <xsl:value-of select="document(concat($sourcedir, $filename,'.xml'))/descendant::t:place[1]/t:placeName[1]"/>
      </xsl:when>
      <xsl:when test="contains(.,'person/')">
       <!-- Grabs person name data from xml document -->
       <xsl:value-of select="document(concat('../../persons/xml/tei/',$filename,'.xml'))/descendant::t:person[1]/t:persName[1]/descendant::*"/>
      </xsl:when>
     </xsl:choose>
   </xsl:variable>
   <li>
    <!--NOTE:  href is currently pointing to the value in the relation element, files do not currently exist at this location  -->
    <a href="{concat($filename,'.html')}"><xsl:value-of select="$active-name"/></a><xsl:text> </xsl:text>
    <xsl:value-of select="$name-string"/><xsl:text> </xsl:text>
    <xsl:value-of select="$passive-name"/><xsl:text> </xsl:text>
    <xsl:value-of select="$do-dates"/><xsl:text> </xsl:text>
    <!-- If footnotes exist call function do-refs pass footnotes and language variables to function -->
    <xsl:if test="$footnote"><xsl:sequence select="local:do-refs($footnote,$lang)"/></xsl:if>
   </li>
  </xsl:for-each>
 </xsl:template>
 
 <xsl:template match="t:location[@type='geopolitical' or @type='relative']">
  <li><xsl:apply-templates/>
   <xsl:sequence select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/></li>
 </xsl:template>
 
 
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of 'nested' locations 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
 <xsl:template match="t:location[@type='nested']">
  <li>Within <xsl:for-each select="t:*">
   <xsl:apply-templates select="."/>
   <xsl:if test="following-sibling::t:*">
    <xsl:text> within </xsl:text>
   </xsl:if>
  </xsl:for-each>
  <xsl:text>.</xsl:text>
   <xsl:apply-templates select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/>
  </li>
 </xsl:template>
 
 <xsl:template match="t:location[@type='gps' and t:geo]">
  <li>Coordinates: <xsl:value-of select="t:geo"/><xsl:sequence select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/></li>
 </xsl:template>
 
 <xsl:template match="t:offset | t:measure">
  <xsl:apply-templates select="." mode="out-normal"/>
 </xsl:template>
 
 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     Description templates 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 <!-- Descriptions without list elements or paragraph elements -->
 <xsl:template match="t:desc" mode="plain">
   <xsl:apply-templates/>
 </xsl:template>
 <xsl:template match="t:label" mode="plain">
  <xsl:apply-templates/>
 </xsl:template>
 <!-- Descriptions for place abstract  added template for abstracts, handles quotes and references.-->
 <xsl:template match="t:desc[not(starts-with(@xml:id, 'abstract-en'))]" mode="abstract">
  <p>
   <xsl:apply-templates/>
  </p>
 </xsl:template>
 <!-- General descriptions within the body of the place element, uses lists -->
 <xsl:template match="t:desc[not(starts-with(@xml:id, 'abstract-en'))]">
  <li>
   <xsl:call-template name="langattr"/>
   <xsl:apply-templates/>
  </li>
 </xsl:template>
 
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of a listBibl element 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
 <xsl:template match="t:listBibl">
  <ul class="listBibl">
   <xsl:for-each select="t:bibl">
    <li><xsl:apply-templates select="." mode="biblist"/><xsl:text>.</xsl:text></li>
   </xsl:for-each>
  </ul>
 </xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of a note element 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
 <xsl:template match="t:note">
  <xsl:variable name="xmlid" select="@xml:id"/>
  <xsl:choose>
   <!-- Adds definition list for depreciated names -->
   <xsl:when test="@type='deprecation'">
    <dl>
     <dt>
      <xsl:apply-templates select="../t:link[contains(@target,$xmlid)]"/>
     </dt>
     <dd>
      <xsl:apply-templates/>
      <!-- Check for ending punctuation, if none, add . -->
      <xsl:if test="not(ends-with(.,'.'))">
       <xsl:text>.</xsl:text>
      </xsl:if>
     </dd>
    </dl>
   </xsl:when>
   <xsl:otherwise>
    <p>
     <xsl:apply-templates/>
     <!-- Check for ending punctuation, if none, add . -->
     <xsl:if test="not(ends-with(.,'.'))">
      <xsl:text>.</xsl:text>
     </xsl:if>
    </p>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
<!-- Handles t:link elements for deperciated notes, pulls value from matching element, output element and footnotes -->
 <xsl:template match="t:link">
  <xsl:variable name="elementID" select="substring-after(substring-before(@target,' '),'#')"/>
  <xsl:for-each select="/descendant-or-self::*[@xml:id=$elementID]">
   <xsl:apply-templates select="."/>
   <!-- NOTE: position last is not working? -->
<!--   <xsl:if test="not(../preceding-sibling::*[@xml:id=$elementID])"><xsl:text>, </xsl:text></xsl:if>-->
   <xsl:text> </xsl:text>
  </xsl:for-each>
 </xsl:template>

 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of a p element 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

 <xsl:template match="t:p">
  <p>
   <xsl:call-template name="langattr"/>
   <xsl:apply-templates/>
  </p>
 </xsl:template>
 
 
 <xsl:template match="t:quote">
  <xsl:text>“</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>”</xsl:text>
  <xsl:sequence select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/>
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
    <!-- NOTE: added footnotes to all placeNames if available. Uses local do-refs function -->
    <span class="placeName">
     <xsl:call-template name="langattr"/>
     <xsl:apply-templates mode="cleanout"/>
     <xsl:sequence select="local:do-refs(@source,@xml:lang)"/>
    </span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="t:placeName"  mode="list">
  <xsl:param name="idx"/>
  <xsl:variable name="nameID" select="concat('#',@xml:id)"/>
  <xsl:choose>
   <!-- Suppress depreciated names here -->
   <xsl:when test="/descendant-or-self::t:link[substring-before(@target,' ') = $nameID][contains(@target,'deprecation')]"/>
   <!-- Output all other names -->
   <xsl:otherwise>
    <li dir="ltr">
     <!-- write out the placename itself, with appropriate language and directionality indicia -->
     <span class="placeName">
      <xsl:call-template name="langattr"/>
      <xsl:apply-templates select="." mode="out-normal"/>
     </span>
     <xsl:sequence select="local:do-refs(@source,ancestor::t:*[@xml:lang][1])"/>
    </li>
   </xsl:otherwise>
  </xsl:choose>
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
 
 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle standard output of the ref element
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
<xsl:template match="t:ref">
 <a href="{@target}"><xsl:apply-templates/></a>
</xsl:template> 
 
 <!-- NOTE: depreciated
  Use local function local:do-refs(element,lang) in normalization.xsl
 -->
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
 
 <!-- NOTE: where is this used? Seems to be an issue with syrac text-->
 
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