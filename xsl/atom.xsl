<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:a="http://www.w3.org/2005/Atom"
  xmlns="http://www.w3.org/2005/Atom"
  exclude-result-prefixes="xs t a"
  version="2.0">
  
  <xsl:import href="place-title-std.xsl"/>
  
  <xsl:param name="normalization">NFKC</xsl:param>
  
  <xsl:output name="atom" encoding="UTF-8" method="xml" indent="yes" exclude-result-prefixes="#all"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:listPlace">
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title></title>
      <link rel="alternate" type="text/html"></link>
      <link rel="self" type="application/atom+xml"/>
      <xsl:for-each select="t:place">
        <xsl:sort select="xs:date(t:bibl[@type='self'][1]/t:date)"/>
        <xsl:if test="not(position() &gt; 10)">
          <xsl:message><xsl:value-of select="t:idno[@type='SRP']"/></xsl:message>
          <xsl:apply-templates select="." mode="atom-out"/>
        </xsl:if>
      </xsl:for-each>
    </feed>
  </xsl:template>
  
  <xsl:template match="t:place" mode="atom-out">
    <entry>
      <title>
        <xsl:call-template name="place-title-std">
          <xsl:with-param name="withbdi">no</xsl:with-param>
        </xsl:call-template>
      </title>
      <link rel="alternate" type="text/html"></link>
      <link rel="self" type="application/atom+xml"></link>
      <id>tag:syriaca.org,2013:<xsl:value-of select="@xml:id"/></id>
      <updated>
        <xsl:value-of select="t:bibl[@type='self'][1]/t:date[1]"/>
      </updated>
      <summary>
        <xsl:apply-templates select="t:desc[@type='abstract'][1]" mode="atom-out"/> 
      </summary>
      <author></author>
      <contributor></contributor>
    </entry>
    
  </xsl:template>
  
  <xsl:template match="t:*" mode="atom-out">
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:apply-templates select="." mode="text-normal"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="atom-out"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>