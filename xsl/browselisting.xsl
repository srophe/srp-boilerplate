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
       browselisting.xsl
       
       This XSLT loops through all places listed in the input xml index
       file and attempts to construct an browse page for the Syriac 
       Gazetteer. It makes 3 passes through the index file, filtering and
       sorting content so that it can make three browse lists: one sorted
       by English-language placenames, another sorted by Syriac-language
       placenames, and a third sorted by place number.
       
       parameters:
        + sourcedir: path to source directory containing input xml files
        + destdir: path to destination directory for the index file
        + description: description to use in HTML meta tag
        + description-page: description to use in body HTML
        + name-app: name of site for use in page headers
        + name-page-short: short name of browse page for use in head/title and
          other short contexts
        + name-page-long: full name of browse page for use on the page itself
        + copyright-holders: names of copyright holders for use in footer
        + copyright-year: copyright years for use in footer
       
       assumptions and dependencies:
        + transform has been tested with Saxon PE 9.4.0.6 with initial
          template (-it) option set to "do-list" (i.e., there is no 
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
 
 
 <xsl:import href="boilerplate-head.xsl"/>
 <xsl:import href="boilerplate-bottom.xsl"/>
 <xsl:import href="boilerplate-badbrowser.xsl"/>
 <xsl:import href="boilerplate-nav.xsl"/>
 <xsl:import href="boilerplate-footer.xsl"/>
 <xsl:import href="collations.xsl"/>
 <xsl:import href="langattr.xsl"/>
 <xsl:import href="log.xsl"/>
 <xsl:import href="normalization.xsl"/>
 

 <xsl:output encoding="UTF-8" method="html" indent="yes"/>

 <xsl:param name="sourcedir">../places/</xsl:param>
 <xsl:param name="destdir">./places/</xsl:param>
 <xsl:param name="normalization">NFKC</xsl:param>
 <xsl:param name="description">Listings of places registered in the Syriac Gazetteer.</xsl:param>
 <xsl:param name="description-page">Listings of places registered in the Syriac Gazetteer.</xsl:param>
 <xsl:param name="name-app">The Syriac Gazetteer</xsl:param>
 <xsl:param name="name-page-short">Browse</xsl:param>
 <xsl:param name="name-page-long">Browse Lists</xsl:param>
 <xsl:param name="copyright-holders">CHANGE THE COPYRIGHT HOLDERS PARAMETER</xsl:param>
 <xsl:param name="copyright-year">2013</xsl:param>

 <xsl:variable name="idxquery"><xsl:value-of select="$sourcedir"/>index.xml</xsl:variable>
 
 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-list
     
     top-level logic and instructions for creating the browse listing page
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --> 
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
 
 <!-- start first-level named templates, called from do-index --> 
 

 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-list-english
     
     loops through the contents of the index.xml file, filtering out only
     places that have at least one english placename in them and then
     sorting according to the custom "mixed" collation defined for SRP
     in order to handle extended Latin characters in line with those
     Latin characters without diacriticals, etc. Note that the regularized
     form assumed to be housed in the @reg attribute of the placename
     is used for the sort.
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 <xsl:template name="do-list-english">
 <ul>
  <xsl:for-each select="document($idxquery)/descendant-or-self::t:place[t:placeName[@xml:lang='en']]">
   <xsl:sort collation="mixed" select="./t:placeName[@xml:lang='en'][1]/@reg"/>
   <xsl:message>foo</xsl:message>
   <xsl:variable name="placenum" select="t:idno[@type='placeID']"/>
   <xsl:choose>
    <xsl:when test="matches($placenum, '^\d+$')">
     <xsl:variable name="htmlurl">
      <xsl:value-of select="$destdir"/>
      <xsl:value-of select="$placenum"/>
      <xsl:text>.html</xsl:text>
     </xsl:variable>
     <li>
      <a href="{$htmlurl}">
       <xsl:apply-templates select="./t:placeName[@xml:lang='en'][1]"/>
       <bdi dir="ltr" xml:lang="en" lang="en">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>)</xsl:text>
       </bdi>       
       <xsl:if test="./t:placeName[@xml:lang='syr']">
       <bdi dir="ltr"><xsl:text> — </xsl:text></bdi>
       <xsl:apply-templates select="t:placeName[@xml:lang='syr']"/>
       </xsl:if>
      </a>
     </li>
    </xsl:when>
   </xsl:choose>
  </xsl:for-each>
 </ul>
</xsl:template>
 
 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-list-syriac
     
     loops through the contents of the index.xml file, filtering out only
     places that have at least one syriac placename in them and then
     sorting according to whatever collation the XSL processor assumes is
     good for the 'syr' language tag. Note that the regularized
     form assumed to be housed in the @reg attribute of the placename
     is used for the sort.
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 <xsl:template name="do-list-syriac">
  <ul>
   <xsl:for-each select="document($idxquery)/descendant-or-self::t:place[t:placeName[@xml:lang='syr']]">
    <xsl:sort lang="syr" select="./t:placeName[@xml:lang='syr'][1]/@reg"/>
    <xsl:variable name="placenum" select="t:idno[@type='placeID']"/>
    <xsl:choose>
     <xsl:when test="matches($placenum, '^\d+$')">
      <xsl:variable name="htmlurl">
       <xsl:value-of select="$destdir"/>
       <xsl:value-of select="$placenum"/>
       <xsl:text>.html</xsl:text>
      </xsl:variable>
      <li>
       <a href="{$htmlurl}">
        <xsl:apply-templates select="t:placeName[@xml:lang='syr'][1]"/>
        <xsl:if test="t:placeName[@xml:lang='en']">
         <bdi dir="rtl"><xsl:text> — </xsl:text></bdi>
         <xsl:apply-templates select="t:placeName[@xml:lang='en'][1]"/>
        </xsl:if>
       </a>
      </li>
     </xsl:when>
    </xsl:choose>
   </xsl:for-each>
  </ul>
 </xsl:template>

 <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-list-number
     
     loops through the contents of the index.xml file, 
     sorting according to placeID for each place
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 <xsl:template name="do-list-number">
  <!-- write a sorted, linked list of all the place titles in the gazetteer -->
  <ul>
   <xsl:for-each select="document($idxquery)/descendant-or-self::t:place">
    <xsl:sort select="xs:integer(t:idno[@type='placeID'])"/>
    <xsl:variable name="placenum" select="t:idno[@type='placeID']"/>
    <xsl:choose>
     <xsl:when test="matches($placenum, '^\d+$')">
      <xsl:variable name="htmlurl">
       <xsl:value-of select="$destdir"/>
       <xsl:value-of select="$placenum"/>
       <xsl:text>.html</xsl:text>
      </xsl:variable>
      <li>
       <a href="{$htmlurl}"><xsl:value-of select="$placenum"/><xsl:text>: </xsl:text>
        <xsl:apply-templates select="t:placeName[@xml:lang='en'][1]"/>
        <bdi dir="ltr" xml:lang="en" lang="en">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="@type"/>
         <xsl:text>)</xsl:text>
        </bdi>
        <xsl:if test="t:placeName[@xml:lang='syr']">
         <bdi dir="ltr"><xsl:text> — </xsl:text></bdi>
         <xsl:apply-templates select="t:placeName[@xml:lang='syr']"/>
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
 
</xsl:stylesheet>
