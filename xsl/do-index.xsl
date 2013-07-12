<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:ipse="urn.ipsens"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:syriaca="http://syriaca.org"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t ipse xi svg math syriaca"
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
       do-index.xsl
       
       This XSLT loops through all XML files in a specified directory and
       attempts to construct an XML index file that is intended for 
       subsequent use in other processes. 
       
       parameters:
        + forceBreaks: force line breaks in index file
        + sourcedir: path to source directory containing input xml files
        + destdir: path to destination directory for the index file
        + normalization: standard normalization algorithm to use in 
          standardizing text strings
       
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
  
  <xsl:import href="log.xsl"/>
  <xsl:import href="normalization.xsl"/>
  
  <xsl:param name="forceBreaks">yes</xsl:param>
  <xsl:param name="sourcedir">../../places/xml/</xsl:param>
  <xsl:param name="destdir">../places/</xsl:param>
  <xsl:param name="normalization">NFKC</xsl:param>
  
  <xsl:variable name="colquery"><xsl:value-of select="$sourcedir"/>?select=*.xml</xsl:variable>
  <xsl:variable name="n">
    <xsl:text>
</xsl:text>
  </xsl:variable>
  
  <xsl:output name="xml" encoding="UTF-8" exclude-result-prefixes="xs t ipse xi svg math syriaca" method="xml" indent="no"/>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-index
     
     top-level logic and instructions for reading input files and 
     contstructing the index
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <xsl:template name="do-index">
    <xsl:variable name="files" select="collection($colquery)"/>
    <xsl:result-document method="xml" href="{$destdir}index.xml">
      <listPlace xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:for-each select="$files">
          <xsl:choose>
            <xsl:when test="not(./descendant-or-self::t:TEI)">
              <xsl:call-template name="log">
                <xsl:with-param name="msg">
                  <xsl:text>Skipping file: no TEI element found</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(./descendant-or-self::t:place)">
              <xsl:call-template name="log">
                <xsl:with-param name="msg">
                  <xsl:text>Skipping file: no place element found</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <place>
                <xsl:call-template name="sanity-check"/>
                <xsl:call-template name="copy-xml-id"/>
                <xsl:call-template name="get-placeType"/>
                <xsl:call-template name="get-canonicalNames"/>
                <xsl:call-template name="get-abstract"/>
                <xsl:call-template name="get-placeID"/>
                <xsl:call-template name="get-placeURI"/>
                <xsl:call-template name="get-locations"/>
                <xsl:call-template name="do-selfBibl"/>
              </place>
              <xsl:if test="$forceBreaks='yes'">
                <xsl:value-of select="$n"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </listPlace>
    </xsl:result-document>
  </xsl:template>
  
  
