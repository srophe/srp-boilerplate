<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xs"
 version="2.0">
 
 <xsl:template name="boilerplate-footer">
  <xsl:param name="copyright-year">SET THE COPYRIGHT YEAR PARAMETER</xsl:param>
  <xsl:param name="copyright-holders">SET THE COPYRIGHT HOLDER PARAMETER</xsl:param>

  <hr/>
  <footer>
   <p><a rel="license" href="http://creativecommons.org/licenses/by/3.0/deed.en_US"><img
    alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/80x15.png"
   /></a><br/>This work is licensed under a <a rel="license"
    href="http://creativecommons.org/licenses/by/3.0/deed.en_US">Creative Commons Attribution 3.0 Unported
    License</a>. <br/>Copyright <xsl:value-of select="$copyright-holders"/>
    <xsl:value-of select="$copyright-year"/>.</p>.
  </footer>
 </xsl:template>
</xsl:stylesheet>