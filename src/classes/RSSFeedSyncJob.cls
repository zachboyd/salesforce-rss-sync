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
		
		// download the RSS feed
		RSSFeedDownloadService.RSSFeed downloadedFeed = RSSFeedDownloadService.downloadRSSFeed( feed.URL__c );
		
		if( downloadedFeed != null ) {
			
			List<RSS_Feed_Item__c> feedItemList = new List<RSS_Feed_Item__c>();
			
			// build items
			
			for( RSSFeedDownloadService.RSSFeedItem downloadedItem : downloadedFeed.items ) {
				
				// the guid is the external id, but most RSS feeds use a url as the guid. This could
				// exceed the 255 character limit so we will hash the string to make it unique
				String hashedGuid = EncodingUtil.convertToHex( Crypto.generateDigest('SHA1',Blob.valueOf( downloadedItem.guid ) ) );
				
				RSS_Feed_Item__c feedItem = new RSS_Feed_Item__c(
					RSS_Feed__c = feed.Id,
					Title__c = downloadedItem.title,
					Description__c = downloadedItem.description,
					Link__c = downloadedItem.link,
					GUID__c = hashedGuid
				);
				
				feedItemList.add( feedItem );
				
			}
			
			for( RSS_Feed_Item__c item : feedItemList ) {
				System.debug( item.GUID__c );
			}
			
			upsert feedItemList;
			
		}
		
	}
	
	/**
	* Helper method to get RSS_Feed__c by id
	*/
	private static RSS_Feed__c getRSSFeed( Id recordId ) {
		
		List<RSS_Feed__c> feedList = [
			SELECT
				Id, 
				URL__c
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