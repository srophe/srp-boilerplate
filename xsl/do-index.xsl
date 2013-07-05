<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- ****************************************************************** -->
  <!-- CREATE A SIMPLE PLACE INDEX FILE -->
  <!-- ****************************************************************** -->
  <xsl:param name="forceBreaks">yes</xsl:param>
  <xsl:param name="sourcedir">../../places/xml/</xsl:param>
  <xsl:param name="destdir">../places/</xsl:param>
  <xsl:param name="uribase">http://syriaca.org/place/</xsl:param>
  <xsl:param name="normalization">NFKC</xsl:param>
  <xsl:variable name="colquery"><xsl:value-of select="$sourcedir"/>?select=*.xml</xsl:variable>
  <xsl:variable name="n">
    <xsl:text>
</xsl:text>
  </xsl:variable>
  
  <xsl:output name="xml" encoding="UTF-8" exclude-result-prefixes="xs t" method="xml" indent="yes"/>
  
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
                <xsl:call-template name="get-placeType"/>
                <xsl:call-template name="get-placeID"/>
                <xsl:call-template name="get-canonicalNames"/>
                <xsl:call-template name="get-placeURI"/>
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
  
  <xsl:template name="sanity-check">
    <xsl:if test="count(./descendant-or-self::t:place) &gt; 1">
      <xsl:message>WARNING: Found more than one place element in <xsl:value-of select="document-uri(.)"/>; ignoring all but the first</xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="get-placeID">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:choose>
      <xsl:when test="$place/@xml:id">
        <xsl:copy-of select="$place/@xml:id"/>
        <xsl:variable name="fullid" select="xs:string($place/@xml:id)"/>
        <xsl:choose>
          <xsl:when test="matches($fullid, '^(place\-)\d+$')">
            <xsl:variable name="placeID" select="substring-after($fullid, 'place-')"/>
            <idno type="placeID"><xsl:value-of select="$placeID"/></idno>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>WARNING: value of xml:id attribute on first place element in <xsl:value-of select="document-uri(.)"/> doesn't conform to expected pattern; setting placeID to -1 (minus one)</xsl:message>
            <idno type="placeID">-1</idno>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>WARNING: No xml:id attribute found on the first place element in <xsl:value-of select="document-uri(.)"/>; placeID set to 0 (zero)</xsl:message>
        <idno type="placeID">0</idno>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$forceBreaks='yes'">
      <xsl:value-of select="$n"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="get-placeType">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:choose>
      <xsl:when test="$place/@type">
        <!-- todo: check for valid values of @type? -->
        <xsl:copy-of select="$place/@type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>WARNING: No type attribute found on the first place element in <xsl:value-of select="document-uri(.)"/>; type set to 'unspecified'</xsl:message>
        <xsl:attribute name="type">unspecified</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-canonicalNames">
    <xsl:variable name="place" select="./descendant-or-self::t:place[1]"/>
    <xsl:if test="not($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='en'])">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>No English language placeName marked as headword was found in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='syr'])">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>No Syriac language placeName marked as headword was found in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword')]) &gt; 2">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 2 placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='en']) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 1 English-language placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and @xml:lang='syr']) &gt; 1">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>More than 1 Syriac-language placeNames marked as headword were found in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and not(@xml:lang='en') and not(@xml:lang='syr')]) &gt; 0">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>Found a placeName marked as headword, but with a language other than English or Syriac in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="count($place/t:placeName[contains(@syriaca-tags, '#syriaca-headword') and not(@xml:lang)]) &gt; 0">
      <xsl:call-template name="log">
        <xsl:with-param name="msg">
          <xsl:text>WARNING: Found a placeName marked as headword, but with no language attribute in the first place element in file</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$place/t:placeName[contains(@syriaca-tags, '#syriaca-headword')]"/>
  </xsl:template>
  
  <xsl:template match="t:placeName">
    <placeName>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="." mode="text-normal-check"/>
    </placeName>
    <xsl:if test="$forceBreaks='yes'">
      <xsl:value-of select="$n"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:*" mode="text-normal-check">
    <xsl:variable name="raw" select="xs:string(.)"/>
    <xsl:variable name="cooked" select="normalize-space(normalize-unicode($raw, $normalization))"/>
    
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

    <xsl:variable name="lang" select="xs:string(./ancestor-or-self::*[@xml:lang][1]/@xml:lang)"/>
    <xsl:call-template name="check-text-range">
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:call-template>
    <xsl:value-of select="$cooked"/>
  </xsl:template>
  
  <xsl:template name="get-placeURI">
    
  </xsl:template>
  
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