<!-- start first-level named templates, called from do-index --> 
    
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: sanity-check
     
     test the current input file to ensure it meets basic expectations
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <xsl:template name="sanity-check">
    <xsl:if test="count(./descendant-or-self::t:place) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Found more than one place element in file; ignoring all but the first</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: copy-xml-id
     
     if there is an xml:id attribute on the context element, copy it to 
     the current output element
     
     NB: warnings about missing xml:id attributes are generated in the 
     get-placeID template
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="copy-xml-id">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:if test="$place/@xml:id">
      <xsl:copy-of select="$place/@xml:id"/>
    </xsl:if>
  </xsl:template>


  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-abstract
     
     if there is an english abstract, copy it to the index file
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="get-abstract">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:for-each select="$place/t:desc[starts-with(@xml:id, 'abstract-en')][1]">
      <desc type="abstract">
        <xsl:copy-of select="@xml:lang"/>
        <xsl:apply-templates mode="cleancopy"/>
      </desc>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="text()" mode="cleancopy">
    <xsl:variable name="raw" select="."/>
    <xsl:if test="substring($raw, 1, 1)=' '">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space($raw)"/>
    <xsl:if test="substring($raw, string-length($raw))=' '">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:geo | t:region" mode="cleancopy">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@ref"/>
      <xsl:apply-templates mode="cleancopy"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*" mode="cleancopy">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="cleancopy"/>
    </xsl:copy>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-placeID
     
     parse content of the xml:id attribute on the context element and 
     generate an idno element in the output with type=placeID; do 
     completeness and validity checks on the xml:id
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="get-placeID">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:choose>
      <xsl:when test="$place/@xml:id">
        <xsl:variable name="fullid" select="xs:string($place/@xml:id)"/>
        <xsl:choose>
          <xsl:when test="matches($fullid, '^(place\-)\d+$')">
            <xsl:variable name="placeID" select="substring-after($fullid, 'place-')"/>
            <idno type="placeID"><xsl:value-of select="$placeID"/></idno>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="log">
              <xsl:with-param name="msg">
                <xsl:text>Value of xml:id attribute on first place element in file doesn't conform to expected pattern; setting placeID to -1 (minus one)</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="withElementContext">no</xsl:with-param>
            </xsl:call-template>            
            <idno type="placeID">-1</idno>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log">
          <xsl:with-param name="msg">
            <xsl:text>No xml:id attribute found on the first place element in file; placeID set to 0 (zero)</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="withElementContext">no</xsl:with-param>
        </xsl:call-template>
        <idno type="placeID">0</idno>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$forceBreaks='yes'">
      <xsl:value-of select="$n"/>
    </xsl:if>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-PlaceType
     
     copy the type attribute from the context element to the output
     
     TODO: check for valid values of @type?
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="get-placeType">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:choose>
      <xsl:when test="$place/@type">
        <xsl:copy-of select="$place/@type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log">
          <xsl:with-param name="msg">
            <xsl:text>No type attribute found on the first place element in file; type set to 'unspecified'</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="withElementContext">no</xsl:with-param>
        </xsl:call-template>
        <xsl:attribute name="type">unspecified</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-canonicalNames
     
     apply templates to copy placenames in the original context that are 
     marked as "syriaca headwords" to the output (with generated search 
     keys and  other enhancements) after performing completeness and 
     validity checks on same; apply-templates to copy 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="get-canonicalNames">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    
    <!-- tests for completeness -->
    <xsl:if test="not($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='en'])">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>No English language placeName marked as headword was found in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='syr'])">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>No Syriac language placeName marked as headword was found in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword')]) &gt; 2">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 2 placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='en']) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 1 English-language placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='syr']) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 1 Syriac-language placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and not(@xml:lang='en') and not(@xml:lang='syr')]) &gt; 0">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Found a placeName marked as headword, but with a language other than English or Syriac in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and not(@xml:lang)]) &gt; 0">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Found a placeName marked as headword, but with no language attribute in the first place element in file</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <!-- transfer the headwords to the index file -->
    <xsl:apply-templates select="$place/t:placeName[contains(@syriaca-tags, '#syriaca-headword')]"/>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-placeURI
     
     finds known-category idno@type=URI links (SRP, Pleiades, Wikipedia)
     and produces corresponding idno elements in the output that have
     distinctive type attributes (for quicker processing). Checks for and
     alerts on missing or multiple SRP URIs.
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->    
  <xsl:template name="get-placeURI">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:variable name="srpinit">http://syriaca.org/place/</xsl:variable>
    <xsl:variable name="pleiadesinit">http://pleiades.stoa.org/places/</xsl:variable>
    <xsl:variable name="wikipediainit">http://en.wikipedia.org/wiki/</xsl:variable>
    
    <xsl:if test="count($place/t:idno[@type='URI' and starts-with(., $srpinit)]) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Found more than one syriaca.org URI idno in the first place element</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>   
    <xsl:if test="not($place/t:idno[@type='URI' and starts-with(., $srpinit)])">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Did not find a syriaca.org URI idno in the first place element</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="withElementContext">no</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:for-each select="$place/t:idno[@type='URI' and starts-with(., $srpinit)]">
      <idno type="SRP"><xsl:value-of select="."/></idno>
    </xsl:for-each>
    
    <xsl:for-each select="$place/t:idno[@type='URI' and starts-with(., $pleiadesinit)]">
      <idno type="Pleiades"><xsl:value-of select="."/></idno>
    </xsl:for-each>
    
    <xsl:for-each select="$place/t:idno[@type='URI' and starts-with(., $wikipediainit)]">
      <idno type="Wikipedia"><xsl:value-of select="."/></idno>
    </xsl:for-each>
    
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: get-locations
     
     copies location information into the index
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template name="get-locations">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:choose>
      <xsl:when test="$place/t:location">
        <xsl:for-each select="$place/t:location">
          <location>
            <xsl:copy-of select="@type"/>
            <xsl:apply-templates mode="cleancopy"/>
          </location>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log">
          <xsl:with-param name="withElementContext">no</xsl:with-param>
          <xsl:with-param name="msg">No location element was found for this place.</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: do-selfBibl
     
     create bibliographic information about each place record
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template name="do-selfBibl">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <bibl type="self">
      <xsl:apply-templates select="descendant-or-self::t:publicationStmt/t:date" mode="selfBibl"/>  
      <xsl:apply-templates select="descendant-or-self::t:titleStmt/t:editor" mode="selfBibl"/>
      <xsl:apply-templates select="descendant-or-self::t:titleStmt/t:respStmt" mode="selfBibl"/>
    </bibl>
  </xsl:template>
  
  <xsl:template match="t:editor" mode="selfBibl">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(.), $normalization))"/>
    <xsl:if test="not(preceding-sibling::t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name])">
      <editor><xsl:value-of select="$name"/></editor>
    </xsl:if>
  </xsl:template> 

  <xsl:template match="t:respStmt" mode="selfBibl">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(t:name), $normalization))"/>
    <xsl:if test="not(../t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name]) and not(preceding-sibling::t:respStmt[normalize-space(normalize-unicode(xs:string(t:name), $normalization))=$name])">
      <author><xsl:value-of select="$name"/></author>
    </xsl:if>
  </xsl:template> 
  
  <xsl:template match="t:*" mode="selfBibl">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates mode="selfBibl"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text()" mode="selfBibl">
    <xsl:apply-templates select="." mode="text-normal"/>
  </xsl:template>
  
  <!-- end first-level named templates --> 
  
  <!-- start helper templates --> 
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     template: match=t:placeName
     
     generates a placeName element in the output, copying xml:id, xml:lang,
     and syriaca-tags attributes to same; 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template match="t:placeName">
    <placeName>
      <xsl:copy-of select="@xml:id"/>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:copy-of select="syriaca-tags"/>
      <xsl:call-template name="gen-search-key"/>
      <xsl:apply-templates select="." mode="text-normal-check"/>
    </placeName>
    <xsl:if test="$forceBreaks='yes'">
      <xsl:value-of select="$n"/>
    </xsl:if>
  </xsl:template>


