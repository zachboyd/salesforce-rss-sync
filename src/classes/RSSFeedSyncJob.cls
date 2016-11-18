global class RSSFeedSyncJob implements Queueable, Database.AllowsCallouts {
	
	private Id recordId;
	
	public RSSFeedSyncJob( Id recordId ) {
		this.recordId = recordId;
	}
		
    public void execute( QueueableContext context ) {
        
        // get the rss feed
		RSS_Feed__c feed = getRSSFeed( this.recordId );
		
		if( feed != null ) {
			
			if( feed.Active__c ) {
				syncFeed( feed );							
			}
			
		}
        
    }
	
	/**
	* Helper webservice method invoked by custom button
	*/
	webservice static void syncFeed( Id recordId ) {
		syncFeed( getRSSFeed( recordId ) );
	}
	
	public static void syncFeed( RSS_Feed__c feed ) {
		
        RSSFeedDownloadService.RSSOptions options = new RSSFeedDownloadService.RSSOptions();
        
        // set options
        options.feedType = feed.Type__c;
        options.feedTitleKey = feed.Feed_Title_Key__c;
        options.feedLinkKey = feed.Feed_Link_Key__c;
        options.feedDescriptionKey = feed.Feed_Description_Key__c;
        options.feedItemTitleKey = feed.Item_Title_Key__c;
        options.feedItemLinkKey = feed.Item_Link_Key__c;
        options.feedItemDescriptionKey = feed.Item_Description_Key__c;
        options.feedItemIdKey = feed.Item_ID_Key__c;
        
		// download the RSS feed
		RSSFeedDownloadService.RSSFeed downloadedFeed = RSSFeedDownloadService.downloadRSSFeed( feed.URL__c, options );
		
		if( downloadedFeed != null ) {
			
			List<RSS_Feed_Item__c> feedItemList = new List<RSS_Feed_Item__c>();
			
			// build items
			
			for( RSSFeedDownloadService.RSSFeedItem downloadedItem : downloadedFeed.items ) {
				
				// TODO add support for parsing published date
				
				// Concatenate all fields and hash to make a unique guid
				// This is a hack since not all RSS feeds provide a valid GUID
				String uniqueId = downloadedItem.title + downloadedItem.description + downloadedItem.link + downloadedItem.id;
				String hashedId = EncodingUtil.convertToHex( Crypto.generateDigest( 'SHA1', Blob.valueOf( uniqueId ) ) );								
				
				// certain RSS feeds have an &apos; (Apostrophe) as the first character 
				// in the url, i.e. status.salesforce.com
				// This logic is being put in place to replace the first character if it is an '
				String link = downloadedItem.link;
				
				if( String.isNotBlank( link ) ) {
					
                    if( link.indexOf( '\'' ) == 0 ) {
						link = link.substring( 1, link.length() );
					}
                    
                    // guarantee that link is url encoded. Start by decoding url which should be original
                    // even if it wasn't encoded and then re-encode
                    link = EncodingUtil.urlDecode( link, 'UTF-8' );
                    link = EncodingUtil.urlEncode( link, 'UTF-8' );
                    
				}              
				
				RSS_Feed_Item__c feedItem = new RSS_Feed_Item__c(
					RSS_Feed__c = feed.Id,
					Title__c = downloadedItem.title,
					Description__c = downloadedItem.description,
					Link__c = link,
					GUID__c = hashedId			
				);
				
				feedItemList.add( feedItem );
				
			}
			
			upsert feedItemList GUID__c;
			
		}
		
	}
	
	/**
	* Helper method to get RSS_Feed__c by id
	*/
	private static RSS_Feed__c getRSSFeed( Id recordId ) {
		
		List<RSS_Feed__c> feedList = [
			SELECT
				Id,
				Active__c,
				URL__c,
            	Sync_Schedule__c,
            	Type__c,
            	Feed_Title_Key__c,
            	Feed_Description_Key__c,
            	Feed_Link_Key__c,
            	Item_ID_Key__c,
            	Item_Title_Key__c,
            	Item_Description_Key__c,
            	Item_Link_Key__c
			FROM
				RSS_Feed__c
			WHERE
				Id = :recordId				
		];
		
		if( feedList.size() > 0 ) {
			return feedList[0];			
		}
		
		return null;
		
	}
	
}