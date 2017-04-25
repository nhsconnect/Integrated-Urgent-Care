<?xml version="1.0"?>
<!--
		XSLT to convert CFH CDA like "templated" examples to true CDA - Rik
		Smithies 21/02/2007 v0.4
		Updated Tim Ireland 3/01/2009 v2.0 
	-->
<!--
		This transform is limited since it needs to know about input model
		element names. Ideally the input data would be marked up to allow
		conversion to CDA, obviating the need for an ad hoc transform that
		knows the structure of the input models. The transform is for guidance
		only, and takes several shortcuts that are currently valid but may not
		be in future. It is not suitable for production use. There are two
		main tasks in this transform. Firstly, the input message uses the CFH
		tooling schema order, which does not match that of the normative CDA
		schema (or that of the CFH CDA schema, which has been manually
		reordered to match CDA). Secondly the "templated" names are converted
		to their CDA equivalents. Since the templated name can be anything of
		the modellers choice, this transform will need continually updating.
		It does however make some sensible guesses as to which CDA element is
		meant (e.g. all classCode="OBS" are considered CDA Observations).
		Template model authors can avoid changes to this being needed by
		sticking to CDA names in models unless there is a need to change. This
		also helps the templates be understood in terms of CDA. Input files
		should not list redundant name spaces, that is, ones declared and
		never used (e.g. a common one is
		xmlns:gsd="http://aurora.regenstrief.org/GenericXMLSchema"). Otherwise
		these will get copied verbosely (but harmlessly) in the output.
	-->
