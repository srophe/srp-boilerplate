<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:a="http://www.w3.org/2005/Atom"
  xmlns="http://www.w3.org/2005/Atom"
  exclude-result-prefixes="xs t a"
  version="2.0">
  
  <xsl:import href="collations.xsl"/>
  <xsl:import href="place-title-std.xsl"/>
  
  <xsl:param name="sourcedir">../places/</xsl:param>
  
  <xsl:param name="destdir">../places/</xsl:param>
  
  <xsl:param name="normalization">NFKC</xsl:param>
  <xsl:param name="base">http://srophe.github.io/srp-places-app/</xsl:param>
  <xsl:param name="placeslevel">places/</xsl:param>
  <xsl:variable name="idxquery"><xsl:value-of select="$sourcedir"/>index.xml</xsl:variable>
  
  <xsl:output name="atom" encoding="UTF-8" method="xml" indent="yes" exclude-result-prefixes="#all"/>
  
  <xsl:template name="do-atom">
    <xsl:for-each select="document($idxquery)/descendant-or-self::t:listPlace">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="t:listPlace">
    <xsl:message>whoop</xsl:message>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>The Syriac Gazetteer: Latest Updates</title>
      <link rel="self" type="application/atom+xml" href="{$base}latest-atom.xml"/>
      <id>tag:syriaca.org,2013:gazetteer-latest</id>
      <updated>
        <xsl:for-each select="t:place">
          <xsl:sort select="xs:date(t:bibl[@type='self'][1]/t:date)" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="xs:date(t:bibl[@type='self'][1]/t:date)"/>
          </xsl:if>
        </xsl:for-each>
      </updated>
      <xsl:for-each select="t:place">
        <xsl:sort select="xs:date(t:bibl[@type='self'][1]/t:date)" order="descending"/>
        <xsl:sort select="t:placeName[@xml:lang='en'][1]" collation="mixed"/>
        <xsl:if test="not(position() &gt; 10)">
          <xsl:message><xsl:value-of select="t:idno[@type='SRP']"/></xsl:message>
          <xsl:apply-templates select="." mode="atom-out"/>
        </xsl:if>
        
        <xsl:result-document href="{$destdir}{t:idno[@type='placeID']}-atom.xml">
          <feed xmlns="http://www.w3.org/2005/Atom">
            <title>
              <xsl:call-template name="place-title-std">
                <xsl:with-param name="withbdi">no</xsl:with-param>
              </xsl:call-template>
            </title>
            <link rel="self" type="application/atom+xml" href="{$base}{t:idno[@type='placeID']}-atom.xml"/>
            <id>tag:syriaca.org,2013:<xsl:value-of select="@xml:id"/></id>
            <updated>
              <xsl:value-of select="t:bibl[@type='self'][1]/t:date[1]"/>
            </updated>
            <xsl:apply-templates select="." mode="atom-out"/>
          </feed>
        </xsl:result-document>
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
      <link rel="alternate" type="text/html" href="{$base}{$placeslevel}{t:idno[@type='placeID']}.html"></link>
      <link rel="self" type="application/atom+xml" href="{$base}{$placeslevel}{t:idno[@type='placeID']}-atom.xml"></link>
      <id>tag:syriaca.org,2013:<xsl:value-of select="@xml:id"/></id>
      <updated>
        <xsl:value-of select="t:bibl[@type='self'][1]/t:date[1]"/>
      </updated>
      <xsl:apply-templates select="t:desc[@type='abstract'][1]" mode="atom-out"/> 
      <xsl:apply-templates select="t:bibl[@type='self'][1]/t:editor" mode="atom-out"/>
      <xsl:apply-templates select="t:bibl[@type='self'][1]/t:author" mode="atom-out"/>
    </entry>
    
  </xsl:template>
  
  <xsl:template match="t:editor" mode="atom-out">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(.), $normalization))"/>
    <xsl:if test="not(preceding-sibling::t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name])">
      <author><xsl:value-of select="$name"/></author>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:author" mode="atom-out">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(.), $normalization))"/>
    <xsl:if test="not(preceding-sibling::t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name]) and not(preceding-sibling::t:author[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name])">
      <contributor><xsl:value-of select="$name"/></contributor>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:desc" mode="atom-out">
    <xsl:message>desc: <xsl:value-of select="."/></xsl:message>
      <summary><xsl:apply-templates mode="atom-out"/></summary>    
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
  
  <xsl:template match="text()" mode="atom-out">
    <xsl:apply-templates select="." mode="text-normal"/>
  </xsl:template>
  
  <xsl:template match="*"/>
</xsl:stylesheet>