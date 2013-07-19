<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="xs saxon"
  version="2.0">
  
  <saxon:collation name="mixed" rules="&lt; a,A &lt; b,B &lt; c,C &lt; d,D &lt; e,E &lt; f,F &lt; g,G &lt; h,H &lt; i,I &lt; j,J &lt; k,K &lt; l,L &lt; m,M &lt; n,N &lt; o,O &lt; p,P &lt; q,Q &lt; r,R &lt; s,S &lt; t,T &lt; u,U &lt; v,V &lt; w,W &lt; x,X &lt; y,Y &lt; z,Z &amp; OE = Œ &amp; oe = œ &amp; a = ẵ &amp; A = Ẵ &amp; e = ễ &amp; E = Ễ &amp; a = ằ &amp; A = Ằ &amp; d = đ &amp; D = Đ &amp; a = ā &amp; A = Ā &amp; s = š &amp; S = Š &amp; u = ū &amp; U = Ū &amp; h = ḥ &amp; H = Ḥ &amp; s = ṣ &amp; S = Ṣ &amp; t = ṭ &amp; T = Ṭ &amp; i = ī &amp; I = Ī" ignore-case="yes" ignore-modifiers="yes" ignore-symbols="yes"/>
  
  <saxon:collation name="languages" rules="&lt; syr &lt; ar &lt; en &amp; en=fr &amp; en=de" ignore-case="yes" ignore-modifiers="yes" ignore-symbols="yes"/>
  
</xsl:stylesheet>