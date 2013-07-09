<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:template name="boilerplate-bottom">
        <xsl:param name="basepath">.</xsl:param>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"/>
        <script>window.jQuery || document.write('&lt;script src="js/vendor/jquery-1.9.1.min.js">&lt;\/script>')</script>
        <script src="{$basepath}/js/vendor/bootstrap.min.js"/>
        <script src="{$basepath}/js/plugins.js"/>
        <script src="{$basepath}/js/main.js"/>
        <script>
            var _gaq=[['_setAccount','UA-XXXXX-X'],['_trackPageview']];
            (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
            g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g,s)}(document,'script'));
        </script>
    </xsl:template>
</xsl:stylesheet>
