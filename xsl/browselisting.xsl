<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 xmlns:s="http://syriaca.org"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s"
 version="2.0">
 
 <xsl:param name="sourcedir">../../places/xml/</xsl:param>
 <xsl:variable name="colquery"><xsl:value-of select="$sourcedir"/>?select=*.xml</xsl:variable>
 <xsl:template name="do-list">
  <ul>
   <xsl:for-each select="collection($colquery)">
    <xsl:sort select="./descendant-or-self::t:TEI/t:teiHeader/descendant::t:titleStmt/t:title[ancestor-or-self::*[@xml:lang]/@xml:lang='en'][1]"/>
    <xsl:apply-templates select="./descendant-or-self::t:TEI/t:teiHeader/descendant::t:titleStmt/t:title[ancestor-or-self::*[@xml:lang]/@xml:lang='en'][1]"/>
   </xsl:for-each>
  </ul>
 </xsl:template>
 
 <xsl:template match="t:title">
  <li><xsl:value-of select="normalize-space(normalize-unicode(.))"/></li>
 </xsl:template>
</xsl:stylesheet>