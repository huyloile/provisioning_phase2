<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
    method="text"/>

<xsl:template match="ListeClient">
  <xsl:for-each select="Client">
    <xsl:if test="@etatDossier=70">
      <xsl:for-each select="AttributClient">
	<xsl:if test="@nomAttribut='IMSI'">
	  <xsl:value-of select="."/>
	</xsl:if>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
