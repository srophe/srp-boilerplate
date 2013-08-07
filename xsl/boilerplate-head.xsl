<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 xmlns:s="http://syriaca.org"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s"
 version="2.0">
 
 <xsl:variable name="n">
  <xsl:text>
</xsl:text>
 </xsl:variable>
 
 <xsl:template name="boilerplate-head">
  <xsl:param name="name-app">CHANGE THE APP NAME</xsl:param>
  <xsl:param name="name-page-short">CHANGE THE SHORT PAGE NAME</xsl:param>
  <xsl:param name="description">CHANGE THE DESCRIPTION</xsl:param>
  <xsl:param name="basepath">.</xsl:param>
  <xsl:param name="sourcedoc"/>
  <xsl:param name="titleStmt"/>
  
  <head>
   <meta charset="utf-8"/>
   <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
   <title><xsl:value-of select="$name-app"/> | <xsl:value-of select="$name-page-short"/></title>
   <xsl:if test="normalize-space(xs:string($description))!=''">
    <meta name="description" content="{normalize-space(xs:string($description))}"/>
   </xsl:if>
   <meta name="viewport" content="width=device-width"/>
   <xsl:apply-templates select="$sourcedoc/descendant::t:geo[1]" mode="json-uri"/>
   <xsl:call-template name="boilerplate-biblio">
    <xsl:with-param name="titleStmt" select="$titleStmt"/>
   </xsl:call-template>
   <link rel="stylesheet" href="{$basepath}/css/bootstrap.min.css"/>
   <xsl:value-of select="$n"/>
   <style>body{padding:10px; padding-top:70px; padding-bottom:40px;}</style>
   <xsl:value-of select="$n"/>
   <link rel="stylesheet" href="{$basepath}/css/bootstrap-responsive.min.css"/>
   <link rel="stylesheet" href="{$basepath}/css/main.css"/>
   <xsl:value-of select="$n"/>
   <script src="{$basepath}/js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"/>   
   <xsl:value-of select="$n"/>
   <script src='http://isawnyu.github.com/awld-js/lib/requirejs/require.min.js' type='text/javascript'></script>
   <xsl:value-of select="$n"/>
   <script src='http://isawnyu.github.com/awld-js/awld.js?autoinit' type='text/javascript'></script>
  </head>
 </xsl:template>
 
 <xsl:template name="boilerplate-biblio">
  <xsl:param name="titleStmt"/>
  <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />
  <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" />
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.subject</xsl:with-param>
   <xsl:with-param name="textcontent">Geography, Ancient</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.type</xsl:with-param>
   <xsl:with-param name="textcontent">Text</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.isPartOf</xsl:with-param>
   <xsl:with-param name="textcontent">The Syriac Gazetteer</xsl:with-param>
  </xsl:call-template>
  <xsl:if test="xs:string($titleStmt)!=''">
   <xsl:apply-templates select="$titleStmt/t:*" mode="b"/>
   <xsl:apply-templates select="$titleStmt/../t:publicationStmt" mode="b"/>
  </xsl:if>
 </xsl:template>
 
 <xsl:template match="t:publicationStmt" mode="b">
  <xsl:apply-templates select="t:*" mode="b"/>
 </xsl:template>
 
 <xsl:template match="t:title[@level='m']" mode="b"/>
 
 <xsl:template match="t:title[@level='a']" mode="b">
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.title</xsl:with-param>
   <xsl:with-param name="content" select="."/>
  </xsl:call-template>
 </xsl:template>
 
 <xsl:template match="t:authority | t:publisher" mode="b">
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.publisher</xsl:with-param>
   <xsl:with-param name="content" select="."/>
  </xsl:call-template>
 </xsl:template>
 
 <xsl:template match="t:availability" mode="b">
  <xsl:apply-templates select="t:*" mode="b"/>
 </xsl:template>
 
 <xsl:template match="t:licence[@target]" mode="b">
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.rights</xsl:with-param>
   <xsl:with-param name="content" select="."/>
  </xsl:call-template>
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DCTERMS.license</xsl:with-param>
   <xsl:with-param name="textcontent" select="@target"/>
  </xsl:call-template>
 </xsl:template>
 
 <xsl:template match="t:date" mode="b">
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.date</xsl:with-param>
   <xsl:with-param name="content" select="."/>
  </xsl:call-template>
 </xsl:template>
 
 <xsl:template match="t:idno[@type='URI']"  mode="b">
  <xsl:call-template name="meta-out">
   <xsl:with-param name="name">DC.identifier</xsl:with-param>
   <xsl:with-param name="textcontent" select="substring-before(., $teiuripostfix)"/>
  </xsl:call-template>
  
 </xsl:template>
 
 <xsl:template match="t:editor" mode="b">
  <xsl:variable name="name" select="xs:string(.)"/>
  <xsl:if test="not(preceding::t:editor=$name)">
   <xsl:call-template name="meta-out">
    <xsl:with-param name="name">DC.creator</xsl:with-param>
    <xsl:with-param name="content" select="."/>
   </xsl:call-template>
  </xsl:if>
 </xsl:template>
 
 <xsl:template match="t:respStmt" mode="b">
  <xsl:variable name="name" select="xs:string(t:name)"/>
  <xsl:if test="not(ancestor-or-self::t:titleStmt/t:editor=$name)">
   <xsl:call-template name="meta-out">
    <xsl:with-param name="name">DC.contributor</xsl:with-param>
    <xsl:with-param name="content" select="t:name"/>
   </xsl:call-template>
  </xsl:if>
 </xsl:template>
 
 <!-- suppress these -->
 <xsl:template match="t:funder | t:principal | t:sponsor" mode="b"/>
 
 <xsl:template match="t:*" mode="b">
  <xsl:call-template name="log">
   <xsl:with-param name="msg">
    <xsl:text>suppressed element with template match=t:* mode=b in boilerplate-head.xsl</xsl:text>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>
  
  <xsl:template name="meta-out">
   <xsl:param name="name"/>
   <xsl:param name="itemprop"/>
   <xsl:param name="content"/>
   <xsl:param name="textcontent"/>
   <xsl:element name="meta">
    <xsl:attribute name="name">
     <xsl:value-of select="$name"/>
    </xsl:attribute>
    <xsl:attribute name="property">
     <xsl:value-of select="lower-case($name)"/>
    </xsl:attribute>
    <xsl:if test="$itemprop!=''">
     <xsl:attribute name="itemprop">
      <xsl:value-of select="$itemprop"/>
     </xsl:attribute>
    </xsl:if>
    <xsl:choose>
     <xsl:when test="$textcontent=''">
      <xsl:attribute name="lang">
       <xsl:value-of select="$content/ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
      </xsl:attribute>     
      <xsl:attribute name="content">
       <xsl:value-of select="normalize-space($content)"/>
      </xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="content">
       <xsl:value-of select="$textcontent"/>
      </xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>