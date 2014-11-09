/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content;

import java.io.IOException;
import java.sql.SQLException;

import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.embargo.EmbargoManager;
import org.dspace.event.Event;
import org.dspace.handle.HandleManager;

import org.apache.log4j.Logger;
import javax.servlet.ServletException;

import org.dspace.core.ConfigurationManager;

import org.dspace.license.CreativeCommons;
import java.io.InputStream;
import java.io.FileInputStream;

/**
 * Support to install an Item in the archive.
 * 
 * @author dstuve
 * @version $Revision: 6864 $
 */
public class InstallItem
{

    /** log4j category */
    private static Logger log = Logger.getLogger(InstallItem.class);
    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item,
     * creating a new Handle.
     * 
     * @param c
     *            DSpace Context
     * @param is
     *            submission to install
     * 
     * @return the fully archived Item
     */

    public static Item installItem(Context c, InProgressSubmission is)
            throws SQLException, IOException, AuthorizeException, Exception
    {
        return installItem(c, is, null);
    }


    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item.
     * 
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give to the installed item
     * 
     * @return the fully archived Item
     */
    public static Item installItem(Context c, InProgressSubmission is,
            String suppliedHandle) throws SQLException,
            IOException, AuthorizeException, Exception
    {
        Item item = is.getItem();
        String handle;
        
        // if no previous handle supplied, create one
        if (suppliedHandle == null)
        {
            // create a new handle for this item
            handle = HandleManager.createHandle(c, item);
        }
        else
        {
            // assign the supplied handle to this item
            handle = HandleManager.createHandle(c, item, suppliedHandle);
        }

	/*try {
	    
	    log.info("registering final URL for handle " + handle);
	    HandleManager.registerFinalHandleURL(handle);
	} catch (Exception error) {
	    throw new ServletException(error);
	}*/
	log.info("istallItem: handle=" + handle);

        populateHandleMetadata(item, handle);

	log.debug("installItem: handleMetadata populated");

	//create urn with checksum
	String prefix = ConfigurationManager.getProperty("urn.prefix"); 
	String urn = prefix + handle + "-";
	item.addDC("identifier", "urn", null, urn + URNChecksum(urn));	

	//if default cc configured create it
	if (ConfigurationManager.getProperty("cc.license.uri") == "true")
        {
		createDefaultCCLicense(c, item);
		String license_uri = ConfigurationManager.getProperty("cc.license.uri");
	        item.addDC("rights", "uri", null, license_uri);
	}

        // this is really just to flush out fatal embargo metadata
        // problems before we set inArchive.
        DCDate liftDate = EmbargoManager.getEmbargoDate(c, item);

        populateMetadata(c, item, liftDate);

        return finishItem(c, item, is, liftDate);

    }

    /**
     * Turn an InProgressSubmission into a fully-archived Item, for
     * a "restore" operation such as ingestion of an AIP to recreate an
     * archive.  This does NOT add any descriptive metadata (e.g. for
     * provenance) to preserve the transparency of the ingest.  The
     * ingest mechanism is assumed to have set all relevant technical
     * and administrative metadata fields.
     *
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give the installed item, or null
     *            to create a new one.
     e
     * @return the fully archived Item
     */
    public static Item restoreItem(Context c, InProgressSubmission is,
            String suppliedHandle)
        throws SQLException, IOException, AuthorizeException, Exception
    {
        Item item = is.getItem();
        String handle;

        // if no handle supplied
        if (suppliedHandle == null)
        {
            // create a new handle for this item
            handle = HandleManager.createHandle(c, item);
            //only populate handle metadata for new handles
            // (existing handles should already be in the metadata -- as it was restored by ingest process)
            populateHandleMetadata(item, handle);
        }
        else
        {
            // assign the supplied handle to this item
            handle = HandleManager.createHandle(c, item, suppliedHandle);
		log.info("InstallItem: handle supplied=" + handle);
        }

        // Even though we are restoring an item it may not have a have the proper dates. So lets
        // double check that it has a date accessioned and date issued, and if either of those dates
        // are not set then set them to today.
        DCDate now = DCDate.getCurrent();
        
        // If the item dosn't have a date.accessioned create one.
        DCValue[] dateAccessioned = item.getDC("date", "accessioned", Item.ANY);
        if (dateAccessioned.length == 0)
        {
	        item.addDC("date", "accessioned", null, now.toString());
        }
        
        // create issue date if not present
        DCValue[] currentDateIssued = item.getDC("date", "issued", Item.ANY);
        if (currentDateIssued.length == 0)
        {
            DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
            item.addDC("date", "issued", null, issued.toString());
        }

	// create urn if not present
        DCValue[] urn = item.getDC("identifier", "urn", Item.ANY);
        if (urn.length == 0)
        {
	   String prefix = ConfigurationManager.getProperty("urn.prefix");
           item.addDC("identifier", "urn", null, prefix + handle + "-" + URNChecksum(item, handle)); 
        }
       
	// create cc license if not present and default cc true
	if (ConfigurationManager.getProperty("cc.license.uri") == "true")
	{
	
        	DCValue[] cc_uri = item.getDC("rights", "uri", Item.ANY);
	        if (cc_uri.length == 0)
	        {
		   createDefaultCCLicense(c, item);
		   String license_uri = ConfigurationManager.getProperty("cc.license.uri");
	           item.addDC("rights", "uri", null, license_uri);
        	}
	}

 
        // Record that the item was restored
		String provDescription = "Restored into DSpace on "+ now + " (GMT).";
		item.addDC("description", "provenance", "en", provDescription);

        return finishItem(c, item, is, null);
    }

