<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t"
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
 
 <xsl:template match="text()" mode="text-normal">
  <xsl:variable name="prefix">
   <xsl:if test="(preceding-sibling::t:* or preceding-sibling::text()[normalize-space()!='']) and string-length(.) &gt; 0 and substring(., 1, 1)=' '">
    <xsl:text> </xsl:text>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="suffix">
   <xsl:if test="(following-sibling::t:* or following-sibling::text()[normalize-space()!='']) and string-length(.) &gt; 0 and substring(., string-length(.), 1)=' '">
    <xsl:text> </xsl:text>
   </xsl:if>
  </xsl:variable>
  <xsl:value-of select="$prefix"/>
  <xsl:value-of select="normalize-space(normalize-unicode(., $normalization))"/>
  <xsl:value-of select="$suffix"/>
 </xsl:template>
 
 
</xsl:stylesheet>