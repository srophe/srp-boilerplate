<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
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
       log.xsl
       
       This file contains a named template that can be used to provide 
       standardized logging to output context (as an xml comment) and to 
       the transform engine's log output (via xsl:message).
       
       parameters:
        + withFilePathContext: 'yes' means: report the path context of the 
          file being processed
        + withFileContext: 'yes' means: report the filename of the file 
          being processed
        + withElementContext: 'yes' means: report the local name of the
          context element
        + msg: text string to be output as log message
       
       assumptions and dependencies:
        + transform has been tested with Saxon PE 9.4.0.6
        
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
     named template: log
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="log">
    <xsl:param name="withFilePathContext">no</xsl:param>
    <xsl:param name="withFileContext">yes</xsl:param>
    <xsl:param name="withElementContext">yes</xsl:param>
    <xsl:param name="msg">NO MESSAGE PASSED BY CALLING TRAP</xsl:param>
    
    <xsl:variable name="fullpathname" select="base-uri(.)"/>
    <xsl:variable name="filename" select="tokenize($fullpathname, '/')[last()]"/>
    <xsl:variable name="pathname" select="substring-before($fullpathname, $filename)"/>
    <xsl:variable name="outmsg">
      <xsl:if test="$withFilePathContext='yes'">
        <xsl:value-of select="$pathname"/>
      </xsl:if>
      <xsl:if test="$withFileContext='yes'">
        <xsl:value-of select="$filename"/>
      </xsl:if>
      <xsl:if test="$withFilePathContext='yes' or $withFileContext='yes'">
        <xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:if test="$withElementContext='yes'">
        <xsl:variable name="eleName" select="local-name(.)"/>
        <xsl:value-of select="$eleName"/>
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:text>@xml:id="</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>"</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding::*[local-name()=$eleName])+1"/>
            <xsl:text>]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:value-of select="$msg"/>
    </xsl:variable>
    <xsl:message><xsl:value-of select="$outmsg"/></xsl:message>
    <xsl:comment>WARNING: <xsl:value-of select="$outmsg"/></xsl:comment>
  </xsl:template>
  
</xsl:stylesheet>