<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: gen-search-key
     
     generates a search key from the context that meets SRP rules for 
     language and script combination
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="gen-search-key">
    <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/>
    <xsl:variable name="raw">
      <xsl:apply-templates select="." mode="out-normal"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$lang='en'">
        <xsl:attribute name="reg" select="ipse:ensort(.)"/>
      </xsl:when>
      <xsl:when test="$lang='syr'">
        <xsl:attribute name="reg" select="ipse:syrsort(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log">
          <xsl:with-param name="msg">
            <xsl:text>template gen-search-key called with unsuppported language context: @xml:lang="</xsl:text>
            <xsl:value-of select="$lang"/>
            <xsl:text>"</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     function: ipse:syrsort
     
     creates a search key matching SRP expectations for syriac language
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:function name="ipse:syrsort">
    <xsl:param name="instring"></xsl:param>
    <xsl:variable name="norm">
      <xsl:apply-templates select="$instring" mode="out-normal"/>
    </xsl:variable>
    <xsl:value-of select="$norm"/>
  </xsl:function>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     function: ipse:ensort
     
     creates a search key matching SRP expectations for english language
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:function name="ipse:ensort">
    <xsl:param name="instring"></xsl:param>
    <xsl:variable name="norm">
      <xsl:apply-templates select="$instring" mode="out-normal"/>
    </xsl:variable>
    <xsl:call-template name="enstrip">
      <xsl:with-param name="instring" select="$norm"/>
    </xsl:call-template>
  </xsl:function>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: enstrip
     
     recursively strips undesireable leading and bracketing characters
     from the input string to support creation of search keys
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="enstrip">
    <xsl:param name="instring"/>
    <xsl:choose>
      <xsl:when test="starts-with($instring, ' ')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="substring($instring, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($instring, 'al-')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="substring-after($instring, 'al-')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($instring, ' al-')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="replace($instring, ' al-', ' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($instring, '&#703;')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="replace($instring, '&#703;', '')"/>
        </xsl:call-template>    
      </xsl:when>
      <xsl:when test="contains($instring, '‘')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="replace($instring, '‘', '')"/>
        </xsl:call-template>    
      </xsl:when>
      <xsl:when test="starts-with($instring, '‘') and ends-with($instring, '’')">
        <xsl:call-template name="enstrip">
          <xsl:with-param name="instring" select="substring-before(substring-after($instring, '‘'), '’')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($instring)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     moded template: match=t:* mode=text-normal-check
     
     checks the text content of the current element for any unicode
     characters falling outside the expected range(s) based on language
     tags, then outputs a normalized version of that text content in which
     both space and unicode composition have been normalized (the latter
     according to the algorithm specified in the stylesheet parameter
     "normalization". Checks for and reports on any change that occurs 
     during normalization. 
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template match="t:*" mode="text-normal-check">
    <xsl:variable name="raw" select="xs:string(.)"/>
    <xsl:variable name="cooked" select="normalize-space(normalize-unicode($raw, $normalization))"/>
    
    <xsl:variable name="lang" select="xs:string(./ancestor-or-self::*[@xml:lang][1]/@xml:lang)"/>
    <xsl:call-template name="check-text-range">
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:call-template>
    
    <xsl:if test="$raw != $cooked">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>normalized string "</xsl:text>
          <xsl:value-of select="$cooked"/>
          <xsl:text>" is different from raw string "</xsl:text>
          <xsl:value-of select="$raw"/>
          <xsl:text>"</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:value-of select="$cooked"/>
  </xsl:template>
  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     named template: check-text-range
     
     based on parameter values, assembles a regular expression to check
     for inclusion/exclusion of particular character ranges; understands
     SRP-specific patterns for English (=Latin characters) and Syriac, 
     as well as common punctuation. Only outputs are log messages on fail.
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->  
  <xsl:template name="check-text-range">
    <xsl:param name="instring" select="."/>
    <xsl:param name="lang"/>
    <xsl:param name="customrange"/>
    <xsl:param name="allowPunctuation">yes</xsl:param>
    <xsl:param name="exclude">yes</xsl:param>
    
    <xsl:choose>
      <xsl:when test="$lang!='en' and $lang!='syr' and $customrange=''">
        <xsl:call-template name="log">
          <xsl:with-param name="msg">
            <xsl:text>template "check-text-range" was called with an unsupported lang parameter value of "</xsl:text>
            <xsl:value-of select="$lang"/>
            <xsl:text>"</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    
    <xsl:variable name="punctrange">
      <xsl:text>\P{IsGeneralPunctuation}</xsl:text>
    </xsl:variable>
    <xsl:variable name="latinrange">
      <xsl:text>\P{IsBasicLatin}</xsl:text>
    </xsl:variable>
    <xsl:variable name="syriacrange">
      <xsl:text>\P{IsSyriac}</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="range">
      <xsl:text>[</xsl:text>
      <xsl:if test="$exclude='yes'">
        <xsl:text>^</xsl:text>
      </xsl:if>
      <xsl:if test="$customrange!=''">
        <xsl:value-of select="$customrange"/>
      </xsl:if>
      <xsl:if test="$lang='en'">
        <xsl:value-of select="$latinrange"/>
      </xsl:if>
      <xsl:if test="$lang='syr'">
        <xsl:value-of select="$syriacrange"/>
      </xsl:if>
      <xsl:if test="$allowPunctuation='yes'">
        <xsl:value-of select="$punctrange"/>
      </xsl:if>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <xsl:if test="matches($instring, $range)">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>string contains unexpected characters: </xsl:text>
          <xsl:text>lang="</xsl:text>
          <xsl:value-of select="$lang"/>
          <xsl:text>" customrange="</xsl:text>
          <xsl:value-of select="$customrange"/>
          <xsl:text>" allowPunctuation="</xsl:text>
          <xsl:value-of select="$allowPunctuation"/>
          <xsl:text>" exclude="</xsl:text>
          <xsl:value-of select="$exclude"/>
          <xsl:text>"</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  
  <!-- end helper templates --> 
  
  
</xsl:stylesheet>