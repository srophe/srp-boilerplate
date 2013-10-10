<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs"
 version="2.0">
 
 <xsl:template name="boilerplate-nav">
  <xsl:param name="app-name">CHANGE THE APP NAME</xsl:param>
  <xsl:param name="active">home</xsl:param>
  <xsl:param name="basepath">.</xsl:param>
  <div class="navbar navbar-inverse navbar-fixed-top">
   <div class="navbar-inner">
    <div class="container-fluid">
     <!-- add a navbar button for when narrow media collapses the navbar -->
     <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
     </a>
     <p class="brand"><a href="{$basepath}"><xsl:value-of select="$app-name"/></a><br/>
      <span style="font-size:.75em; font-style:italic;">Pre-Publication Draft</span>
     </p>
     <div class="nav-collapse collapse">
      <ul class="nav">
       <xsl:element name="li">
        <xsl:if test="$active='browse'">
         <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <a href="{$basepath}/browse.html">browse</a>
       </xsl:element>
       <xsl:element name="li">
        <xsl:if test="$active='about'">
         <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <a href="{$basepath}/about.html">about</a>
       </xsl:element>
       <xsl:element name="li">
        <xsl:if test="$active='help'">
         <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <a href="{$basepath}/help/index.html">help</a>
       </xsl:element>
      </ul>
      <p class="navbar-text"><a class="pull-right btn btn-info">advanced</a></p>
      <form class="navbar-search pull-right s-asearch">
       <input class="search-query" type="text" placeholder="search"/>
      </form>
      
     </div><xsl:comment>/.nav-collapse</xsl:comment>
    </div><xsl:comment>/ .container-fluid</xsl:comment>
   </div>
  </div>
 </xsl:template>
</xsl:stylesheet>