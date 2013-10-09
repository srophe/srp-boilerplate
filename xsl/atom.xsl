<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:a="http://www.w3.org/2005/Atom"
  xmlns:georss="http://www.georss.org/georss"
  xmlns="http://www.w3.org/2005/Atom"
  exclude-result-prefixes="xs t a"
  version="2.0">
  
  <xsl:import href="collations.xsl"/>
  <xsl:import href="place-title-std.xsl"/>
  
  <xsl:param name="sourcedir">../places/</xsl:param>
  <xsl:param name="destdir">../</xsl:param>
  <xsl:param name="latestmax">10</xsl:param>
  <xsl:param name="latestfilename">latest-atom.xml</xsl:param>  
  <xsl:param name="fullmax">0</xsl:param>
  <xsl:param name="fullfilename">full-atom.xml</xsl:param>
  <xsl:param name="normalization">NFKC</xsl:param>
  <xsl:param name="base">http://srophe.github.io/srp-places-app/</xsl:param>
  <xsl:param name="placeslevel">places/</xsl:param>
  
  <xsl:variable name="idxquery"><xsl:value-of select="$sourcedir"/>index.xml</xsl:variable>
  
  <xsl:output name="atom" encoding="UTF-8" method="xml" indent="yes" exclude-result-prefixes="xs t a"/>
  <xsl:output encoding="UTF-8" method="xml" indent="yes" exclude-result-prefixes="xs t a"/>
  
  <xsl:template name="do-atom">
    <xsl:for-each select="document($idxquery)/descendant-or-self::t:listPlace">
      <!-- default: do latest -->
      <xsl:apply-templates select="." mode="atom-out">
        <xsl:with-param name="max" select="$latestmax"/>
        <xsl:with-param name="filename" select="$latestfilename"/>
      </xsl:apply-templates>
      <!-- now do the full thing -->
      <xsl:apply-templates select="." mode="atom-out">
        <xsl:with-param name="max" select="$fullmax"/>
        <xsl:with-param name="filename" select="$fullfilename"/>
      </xsl:apply-templates>
      <!-- now do each place as a separate feed -->
      <xsl:apply-templates select="t:place" mode="atom-feed"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="t:listPlace" mode="atom-out">
    <xsl:param name="max" select="$latestmax"/>
    <xsl:param name="filename" select="$latestfilename"/>
    <xsl:result-document format="atom" href="{$destdir}{$filename}">
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
          <xsl:if test="$max=0 or ($max!=0 and not(position() &gt; $max))">
            <xsl:apply-templates select="." mode="atom-entry"/>
          </xsl:if>
        </xsl:for-each>
      </feed>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="t:place" mode="atom-feed">
        <xsl:result-document format="atom" href="{$destdir}{$placeslevel}{t:idno[@type='placeID']}-atom.xml">
          <feed xmlns="http://www.w3.org/2005/Atom">
            <title>
              <xsl:variable name="title">
                <xsl:call-template name="place-title-std">
                  <xsl:with-param name="withbdi">no</xsl:with-param>
                </xsl:call-template>                
              </xsl:variable>
              <xsl:value-of select="$title"/>
            </title>
            <link rel="self" type="application/atom+xml" href="{$base}{t:idno[@type='placeID']}-atom.xml"/>
            <id>tag:syriaca.org,2013:<xsl:value-of select="@xml:id"/></id>
            <updated>
              <xsl:value-of select="t:bibl[@type='self'][1]/t:date[1]"/>
            </updated>
            <xsl:apply-templates select="." mode="atom-entry"/>
          </feed>
        </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="t:place" mode="atom-entry">
    <entry>
      <title>
        <xsl:variable name="title">
          <xsl:call-template name="place-title-std">
            <xsl:with-param name="withbdi">no</xsl:with-param>
          </xsl:call-template>                
        </xsl:variable>
        <xsl:value-of select="$title"/>
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
      <xsl:apply-templates select="t:location[@type='gps']" mode="atom-out"/>
    </entry>
  </xsl:template>
  
  <xsl:template match="t:editor" mode="atom-out">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(.), $normalization))"/>
    <xsl:if test="not(preceding-sibling::t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name])">
      <author>
        <name>
          <xsl:value-of select="$name"/>          
        </name>
      </author>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:author" mode="atom-out">
    <xsl:variable name="name" select="normalize-space(normalize-unicode(xs:string(.), $normalization))"/>
    <xsl:if test="not(preceding-sibling::t:editor[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name]) and not(preceding-sibling::t:author[normalize-space(normalize-unicode(xs:string(.), $normalization))=$name])">
      <contributor>
        <name><xsl:value-of select="$name"/></name>
      </contributor>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:desc" mode="atom-out">
    <xsl:message>desc: <xsl:value-of select="."/></xsl:message>
      <summary><xsl:apply-templates mode="atom-out"/></summary>    
  </xsl:template>
  
  <xsl:template match="t:location[@type='gps' and t:geo]" mode="atom-out">
    <georss:where>
      <georss:point><xsl:value-of select="t:geo"/></georss:point>
    </georss:where>
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