<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai" 
    version="1.0">
    
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
 
	<xsl:template match="/">
		
		 <epicur xmlns="urn:nbn:de:1111-2004033116" 
		 xmlns:epicur="urn:nbn:de:1111-2004033116" 
		 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		 xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd">	
			
			<administrative_data>
				<delivery>
					<update_status type="urn_new"/>
				</delivery>
			</administrative_data>
			<record>
				<identifier scheme="urn:nbn:de">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']" />
                </identifier>

				<resource>
					<identifier scheme="url" type="frontpage" role="primary">
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" />
					</identifier>
					<format scheme="imt">text/html</format>
               </resource>
			</record>
			
		</epicur>
	</xsl:template>

</xsl:stylesheet>

