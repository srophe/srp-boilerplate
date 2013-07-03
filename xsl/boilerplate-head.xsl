<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:t="http://www.tei-c.org/ns/1.0"
 xmlns:s="http://syriaca.org"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs t s"
 version="2.0">
 
 <xsl:template name="boilerplate-head">
  <xsl:param name="name-app">CHANGE THE APP NAME</xsl:param>
  <xsl:param name="name-page-short">CHANGE THE SHORT PAGE NAME</xsl:param>
  <xsl:param name="description">CHANGE THE DESCRIPTION</xsl:param>
  <xsl:param name="basepath">.</xsl:param>
  <head>
   <meta charset="utf-8"/>
   <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
   <title><xsl:value-of select="$name-app"/> | <xsl:value-of select="$name-page-short"/></title>
   <meta name="description" content="{$description}"/>
   <meta name="viewport" content="width=device-width"/>
   <link rel="stylesheet" href="{$basepath}/css/bootstrap.min.css"/>
   <style>
    body{
     padding:10px;
     padding-top:70px;
     padding-bottom:40px;
    }</style>
   <link rel="stylesheet" href="{$basepath}/css/bootstrap-responsive.min.css"/>
   <link rel="stylesheet" href="http://fonts.googleapis.com/earlyaccess/amiri.css" type="text/css"/>
    
   <link rel="stylesheet" href="{$basepath}/css/main.css"/>

   <script src="{$basepath}/js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"/>
  </head>
   
 </xsl:template>
</xsl:stylesheet>