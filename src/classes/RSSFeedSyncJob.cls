global class RSSFeedSyncJob implements Schedulable {
	
	private Id recordId;
	
	public RSSFeedSyncJob( Id recordId ) {
		this.recordId = recordId;
	}
	
	public void execute( SchedulableContext context ) {
		
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
				
				// Hash the id field just in case it is greater than 255. This should still allow for a unique value, assuming the
				// key was unique to being with
				String hashedId = EncodingUtil.convertToHex( Crypto.generateDigest( 'SHA1', Blob.valueOf( downloadedItem.id ) ) );								
				
				RSS_Feed_Item__c feedItem = new RSS_Feed_Item__c(
					RSS_Feed__c = feed.Id,
					Title__c = downloadedItem.title,
					Description__c = downloadedItem.description,
					Link__c = downloadedItem.link,
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