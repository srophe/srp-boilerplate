<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:import href="normalization.xsl"/>
  
  <xsl:template name="place-title-std">
    <xsl:param name="place" select="."/>
    <xsl:param name="withbdi">yes</xsl:param>
    <xsl:choose>
      <xsl:when test="$withbdi='yes'">
        <xsl:for-each select="$place/t:placeName[@xml:lang='en'][1]">
          <bdi dir="ltr" lang="{@xml:lang}">
            <xsl:copy-of select="@xml:lang"/>
            <xsl:apply-templates mode="text-normal"/>
          </bdi>
        </xsl:for-each>
        <xsl:if test="$place/t:placeName[@xml:lang='en'] and $place/t:placeName[@xml:lang='syr']">
          <xsl:text> — </xsl:text>
        </xsl:if>
        <xsl:for-each select="$place/t:placeName[@xml:lang='syr'][1]">
          <bdi dir="rtl" lang="{@xml:lang}">
            <xsl:copy-of select="@xml:lang"/>
            <xsl:apply-templates mode="text-normal"/>
          </bdi>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
        <xsl:for-each select="$place/t:placeName[@xml:lang='en'][1]">
          <xsl:apply-templates mode="text-normal"/>
        </xsl:for-each>
        <xsl:if test="$place/t:placeName[@xml:lang='en'] and $place/t:placeName[@xml:lang='syr']">
          <xsl:text> — </xsl:text>
        </xsl:if>
        <xsl:for-each select="$place/t:placeName[@xml:lang='syr'][1]">
          <xsl:apply-templates mode="text-normal"/>
        </xsl:for-each>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>