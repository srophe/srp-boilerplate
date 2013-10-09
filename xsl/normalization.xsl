<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 xmlns:local="http://syriaca.org/ns"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t"
 version="2.0">
 
 <!-- 
  Function to output dates in correct formats passes whole element to function, 
  function also uses trim-date to strip leading 0
 -->
 <xsl:function name="local:do-dates">
  <xsl:param name="element" as="node()"/>
  <xsl:if test="$element/@when or $element/@notBefore or $element/@notAfter or $element/@from or $element/@to">
   (<xsl:choose>
    <!-- Formats to and from dates -->
    <xsl:when test="$element/@from">
     <xsl:choose>
      <xsl:when test="$element/@to">
       <xsl:value-of select="local:trim-date($element/@from)"/>-<xsl:value-of select="local:trim-date($element/@to)"/> 
      </xsl:when>
      <xsl:otherwise>from <xsl:value-of select="local:trim-date($element/@from)"/></xsl:otherwise>
     </xsl:choose>
    </xsl:when>
    <xsl:when test="$element/@to">to <xsl:value-of select="local:trim-date($element/@to)"/></xsl:when>
   </xsl:choose>
   <!-- Formats notBefore and notAfter dates -->
   <xsl:if test="$element/@notBefore">
    <!-- Adds comma if there are other dates -->
    <xsl:if test="$element/@to or $element/@from">, </xsl:if>not before <xsl:value-of select="local:trim-date($element/@notBefore)"/>
   </xsl:if>
   <xsl:if test="$element/@notAfter">
    <!-- Adds comma if there are other dates -->
    <xsl:if test="$element/@to or $element/@from or $element/@notBefore">, </xsl:if>not after <xsl:value-of select="local:trim-date($element/@notAfter)"/>
   </xsl:if>
   <!-- Formats when, single date -->
   <xsl:if test="$element/@when">
    <!-- Adds comma if there are other dates -->
    <xsl:if test="$element/@to or $element/@from or $element/@notBefore or $element/@notAfter">, </xsl:if>
    <xsl:value-of select="local:trim-date($element/@when)"/>
   </xsl:if>)
   </xsl:if>
 </xsl:function>
 
 <!-- Date function to remove leading 0s -->
 <xsl:function name="local:trim-date">
  <xsl:param name="date"/>
  <xsl:choose>
   <!-- NOTE: This can easily be changed to display BCE instead -->
   <!-- removes leading 0 but leaves -  -->
   <xsl:when test="starts-with($date,'-0')">
    <xsl:value-of select="concat('-',substring($date,3))"/>
   </xsl:when>
   <!-- removes leading 0 -->
   <xsl:when test="starts-with($date,'0')">
    <xsl:value-of select="substring($date,2)"/>
   </xsl:when>
   <!-- passes value through without changing it -->
   <xsl:otherwise>
    <xsl:value-of select="$date"/>
   </xsl:otherwise>
  </xsl:choose>
<!--  <xsl:value-of select="string(number($date))"/>-->
 </xsl:function>
 
 <!-- Function for adding footnotes -->
 <xsl:function name="local:do-refs" as="node()">
  <xsl:param name="refs"/>
  <xsl:param name="lang"/>
  <!-- 
   <bdi class="footnote-refs" dir="ltr"> <span class="footnote-ref"><a href="#bib78-5">5</a></span></bdi>
   NOTE: check to see if this is the real rule accross footnotes, otherwise it will need to get more complicated.
  -->
  <bdi class="footnote-refs" dir="ltr">
   <xsl:if test="$lang != 'en'">
    <xsl:attribute name="lang">en</xsl:attribute>
    <xsl:attribute name="xml:lang">en</xsl:attribute>
   </xsl:if>
    <xsl:for-each select="tokenize($refs,' ')">
     <span class="footnote-ref">
      <xsl:text> </xsl:text>
      <a href="{.}"><xsl:value-of select="substring-after(.,'-')"/></a><xsl:if test="position() != last()">,<xsl:text> </xsl:text></xsl:if>
     </span>
    </xsl:for-each>
  </bdi>
 </xsl:function>
 
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