<!-- todo review and remove todo comments before final release -->
<!-- todo document the rules in here in "english" -->
<!-- Known Issues -->
<!--
		Transform doesn't cover every possible participation, and doesn't cover
		every RIM attribute in CDA
	-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:npfitlc="NPFIT:HL7:Localisation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:h="urn:hl7-org:v3" xmlns:mif="urn:hl7-org:v3/mif" exclude-result-prefixes="h mif">
	<xsl:import href="postTxReorder_v2.xslt"/>
	<xsl:output encoding="UTF-8"/>
	<xsl:output method="xml"/>
	<xsl:output indent="no"/>
	<xsl:template match="@*[local-name(.)='schemaLocation']"/>
	<xsl:strip-space elements="*"/>
	<!--
		By default the transform uses the CFH CDA constrained schema.
		(typically located at ../schemas/POCD_MT000001UK01.xsd). Override this
		parameter on transformation command line to substitute another schema,
		for instance the true CDA schema, where-ever it happens to be located
		e.g.
		file:/C:/reference/hl7/CDA/CDA_R2_NormativeWebEdition/infrastructure/cda/CDA.xsd
	-->
	<xsl:param name="p_TemplateLookup" select="document('TemplateLookup.xml')/Templates"/>
	<!-- Style sheet param  -->
	<xsl:param name="sSchemaFileNameWithPath" select="'../../schemas/POCD_MT000001UK04.xsd'"/>
	<xsl:param name="bgShowWarnings" select="false()"/>
	<!-- Starts here -->
	<xsl:variable name="intermediate">
		<xsl:apply-templates select="/" mode="phase1"/>
	</xsl:variable>
	<xsl:template match="/">
		<xsl:apply-templates select="$intermediate" mode="re-order"/>
	</xsl:template>
	<!--	-->
	<!--	-->
	<!--	<xsl:template match="/">-->
	<!--		<xsl:if test="$bgShowWarnings=true()">-->
	<!--			<xsl:apply-templates select="//*[@classCode]"-->
	<!--				mode="warnings" />-->
	<!--		</xsl:if>-->
	<!--		<xsl:apply-templates select="*|comment()" />-->
	<!--	</xsl:template>-->
	<!--	-->
	<!--
		kill some implied attributes that we don't want to copy to output
	-->
	<xsl:template match="@type"/>
	<xsl:template match="@integrityCheckAlgorithm"/>
	<!--<xsl:template match="@mediaType"/>
	<xsl:template match="@representation"/>-->
	<xsl:template match="@operator"/>
	<xsl:template match="@inverted"/>
	<xsl:template match="@inclusive"/>
	<xsl:template match="@partType"/>
	<xsl:template match="@CfhTemplatedExample"/>
	<!-- kill comments as these will get out of order -->
	<xsl:template match="comment()" priority="1">
		<xsl:variable name="sCommentText">
			<xsl:value-of select="."/>
		</xsl:variable>
		<xsl:if test="contains($sCommentText,'This example message')">
			<!--
				<xsl:comment> <xsl:value-of select="$sCommentText"/> </xsl:comment>
			-->
		</xsl:if>
		<!-- special way to keep any given comment in if necessary -->
		<xsl:if test="contains($sCommentText,'Commented out')">
			<xsl:comment>
				<xsl:value-of select="$sCommentText"/>
			</xsl:comment>
		</xsl:if>
	</xsl:template>
	<!--
		identity template to copy all non-root elements unless overridden
		elsewhere
	-->
	<xsl:template match="*[not(@typeCode) and not(@classCode)]">
		<!--  should catch children of class variables.  -->
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="child::node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*[@typeCode | @classCode]" priority="-1">
		<!--  Generic class entry where no re-naming is required e.g. author participation -->
		<xsl:copy>
			<xsl:call-template name="copyChildren"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:copy>
		</xsl:copy>
	</xsl:template>
	<!--
		general template to copy all children making some generic changes
	-->
	<xsl:template name="copyChildren">
		<xsl:param name="bNoAttributes" select="false()"/>
		<xsl:param name="assocName" select="local-name(current())"/>
		<!--
			copy attributes, must come before elements (and caller must not have
			already sent out any elements)
		-->
		<xsl:if test="not($bNoAttributes)">
			<xsl:apply-templates select="@*"/>
		</xsl:if>
		<!-- show in-line comments about parent -->
		<xsl:if test="$bgShowWarnings=true()">
			<xsl:apply-templates select="." mode="warnings"/>
		</xsl:if>
		<xsl:apply-templates select="child::*[not(@typeCode)][not(@classCode)]">		
		</xsl:apply-templates>
		<!--			for associations we could use this: -->
		<xsl:apply-templates select="child::*[@typeCode | @classCode]">
		</xsl:apply-templates>
	</xsl:template>
	<!--
		kill the existing schema location, which will be replaced in
		ClinicalDocument template
	-->
	<!--
		this is necessary, to prevent it reappearing after it gets replaced
	-->
	<xsl:template match="@*[local-name(.)='schemaLocation']"/>
	<xsl:template match="h:ClinicalDocument" mode="phase1">
		<xsl:comment>
			This example message is provided for illustrative purposes only. It
			has had no clinical validation. Whilst every effort has been taken to
			ensure that the examples are consistent with the
			message specification contained within the MiM, where there are conflicts
			with the written message specification or schema, the specification
			or schema shall be considered to take
			precedence
		</xsl:comment>
		<xsl:element name="ClinicalDocument" xmlns="urn:hl7-org:v3">
			<xsl:namespace name="npfitlc" select="'NPFIT:HL7:Localisation'"/>
			<!-- insert schema location based on global parameter -->
			<xsl:attribute name="xsi:schemaLocation"><xsl:text>urn:hl7-org:v3 </xsl:text><xsl:value-of select="$sSchemaFileNameWithPath"/></xsl:attribute>
			<!-- Copy all children including attributes -->
			<!--
				note that line below this would reinsert the orignal schema
				attribute, but is prevented from doing so by the schemaLocation
				killing template above
			-->
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'ClinicalDocument'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	<!-- convert actRefs to CDA style -->
	<xsl:template match="*[@classCode]
                                                  [contains(local-name(),'Ref')]
                                                  [../h:templateId/@root='2.16.840.1.113883.2.1.3.2.4.18.2']" priority="10">
		<!--
			ActReferences of the sort used in current HL7.org Clinical Statement
			pattern, did not exist at the time CDA last was harmonised with
			Clinical Statement. CFH has a history of using ActRefs and so these
			must be modelled in CDA (even though there is no native support for
			them). In fact Clinical Statement itself just uses a cut down act
			(that has only classCode, moodCode and id) to represent an ActRef.

			CDA can approximate this using any of several of its clinical
			statement choice classes (although one of these, Act, has the
			act.code as also mandatory). Consequently, ActRefs are represented in
			CDA using an appropriate CDA clinical statement, that has 4
			attributes classCode, moodCode, id and code. Code must always be sent
			with a nullFlavor of "NA" to show it is just there for schema
			compliance. An exception is for actRefs to document parts, DOCCLIN or
			DOCSECT (used in sealing related templates. Since these can't be
			accommodated by the clinical statement choice box (the classCodes
			aren't available in there), they instead use the CDA
			reference/externalAct construct.
		-->
		<!--
			This template doesn't actually do anything that wouldn't happen
			elsewhere in the style sheet (other than adding a comment) but it
			does give a point that all actRefs pass through, so they can all be
			modified if need be e.g. to add a templateId, or to alter the data type
			to use the forthcoming id.useType
		-->
		<xsl:variable name="sActType">
			<xsl:choose>
				<xsl:when test="contains(local-name(),'TextSectionRef') or contains(local-name(),'DocumentHeaderRef')">
					<xsl:text>externalAct</xsl:text>
				</xsl:when>
				<xsl:when test="contains(local-name(),'EncompassingEncounter')">
					<xsl:text>encompassingEncounter</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<!--
							it is necessary to use the correct class, because the generic Act
							cannot have the more specific classCodes that specialised classes
							exist for
						-->
						<xsl:when test="@classCode='OBS'">
							<xsl:text>observation</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='PROC'">
							<xsl:text>procedure</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='SBADM'">
							<xsl:text>substanceAdministration</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='SPLY'">
							<xsl:text>supply</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='ENC'">
							<xsl:text>encounter</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='BATTERY'">
							<xsl:text>organizer</xsl:text>
						</xsl:when>
						<xsl:when test="@classCode='MANU'">
							<xsl:text>participantRole</xsl:text>
						</xsl:when>
						<!--
							an implementation option here would be to always to use Act,
							regardles of classCode
						-->
						<xsl:otherwise>
							<xsl:text>act</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains(local-name(),'TextSectionRef') or contains(local-name(),'DocumentHeaderRef')">
				<xsl:comment>
					This represents an ActRef to a text section
					DOCCLIN or DOCSECT
				</xsl:comment>
			</xsl:when>
			<xsl:otherwise>
				<!--
					<xsl:comment> This Act represents a clinical statement ActRef
					</xsl:comment>
				-->
			</xsl:otherwise>
		</xsl:choose>
		<xsl:element name="{$sActType}" xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="$sActType"/>
			</xsl:call-template>
			<!-- this may not be needed, and also it may already be there anyway -->
			<!--code nullFlavor="NA"/-->
			<!--
				todo it is not ideal that organizer (alone) needs statusCode here
				(needs model change to support this really)
			-->
			<xsl:if test="$sActType='organizer'">
				<!--
					may already be there in future, but not allowed now, so no check
				-->
				<xsl:comment>
					This statusCode added automatically when
					making the act reference
				</xsl:comment>
				<xsl:if test="not(h:statusCode)">
					<statusCode code="completed" xmlns="urn:hl7-org:v3"/>
				</xsl:if>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- Acts -->
	<!--
		General CDA acts are used, per classCode, with exceptions coming later
	-->
	<!-- All classCodes that are found in CFH CDA are covered -->
	<!--
		DOCCLIN itself (focal act and ParentDocument) not specifically covered
	-->
	<!--	<xsl:template match="*[@classCode='DOCBODY']">-->
	<!--		<structuredBody xmlns="urn:hl7-org:v3">-->
	<!--			<xsl:call-template name="copyChildren" />-->
	<!--			-->
	<!--		</structuredBody>-->
	<!--	</xsl:template>-->
	<xsl:template match="*[@classCode='DOCSECT']">
		<section xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'section'"/>
			</xsl:call-template>
		</section>
	</xsl:template>
	<xsl:template match="*[@classCode='OBS' or @classCode='OBSSER' or @classCode='OBSCOR']">
		<xsl:choose>
			<xsl:when test="contains(local-name(),'ObservationMedia')">
				<observationMedia xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'observationMedia'"/>
					</xsl:call-template>
				</observationMedia>
			</xsl:when>
			<xsl:otherwise>
				<observation xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'observation'"/>
					</xsl:call-template>
				</observation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[@classCode='COND']">
		<observation xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'observation'"/>
			</xsl:call-template>
		</observation>
	</xsl:template>
	<xsl:template match="*[@classCode='DGIMG']">
		<observation xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'observation'"/>
			</xsl:call-template>
		</observation>
	</xsl:template>
	<xsl:template match="*[@classCode='OBS'][@moodCode='EVN.CRT']">
		<observationRange xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'observationRange'"/>
			</xsl:call-template>
		</observationRange>
	</xsl:template>
	<!-- ROIOVL not in CFH -->
	<xsl:template match="*[@classCode='SBADM']">
		<substanceAdministration xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'substanceAdministration'"/>
			</xsl:call-template>
		</substanceAdministration>
	</xsl:template>
	<xsl:template match="*[@classCode='SPLY']">
		<supply xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'supply'"/>
			</xsl:call-template>
		</supply>
	</xsl:template>
	<xsl:template match="*[@classCode='PROC']">
		<xsl:choose>
			<xsl:when test="../@typeCode='DOC'">
				<serviceEvent xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'serviceEvent'"/>
					</xsl:call-template>
				</serviceEvent>
			</xsl:when>
			<xsl:otherwise>
				<procedure xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'procedure'"/>
					</xsl:call-template>
				</procedure>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[@classCode='ENC']">
		<xsl:choose>
			<xsl:when test="contains(local-name(),'EncompassingEncounter')">
				<encompassingEncounter xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'encompassingEncounter'"/>
					</xsl:call-template>
				</encompassingEncounter>
			</xsl:when>
			<xsl:otherwise>
				<encounter xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'encounter'"/>
					</xsl:call-template>
				</encounter>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Organizers -->
	<!-- CLUSTER not used so far (MIM 6.1) in CFH -->
	<!-- TJI according to IT all refs should be ACTS -->
	<xsl:template match="*[@classCode='BATTERY']|*[@classCode='CLUSTER']">
		<organizer xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'act'"/>
			</xsl:call-template>
		</organizer>
	</xsl:template>
	<!-- Generic Act -->
	<xsl:template match="*[@classCode='ACT']">
		<xsl:choose>
			<xsl:when test="contains(local-name(..),'inFulfillmentOf')">
				<order xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'order'"/>
					</xsl:call-template>
				</order>
			</xsl:when>
			
			<xsl:when test="contains(local-name(.),'ServiceEvent')">
				<serviceEvent xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'order'"/>
					</xsl:call-template>
				</serviceEvent>
			</xsl:when>
			
			<xsl:otherwise>
				<act xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'act'"/>
					</xsl:call-template>
				</act>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
		Act subtypes are ACCM CONS CTTEVENT INC INFRM PCPR REG SPCTRT Some are
		not anticipated in CFH
	-->
	<xsl:template match="*[@classCode='INFRM']">
		<act xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'act'"/>
			</xsl:call-template>
		</act>
	</xsl:template>
	
	<xsl:template match="*[@classCode='CONS']">
		<consent xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'act'"/>
			</xsl:call-template>
		</consent>
	</xsl:template>
	
		
	
	<xsl:template match="*[@classCode='PCPR' and not(../@typeCode='DOC')]">
		<act xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'act'"/>
			</xsl:call-template>
		</act>
	</xsl:template>
	<!--
		CFH schema sometimes adds 'prior' on to element names if RPLC is used
	-->
	<xsl:template match="h:priorParentDocument">
		<parentDocument xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'parentDocument'"/>
			</xsl:call-template>
		</parentDocument>
	</xsl:template>
	
	<xsl:template match="h:manufacturedDevice">
		<playingDevice xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'playingDevice'"/>
			</xsl:call-template>
		</playingDevice>
	</xsl:template>
	<xsl:template match="h:entry1">
		<xsl:comment>
			Here are the CRE Type list entries
		</xsl:comment>
		<entry xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entry'"/>
			</xsl:call-template>
		</entry>
	</xsl:template>
	<xsl:template match="h:entry">
		<!--		<xsl:comment>-->
		<!--			Here are the coded entries-->
		<!--		</xsl:comment>-->
		<entry xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entry'"/>
			</xsl:call-template>
		</entry>
	</xsl:template>
	<!-- Entry relationships -->
	<!--
		All things called componentN are mapped to component, similarly
		entryRelationshipN
	-->
	<!--
		Note that component in clinical statement part of CDA is _only_ for
		Organizer to Act links and not for Act to Act (which uses
		entryRelationship)
	-->
	<!-- eg components in blood pressure. -->
	<xsl:template match="*[contains(local-name(),'componentOf')][@typeCode='COMP']">
		<componentOf xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'componentOf'"/>
			</xsl:call-template>
		</componentOf>
	</xsl:template>
	<xsl:template match="*[contains(local-name(),'component') and local-name()!='componentOf'][@typeCode='COMP']">
		<component xmlns="urn:hl7-org:v3">
			<!--
				<xsl:if test="name(parent::node())='classificationSection'">
				<xsl:comment>Here is the text section</xsl:comment>
				<xsl:call-template name="copyChildren" /> </xsl:if>
			-->
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'component'"/>
			</xsl:call-template>
		</component>
	</xsl:template>
	<xsl:template match="*[contains(local-name(),'entryRelationship')]">
		<entryRelationship xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entryRelationship'"/>
			</xsl:call-template>
		</entryRelationship>
	</xsl:template>
	<!-- Participations -->
	<!-- tested for 6.1, still needed -->
	<!--
		map to general participation off the clinical statement choice, this
		may get overriden
	-->
	<!--
		Many participations and PRCP in clinical choice box maps to generic
		participant
	-->
	<!-- PRCP in clinical choice box maps to generic participant -->
	<xsl:template match="*[@typeCode='LOC' or @typeCode='SPRF' or @typeCode='DST'
                                                  or @typeCode='ORG' or @typeCode='RCV' or @typeCode='TRC'
                                                  or @typeCode='REF' or @typeCode='RESP' or @typeCode='WIT' or @typeCode='SBJ' or @typeCode='ADM' or  @typeCode='ATND' or
                                                   @typeCode='CON' or  @typeCode='DIS' or  @typeCode='REF'  ] 
                                          |*[@typeCode]/*/*[@typeCode='PRCP']
                                          |*[@typeCode='INF'][*/@classCode='ASSIGNED']">
		<!-- UPDATED TO ALLOW All  FROM x_EncounterParticipant -->
		<xsl:choose>
			<xsl:when test="contains(local-name(),'encounterParticipant')">
				<encounterParticipant xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!--
						todo temporarlily force contextControlCode to OP until model is
						fixed
					-->
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'encounterParticipant'"/>
					</xsl:call-template>
				</encounterParticipant>
			</xsl:when>
			<xsl:when test="contains(local-name(),'responsibleParty') and not(./h:time) and ../@classCode='ENC'">
				<!-- This is ok for now-->
				<responsibleParty xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!--
						todo temporarlily force contextControlCode to OP until model is
						fixed
					-->
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'responsibleParty'"/>
					</xsl:call-template>
				</responsibleParty>
			</xsl:when>
			<!-- COCD_TP146200 and COCD_TP146060 are encompassing encounter templates -->
			<xsl:when test="contains(local-name(),'location') and 
										(starts-with(./h:templateId/@extension,'COCD_TP146060') or starts-with(./h:templateId/@extension,'COCD_TP146200')
										or starts-with(./h:templateId/@extension,'COCD_TP146228') or starts-with(./h:templateId/@extension,'COCD_TP146232'))">
				<!-- do we need to change this as BT req to make more generic? this -->
				<location xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!--
						todo temporarlily force contextControlCode to OP until model is
						fixed
					-->
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'location'"/>
					</xsl:call-template>
				</location>
			</xsl:when>
			<xsl:when test="contains(local-name(),'informant') and not(descendant::h:desc)">
				<informant xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'informant'"/>
					</xsl:call-template>
				</informant>
			</xsl:when>
			<xsl:otherwise>
				<participant xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!--
						todo temporarlily force contextControlCode to OP until model is
						fixed
					-->
					<xsl:if test="@typeCode='PRCP'">
						<xsl:attribute name="contextControlCode">OP</xsl:attribute>
					</xsl:if>
					<!--
						<xsl:if test="@typeCode='INF'"> <xsl:comment> ADDED MISSING TYPEID
						</xsl:comment> <typeId root="2.16.840.1.113883.1.3"
						extension="COCD_TP000000UK01#informant" xmlns="urn:hl7-org:v3"/>
						</xsl:if>
					-->
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'participant'"/>
					</xsl:call-template>
				</participant>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- location (SDLOC, ISDLOC) is from encounter -->
	<xsl:template match="*[@classCode='SDLOC' or @classCode='ISDLOC'
                                                  or @classCode='PRS' or @classCode='ROL']">
		<!-- TJI may need to Change -->
		<xsl:choose>
			<xsl:when test="contains(local-name(),'HealthCareFacility')">
				<healthCareFacility xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!--
						todo temporarlily force contextControlCode to OP until model is
						fixed
					-->
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'healthCareFacility'"/>
					</xsl:call-template>
				</healthCareFacility>
			</xsl:when>
			<xsl:when test="(local-name(..) = 'participant') and ../../@classCode='DOCCLIN'"> <!--PRTR1 - Additional Rule to handle COCD_TP145007UK03 Related Entity template used for generic participant-->
				<associatedEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'associatedEntity'"/>
					</xsl:call-template>
				</associatedEntity>			
			</xsl:when>
			<xsl:otherwise>
				<participantRole xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'participantRole'"/>
					</xsl:call-template>
				</participantRole>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[@classCode='PAT']">
		<xsl:choose>
			<xsl:when test="contains(local-name(..),'subject')">
				<participantRole xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'participantRole'"/>
					</xsl:call-template>
				</participantRole>
			</xsl:when>
			<xsl:otherwise>
				<patientRole xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'patientRole'"/>
					</xsl:call-template>
				</patientRole>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[@typeCode='CST']/*[@classCode='ASSIGNED']">
		<assignedCustodian xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'assignedCustodian'"/>
			</xsl:call-template>
		</assignedCustodian>
	</xsl:template>
	<!-- bug fix here post MIM 6.1, could not have matched anything -->
	<xsl:template match="*[@typeCode='INF']/*[@classCode='PRS']">
		<relatedEntity xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'relatedEntity'"/>
			</xsl:call-template>
		</relatedEntity>
	</xsl:template>
	<!-- todo code to strip of SDS ?? -->
	<!--
		TODO needs to use classCode Need to try this on these 2 templates and
		regression test
	-->
	<!--<xsl:template match="*[../@typeCode='AUT'][contains(local-name(),'AssignedAuthor')]
                                                  |*[../@typeCode='AUT'][contains(local-name(),'AssignedEntity')]">
	-->
	<xsl:template match="*[../@typeCode='AUT'][contains(local-name(),'AssignedAuthor')]
                                                  |*[../@typeCode='AUT'][contains(local-name(),'AssignedEntity')]	
												  |*[../@typeCode='AUT'][contains(local-name(),'Workgroup')]">		
		<assignedAuthor xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'assignedAuthor'"/>
			</xsl:call-template>
		</assignedAuthor>
	</xsl:template>
	<xsl:template match="h:author1[@typeCode='AUT']">
		<author xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'author'"/>
			</xsl:call-template>
		</author>
	</xsl:template>
	<xsl:template match="h:participant1[@typeCode='AUT']">
		<participant xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'participant'"/>
			</xsl:call-template>
		</participant>
	</xsl:template>
	<!-- tracker off focal act -->
	<xsl:template match="//h:*[@typeCode='TRC'][../@classCode='DOCCLIN']">
		<informationRecipient xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'informationRecipient'"/>
			</xsl:call-template>
		</informationRecipient>
	</xsl:template>
	<!--
		assignedEntity is assignedEntity except when its done with the generic
		Partication
	-->
	<!-- todo use classCode instead of name (tracker should be here ?) -->
	<!--
		todo drop the not() bit and regression test it, template below should
		take priority
	-->
	<xsl:template match="*[contains(local-name(),'AssignedEntitySDS') or contains(local-name(),'ParticipantRole') or contains(local-name(),'AssignedEntity') or contains(local-name(),'AssociatedEntity')]  
									  [not(contains(local-name(..),'receiver') or contains(local-name(..),'referrer') or contains(local-name(..),'tracker') or  ../h:time)] 
                                      |*[@classCode='ASSIGNED']
                                      [../@typeCode='AUTHEN' or ../@typeCode='LA' or ../@typeCode='ENT' or ../@typeCode='INF' or ../@typeCode='PRF' or ../@typeCode='RESP'] ">
		<!-- put choice here for participation REFB?-->
		<xsl:choose>
			<xsl:when test="../@typeCode='REFB '">
				<associatedEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'associatedEntity'"/>
					</xsl:call-template>
				</associatedEntity>
			</xsl:when>
					<xsl:when test="contains(local-name(.),'ParticipantRole')">
				<participantRole xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'ParticipantRole'"/>
					</xsl:call-template>
				</participantRole>
			</xsl:when>
				<xsl:when test="contains(local-name(..),'participant') and ./../../@classCode='DOCCLIN' ">
				<associatedEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'associatedEntity'"/>
					</xsl:call-template>
				</associatedEntity>
			</xsl:when>
			<xsl:otherwise>
				<assignedEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'assignedEntity'"/>
					</xsl:call-template>
				</assignedEntity>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
		this is the role in the generic participant off clinical statement
		choice TODO refactor this to make its use more obvious
	-->
	<!-- this takes priority over generic ASSIGNED one above -->
	<xsl:template match="*[@classCode='ASSIGNED']
                                                          [contains(local-name(..),'receiver')
                                                                  or contains(local-name(..),'tracker')
                                                                  or contains(local-name(..),'referrer')
                                                                  or contains(local-name(..),'subject')
                                                                 or contains(local-name(..),'witness') or  (../h:time and ../@typeCode='RESP')  ]">
		<participantRole xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'participantRole'"/>
			</xsl:call-template>
		</participantRole>
	</xsl:template>
	<xsl:template match="*[contains(local-name(),'representedOrganization')]">
		<xsl:choose>
			<xsl:when test="contains(local-name(..),'ParticipantRole')">
				<scopingEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'scopingEntity'"/>
					</xsl:call-template>
				</scopingEntity>
			</xsl:when>
			<xsl:when test="preceding-sibling::npfitlc:recipientRoleCode or contains(local-name(..),'IntendedRecipient')">
				<receivedOrganization xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'receivedOrganization'"/>
					</xsl:call-template>
				</receivedOrganization>
			</xsl:when>
			<xsl:when test="current()[../../@typeCode='REFB'  and ../../../@classCode='DOCCLIN']">
				<scopingOrganization xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'scopingOrganization'"/>
					</xsl:call-template>
				</scopingOrganization>
			</xsl:when>
			<xsl:otherwise>
				<representedOrganization xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'representedOrganization'"/>
					</xsl:call-template>
				</representedOrganization>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- todo this template may make the one above unnecessary -->
	<!--	<xsl:template-->
	<!--		match="*[@typeCode='INF'or typeCode='PRF']/*[@classCode='ASSIGNED']/*[contains(local-name(),'representedOrganization')]">-->
	<!--		<scopingEntity xmlns="urn:hl7-org:v3">-->
	<!--			<xsl:call-template name="copyChildren" >-->
	<!--			<xsl:with-param name="assocName" select="'scopingEntity'"></xsl:with-param>-->
	<!--			</xsl:call-template>-->
	<!--		</scopingEntity>-->
	<!--	</xsl:template>-->
	<!-- todo other subtypes of PRCP could go here and in template below -->
	<xsl:template match="*[../@typeCode='PRCP' or ../@typeCode='TRC'][contains(local-name(),'AssignedEntitySDS') or contains(local-name(),'IntendedRecipient') or contains(local-name(),'RecipientWorkgroup') or contains(local-name(),'AssignedEntity')][../../@classCode='DOCCLIN']">
		<intendedRecipient xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'intendedRecipient'">
			</xsl:with-param>
			</xsl:call-template>
		</intendedRecipient>
	</xsl:template>
	<!--	-->
	<!--	<xsl:template-->
	<!--		match="*[../../@typeCode='PRCP' or ../../@typeCode='TRC'][local-name()='representedOrganization']">-->
	<!--		<receivedOrganization xmlns="urn:hl7-org:v3">-->
	<!--			<xsl:call-template name="copyChildren" >-->
	<!--			<xsl:with-param name="assocName" select="'receivedOrganization'"></xsl:with-param>-->
	<!--			</xsl:call-template>-->
	<!--		</receivedOrganization>-->
	<!--	</xsl:template>-->
	<!--	<xsl:template-->
	<!--		match="*[../../@typeCode='REFB'  and ../../../@classCode='DOCCLIN'][local-name()='representedOrganization']">-->
	<!--		<scopingOrganization xmlns="urn:hl7-org:v3">-->
	<!--			<xsl:call-template name="copyChildren" >-->
	<!--			<xsl:with-param name="assocName" select="'scopingOrganization'"></xsl:with-param>-->
	<!--			</xsl:call-template>-->
	<!--		</scopingOrganization>-->
	<!--	</xsl:template>-->
	<xsl:template match="*[@classCode='PSN']">
		<xsl:choose>
			<xsl:when test="../@classCode='PAT'">
				<patient xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'patient'"/>
					</xsl:call-template>
				</patient>
			</xsl:when>
			<xsl:when test="../../local-name(.)='participant' and ../../../@classCode='DOCCLIN'">
				<associatedPerson xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'associatedPerson'"/>
					</xsl:call-template>
				</associatedPerson>
			</xsl:when>
			<xsl:when test="contains(local-name(..),'COCD_TP145016UK')">
				<playingEntity xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'playingEntity'"/>
					</xsl:call-template>
				</playingEntity>
			</xsl:when>
			<!--			or ../../@typeCode='REF'-->
			<xsl:when test="../../@typeCode='AUT' or (../../@typeCode='PRF' and not(contains(local-name(..),'ParticipantRole')))   or ../../@typeCode='AUTHEN' or ../../@typeCode='LA' or ../../@typeCode='ENT' or (../../@typeCode='RESP' and not( ../../h:time)) or ../../@typeCode='ATND'  or  (../../../@classCode='ENC' and ../../../h:dischargeDispositionCode)">
				<!--
					problem here TJI may need to add additional particpation
					x_EncounterParticipant.
				-->
				<assignedPerson xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'assignedPerson'"/>
					</xsl:call-template>
				</assignedPerson>
			</xsl:when>
			<xsl:when test="../../@typeCode='PRCP' and not(../../../../@typeCode)">
				<!-- PRCP off root (only) has a special case entity -->
				<informationRecipient xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'informationRecipient'"/>
					</xsl:call-template>
				</informationRecipient>
			</xsl:when>
			<xsl:when test="../../@typeCode='TRC' and ../../../@classCode='DOCCLIN'">
				<informationRecipient xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'informationRecipient'"/>
					</xsl:call-template>
				</informationRecipient>
			</xsl:when>
			<xsl:when test="../../@typeCode='INF'">
				<xsl:choose>
					<xsl:when test="../@classCode='ASSIGNED' and ../*/h:desc">
						<playingEntity xmlns="urn:hl7-org:v3">
							<xsl:call-template name="copyChildren">
								<xsl:with-param name="assocName" select="'playingEntity'"/>
							</xsl:call-template>
						</playingEntity>
					</xsl:when>
					<xsl:when test="../@classCode='ASSIGNED' and not(../*/h:desc)">
						<assignedPerson xmlns="urn:hl7-org:v3">
							<xsl:call-template name="copyChildren">
								<xsl:with-param name="assocName" select="'asssignedPerson'"/>
							</xsl:call-template>
						</assignedPerson>
					</xsl:when>
					<xsl:otherwise>
						<relatedPerson xmlns="urn:hl7-org:v3">
							<xsl:call-template name="copyChildren">
								<xsl:with-param name="assocName" select="'relatedPerson'"/>
							</xsl:call-template>
						</relatedPerson>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Remaining PSNs are playingEntities -->
				<!--
					medication supply is one of these (it matches
					[../../@typeCode='RCV'])
				-->
				<playingEntity xmlns="urn:hl7-org:v3">
					<!--					<xsl:apply-templates select="@*" />-->
					<!-- TODO THIS IS A WORKAROUND FOR A MISSING TYPEID IN THE MODEL -->
					<xsl:if test="not(h:typeId)">
						<!--
							<xsl:comment> TYPEID ADDED AS A WORKAROUND </xsl:comment> <typeId
							xmlns="urn:hl7-org:v3" root="2.16.840.1.113883.1.3"
							extension="COCD_TP145006UK01#assignedPerson"/>
						-->
					</xsl:if>
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'playingEntity'"/>
					</xsl:call-template>
				</playingEntity>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[@classCode='PLC' and not(h:addr)]">
		<!-- in TRNS acts -->
		<playingEntity xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'playingEntity'"/>
			</xsl:call-template>
		</playingEntity>
	</xsl:template>
	<!-- secondary performers need careful handling -->
	<!-- todo helpful to rename the SPRF one in our models ? -->
	<xsl:template match="*[../@typeCode='SPRF'][contains(local-name(),'AssignedEntitySDS') or contains(local-name(),'ParticipantRole') or contains(local-name(),'AssignedEntity')]">
		<participantRole xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'participantRole'"/>
			</xsl:call-template>
		</participantRole>
	</xsl:template>
	<xsl:template match="*[../../@typeCode='SPRF'][contains(local-name(),'Person')]">
		<playingEntity xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'playingEntity'"/>
			</xsl:call-template>
		</playingEntity>
	</xsl:template>
	<!--
		some performers are not CDA performers and have to be modelled with
		generic participant
	-->
	<xsl:template match="h:performer">
		<!--<xsl:message>Workaround</xsl:message>-->
		<xsl:choose>
			<xsl:when test="./*[contains(local-name(),'ParticipantRole')]">
				<participant xmlns="urn:hl7-org:v3" contextControlCode="OP">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'participant'"/>
					</xsl:call-template>
				</participant>
			</xsl:when>
			<xsl:otherwise>
				<performer xmlns="urn:hl7-org:v3">
					<xsl:call-template name="copyChildren">
						<xsl:with-param name="assocName" select="'performer'"/>
					</xsl:call-template>
				</performer>
			</xsl:otherwise>
		</xsl:choose>
		<!--		<participant xmlns="urn:hl7-org:v3">-->
		<!--			<xsl:call-template name="copyChildren" >-->
		<!--			<xsl:with-param name="assocName" select="'participant'"></xsl:with-param>-->
		<!--			</xsl:call-template>-->
		<!--		</participant>-->
	</xsl:template>
	<xsl:template match="*[contains(local-name(),'scopingOrganization')  and ../../../@classCode!='DOCCLIN' ]">
		<scopingEntity xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'scopingEntity'"/>
			</xsl:call-template>
		</scopingEntity>
	</xsl:template>
	<xsl:template match="h:manufacturedManufacturedMaterial">
		<manufacturedMaterial xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'manufacturedMaterial'"/>
			</xsl:call-template>
		</manufacturedMaterial>
	</xsl:template>
	<!--
		This could be refactored to join up all templates that do
		participantRole
	-->
	<!--
		this is anything in generic participant/role, any subtype of ROL is
		allowed (though CFH doesnt use many)
	-->
	<xsl:template match="*[@typeCode]/*/*[@typeCode='PRCP']/*[@classCode='PAT' or @classCode='ASSIGNED']">
		<participantRole xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'participantRole'"/>
			</xsl:call-template>
		</participantRole>
	</xsl:template>
	<xsl:template match="//h:*[@classCode='SBADM' or @classCode='SPLY']/h:effectiveTime[h:low or h:center and not(@xsi:type)]" priority="5">
		<effectiveTime xsi:type="IVL_TS" xmlns="urn:hl7-org:v3">
			<xsl:copy-of select="@*|child::node()"/>
			<!--<xsl:call-template name="copyChildren" />-->
		</effectiveTime>
	</xsl:template>
	<xsl:template match="h:value" priority="5">
		<xsl:variable name="v_templateId" select="../h:templateId/@extension"/>
		<xsl:variable name="v_localname" select="local-name(.)"/>
		<xsl:variable name="v_test" select="$p_TemplateLookup/class[@templateId = $v_templateId]/attribute[@name=$v_localname]"/>
		<xsl:element name="value" xmlns="urn:hl7-org:v3">
			<xsl:choose>
				<!-- put a catch for observation Range? -->
				<!--			<xsl:when test=""></xsl:when>-->
				<xsl:when test="$v_test">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance">
						<xsl:value-of select="$v_test/@typeSpecialisation"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="current()[local-name(..)='estimatedDischargeDate']">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'TS'"/></xsl:attribute>
				</xsl:when>
				<xsl:when test=" (current()/@value) and not(current()/@unit)">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'BL'"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="current()[h:low or h:center and not(@xsi:type)]">
					<xsl:choose>
						<xsl:when test="current()[h:low/@unit or h:center/@unit]">
							<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'IVL_PQ'"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'IVL_TS'"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="current()[@unit and not(@xsi:type)]">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'PQ'"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="current()[string-length()&gt;0 and not(@xsi:type) and not(./*)]">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'ST'"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="current()[@root and not(@xsi:type)][current()/../@classCode='OBS']">
					<xsl:attribute name="xsi:type" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="'II'"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@*|child::node()"/>
		</xsl:element>
	</xsl:template>
	<!--
		Templated Location/Place in ServiceDeliveryLocationSDS allows saying
		xsi:type='TN' (although its not mandatory) but this is forbidden in
		CDA, so strip it (since this isn't a subtype of CDA 'PN')
	-->
	<xsl:template match="h:name[../@classCode='PLC'][contains(../h:templateId/@extension,'145008UK03')]">
		<name xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="bNoAttributes" select="true()"/>
			</xsl:call-template>
		</name>
	</xsl:template>
	<!--
		new for sealing, most things called component are actually CDA
		entryRelationships rather than component, so we need to convert.
	-->
	<xsl:template match="*[@typeCode='COMP'][starts-with(../h:templateId/@extension,'COCD_TP146044') and contains(../h:templateId/@extension,'RefusalToSeal')]">
		<entryRelationship xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entryRelationship'"/>
			</xsl:call-template>
		</entryRelationship>
	</xsl:template>
	<!--
		todo this may no longer be needed, since template below may cover it
	-->
	<xsl:template match="*[local-name()='component3'][contains(../h:templateId/@extension,'UnSealingEvent')]">
		<entryRelationship xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entryRelationship'"/>
			</xsl:call-template>
		</entryRelationship>
	</xsl:template>
	<!-- This is now needed, above may not be todo -->
	<xsl:template match="h:component3[h:requestToSeal]">
		<entryRelationship xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entryRelationship'"/>
			</xsl:call-template>
		</entryRelationship>
	</xsl:template>
	<xsl:template match="h:component3[h:requestToUnSeal]">
		<entryRelationship xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'entryRelationship'"/>
			</xsl:call-template>
		</entryRelationship>
	</xsl:template>
	<!--
		custodian could be called participant in the model, would be easier to
		read
	-->
	<xsl:template match="h:custodian[contains(local-name(..),'SealingEvent')]">
		<participant xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'participant'"/>
			</xsl:call-template>
		</participant>
	</xsl:template>
	<!-- careful of other CST which takes priority -->
	<!--
		<xsl:template match="*[starts-with(name(.),'COCD_TP145015UK') and
		contains(name(.),'AssignedWorkGroup') ]" priority="1"> TJI need to
		allow for location <participantRole xmlns="urn:hl7-org:v3">
		<xsl:call-template name="copyChildren"/> </participantRole>
		</xsl:template>
	-->
	<!-- Fixes for current modelling issues (POST MIM 6.1) -->
	<!-- TODO THIS IS A WORKAROUND FOR BUG IN TRC IN REQUESTMEDSUPPLY -->
	<xsl:template match="*[@typeCode='TRC']/@contextControlCode">
		<!-- force to mandatory correct value, our model is wrong -->
		<xsl:attribute name="contextControlCode">OP</xsl:attribute>
	</xsl:template>
	<!-- TODO THIS IS A WORKAROUND FOR BUG IN LOC IN REQUESTMEDSUPPLY -->
	<xsl:template match="*[@typeCode='LOC']/@contextControlCode">
		<!-- force to mandatory correct value, our model is wrong -->
		<xsl:attribute name="contextControlCode">OP</xsl:attribute>
	</xsl:template>
	<!--
		data enterer must have context control, doesnt have it at all in
		discharge at least
	-->
	<!--
		<xsl:template match="*[@typeCode='ENT']"> <dataEnterer
		xmlns="urn:hl7-org:v3"> <xsl:attribute
		name="contextControlCode">OP</xsl:attribute> <xsl:call-template
		name="copyChildren"/> </dataEnterer> </xsl:template>
	-->
	<!--
		organisations in authenticator/dataEnter are all wrong, remove to
		workaround representedOrganization/representedOrganizationSDS
	-->
	<xsl:template match="*[@classCode='ORG'][../../@typeCode='AUTHEN' or ../../@typeCode='ENT']">
		<!--
			<xsl:comment>WARNING - NON CONFORMANT ORGANISATION REMOVED
			</xsl:comment>
		-->
	</xsl:template>
	<!-- todo move down -->
	<!-- todo this fixes missing time and signatureCode -->
	<xsl:template match="*[@classCode='ASSIGNED'][../@typeCode='AUTHEN' or ../@typeCode='LA' or ../@typeCode='ENT']">
		<!--
			<xsl:comment> WARNING Some templates dont allow the CDA mandatory
			time and signatureCode here. Dummy values added.</xsl:comment>
		-->
		<!--
			<time xmlns="urn:hl7-org:v3"/> <xsl:if test="../@typeCode='AUTHEN' or
			../@typeCode='LA'"> <signatureCode xmlns="urn:hl7-org:v3"/> </xsl:if>
		-->
		<assignedEntity xmlns="urn:hl7-org:v3">
			<xsl:call-template name="copyChildren">
				<xsl:with-param name="assocName" select="'assignedEntity'"/>
			</xsl:call-template>
		</assignedEntity>
	</xsl:template>
	<!--
		todo this fixes the no-id error in some dataEnterer assigned entities
	-->
	<!-- also fixes lifestyle/author/assigned, no id when its mandatory -->
	<!--	<xsl:template-->
	<!--		match="*[@classCode='ASSIGNED']-->
	<!--                                                  [../@typeCode='AUTHEN' or ../@typeCode='LA' or ../@typeCode='ENT'-->
	<!--                                                          or ../@typeCode='AUT' or ../@typeCode='INF' or ../@typeCode='PRF']/h:code">-->
	<!--
			<xsl:comment> WARNING Some templates dont allow the CDA mandatory ID
			here. Dummy id added.</xsl:comment> <id
			root="2.16.840.1.113883.2.1.3.2.4.17.9999" extension="dummyid"
			xmlns="urn:hl7-org:v3"/>
		-->
	<!--		<code xmlns="urn:hl7-org:v3">-->
	<!--			<xsl:call-template name="copyChildren" />-->
	<!--		</code>-->
	<!--	</xsl:template>-->
	<!-- fix for desc being mandatory -->
	<!--
		Informant in Alcohol consumption has EntityNonSDSWithOrgSDS
		(COCD_TP145005UK01) as an option which has OrganizationSDS, with
		mandatory desc. This cords to Organization clone in CDA, which doesn’t
		have desc at all.
	-->
	<!--
		xsl:template
		match="h:informant/*[@classCode='ASSIGNED']/*[@classCode='ORG']/h:desc">
		<xsl:comment> FIX desc removed since CDA doesnt have it </xsl:comment>
		</xsl:template
	-->
	<!--
		same issue with Performer in Inform in MedicationDiscontinuation
	-->
	<xsl:template match="h:informPatient/h:performer/*[@classCode='ASSIGNED']/*[@classCode='ORG']/h:desc">
		<xsl:comment>
			FIX desc removed since CDA doesnt have
			it
		</xsl:comment>
	</xsl:template>
	<!--
		wrong typeId case in <typeId root="2.16.840.1.113883.1.3"
		extension="COCD_TP146005UK01#Location"
	-->
	<!--
		<xsl:template match="@extension[starts-with(.,'COCD_TP146005UK') and
		contains(.,'#Location')]"> <xsl:attribute
		name="extension">COCD_TP146005UK01#location</xsl:attribute>
		</xsl:template> <xsl:template
		match="@extension[starts-with(.,'COCD_TP146031UK') and
		contains(.,'Location')]"> <xsl:attribute
		name="extension">COCD_TP146031UK01#location</xsl:attribute>
		</xsl:template>
	-->
	<!-- kill incorrect mandatory contextControlCode -->
	<!--
		<xsl:template
		match="h:consumable[@typeCode='CSM']/@contextControlCode"/>
	-->
	<!-- end of main templates -->
	<!-- warnings about possible modelling problems -->
	<!-- unless a more specific warning template fires, eat this node -->
	<xsl:template match="*" mode="warnings"/>
	<!--
		Attempt to detect act to act relationships that dont use
		entryRelatioship
	-->
	<xsl:template match="*[@classCode='ACT' or @classCode='OBS' or @classCode='SBADM'
                                                          or @classCode='SPLY' or @classCode='ENC' or @classCode='PROC']
                                                  [not(contains(local-name(..), 'entryRelationship'))]
                                                  [../../@classCode]
                                                  [../../@classCode!='BATTERY']
                                                  [../../@classCode!='DOCCLIN']
                                                  [../../@classCode!='DOCSECT']" mode="warnings">
		<!-- Indent this to left margin so it stands out -->
		<xsl:comment>
			Warning : Found act-to-act relationship that
			doesn't appear to use entryRelationship
			<xsl:value-of select="local-name(..)"/>
			.
			<xsl:value-of select="local-name(.)"/>
			<xsl:text>
 
</xsl:text>
		</xsl:comment>
	</xsl:template>
</xsl:stylesheet>
