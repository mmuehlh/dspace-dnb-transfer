<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"     
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:xlink="http://www.w3.org/TR/xlink/" 
	xmlns:zip="http://apache.org/cocoon/zip-archive/1.0"
	exclude-result-prefixes="mets xlink"
	version="1.0">
	<xsl:output indent="yes"/>

	<xsl:variable name="baseURL">cocoon:/</xsl:variable>

       <xsl:template match="text()"/>
       <xsl:template match="/">
		<xsl:call-template name="fileSection"/>
	</xsl:template>

	

	<xsl:template name="fileSection">
		
		<xsl:variable name="fileData" select="//mets:fileGrp[@USE='CONTENT']"/>
		
		<zip:archive>
			<xsl:for-each select="$fileData/mets:file">
			
      	
      				<zip:entry name="{mets:FLocat/@xlink:title}" src="{concat('cocoon:/', mets:FLocat/@xlink:href)}"/>
			</xsl:for-each>
      		</zip:archive>
		
	</xsl:template>

	
	
</xsl:stylesheet>
