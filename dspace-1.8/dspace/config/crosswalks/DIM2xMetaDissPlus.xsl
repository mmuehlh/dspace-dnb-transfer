<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
	xmlns:cc="http://www.d-nb.de/standards/cc/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcmitype="http://purl.org/dc/dcmitype/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:pc="http://www.d-nb.de/standards/pc/"
	xmlns:urn="http://www.d-nb.de/standards/urn/"
	xmlns:hdl="http://www.d-nb.de/standards/hdl/"
	xmlns:doi="http://www.d-nb.de/standards/doi/"
	xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
	xmlns:ddb="http://www.d-nb.de/standards/ddb/"
	xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
	xmlns="http://www.d-nb.de/standards/subject/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/
	http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd"
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:xlink="http://www.w3.org/TR/xlink/" 
	version="1.0">
	<xsl:output indent="yes"/>


	<!-- global variables -->
	<xsl:variable name="baseURL">http://ediss.uni-goettingen.de:8080</xsl:variable>
	<xsl:variable name="metsURL" select="concat($baseURL, '/ediss/metadata/handle')"/>
	<xsl:variable name="lifeURL">http://ediss.uni-goettingen.de</xsl:variable>	
        <!-- language info is needed global -->
       <xsl:variable name="lang">
		<xsl:choose>
			<xsl:when test="//dim:field[@element='language'][@qualifier='iso'] = 'deu'">
				<xsl:text>ger</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="//dim:field[@element='language'][@qualifier='iso']" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

       <xsl:template match="text()"/>
       <xsl:template match="/">
	<xsl:if test="not(//dri:field[@element='date'][@qualifier='embargoed']">
	<xMetaDiss:xMetaDiss xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/" xmlns:cc="http://www.d-nb.de/standards/cc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:pc="http://www.d-nb.de/standards/pc/" xmlns:urn="http://www.d-nb.de/standards/urn/" xmlns:hdl="http://www.d-nb.de/standards/hdl/" xmlns:doi="http://www.d-nb.de/standards/doi/" xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/" xmlns:ddb="http://www.d-nb.de/standards/ddb/" xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/" xmlns="http://www.d-nb.de/standards/subject/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">	


		<xsl:call-template name="titles"/>
		<xsl:call-template name="author"/>
		<xsl:call-template name="dnb-sg"/>
		<xsl:call-template name="subjects"/>
		<xsl:call-template name="abstracts"/>
		<xsl:call-template name="publisher"/>
		<xsl:call-template name="contributors"/>
		<xsl:call-template name="dates"/>
		<xsl:call-template name="publType"/>
		<xsl:call-template name="version"/>
		<xsl:call-template name="identifiers"/>
		<xsl:call-template name="language"/>
		<xsl:call-template name="degree"/>
		<xsl:call-template name="fileSection"/>
		<xsl:call-template name="ddb:rights"/>
	  </xMetaDiss:xMetaDiss>
	 </xsl:if>
	</xsl:template>

	<!-- title data -->
	<xsl:template name="titles">
	                <dc:title xsi:type="ddb:titleISO639-2" lang="{$lang}">
        	                <xsl:value-of select="//dim:field[@element ='title' and not(@qualifier)]"/>
        	        </dc:title>

			<!-- we do not deliver tranlated title because we do not know the language of that 

       			<xsl:if test="//dim:field[@element ='title' and @qualifier='translated']"> 
		                <dc:title xsi:type="ddb:titleISO639-2" lang="{//dim:field[@element ='title' and @qualifier='translated']/@lang}" ddb:type="translated">
        		                <xsl:value-of select="//dim:field[@element ='title' and @qualifier='translated']"/>
        		        </dc:title>
			</xsl:if> -->


        	<xsl:if test="//dim:field[@element ='title' and @qualifier='alternative']">
	                <dcterms:alternative xsi:type="ddb:talternativeISO639-2" lang="{$lang}">
        	                <xsl:value-of select="//dim:field[@element ='title' and @qualifier='alternative']"/>
        	        </dcterms:alternative>
        	</xsl:if>

		<!--
        	<xsl:if test="//dim:field[@element ='title' and @qualifier='alternativeTranslated']">
	                <dcterms:alternative xsi:type="ddb:talternativeISO639-2" lang="{//dim:field[@element ='title' and @qualifier='alternativeTranslated']/@lang}">
        	                <xsl:value-of select="//dim:field[@element ='title' and @qualifier='alternativeTranslated']"/>
        	        </dcterms:alternative>
        	</xsl:if>
		-->
		
        </xsl:template>

	<!-- author date -->
	<xsl:template name="author">
		<dc:creator xsi:type="pc:MetaPers">
			<!--<pc:person>
				<pc:name type="nameUsedByThePerson">
					
					<xsl:variable name="tail"><xsl:value-of select="normalize-space(substring-after(//dim:field[@qualifier='author'], ','))"/></xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($tail, ' ')">
							<pc:foreName><xsl:value-of select="substring-before($tail, ' ')" /></pc:foreName>
						</xsl:when>
						<xsl:otherwise>
					
					<pc:foreName><xsl:value-of select="$tail"/></pc:foreName>
						</xsl:otherwise>
					</xsl:choose>
					<pc:surName><xsl:value-of select="substring-before(//dim:field[@element ='contributor' and @qualifier='author'], ',')"/></pc:surName>
				</pc:name>
			</pc:person> -->
			<pc:person>
                                <pc:name type="nameUsedByThePerson">

                                        <xsl:variable name="tail"><xsl:value-of select="normalize-space(substring-after(//dim:field[@qualifier='author'], ','))"/></xsl:variable>
                                        
                                        <xsl:variable name="prefix">
				 		<xsl:choose>
							<xsl:when test="contains($tail, ' von ') ">
								<xsl:value-of select="concat('von ', substring-after($tail, ' von '))"/>
							</xsl:when>
																						
							<xsl:when test="contains($tail, ' van ') ">
								<xsl:value-of select="concat('van ', substring-after($tail, ' van '))"/>
							</xsl:when>
																	
							<xsl:when test="contains($tail, ' Van ') ">
								<xsl:value-of select="concat('Van ', substring-after($tail, ' Van '))"/>
							</xsl:when>
							<xsl:when test="contains($tail, ' de ') ">
								<xsl:value-of select="concat('de ', substring-after($tail, ' de '))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>none</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>	
					<pc:foreName>
                                       		<xsl:choose>
                                                	<xsl:when test="($prefix != 'none')">
								<xsl:value-of select="substring-before($tail, $prefix)" />
							</xsl:when>
	                                                <xsl:otherwise>
								<xsl:value-of select="$tail"/>
	                                                </xsl:otherwise>
        	                                </xsl:choose> 
                                        </pc:foreName>
                                        <pc:surName><xsl:value-of select="substring-before(//dim:field[@element ='contributor' and @qualifier='author'], ',')"/></pc:surName>
                                        <xsl:if test="not($prefix = 'none')">
							<pc:prefix><xsl:value-of select="$prefix" /></pc:prefix>
                                        </xsl:if>
                                </pc:name>
                        </pc:person>
		</dc:creator>
        </xsl:template>

	<!-- subjects -->
	<xsl:template name="dnb-sg">
		<dc:subject xsi:type="xMetaDiss:DDC-SG"><xsl:value-of select="substring-before(//dim:field[@element ='subject' and @qualifier='dnb'], ' ')"/></dc:subject>
	</xsl:template>

	<xsl:template name="subjects">
		<xsl:for-each select="//dim:field[@element ='subject'][@qualifier='eng' or @qualifier='ger']">
			<dc:subject xsi:type="xMetaDiss:noScheme"><xsl:value-of select="translate(., ';', ',')"/></dc:subject>
		</xsl:for-each>
	</xsl:template>

	<!-- abstract -->
	<xsl:template name="abstracts">
		<xsl:if test="//dim:field[@qualifier ='abstracteng']">
			<dcterms:abstract xsi:type="ddb:contentISO639-2" lang="eng">
				<xsl:value-of select="//dim:field[@qualifier ='abstracteng']"/>
			</dcterms:abstract>
		</xsl:if>
		<xsl:if test="//dim:field[@qualifier ='abstractger']">
			<dcterms:abstract xsi:type="ddb:contentISO639-2" lang="ger">
				<xsl:value-of select="//dim:field[@qualifier ='abstractger']"/>
			</dcterms:abstract>
		</xsl:if>
	</xsl:template>


	<!-- publisher -->
	<xsl:template name="publisher">
		<dc:publisher ddb:role="Universitaetsbibliothek" xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
			<cc:universityOrInstitution cc:GKD-Nr="2020450-4">
				<cc:name>Niedersächsische Staats- und Universitätsbibliothek Göttingen</cc:name>
				<cc:place>Göttingen</cc:place>
			</cc:universityOrInstitution>
			<cc:address>Platz der Göttinger Sieben 1, 37073 Göttingen</cc:address>
		</dc:publisher>
	</xsl:template>

	<!-- contributors -->
	<xsl:template name="contributors">
		<xsl:for-each select="//dim:field[@element ='contributor' and not(@qualifier='author')]">
			<dc:contributor xsi:type="pc:Contributor" countryCode="DE">
				<xsl:choose>
					<xsl:when test="contains(@qualifier, 'eferee')">
						<xsl:attribute name="thesis:role">referee</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="thesis:role"><xsl:value-of select="@qualifier"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<pc:person>
					<xsl:variable name="tail" select="substring-after(., ',')"/>
					
					<xsl:choose>
                                        	<xsl:when test="contains(., 'Prof.')">
							<pc:name type="otherName">
								
								<pc:foreName><xsl:value-of select="normalize-space(substring-before($tail, 'Prof.'))"/></pc:foreName>
		                                                <pc:surName><xsl:value-of select="substring-before(., ',')"/></pc:surName>
							</pc:name>
							<pc:academicTitle>
								<xsl:text>Prof.</xsl:text>
								<xsl:if test="contains($tail, 'Prof. em.')">
									<xsl:text> em.</xsl:text>
								</xsl:if> 
							</pc:academicTitle>
							
						</xsl:when>
						
						<xsl:when test="contains(., 'PD')">
							<pc:name type="otherName">
                                                                <pc:foreName><xsl:value-of select="normalize-space(substring-before($tail, 'PD'))"/></pc:foreName>
                                                                <pc:surName><xsl:value-of select="substring-before(., ',')"/></pc:surName>
							</pc:name>
                                                        <pc:academicTitle>PD</pc:academicTitle>
                                                </xsl:when>
						<xsl:otherwise>
							 <pc:name type="otherName">
                                                                <pc:foreName><xsl:value-of select="normalize-space(substring-before($tail, 'Dr.'))"/></pc:foreName>
                                                                <pc:surName><xsl:value-of select="substring-before(., ',')"/></pc:surName>
                                                        </pc:name>

						</xsl:otherwise>
					</xsl:choose>
					 <xsl:if test="contains($tail, 'Dr. Dr.')">
                                                <pc:academicTitle>Dr.</pc:academicTitle>
                                        </xsl:if>
					<xsl:if test="contains($tail, 'Dr.')">
                                                <pc:academicTitle>
							<xsl:text>Dr.</xsl:text>
							<xsl:if test="contains($tail, 'Dr. h.c.')">
								<xsl:text> h.c.</xsl:text>
							</xsl:if>
						</pc:academicTitle>
                                        </xsl:if>
				</pc:person>
			</dc:contributor>
		</xsl:for-each>
	</xsl:template>


	<!-- dates -->
	<xsl:template name="dates">
		<dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
			<xsl:value-of select="//dim:field[@element ='date'][@qualifier='examination']"/>	
		</dcterms:dateAccepted>
		<dcterms:issued xsi:type="dcterms:W3CDTF">
			<xsl:value-of select="//dim:field[@element ='date'][@qualifier='issued']"/>
		</dcterms:issued>
	</xsl:template>



	<!-- publication type -->
	<xsl:template name="publType">	
		<dc:type xsi:type="dini:PublType">
			<xsl:choose>
                                <xsl:when test="//dim:field[@element ='type']='magisterThesis')">
                                        <xsl:text>masterThesis</xsl:text>
                                </xsl:when>
                                <xsl:when test="//dim:field[@element ='type']='masterThesis')">
                                        <xsl:text>masterThesis</xsl:text>
                                </xsl:when>
                                <xsl:when test="//dim:field[@element ='type']='bachelorThesis')">
                                        <xsl:text>bachelorThesis</xsl:text>
                                </xsl:when>
				<xsl:otherwise>
					<xsl:text>doctoralThesis</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</dc:type>
	</xsl:template>

        <!-- driver version -->
        <xsl:template name="version">
                <dini:version_driver>publishedVersion</dini:version_driver>
        </xsl:template>

	<!-- identifiers -->
	<xsl:template name="identifiers">
		<dc:identifier xsi:type="urn:nbn">
			<xsl:value-of select="//dim:field[@qualifier='urn']"/>
		</dc:identifier>
	</xsl:template>

	<!-- Language -->
	<xsl:template name="language">
		<dc:language xsi:type="dcterms:ISO639-2">
			<xsl:value-of select="$lang"/>
		</dc:language>
	</xsl:template>

	<!-- Degree -->
	<xsl:template name="degree">
	  <thesis:degree>
		<thesis:level>
                        <xsl:choose>
                                <xsl:when test="//dim:field[@element ='type']='magisterThesis')">
                                        <xsl:text>thesis.master</xsl:text>
                                </xsl:when>
                                <xsl:when test="//dim:field[@element ='type']='masterThesis')">
                                        <xsl:text>thesis.master</xsl:text>
                                </xsl:when>
                                <xsl:when test="//dim:field[@element ='type']='bachelorThesis')">
                                        <xsl:text>thesis.bachelor</xsl:text>
                                </xsl:when>
				<xsl:otherwise>
					<xsl:text>thesis.doctoral</xsl:text>
				</xsl:otherwise>
                        </xsl:choose>
		</thesis:level>
		<thesis:grantor>
			<cc:universityOrInstitution  cc:GKD-Nr="2024315-7">
				<cc:name>Georg-August Universität</cc:name>
				<cc:place>Göttingen</cc:place>
				<cc:department>
					<cc:name><xsl:value-of select="//dim:field[@qualifier='institute']"/></cc:name>
				</cc:department>
			</cc:universityOrInstitution>
		</thesis:grantor>
	  </thesis:degree>
	</xsl:template>

	<xsl:template name="fileSection">
		<xsl:variable name="handle" select="substring-after(//dim:field[@element ='identifier'][@qualifier='uri'], 'http://hdl.handle.net')"/>
		<xsl:variable name="docURL" select="concat('http://ediss.uni-goettingen.de:8080/metadata/handle', $handle, '/mets.xml')"/>
		<xsl:variable name="doc" select="document($docURL)"/>
		<!-- <xsl:variable name="doc" select="document('test-mets.xml')"/> -->
		<xsl:variable name="fileData" select="$doc//mets:fileGrp[@USE='CONTENT']"/> 
		<!-- <ddb:fileData><xsl:value-of select="$docURL" /></ddb:fileData> -->
		<!--DOCURL: <xsl:value-of select="$docURL"/>	
		HANDLE: <xsl:value-of select="$handle"/>
		FILEDATA: -->
		<xsl:value-of select="$fileData"/>
		<ddb:fileNumber><xsl:value-of select="count($fileData/mets:file)"/></ddb:fileNumber>
		<xsl:for-each select="$fileData/mets:file">
			<ddb:fileProperties>
				<xsl:attribute name="ddb:fileName"><xsl:value-of select="./mets:FLocat/@xlink:title"/></xsl:attribute>
			</ddb:fileProperties>
		</xsl:for-each>
		<xsl:choose>
		<xsl:when test="count($fileData/mets:file) = 1">
			 <ddb:transfer ddb:type="dcterms:URI"><xsl:value-of select="concat($lifeURL, $fileData/mets:file/mets:FLocat/@xlink:href)"/></ddb:transfer>
		</xsl:when>
		<xsl:otherwise>
			<ddb:transfer ddb:type="dcterms:URI"><xsl:value-of select="concat($lifeURL, '/downloads', $handle, '.zip')"/></ddb:transfer>
		</xsl:otherwise>
		</xsl:choose>
		<ddb:identifier ddb:type="handle"><xsl:value-of select="//dim:field[@element ='identifier'][@qualifier='uri']"/></ddb:identifier>

	</xsl:template>


	<xsl:template name="ddb:rights">
		<ddb:rights ddb:kind="free" />
	</xsl:template>
	<!--
	<ddb:fileNumber>1</ddb:fileNumber>
	<ddb:fileProperties
	ddb:fileName="dissertation.pdf"/> -->
	<!-- Wenn es sich bei dem Dokument um ein einzelnes PDF handelt, dann sollte sich dies in der Transfer-URL widerspiegeln.
	     Besteht die Publikation aus mehrere Dateien, dann muss in der Transfer-URL entsprechend ein Archivordner z. B. ZIP geliefert werden. -->
	<!--<ddb:transfer ddb:type="dcterms:URI">
		http://www.ub-beispielstadt.de/dissertation.pdf</ddb:transfer>
	<ddb:identifier ddb:type="URL">
		http://archiv.tu-chemnitz.de/pub/2003/0162/index.html</ddb:identifier>
	<ddb:rights ddb:kind="free"/> -->
</xsl:stylesheet>
