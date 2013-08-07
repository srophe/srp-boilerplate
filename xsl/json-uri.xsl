<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:template match="t:geo" mode="json-uri">
    <xsl:variable name="coords">
      <xsl:value-of select="tokenize(normalize-space(.), ' ')"/>
    </xsl:variable>
    <xsl:variable name="json">
      <xsl:text>{"type": "Point", "coordinates": [</xsl:text>
      <xsl:value-of select="$coords[2]"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="$coords[1]"/>
      <xsl:text>]}</xsl:text>
    </xsl:variable>
    <link rel="where">
      <xsl:attribute name="href">
        <xsl:text>data:application/json,</xsl:text>
        <xsl:value-of select="encode-for-uri($json)"/>
      </xsl:attribute>
    </link>
  </xsl:template>
</xsl:stylesheet>