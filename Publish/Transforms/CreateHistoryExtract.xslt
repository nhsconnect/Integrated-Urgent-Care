<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:npfitlc="NPFIT:HL7:Localisation" exclude-result-prefixes="n1">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<component typeCode="COMP" contextConductionInd="true">
			<section classCode="DOCSECT" moodCode="EVN">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<!-- force copy the id field-->
					<xsl:copy-of select="n1:id"/>
					<entry xmlns="urn:hl7-org:v3" typeCode="COMP" contextConductionInd="true">
						<npfitlc:contentId root="2.16.840.1.113883.2.1.3.2.4.18.16" extension="COCD_TP146091GB01#IntegratedUrgentCareHistory"/>
						<!-- create the encounter element-->
						<encounter classCode="ENC" moodCode="EVN">
							<!-- create the templateId element-->
							<templateId root="2.16.840.1.113883.2.1.3.2.4.18.2" extension="COCD_TP146091GB01#IntegratedUrgentCareHistory"/>
							<xsl:copy-of select="/n1:ClinicalDocument/n1:componentOf/n1:encompassingEncounter/n1:id"/>
							<text>
								<html xmlns="NPfIT:PresentationText">
									<head/>
									<body>
										<!-- loop through the sections and geet the title and the text from them-->
										<xsl:for-each select="/n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component/n1:section/n1:component/n1:section">
											<history>
												<title>
													<xsl:value-of select="n1:title"/>
												</title>
												<xsl:copy-of select="n1:text"/>
												<!-- If there is a nested section then get the details as well-->
												<xsl:if test="n1:component/n1:section/n1:text">
													<xsl:copy-of select="n1:component/n1:section/n1:text"/>
												</xsl:if>
											</history>
										</xsl:for-each>
									</body>
								</html>
							</text>
							<effectiveTime value="{/n1:ClinicalDocument/n1:effectiveTime/@value}"/>
							<priorityCode codeSystem="2.16.840.1.113883.2.1.3.2.4.17.325" code="{/n1:ClinicalDocument/n1:componentOf/n1:encompassingEncounter/n1:dischargeDispositionCode/@code}" displayName="{/n1:ClinicalDocument/n1:componentOf/n1:encompassingEncounter/n1:dischargeDispositionCode/@displayName}"/>
							<!-- loop through all authors if more than one-->
							<xsl:for-each select="/n1:ClinicalDocument/n1:author">
								<xsl:choose>
									<xsl:when test="n1:assignedAuthor/n1:assignedPerson/n1:name">
										<xsl:copy>
											<xsl:copy-of select="@*"/>
											<templateId extension="COCD_TP146091GB01#author" root="2.16.840.1.113883.2.1.3.2.4.18.2"/>
											<xsl:copy-of select="*"/>
										</xsl:copy>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Unknown author</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							<!-- clsoe the encounter element-->
						</encounter>
					</entry>
				</xsl:copy>
				<!-- check for existing history and append below -->
				<!--<xsl:choose>
					<xsl:when test="n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component/n1:section/n1:entry/n1:encounter">-->
						<xsl:for-each select="n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component/n1:section/n1:entry/n1:encounter">
								<xsl:choose>
									<xsl:when test="@moodCode !='APT'">
											<entry xmlns="urn:hl7-org:v3" typeCode="COMP" contextConductionInd="true">
												<npfitlc:contentId root="2.16.840.1.113883.2.1.3.2.4.18.16" extension="COCD_TP146091GB01#IntegratedUrgentCareHistory"/>
												<xsl:copy-of select="."/>
											</entry>
									</xsl:when>
								</xsl:choose>
						</xsl:for-each>
					<!--</xsl:when>
				</xsl:choose>-->
			</section>
		</component>
	</xsl:template>
</xsl:stylesheet>
