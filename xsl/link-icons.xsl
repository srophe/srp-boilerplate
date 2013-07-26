<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="xs t"
  version="2.0">
  
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
       link-icons.xsl
       
       This XSLT is meant to be called from placepage.xsl in order to 
       generate "chicklet" link icons to e.g. Pleiades and Wikipedia. 
       
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
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     template: name=link-icons
     emit the link icons div and its contents
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template name="link-icons">
    <xsl:variable name="placenum" select="t:idno[@type='placeID'][1]"/>
    
    <div id="link-icons">
      
      <!-- Pleiades links -->
      <xsl:for-each select="t:idno[@type='Pleiades']">
        <a href="{.}"><img src="../img/circle-pi-25.png" alt="Image of the Greek letter pi in blue; small icon of the Pleiades project" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} in Pleiades"/></a>
      </xsl:for-each>
      
      <!-- Wikipedia links -->
      <xsl:for-each select="t:idno[@type='Wikipedia']">
        <a href="{.}"><img src="../img/Wikipedia-25.png" alt="The Wikipedia icon" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} in Wikipedia"/></a>
      </xsl:for-each>
      
      <!-- Google map links -->
      <xsl:for-each select="t:location[@type='gps']/t:geo">
        <a href="https://maps.google.com/maps?f=q&amp;hl=en&amp;q={$base}{$placeslevel}{$placenum}-atom.xml&amp;z=4"><img src="../img/gmaps-25.png" alt="The Google Maps icon" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} on Google Maps"/></a>
      </xsl:for-each>
      
      <!-- TEI source link -->
      <a href="{$xmlbase}{$placenum}.xml" rel="alternate" type="application/tei+xml"><img src="../img/tei-25.png" alt="The Text Encoding Initiative icon" title="click to view the TEI XML source data for this place"/></a>
      
      <!-- Atom format link -->
      <a href="{$base}places/{$placenum}-atom.xml" rel="alternate" type="application/atom+xml"><img src="../img/atom-25.png" alt="The Atom format icon" title="click to view this data in Atom XML format"/></a>
      
    </div>
  </xsl:template>
  
</xsl:stylesheet>