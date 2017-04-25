<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="urn:hl7-org:v3" xmlns:npfitlc="NPFIT:HL7:Localisation" xmlns:n2="urn:hl7-org:v3/meta/voc" xmlns:voc="urn:hl7-org:v3/voc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="NPfIT:PresentationText"  exclude-result-prefixes="n1 n2 voc npfitlc xsi">
	<xsl:output method="html" indent="yes" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>
	<!-- CDA document Renderer for copy recipients only i.e. when typeCode = 'TRC'-->
	<xsl:param name="debug" select="'no'"/>
	<xsl:template match="/">
		<html>
			<head>
				<xsl:comment>$trasformVersion=1.0 $updateDate=29/06/2012 Interoperability Team</xsl:comment>
				<xsl:comment>$trasformVersion=1.0 $updateDate=12/10/2012 Interoperability Team - branched for NHS111</xsl:comment>
				<!-- <meta name='Generator' content='&CDA-Stylesheet;'/> -->
				<title>
					Patient Journey
				</title>
				<style type="text/css">
						body { color: #000000; font-size: 8pt; line-height: normal; font-family: Verdana, Arial, sans-serif; margin: 10px; }
						a { color: #0099ff; text-decoration: none }
						.input { color: #003366; font-size: 8pt; font-family: Verdana, Arial, sans-serif;  border: solid 1px }
						div.titlebar {  border: 1px solid #000000; padding: 3px; margin-bottom: 20px;}
						div.doctitle { font-size: 12pt; font-weight: bold; margin-bottom: 10px;}
						div.header { font-size: 8pt; margin-bottom: 30px; border: 1px solid #000000; }
						div.footer { font-size: 8pt; margin-top: 30px; border: 1px solid #000000; }
						p {margin-top: 2px; margin-bottom: 6px;}
						h1 { font-size: 10pt; font-weight: bold; color: #000000; margin-top: 20px; margin-bottom: 10px; border-bottom: 1px solid #CCCCCC;}
						h2 { font-size: 8pt; font-weight: bold; color: #000000; margin-top: 20px; margin-bottom: 6px; }
						h3 { font-size: 8pt; font-weight: bold; color: #000000; margin-top: 15px; margin-bottom: 6px; }
						h4 { font-size: 8pt; font-weight: bold; text-decoration: underline; color: #000000; margin-top: 6px; margin-bottom: 6px; }
						h5 { font-size: 8pt; font-weight: normal; text-decoration: underline;  color: #000000; margin-top: 4px; margin-bottom: 4px; }
						h6 { font-size: 8pt; font-weight: normal; color: #000000; margin-top: 2px; margin-bottom: 2px; }
						table { border: 1px solid #000000; }
						th.default {font-size: 8pt;padding: 3px; color: #000000;  text-align: left;}
						th {font-size: 8pt;padding: 3px; color: #000000; }
						td {font-size: 8pt;padding: 3px; }
						table.titlebar { border: 0px;  }
						td.titlebar {font-size: 8pt;color: #000000;  font-weight: bold;}
						th.titlebar {font-size: 8pt;color: #000000;  font-weight: normal; font-style: italic; text-align: left;}
						th.sectitle {font-size: 8pt;color: #000000;  font-weight: bold; text-align: left;}
						th.participant {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table.header { font-size: 8pt;border: 0px;  }
						td.header {font-size: 8pt;color: #000000;  font-weight: bold;}
						th.header {font-size: 8pt;color: #000000;  font-weight: normal; text-align: left; font-style:italic;}
						/*Classes below map to CDA styleCodes*/
						.Bold {font-weight: bold;}
						.Underline {text-decoration:underline;}
						.Italics {font-style:italic;}
						.Emphasis {font-style:italic;}
						.Rrule {border-right: 1px solid black;}
						.Lrule {border-left: 1px solid black;}
						.Toprule {border-top: 1px solid black;}
						.Botrule {border-right: 1px solid black;}
						/*Banner styles*/
						div.banner { font-size: 8pt; margin-bottom: 30px; border: 1px solid #000000; }
						div.banner TABLE { border: 0px;  font-weight: bold; }
						div.banner TD {  vertical-align: top; padding-right: 1em;}
						/*div.banner TABLE P {margin: 0;}*/
						.label {font-style:italic; font-weight: normal;}
						#hist{width:100%;}
						div.banner #hist td {font-size: 8pt;color: #000000;  font-weight: normal; font-style: italic; text-align: left;}
						div.banner #hist th {font-size: 8pt;color: #000000;  font-weight: normal; font-style: italic; text-align: left;}
						table#hist #journdate {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table#hist #disposition {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table#hist #caseid {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table#hist #caseref {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table#hist #jauthor {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						table#hist #advice content[styleCode="bold"] {font-size: 8pt;color: #000000;  font-weight: bold; font-style: italic; text-align: left;}
						
						

				</style>
			</head>
			<xsl:comment>Derived from HL7 Finland R2 Tyylitiedosto: Tyyli_R2_B3_01.xslt</xsl:comment>
			<xsl:comment>Updated by Calvin E. Beebe, Mayo Clinic - Rochester Mn. </xsl:comment>
			<xsl:comment>Updated by Keith W. Boone, Dictaphone - Burlington, MA </xsl:comment>
			<xsl:comment>Updated by Kai U. Heitmann, Heitmann Consulting &amp; Service, NL for VHitG, Germany </xsl:comment>
			<xsl:comment>Updated by Rene Spronk, translate back to english-language labels</xsl:comment>
			<xsl:comment>Updated by Dick Donker, Philips Medical Systems include linkHtml</xsl:comment>
			<xsl:comment>Updated by Tim Pilkington - NHS CFH</xsl:comment>
			<xsl:comment>Updated by Aled Greenhalgh - NHS CFH</xsl:comment>
			<xsl:comment>Updated by Prashant Trivedi - NHS CFH</xsl:comment>
			<xsl:comment>Updated by Dave Barnet - branched for NHS111</xsl:comment>
			<body>
			<!--javascript to toggle the history section-->
			<!--<script language="javascript"> 
					function toggle() {
						var ele = document.getElementById("existingHistory");
						if(ele.style.display == "block") {
								ele.style.display = "none";
						}
						else {
							ele.style.display = "block";
						}
					} 
			</script>-->
				<!--moved title to here daba-->

				<xsl:call-template name="history"/>
				
			</body>
		</html>
	</xsl:template>
	<!-- Get a Name  -->
	<xsl:template name="getName">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name/n1:family">
				<xsl:if test="$name/n1:prefix">
					<xsl:value-of select="$name/n1:prefix"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$name/n1:given"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$name/n1:family"/>
				<xsl:if test="$name/n1:suffix">
					<xsl:text> </xsl:text>
					<xsl:value-of select="$name/n1:suffix"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:variable name="month" select="substring ($date, 5, 2)"/>
		<xsl:value-of select="substring ($date, 7, 2)"/>
		<xsl:if test="substring ($date, 7, 2)">
			<xsl:text>-</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$month='01'">
				<xsl:text>Jan</xsl:text>
			</xsl:when>
			<xsl:when test="$month='02'">
				<xsl:text>Feb</xsl:text>
			</xsl:when>
			<xsl:when test="$month='03'">
				<xsl:text>Mar</xsl:text>
			</xsl:when>
			<xsl:when test="$month='04'">
				<xsl:text>Apr </xsl:text>
			</xsl:when>
			<xsl:when test="$month='05'">
				<xsl:text>May</xsl:text>
			</xsl:when>
			<xsl:when test="$month='06'">
				<xsl:text>Jun</xsl:text>
			</xsl:when>
			<xsl:when test="$month='07'">
				<xsl:text>Jul</xsl:text>
			</xsl:when>
			<xsl:when test="$month='08'">
				<xsl:text>Aug</xsl:text>
			</xsl:when>
			<xsl:when test="$month='09'">
				<xsl:text>Sep</xsl:text>
			</xsl:when>
			<xsl:when test="$month='10'">
				<xsl:text>Oct</xsl:text>
			</xsl:when>
			<xsl:when test="$month='11'">
				<xsl:text>Nov</xsl:text>
			</xsl:when>
			<xsl:when test="$month='12'">
				<xsl:text>Dec</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="substring ($date, 1, 4)"/>
		<xsl:if test="string-length($date)>8">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="substring ($date, 9, 2)"/>
			<xsl:text>:</xsl:text>
			<xsl:value-of select="substring ($date, 11, 2)"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="n1:component/n1:nonXMLBody">
		<xsl:choose>
			<!-- if there is a reference, use that in an IFRAME -->
			<xsl:when test="n1:text/n1:reference">
				<IFRAME name="nonXMLBody" id="nonXMLBody" WIDTH="100%" HEIGHT="66%" src="{n1:text/n1:reference/@value}"/>
			</xsl:when>
			<xsl:when test="n1:text/@mediaType='text/plain'">
				<pre>
					<xsl:value-of select="n1:text/text()"/>
				</pre>
			</xsl:when>
			<xsl:otherwise>
				<CENTER>Cannot display the text</CENTER>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Component/Section -->
	<xsl:template match="n1:component/n1:section">
		<xsl:if test="n1:title != ''">
			<xsl:apply-templates select="n1:title"/>
		</xsl:if>
		<xsl:apply-templates select="n1:text"/>
		<xsl:apply-templates select="n1:component/n1:section"/>
	</xsl:template>
	<xsl:template match="n1:entry">
		<xsl:variable name="v_codedentry" select="child::node()[child::n1:templateId[contains(@extension,'146')]]"/>
		<p>
			<xsl:value-of select="substring-after($v_codedentry/n1:templateId/@extension,'#')"/> - <xsl:value-of select="substring-before($v_codedentry/n1:templateId/@extension,'#')"/>
		</p>
		<p>Code : <xsl:value-of select="$v_codedentry/n1:code/@code"/>
		</p>
		<p>Displayname : <xsl:value-of select="$v_codedentry/n1:code/@displayName"/>
		</p>
		<xsl:for-each select="$v_codedentry/n1:code/n1:qualifier">
			<p>qualifier</p>
			<p>name code=&quot;<xsl:value-of select="n1:name/@code"/>&quot; displayName=&quot;<xsl:value-of select="n1:name/@displayName"/>&quot;</p>
			<p>value code=&quot;<xsl:value-of select="n1:value/@code"/>&quot; displayName=&quot;<xsl:value-of select="n1:value/@displayName"/>&quot;</p>
		</xsl:for-each>
		<xsl:if test="$v_codedentry/n1:code/n1:originalText/n1:reference">
			<p>Reference : 
				<xsl:choose>
					<xsl:when test="contains($v_codedentry/n1:code/n1:originalText/n1:reference/@value,'#')">
						<a>
							<xsl:attribute name="id"><xsl:value-of select="substring-after($v_codedentry/n1:code/n1:originalText/n1:reference/@value,'#')"/></xsl:attribute>
							<xsl:value-of select="$v_codedentry/n1:code/n1:originalText/n1:reference/@value"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$v_codedentry/n1:code/n1:originalText/n1:reference/@value"/>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</xsl:if>
		<p>Status: <xsl:value-of select="$v_codedentry/n1:statusCode/@code"/>
		</p>
		<p>Time:
		<xsl:if test="$v_codedentry/n1:effectiveTime/n1:low/@value">
				<xsl:call-template name="formatDate">
					<xsl:with-param name="date" select="$v_codedentry/n1:effectiveTime/n1:low/@value"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$v_codedentry/n1:effectiveTime/n1:high/@value">
				<xsl:text> to </xsl:text>
				<xsl:call-template name="formatDate">
					<xsl:with-param name="date" select="$v_codedentry/n1:effectiveTime/n1:high/@value"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$v_codedentry//n1:effectiveTime/n1:center/@value">
				<xsl:call-template name="formatDate">
					<xsl:with-param name="date" select="$v_codedentry/n1:effectiveTime/n1:center/@value"/>
				</xsl:call-template>
			</xsl:if>
		</p>
		<hr/>
	</xsl:template>

	<!--   Title  -->

	<!--   Text   -->
	<xsl:template match="n1:text">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Link Html -->
	<xsl:template match="n1:linkHtml">
		<xsl:element name="a">
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates/>
			<!--<xsl:for-each select="l@*">
   			<xsl:if test="not(name()=&quot;originator&quot; or name()=&quot;confidentiality&quot;)">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:if>
		</xsl:for-each> -->
			<xsl:value-of select="link_html"/>
		</xsl:element>
	</xsl:template>

	<!--   paragraph  -->

	<!--   paragraph  -->
	<xsl:template match="n1:br">
		<br/>
	</xsl:template>
	<!--     Content w/ deleted text is hidden -->
	<xsl:template match="n1:content[@revised='delete']"/>
	<!--   content  -->
	
	<!--   list  -->
	<xsl:template match="n1:list">
		<xsl:if test="n1:caption">
			<span style="font-weight:bold; ">
				<xsl:apply-templates select="n1:caption"/>
			</span>
		</xsl:if>
		<ul>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	<xsl:template match="n1:list[@listType='ordered']">
		<xsl:if test="n1:caption">
			<span style="font-weight:bold; ">
				<xsl:apply-templates select="n1:caption"/>
			</span>
		</xsl:if>
		<ol>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ol>
	</xsl:template>
	<!--   caption  -->
	<xsl:template match="n1:caption">
		<xsl:apply-templates/>
		<xsl:text>: </xsl:text>
	</xsl:template>
	<!--      Tables   -->
	<xsl:variable name="debugRowLabelWidth">150px</xsl:variable>
	<xsl:template match="n1:table">
		<table>
			<xsl:if test="$debug='yes' and count(descendant::n1:tr[@ID]|child::n1:thead[@ID]|child::n1:tfoot[@ID]|child::n1:tbody[@ID]|child::n1:thead[@ID]) > 0">
				<xsl:attribute name="style">margin-left: <xsl:value-of select="$debugRowLabelWidth"/>;</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	<xsl:template match="n1:thead">
		<thead>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</thead>
	</xsl:template>
	<xsl:template match="n1:tfoot">
		<tfoot>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</tfoot>
	</xsl:template>
	<xsl:template match="n1:tbody">
		<tbody>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</tbody>
	</xsl:template>
	<xsl:template match="n1:colgroup">
		<colgroup>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</colgroup>
	</xsl:template>
	<xsl:template match="n1:col">
		<col>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</col>
	</xsl:template>
	<xsl:template match="n1:tr">
		<tr>
			<xsl:copy-of select="@*"/>
			<xsl:if test="$debug='yes'">
				<xsl:attribute name="style">position:relative;</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	<xsl:template match="n1:th">
		<th>
			<!--@* except @styleCode is better but is 2.0 only -->
			<xsl:copy-of select="@*[not(local-name()='styleCode')]"/>
			<xsl:attribute name="class"><xsl:value-of select="@styleCode"/></xsl:attribute>
			<xsl:if test="not(@align)">
				<xsl:attribute name="class">default</xsl:attribute>
			</xsl:if>
			<xsl:if test="$debug='yes' and position() = 1">
				<xsl:call-template name="RenderRowDebugLabel"/>
			</xsl:if>
			<xsl:apply-templates/>
		</th>
	</xsl:template>

	<xsl:template match="n1:table/n1:caption">
		<span style="font-weight:bold; ">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template name="RenderRowDebugLabel">
		<xsl:if test="ancestor::n1:*[@ID]">
			<div style="position: relative;">
				<div>
					<xsl:attribute name="style">
						position:absolute; left: -<xsl:value-of select="$debugRowLabelWidth"/>;
						color: red; font-weight: bold;
					</xsl:attribute>
					<xsl:value-of select="ancestor::n1:*/@ID"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	<!--   RenderMultiMedia 
    
    this currently only handles GIF's and JPEG's.  It could, however,
    be extended by including other image MIME types in the predicate
    and/or by generating <object> or <applet> tag with the correct
    params depending on the media type  @ID  =$imageRef  referencedObject
    -->

	
	<!--    Superscript or Subscript   -->
	<xsl:template match="n1:sup">
		<xsl:element name="sup">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="n1:sub">
		<xsl:element name="sub">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<!--  Header  -->
	<!--  Title Bar  -->

	<xsl:template name="history">
					
			<xsl:if test="n1:component/n1:section/n1:entry/n1:encounter">
			
				
				<div id="existingHistory" class="fieldsetContainer">

				<h4>
					<xsl:text>Patient Journey</xsl:text>
				</h4>
				<div>
					<xsl:for-each select="/n1:entry/n1:encounter">
						<xsl:sort order="descending" select="n1:effectiveTime/@value"/>
						<table id="hist">
							<tr>
								<th>Date/Time of call</th>
								<td id="journdate">
									<xsl:call-template name="formatDate">
										<xsl:with-param name="date" select="n1:effectiveTime/@value"/>
									</xsl:call-template>
								</td>
							</tr>
							<tr>
								<th>Disposition</th>
								<td id="disposition">
									<xsl:value-of select="n1:priorityCode/@code"/> - 
										<xsl:value-of select="n1:priorityCode/@displayName"/>
								</td>
							</tr>
							<xsl:choose>
								<xsl:when test="n1:id/@root = '2.16.840.1.113883.2.1.3.2.4.18.35'">
									<tr>
										<th>Case Id</th>
										<td id="caseid">
											<xsl:value-of select="n1:id/@extension"/>
										</td>
									</tr>
								</xsl:when>
								<xsl:when test="n1:id/@root = '2.16.840.1.113883.2.1.3.2.4.18.34'">
									<tr>
										<th>Case Ref</th>
										<td id="caseref">
											<xsl:value-of select="n1:id/@extension"/>
										</td>
									</tr>
								</xsl:when>
							</xsl:choose>
							<tr>
								<th>
									<xsl:text>Author</xsl:text>
								</th>
								<td id="jauthor">
									<xsl:choose>
										<xsl:when test="n1:author/n1:assignedAuthor/n1:assignedPerson/n1:name">
											<xsl:call-template name="getName">
												<xsl:with-param name="name" select="n1:author/n1:assignedAuthor/n1:assignedPerson/n1:name"/>
											</xsl:call-template>
											<xsl:text> - </xsl:text>
											<xsl:value-of select="n1:author/n1:assignedAuthor/n1:code/@displayName"/>
											<xsl:text>, </xsl:text>
											<xsl:value-of select="n1:author/n1:assignedAuthor/n1:representedOrganization/n1:name"/>
										</xsl:when>
										<xsl:when test="n1:author/n1:assignedAuthor/n1:assignedAuthoringDevice/n1:manufacturerModelName">
											<xsl:value-of select="n1:author/n1:assignedAuthor/n1:assignedAuthoringDevice/n1:manufacturerModelName"/>
											<xsl:if test="n1:author/n1:assignedAuthor/n1:representedOrganization/n1:name">
												<xsl:text> at </xsl:text>
												<xsl:value-of select="n1:author/n1:assignedAuthor/n1:representedOrganization/n1:name"/>
											</xsl:if>
										</xsl:when>
										<xsl:when test="n1:author/n1:assignedAuthor/n1:representedOrganization/n1:name">
											<xsl:value-of select="n1:author/n1:assignedAuthor/n1:representedOrganization/n1:name"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Unknown</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
							<tr>
								<th>Advice given</th>
								<td>
									<xsl:choose>									
										<xsl:when test="n1:text/xhtml:html/xhtml:body/n1:text">
												<xsl:for-each select="n1:text/xhtml:html/xhtml:body/n1:text">
													<!--<xsl:copy-of select="n1:text"/>-->
													<p id="advice"><xsl:copy-of select="."/></p>
													<hr/>									
												</xsl:for-each>													
										</xsl:when>
									</xsl:choose>
								</td>
							</tr>
							<xsl:for-each select="n1:text/xhtml:html/xhtml:body/xhtml:history">
								<tr>
									<th><xsl:value-of select="xhtml:title"/>
									</th>
									<td><xsl:copy-of select="n1:text"/>
									</td>
								</tr>
							</xsl:for-each>		
						</table>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
