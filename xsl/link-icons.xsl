<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="xs t"
  version="2.0">
  
  <xsl:template name="link-icons">
    <xsl:variable name="placenum" select="t:idno[@type='placeID'][1]"/>
    
    <div id="link-icons">
      <xsl:for-each select="t:idno[@type='Pleiades']">
        <a href="{.}"><img src="../img/circle-pi-25.png" alt="Image of the Greek letter pi in blue; small icon of the Pleiades project" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} in Pleiades"/></a>
      </xsl:for-each>
      <xsl:for-each select="t:idno[@type='Wikipedia']">
        <a href="{.}"><img src="../img/Wikipedia-25.png" alt="The Wikipedia icon" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} in Wikipedia"/></a>
      </xsl:for-each>
      <xsl:for-each select="t:location[@type='gps']/t:geo">
        <a href="https://maps.google.com/maps?f=q&amp;hl=en&amp;q={$base}{$placeslevel}{$placenum}-atom.xml&amp;z=4"><img src="../img/gmaps-25.png" alt="The Google Maps icon" title="click to view {ancestor::t:place/t:placeName[@xml:lang='en'][1]} on Google Maps"/></a>
      </xsl:for-each>      
    </div>
  </xsl:template>
  
</xsl:stylesheet>