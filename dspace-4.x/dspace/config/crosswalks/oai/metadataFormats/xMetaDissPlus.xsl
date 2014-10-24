<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai" 
    version="1.0">
    
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
    <!-- global variables-->

    <!-- Download url:  http://example-rep.de/download/ or http://exmple-rep.de/diss/download/ in case the sevice is not running as root application.
    The url is the virtual address defined in sitemap.xmap offering zip-download for multiple files. -->
    <!-- Closing slash is important! -->
    <xsl:variable name="zipResourceUrl">http://ediss.sub.uni-goettingen.de/downloads/</xsl:variable> 
     
    <!-- Publihsers DNB identifierr --> 
    <xsl:variable name="gkdnr">"2020450-4</xsl:variable>
   
    <!-- some field valuew for multiple use -->

    <!-- dc.language.iso -->
    <xsl:variable name="lang">
		<xsl:choose>
			<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value'] = 'deu'">
				<xsl:text>ger</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- dc.type -->
	<xsl:variable name="publType">
		<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']" />
	</xsl:variable>
	

	<!-- institute specific static data:
	<dc:publisher>, <thesis:grantor>  
	 -->
		


	<xsl:template match="/">
		
		 <xMetaDiss:xMetaDiss xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
		    xmlns:dc="http://purl.org/dc/elements/1.1/" 
		    xmlns:dcterms="http://purl.org/dc/terms/" 
			xmlns:cc="http://www.d-nb.de/standards/cc/"  
			xmlns:dcmitype="http://purl.org/dc/dcmitype/" 
			xmlns:pc="http://www.d-nb.de/standards/pc/" 
			xmlns:urn="http://www.d-nb.de/standards/urn/" 
			xmlns:hdl="http://www.d-nb.de/standards/hdl/" 
			xmlns:doi="http://www.d-nb.de/standards/doi/" 
			xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/" 
			xmlns:ddb="http://www.d-nb.de/standards/ddb/" 
			xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/" 
			xmlns="http://www.d-nb.de/standards/subject/" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">
			
			<!-- title data: dc.title, dc.title.alternative -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']">
				<dc:title xsi:type="ddb:titleISO639-2" lang="{$lang}">
					<xsl:value-of select="doc:element/doc:field[@name='value']" />
				</dc:title>
				<xsl:if test="doc:element[@name='alternative']">
					<dcterms:alternative xsi:type="ddb:talternativeISO639-2" lang="{$lang}">
        	                <xsl:value-of select="doc:element[@name='alternative']/doc:element/doc:field[@name='value']"/>
					</dcterms:alternative>
        	    </xsl:if>
        	</xsl:for-each>
        	
        	
			<!-- author data-: dc.contributor.author -->
			<dc:creator xsi:type="pc:MetaPers">
			<pc:person>
                <pc:name type="nameUsedByThePerson">
				   <!-- handle names with "von", "van", "Van", and "de" -->
                  <xsl:variable name="tail"><xsl:value-of select="normalize-space(substring-after(doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value'], ','))"/></xsl:variable>
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
                      <pc:surName>
						  <xsl:value-of select="substring-before(doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value'], ',')"/>
					  </pc:surName>
                      <xsl:if test="not($prefix = 'none')">
							<pc:prefix><xsl:value-of select="$prefix" /></pc:prefix>
                      </xsl:if>
                 </pc:name>
             </pc:person>
		    </dc:creator>
		    
		    <!-- subjects data: dc.subject.eng, dc.subject.ger-->
		    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='eng' or @name='ger']">
				<dc:subject xsi:type="xMetaDiss:noScheme"><xsl:value-of select="doc:element/doc:field[@name='value']"/></dc:subject>
			</xsl:for-each>
			
			<!-- abstract data: dc.description.abstracteng, dc.description.abstractger -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']">
				<xsl:if test="doc:element[@name='abstracteng']">
					<dcterms:abstract xsi:type="ddb:contentISO639-2" lang="eng">
						<xsl:value-of select="doc:element[@name='abstracteng']/doc:element/doc:field[@name='value']"/>
					</dcterms:abstract>
				</xsl:if>
				<xsl:if test="doc:element[@name='abstractger']">
					<dcterms:abstract xsi:type="ddb:contentISO639-2" lang="ger">
						<xsl:value-of select="doc:element[@name='abstractger']/doc:element/doc:field[@name='value']"/>
					</dcterms:abstract>
				</xsl:if>
			</xsl:for-each>
			
			<!-- publisher: constant data -->
			<dc:publisher ddb:role="Universitaetsbibliothek" xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
				<cc:universityOrInstitution cc:GKD-Nr="{$gkdnr}">
					<cc:name>Niedersächsische Staats- und Universitätsbibliothek Göttingen</cc:name>
					<cc:place>Göttingen</cc:place>
				</cc:universityOrInstitution>
				<cc:address>Platz der Göttinger Sieben 1, 37073 Göttingen</cc:address>
			</dc:publisher>
			
			<!-- contributors data: dc.contributor.advisor, dc.contributor.referee, dc.contributor.coReferee, dc.contributor.thirdReferee -->

			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[not(@name='author')]">
				<dc:contributor xsi:type="pc:Contributor" countryCode="DE">
					<xsl:choose>
						<xsl:when test="contains(./@name, 'eferee')">
							<xsl:attribute name="thesis:role">referee</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="thesis:role"><xsl:value-of select="./@name"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<pc:person>
						<xsl:variable name="tail" select="substring-after(doc:element/doc:field[@name='value'], ',')"/>
						<!-- allowed academic titles: "Prof. Dr.", "PD Dr.", Prof. em.", "Dr.", "Prof. Dr.Dr.", "Prof. Dr. h.c.", "Dr. h.c." -->
						<xsl:choose>
							 <xsl:when test="contains(doc:element/doc:field[@name='value'], 'Prof.')">
								<pc:name type="otherName">
									
									<pc:foreName><xsl:value-of select="normalize-space(substring-before($tail, 'Prof.'))"/></pc:foreName>
									<pc:surName><xsl:value-of select="substring-before(doc:element/doc:field[@name='value'], ',')"/></pc:surName>
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
									<pc:surName><xsl:value-of select="substring-before(doc:element/doc:field[@name='value'], ',')"/></pc:surName>
								</pc:name>
								<pc:academicTitle>PD</pc:academicTitle>
							</xsl:when>
							<xsl:otherwise>
								 <pc:name type="otherName">
									  <pc:foreName><xsl:value-of select="normalize-space(substring-before($tail, 'Dr.'))"/></pc:foreName>
									  <pc:surName><xsl:value-of select="substring-before(doc:element/doc:field[@name='value'], ',')"/></pc:surName>
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

			<!-- dates: dc.date.examination, dc.date.issued -->
			<dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='examination']/doc:element/doc:field[@name='value']"/>	
			</dcterms:dateAccepted>
			<dcterms:issued xsi:type="dcterms:W3CDTF">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
			</dcterms:issued>

			<!-- publication type: dc.type; possible values: "cumulativeThesis", "diplomaThesis", "doctoralThesis", "habilitation", "magisterThesis", "masterThesis", "studyThesis" -->
			<dc:type xsi:type="dini:PublType">
				<xsl:value-of select="$publType"/>
			</dc:type>

	
			<!-- driver version: static content -->
			<dini:version_driver>publishedVersion</dini:version_driver>

    
			<!-- identifier: dc.identifier.urn -->
			<dc:identifier xsi:type="urn:nbn">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']"/>
			</dc:identifier>


			<!-- language of publication: dc.language.iso -->
			<dc:language xsi:type="dcterms:ISO639-2">
				<xsl:value-of select="$lang"/>
			</dc:language>

			<!-- thesis degree: level mapping http://files.dnb.de/standards/xmetadiss/thesis.xsd -->
		   <thesis:degree>
			<thesis:level>
			   <xsl:choose>
					<xsl:when test="$publType = 'doctoralThesis'">
						 <xsl:text>thesis.doctoral</xsl:text>
					</xsl:when>
					<xsl:when test="$publType = 'cumulativeThesis'">
						 <xsl:text>thesis.doctoral</xsl:text>
					</xsl:when>
					<xsl:when test="$publType = 'masterThesis'">
						 <xsl:text>master</xsl:text>
					</xsl:when>
					<xsl:when test="$publType = 'habilitation'">
						 <xsl:text>thesis.habilitation</xsl:text>
					</xsl:when>
					<xsl:when test="$publType = 'diplomaThesis'">
						 <xsl:text>Diplom</xsl:text>
					</xsl:when>
					<xsl:when test="$publType = 'magisterThesis'">
						 <xsl:text>M.A.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>other</xsl:text>
					</xsl:otherwise>
			   </xsl:choose>
			 </thesis:level>
			 <thesis:grantor>
				<cc:universityOrInstitution  cc:GKD-Nr="2024315-7">
					<cc:name>Georg-August Universität</cc:name>
					<cc:place>Göttingen</cc:place>
					<cc:department>
						<cc:name><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='affiliation']/doc:element[@name='institute']/doc:element/doc:field[@name='value']"/></cc:name>
					</cc:department>
				</cc:universityOrInstitution>
			 </thesis:grantor>
		   </thesis:degree>
		   
		   	<!-- fileSection -->
			<xsl:variable name="handle"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" /></xsl:variable>
			<xsl:variable name="fileNumber">
				<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']">
					<xsl:if test="doc:field/text() = 'ORIGINAL')">
						<xsl:value-of select="count(doc:element[@name='bitstreams']/doc:element[@name='bitstream'])"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<ddb:fileNumber><xsl:value-of select="$fileNumber"/></ddb:fileNumber>
			<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']">
				<xsl:if test="doc:field/text() = 'ORIGINAL')">
					<xsl:for-each select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
						<ddb:fileProperties>					
							<xsl:attribute name="ddb:fileName"><xsl:value-of select="doc:field[@name='name']"/></xsl:attribute>
						</ddb:fileProperties>
					</xsl:for-each>
				</xsl:if>			
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="$fileNumber = 1"> 
					<ddb:transfer ddb:type="dcterms:URI">
						<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']">
							<xsl:if test="doc:field/text() = 'ORIGINAL')">
								<xsl:value-of select="doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='url']"/>
							</xsl:if>
						</xsl:for-each>
					</ddb:transfer>
				</xsl:when>
				<xsl:otherwise>		
					<ddb:transfer ddb:type="dcterms:URI"><xsl:value-of select="concat($zipResourceUrl, $handle, '-files.zip')"/></ddb:transfer>
				</xsl:otherwise> 
			</xsl:choose>	
			<ddb:identifier ddb:type="handle"><xsl:value-of select="$handle"/></ddb:identifier>
			
	  </xMetaDiss:xMetaDiss> 
	    
	</xsl:template>
	


</xsl:stylesheet>

