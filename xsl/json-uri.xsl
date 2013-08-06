<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:template match="t:geo" mode="json-uri">
    <xsl:variable name="json">
      <xsl:text>{"type": "Point", "coordinates": [</xsl:text>
      <xsl:value-of select="replace(normalize-space(.), ' ', ', ')"/>
      <xsl:text>]}</xsl:text>
    </xsl:variable>
    <xsl:text>data:application/json,</xsl:text>
    <xsl:value-of select="encode-for-uri($json)"/>
  </xsl:template>
</xsl:stylesheet>