    private static void populateHandleMetadata(Item item, String handle)
        throws SQLException, IOException, AuthorizeException
    {
        String handleref = HandleManager.getCanonicalForm(handle);

        // Add handle as identifier.uri DC value.
        // First check that identifier dosn't already exist.
        boolean identifierExists = false;
	
	DCValue[] identifiers = item.getMetadata("dc", "identifier", "uri", Item.ANY);
        for (DCValue identifier : identifiers)
        {
        	if (handleref.equals(identifier.value))
            {
        		identifierExists = true;
            }
        }
        if (!identifierExists)
        {
		item.addMetadata("dc", "identifier", "uri", null, handleref);
        }
    }


    private static String URNChecksum(Item item, String handle)
        throws SQLException, IOException, AuthorizeException
    {
		 String prefix = ConfigurationManager.getProperty("urn.prefix").toUpperCase();
                 int[] Nums={1,2,3,4,5,6,7,8,9,41,18,14,19,15,16,21,22,23,24,25,
                             42,26,27,13,28,29,31,12,32,33,11,34,35,36,37,38,39,17,47,43,45,49};

                 String Zeichen="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-:._/+";
                 int erg=0;
                 StringBuffer sb= new StringBuffer();
		 String urn= prefix + handle + "-";
		 log.debug("URNChecksum von " + urn);
                 for(int i=0;i<urn.length();i++) 
                    sb.append(Nums[Zeichen.indexOf(urn.charAt(i))]);
		 
                for(int i=0;i<sb.length();i++) 
                    erg=erg+(i+1)*(sb.charAt(i)-48);
		
                erg=erg/(sb.charAt(sb.length()-1)-48);
                String serg=String.valueOf(erg);
                return serg.substring(serg.length() - 1);
     }

    private static void createDefaultCCLicense(Context c, Item item)
    {
        String filepath = ConfigurationManager.getProperty("cc.license.file");
        InputStream in = null; 
        try
        {
                in = new FileInputStream(filepath);
		try {
			Bundle[] bundles = item.getBundles("CC-LICENSE");
		
			//If there is no CC bundle, create one
			if (bundles.length == 0)
			{
				bundles[0] = item.createBundle("CC-LICENSE");
				CreativeCommons.setLicense(c, item, in, "RDF XML");			

			}
		}
		catch (SQLException se) {
			log.info("SQL error creating default cc-License: " + se.getMessage());
		}
		catch (AuthorizeException ae) {
                        log.info("Auhtorization error creating  default cc-License: " + ae.getMessage());
                }
		
        }
	catch (IOException ioe) {
		log.info("Default CC-License not found: " + ioe.getMessage());

        }
	finally {
		if (in != null)
            {
		try {
	                in.close();
		}
		catch (IOException ioe) {
                                         log.info("IO error creating  default cc-License: " + ioe.getMessage());
                                 }

            }
	}
	

    }


