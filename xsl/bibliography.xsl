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
       bibliography.xsl
       
       This XSLT provides templates for output of bibliographic material. 
       
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
     generate a footnote for the matched bibl entry; if it contains a 
     pointer, try to look up the master bibliography file and use that
     
     assumption: you want the footnote in a list item (li) element
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:bibl" mode="footnote">
    <xsl:param name="footnote-number">-1</xsl:param>
    <xsl:variable name="thisnum">
      <xsl:choose>
        <xsl:when test="$footnote-number='-1'">
          <xsl:value-of select="substring-after(@xml:id, '-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$footnote-number"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <li xml:id="{@xml:id}">
      <span class="footnote-tgt"><xsl:value-of select="$thisnum"/></span>
      <xsl:text> </xsl:text>
      <span class="footnote-content">
        <!-- if the reference points at a master bibliographic record file, use it; otherwise, do 
     what you can with the contents of the present element -->
        <xsl:choose>
          <xsl:when test="t:ptr[@target and starts-with(@target, 'http://syriaca.org/bibl/')]">
            <xsl:variable name="biblfilepath">
              <xsl:value-of select="$biblsourcedir"/>
              <xsl:value-of select="substring-after(t:ptr/@target, 'http://syriaca.org/bibl/')"/>
              <xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="doc-available($biblfilepath)">
                <xsl:apply-templates select="document($biblfilepath)/descendant::t:biblStruct[1]" mode="footnote"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="log">
                  <xsl:with-param name="msg">could not find referenced bibl document <xsl:value-of select="$biblfilepath"/></xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="t:citedRange">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="t:citedRange" mode="footnote"/>
              </xsl:if>
            <xsl:text>.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="footnote"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </li>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle a footnote for a book
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:biblStruct[t:monogr and not(t:analytic)]" mode="footnote">
    <!-- this is a monograph/book -->
    
    <!-- handle editors/authors and abbreviate as necessary -->
    <xsl:variable name="edited" select="if (t:monogr/t:editor[not(@role) or @role!='translator']) then true() else false()"/>
    <xsl:variable name="responsible">
      <xsl:choose>
        <xsl:when test="$edited">
          <xsl:copy-of select="t:monogr/t:editor[not(@role) or @role!='translator']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="t:monogr/t:author"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rcount" select="count($responsible)"/>
    <xsl:call-template name="emit-responsible-persons">
      <xsl:with-param name="perss" select="$responsible"/>
    </xsl:call-template>
    <xsl:if test="$edited">
      <xsl:choose>
        <xsl:when test="$rcount = 1">
          <xsl:text> (ed.)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> (eds.)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>, </xsl:text>
    
    <!-- handle titles -->
    <xsl:for-each select="t:monogr[1]">
      <xsl:choose>
        <xsl:when test="t:title[@xml:lang='en']">
          <xsl:apply-templates select="t:title[@xml:lang='en']" mode="footnote"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="t:monogr/t:title[1]" mode="footnote"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    
    <xsl:text> </xsl:text>
    
    <xsl:apply-templates select="t:monogr/t:imprint" mode="footnote"/>
    
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle a bibllist entry for a book
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:biblStruct[t:monogr and not(t:analytic)]" mode="biblist">
    <!-- this is a monograph/book -->
    
    <!-- handle editors/authors and abbreviate as necessary -->
    <xsl:variable name="edited" select="if (t:monogr/t:editor[not(@role) or @role!='translator']) then true() else false()"/>
    <xsl:variable name="responsible">
      <xsl:choose>
        <xsl:when test="$edited">
          <xsl:copy-of select="t:monogr/t:editor[not(@role) or @role!='translator']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="t:monogr/t:author"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rcount" select="count($responsible)"/>
    <xsl:call-template name="emit-responsible-persons">
      <xsl:with-param name="perss" select="$responsible"/>
      <xsl:with-param name="moded">biblist</xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$edited">
      <xsl:choose>
        <xsl:when test="$rcount = 1">
          <xsl:text> (ed.)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> (eds.)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>. </xsl:text>
    
    <!-- handle titles -->
    <xsl:for-each select="t:monogr[1]">
      <xsl:choose>
        <xsl:when test="t:title[@xml:lang='en']">
          <xsl:apply-templates select="t:title[@xml:lang='en']" mode="biblist"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="t:monogr/t:title[1]" mode="biblist"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    
    <xsl:text> </xsl:text>
    
    <xsl:apply-templates select="t:monogr/t:imprint" mode="biblist"/>
    
  </xsl:template>
  
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     generate a bibl list entry for the matched bibl; if it contains a 
     pointer, try to look up the master bibliography file and use that
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:bibl" mode="biblist">
    <xsl:choose>
      <xsl:when test="t:ptr">
        <xsl:apply-templates select="t:ptr" mode="biblist"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="biblist"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle a ptr inside a bibl: try to look up the corresponding item
     internally or externally and process that
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:ptr[ancestor::t:*[1]/self::t:bibl]" mode="biblist">
    <xsl:choose>
      <xsl:when test="starts-with(@target, '#')">
        <xsl:variable name="thistarget" select="substring-after(@target, '#')"/>
        <xsl:apply-templates select="ancestor::t:TEI/descendant::t:*[@xml:id=$thistarget]" mode="biblist"/>
      </xsl:when>
      <xsl:when test="starts-with(@target, 'http://syriaca.org/bibl/')">
        <xsl:variable name="biblfilepath">
          <xsl:value-of select="$biblsourcedir"/>
          <xsl:value-of select="substring-after(@target, 'http://syriaca.org/bibl/')"/>
          <xsl:text>.xml</xsl:text>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="doc-available($biblfilepath)">
            <xsl:apply-templates select="document($biblfilepath)/descendant::t:biblStruct[1]" mode="biblist"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="log">
              <xsl:with-param name="msg">could not find referenced bibl document <xsl:value-of select="$biblfilepath"/></xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle name components in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:forename | t:addName | t:surname" mode="footnote" priority="1">
    <xsl:if test="preceding-sibling::t:*">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="footnote"/>
  </xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle date, publisher, place of publication, placenames and foreign
     tags (i.e., language+script changes) in footnote context (the main
     reason for this is to capture language and script changes at these
     levels)
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:date | t:publisher | t:pubPlace | t:placeName | t:foreign" mode="footnote" priority="1">
    <span class="{local-name()}">
      <xsl:call-template name="langattr"/>
      <xsl:apply-templates mode="footnote"/>
    </span>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle personal names in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:persName | t:name" mode="footnote">
    <span class="{local-name()}">
      <xsl:call-template name="langattr"/>
      <xsl:choose>
        <xsl:when test="t:*">
          <xsl:apply-templates select="t:*" mode="footnote"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="footnote"/>
        </xsl:otherwise>
      </xsl:choose>
      
    </span>
  </xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle personal names last-name first
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:persName" mode="lastname-first">
    <span class="persName">
      <xsl:call-template name="langattr"/>
      <xsl:choose>
        <xsl:when test="t:surname and t:forename">
          <xsl:apply-templates select="t:surname" mode="footnote"/>
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="t:*[local-name()!='surname']" mode="footnote"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log">
            <xsl:with-param name="withElementContext">no</xsl:with-param>
            <xsl:with-param name="withElementContent">yes</xsl:with-param>
            <xsl:with-param name="msg">persName trapped in mode lastname-first, but does not contain surname and forename elements; therefore subcomponents have been output in document order</xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates select="t:*" mode="footnote"/>          
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle authors and editors in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:author | t:editor | t:principal | t:person" mode="footnote biblist" priority="1">
    <xsl:choose>
      <xsl:when test="@ref and starts-with(@ref, $editoruriprefix)">
        <xsl:variable name="sought" select="substring-after(@ref, $editoruriprefix)"/>
        <xsl:apply-templates select="$editorssourcedoc/descendant::t:body/t:listPerson[1]/t:person[@xml:id=$sought][1]" mode="footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{local-name()}">
          <xsl:choose>
            <xsl:when test="t:persName">
              <xsl:apply-templates select="t:persName[1]" mode="footnote"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="footnote"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle authors and editors in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:author | t:editor | t:principal | t:person" mode="lastname-first" priority="1">
    <xsl:choose>
      <xsl:when test="@ref and starts-with(@ref, $editoruriprefix)">
        <xsl:variable name="sought" select="substring-after(@ref, $editoruriprefix)"/>
        <xsl:apply-templates select="$editorssourcedoc/descendant::t:body/t:listPerson[1]/t:person[@xml:id=$sought][1]" mode="lastname-first"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{local-name()}">
          <xsl:choose>
            <xsl:when test="t:persName">
              <xsl:apply-templates select="t:persName[1]" mode="lastname-first"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="log">
                <xsl:with-param name="withElementContext">no</xsl:with-param>
                <xsl:with-param name="withElementContent">yes</xsl:with-param>
                <xsl:with-param name="msg">no persName element found, but mode was 'lastname-first'; cannot reorder names reliably</xsl:with-param>
              </xsl:call-template>
              <xsl:apply-templates mode="footnote"/>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle the imprint component of a biblStruct
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:imprint" mode="footnote biblist" priority="1">
    <xsl:text>(</xsl:text>
    <xsl:choose>
      <xsl:when test="t:pubPlace">
        <xsl:apply-templates select="t:pubPlace" mode="footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <abbr title="no place of publication">n.p.</abbr>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: </xsl:text>
    <xsl:choose>
      <xsl:when test="t:publisher[@xml:lang='en']">
        <xsl:apply-templates select="t:publisher[@xml:lang='en']" mode="footnote"/>
      </xsl:when>
      <xsl:when test="t:publisher">
        <xsl:apply-templates select="t:publisher[1]" mode="footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <abbr title="no publisher">n.p.</abbr>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>, </xsl:text>
    <xsl:choose>
      <xsl:when test="t:date">
        <xsl:apply-templates select="t:date" mode="footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <abbr title="no date of publication">n.d.</abbr>
      </xsl:otherwise>
    </xsl:choose>    
    <xsl:text>)</xsl:text>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle bibliographic titles in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:title" mode="footnote biblist allbib" priority="1">
    <span>
      <xsl:attribute name="class">
        <xsl:text>title</xsl:text>
        <xsl:choose>
          <xsl:when test="@level='a'">
            <xsl:text>-analytic</xsl:text>            
          </xsl:when>
          <xsl:when test="@level='m'">
            <xsl:text>-monographic</xsl:text>
          </xsl:when>
          <xsl:when test="@level='j'">
            <xsl:text>-journal</xsl:text>
          </xsl:when>
          <xsl:when test="@level='s'">
            <xsl:text>-series</xsl:text>
          </xsl:when>
          <xsl:when test="@level='u'">
            <xsl:text>-unpublished</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="langattr"/>
      <xsl:apply-templates mode="footnote"/>
    </span>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle cited ranges in the context of a footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:citedRange[ancestor::t:bibl or ancestor::t:biblStruct]" mode="footnote" priority="1">
    <xsl:choose>
      <xsl:when test="@unit='pp' and contains(., '-')">
        <xsl:text>pp. </xsl:text>
      </xsl:when>
      <xsl:when test="@unit='pp' and not(contains(., '-'))">
        <xsl:text>p. </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="." mode="out-normal"/>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     handle creators for type footnote
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template name="emit-responsible-persons">
    <xsl:param name="perss"/>
    <xsl:param name="moded">footnote</xsl:param>
    <xsl:param name="maxauthorsfootnote">2</xsl:param>
    <xsl:param name="maxauthorsbiblist">2</xsl:param>
    
    <xsl:variable name="ccount" select="count($perss/t:*)"/>
    <xsl:choose>
      <xsl:when test="$ccount=1 and $moded='footnote'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="footnote"/>
      </xsl:when>
      <xsl:when test="$ccount=1 and $moded='biblist'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="lastname-first"/>
      </xsl:when>
      <xsl:when test="$ccount &gt; $maxauthorsfootnote and $moded='footnote'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="footnote"/>
        <xsl:text> et al.</xsl:text>
      </xsl:when>
      <xsl:when test="$ccount &gt; $maxauthorsbiblist and $moded='biblist'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="lastname-first"/>
        <xsl:text> et al.</xsl:text>
      </xsl:when>
      <xsl:when test="$ccount = 2 and $moded='footnote'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="footnote"/>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="$perss/t:*[2]" mode="footnote"/>
      </xsl:when>
      <xsl:when test="$ccount = 2 and $moded='biblist'">
        <xsl:apply-templates select="$perss/t:*[1]" mode="lastname-first"/>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="$perss/t:*[2]" mode="biblist"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$perss/t:*[position() &lt; $maxauthorsfootnote+1]">
          <xsl:choose>
            <xsl:when test="position() = $maxauthorsfootnote">
              <xsl:text> and </xsl:text>
            </xsl:when>
            <xsl:when test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="$moded='footnote'">
              <xsl:apply-templates select="." mode="footnote"/>
            </xsl:when>
            <xsl:when test="$moded='biblist'">
              <xsl:apply-templates select="." mode="biblist"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     suppress otherwise unhandled descendent nodes of bibl or biblStruct
     in the context of a footnote (and log the fact that we've done so)
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:*" mode="footnote">
    <xsl:call-template name="log">
      <xsl:with-param name="msg">element suppressed in mode footnote</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     suppress otherwise unhandled descendent nodes of bibl or biblStruct
     in the context of a bibliographic list (and log the fact that we've 
     done so)
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:*" mode="biblist">
    <xsl:call-template name="log">
      <xsl:with-param name="msg">element suppressed in mode biblist</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     suppress otherwise unhandled descendent nodes of bibl or biblStruct
     in universal bibliographic context (and log the fact that we've done 
     so)
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:*" mode="allbibl">
    <xsl:call-template name="log">
      <xsl:with-param name="msg">element suppressed in mode allbibl</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     suppress otherwise unhandled descendent nodes of bibl or biblStruct
     in universal bibliographic context (and log the fact that we've done 
     so)
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:*" mode="lastname-first">
    <xsl:call-template name="log">
      <xsl:with-param name="msg">element suppressed in mode lastname-first</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     emit the footnote number for a bibl
     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  
  <xsl:template match="t:bibl" mode="footnote-ref">
    <xsl:param name="footnote-number">1</xsl:param>
    <span class="footnote-ref">
      <a href="#{@xml:id}"><xsl:value-of select="$footnote-number"/></a>
    </span>
  </xsl:template>
  
</xsl:stylesheet>