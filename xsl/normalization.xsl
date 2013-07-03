<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 exclude-result-prefixes="xs"
 version="2.0">
 <xsl:template match="t:*" mode="out-normal">
  <xsl:variable name="thislang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
  <xsl:choose>
   <xsl:when test="starts-with($thislang, 'syr') or starts-with($thislang, 'syc') or starts-with($thislang, 'ar')">
    <bdi dir="rtl">
     <xsl:apply-templates select="." mode="text-normal"/>
    </bdi>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates select="." mode="text-normal"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template match="t:*" mode="text-normal">
  <xsl:value-of select="normalize-space(normalize-unicode(., $normalization))"/>
 </xsl:template>
 
 
</xsl:stylesheet>