    private static void populateMetadata(Context c, Item item, DCDate embargoLiftDate)
        throws SQLException, IOException, AuthorizeException
    {
        // create accession date
        DCDate now = DCDate.getCurrent();
        //item.addDC("date", "accessioned", null, now.toString());
	item.addMetadata("dc", "date", "accessioned", null, now.toString());

        // add date available if not under embargo, otherwise it will
        // be set when the embargo is lifted.
        if (embargoLiftDate == null)
        {
            //item.addDC("date", "available", null, now.toString());
	    item.addMetadata("dc", "date", "available", null, now.toString());	
        }

        // create issue date if not present
        //DCValue[] currentDateIssued = item.getDC("date", "issued", Item.ANY);
	DCValue[] currentDateIssued = item.getMetadata("dc", "date", "issued", Item.ANY);

        if (currentDateIssued.length == 0)
        {
            DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
            item.addDC("date", "issued", null, issued.toString());
        }

         String provDescription = "Made available in DSpace on " + now
                + " (GMT). " + getBitstreamProvenanceMessage(item);

        if (currentDateIssued.length != 0)
        {
            DCDate d = new DCDate(currentDateIssued[0].value);
            provDescription = provDescription + "  Previous issue date: "
                    + d.toString();
        }

        // Add provenance description
        //item.addDC("description", "provenance", "en", provDescription);
	item.addMetadata("dc", "description", "provenance", "en", provDescription);	
    }

    // final housekeeping when adding new Item to archive
    // common between installing and "restoring" items.
    private static Item finishItem(Context c, Item item, InProgressSubmission is, DCDate embargoLiftDate)
        throws SQLException, IOException, AuthorizeException
    {
        // create collection2item mapping
        is.getCollection().addItem(item);

        // set owning collection
        item.setOwningCollection(is.getCollection());

        // set in_archive=true
        item.setArchived(true);

        // save changes ;-)
        item.update();

        // Notify interested parties of newly archived Item
        c.addEvent(new Event(Event.INSTALL, Constants.ITEM, item.getID(),
                item.getHandle()));

        // remove in-progress submission
        is.deleteWrapper();

        // remove the item's policies and replace them with
        // the defaults from the collection
        item.inheritCollectionDefaultPolicies(is.getCollection());

        // set embargo lift date and take away read access if indicated.
        if (embargoLiftDate != null)
        {
            EmbargoManager.setEmbargo(c, item, embargoLiftDate);
        }

        return item;
    }

    /**
     * Generate provenance-worthy description of the bitstreams contained in an
     * item.
     * 
     * @param myitem  the item generate description for
     * 
     * @return provenance description
     */
    public static String getBitstreamProvenanceMessage(Item myitem)
    						throws SQLException
    {
        // Get non-internal format bitstreams
        Bitstream[] bitstreams = myitem.getNonInternalBitstreams();

        // Create provenance description
        StringBuilder myMessage = new StringBuilder();
        myMessage.append("No. of bitstreams: ").append(bitstreams.length).append("\n");

        // Add sizes and checksums of bitstreams
        for (int j = 0; j < bitstreams.length; j++)
        {
            myMessage.append(bitstreams[j].getName()).append(": ")
                    .append(bitstreams[j].getSize()).append(" bytes, checksum: ")
                    .append(bitstreams[j].getChecksum()).append(" (")
                    .append(bitstreams[j].getChecksumAlgorithm()).append(")\n");
        }

        return myMessage.toString();
    }

    /**
     * Calculate checksum for uncomplete urn
     * 
     * 
     * @param uurn  urn without checksum
     * 
     * @return checksum
     */
    private static String URNChecksum(String uurn)
    {
                 String urn = uurn.toUpperCase();
                 int[] Nums={1,2,3,4,5,6,7,8,9,41,18,14,19,15,16,21,22,23,24,25,
                             42,26,27,13,28,29,31,12,32,33,11,34,35,36,37,38,39,17,47,43,45,49};

                 String Zeichen="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-:._/+";
                 int erg=0;
                 StringBuffer sb= new StringBuffer();

                 for(int i=0; i < urn.length(); i++)
                    sb.append(Nums[Zeichen.indexOf(urn.charAt(i))]);

                for(int i=0;i<sb.length();i++)
                    erg=erg+(i+1)*(sb.charAt(i)-48);

                erg=erg/(sb.charAt(sb.length()-1)-48);
                String serg=String.valueOf(erg);
                return serg.substring(serg.length() - 1);
     }
}
