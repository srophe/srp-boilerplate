<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:listPlace">
    <xsl:for-each select="t:place">
      <xsl:sort select="xs:date(t:bibl[@type='self'][1]/t:date)"/>
      <xsl:if test="not(position() &gt; 10)">
        <xsl:message><xsl:value-of select="t:idno[@type='SRP']"/></xsl:message>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>