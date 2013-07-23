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
       citation.xsl
       
       This XSLT provides templates for output of citation guidance. 
       
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
  
  <xsl:variable name="maxauthorsfootnote">2</xsl:variable>
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     template: match=t:titleStmt mode=cite-foot
     
     generate a footnote for the matched titleStmt entry
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:titleStmt" mode="cite-foot">
    <xsl:call-template name="cite-foot-pers">
      <xsl:with-param name="perss" select="t:editor[@role='creator']"/>
    </xsl:call-template>
    <xsl:text>, </xsl:text>
    <xsl:text>“</xsl:text>
    <xsl:call-template name="place-title-std">
      <xsl:with-param name="place" select="ancestor::t:TEI/descendant::t:place[1]"/>
    </xsl:call-template>
    <xsl:text>”</xsl:text>
    <xsl:text> in </xsl:text><span class="title">The Syriac Gazetteer</span><xsl:text>, eds. </xsl:text>
  </xsl:template>
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     template: cite-foot-creators
     
     handle creators for citation guidance of type footnote; exploit 
     general bibliographic template logic where possible
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template name="cite-foot-pers">
    <xsl:param name="perss"/>
    <xsl:variable name="ccount" select="count($perss)"/>
    <xsl:choose>
      <xsl:when test="$ccount=1 or $ccount &gt; $maxauthorsfootnote">
        <xsl:apply-templates select="$perss[1]" mode="footnote"/>
        <xsl:text> et al.</xsl:text>
      </xsl:when>
      <xsl:when test="$ccount = 2">
        <xsl:apply-templates select="$perss[1]" mode="footnote"/>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="$perss[2]" mode="footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$perss[position() &lt; $maxauthorsfootnote+1]">
          <xsl:choose>
            <xsl:when test="position() = $maxauthorsfootnote">
              <xsl:text> and </xsl:text>
            </xsl:when>
            <xsl:when test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates select="." mode="footnote"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  
</xsl:stylesheet>