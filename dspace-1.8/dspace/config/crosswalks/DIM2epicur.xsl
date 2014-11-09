<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:urn="http://www.d-nb.de/standards/urn/"
	xmlns:hdl="http://www.d-nb.de/standards/hdl/"
	xmlns:doi="http://www.d-nb.de/standards/doi/"
	xmlns:epicur="urn:nbn:de:1111-2004033116"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd"
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:xlink="http://www.w3.org/TR/xlink/" 
	version="1.0">
	<xsl:output indent="yes"/>


	<!-- global variables -->
	<xsl:variable name="baseURL">http://localhost:8080</xsl:variable>
	<xsl:variable name="metsURL" select="concat($baseURL, '/ediss/metadata/handle')"/>
	

       <xsl:template match="text()"/>
       <xsl:template match="/">
	<epicur xmlns="urn:nbn:de:1111-2004033116" xmlns:epicur="urn:nbn:de:1111-2004033116" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd">	
		<administrative_data>
			<delivery>
				<update_status type="urn_new"/>
			</delivery>
		</administrative_data>
		<record>


		<identifier scheme="urn:nbn:de">
                                <xsl:value-of select="//dim:field[@element ='identifier'][@qualifier='urn']"/>
                </identifier>

		<resource>
                                <identifier scheme="url" type="frontpage" role="primary">
                                        <xsl:value-of select="//dim:field[@element ='identifier'][@qualifier='uri']"/>
                                </identifier>
                                <format scheme="imt">text/html</format>
                        </resource>


		<!-- <xsl:call-template name="urn"/>
		<xsl:call-template name="resource"/> -->
		
		</record>
	  </epicur>
	</xsl:template>

	<!-- title data -->
	<xsl:template name="urn">
	                <identifier scheme="urn:nbn:de">
        	                <xsl:value-of select="//dim:field[@element ='identifier'][@qualifier='urn']"/>
        	        </identifier>

	</xsl:template>

	<xsl:template name="resource">
        
	                <resource>
				<identifier scheme="url" type="frontpage" role="primary">
        	                	<xsl:value-of select="//dim:field[@element ='identifier'][@qualifier='uri']"/>
				</identifier>
				<format scheme="imt">text/html</format>
        	        </resource>
	</xsl:template>


</xsl:stylesheet>
