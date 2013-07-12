<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:import href="log.xsl"/>
  <xsl:import href="normalization.xsl"/>
  
  <xsl:param name="withbdidefault">yes</xsl:param>
  <xsl:param name="withtypedefault">yes</xsl:param>
  
  <xsl:template name="place-title-std">
    <xsl:param name="place" select="."/>
    <xsl:param name="withbdi" select="$withbdidefault"/>
    <xsl:param name="withtype" select="$withtypedefault"/>
    <xsl:param name="firstlang">en</xsl:param>
    <xsl:param name="secondlang">syr</xsl:param>
    <xsl:param name="withplaceholder">yes</xsl:param>
    
    <!-- handle first lang -->
    <xsl:choose>
      <xsl:when test="$place/t:placeName[@xml:lang=$firstlang]">
        <xsl:apply-templates select="$place/t:placeName[@xml:lang=$firstlang][1]" mode="std-title">
          <xsl:with-param name="withbdi" select="$withbdi"/>
          <xsl:with-param name="withtype" select="$withtype"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="not-avail">
          <xsl:with-param name="withbdi" select="$withbdi"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- separator -->
    <xsl:text> — </xsl:text>
    
    <!-- handle second lang -->
    <xsl:choose>
      <xsl:when test="$place/t:placeName[@xml:lang=$secondlang]">
        <xsl:apply-templates select="$place/t:placeName[@xml:lang=$secondlang][1]" mode="std-title">
          <xsl:with-param name="withbdi" select="$withbdi"/>
          <xsl:with-param name="withtype">no</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="not-avail">
          <xsl:with-param name="withbdi" select="$withbdi"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
  <xsl:template match="t:placeName" mode="std-title">
    <xsl:param name="withbdi" select="$withbdidefault"/>
    <xsl:param name="withtype" select="$withtypedefault"/>
    <xsl:variable name="dir">
      <xsl:choose>
        <xsl:when test="not(@xml:lang)">
          <xsl:call-template name="log">
            <xsl:with-param name="msg">no @xml:lang attribute in place-title-std.xsl</xsl:with-param>
          </xsl:call-template>
          <xsl:text></xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang='en'">ltr</xsl:when>
        <xsl:when test="@xml:lang='syr' or @xml:lang='ar'">rtl</xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log">
            <xsl:with-param name="msg">untrapped @xml:lang value in place-title-std.xsl (<xsl:value-of select="@xml:lang"/>)</xsl:with-param>
          </xsl:call-template>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$withbdi='yes' and $dir!=''">
        <bdi dir="{$dir}" lang="{@xml:lang}" xml:lang="{@xml:lang}">
          <xsl:apply-templates mode="text-normal"/>
        </bdi>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="text-normal"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$withtype='yes'">
      <xsl:choose>
        <xsl:when test="$withbdi='yes'">
          <bdi dir="ltr" lang="en" xml:lang="en">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="ancestor::t:place/@type"/>
            <xsl:text>)</xsl:text>
          </bdi>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> (</xsl:text>
          <xsl:value-of select="ancestor::t:place/@type"/>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="not-avail">
    <xsl:param name="withbdi" select="$withbdidefault"/>
    <xsl:choose>
      <xsl:when test="$withbdi='yes'">
        <bdi dir="ltr">[ Not Available ]</bdi>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[ Not Available ]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>