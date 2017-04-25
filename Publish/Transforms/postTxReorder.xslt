<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="urn:hl7-org:v3" exclude-result-prefixes="h npfitlc" xmlns:npfitlc="NPFIT:HL7:Localisation">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="h:ClinicalDocument">
		<ClinicalDocument xmlns="urn:hl7-org:v3" xmlns:npfitlc="NPFIT:HL7:Localisation">
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="*[not(@typeCode)]">
				<xsl:sort select="name(.)"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
			<xsl:for-each select="*[@typeCode]">
				<xsl:sort select="name(.)"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</ClinicalDocument>
	</xsl:template>
</xsl:stylesheet>
