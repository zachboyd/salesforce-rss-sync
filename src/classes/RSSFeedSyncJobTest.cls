@isTest
public class RSSFeedSyncJobTest {

	@IsTest
	static void test_rss_feed_download() {
		
		// The RSS sample was taken from http://www.w3schools.com/xml/xml_rss.asp and modified
    	// to only include one item
		String httpResponse = '<?xml version="1.0" encoding="UTF-8" ?> <rss version="2.0"> <channel> <title>W3Schools Home Page</title> <link>http://www.w3schools.com</link> <description>Free web building tutorials</description> <item> <title>RSS Tutorial</title> <link>http://www.w3schools.com/xml/xml_rss.asp</link> <description>New RSS tutorial on W3Schools</description> <guid>1234</guid> </item> </channel> </rss>';
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout( httpResponse ) );
	
		Test.startTest();
			
		RSSFeedDownloadService.RSSFeed feed = RSSFeedDownloadService.downloadRSSFeed( 'link ignored due to mock callout' );
	
		// Asert feed values	
					
		System.assert( feed != null, 'RSS feed should not be null' );

		System.assertEquals( 'W3Schools Home Page', feed.title );
		System.assertEquals( 'http://www.w3schools.com', feed.link );
		System.assertEquals( 'Free web building tutorials', feed.description );

		// Assert item values

		System.assert( feed.items != null, 'RSS feed items should not be null' );
		System.assert( feed.items.size() == 1, 'RSS feed items size should be equal to 1' );
		
		RSSFeedDownloadService.RSSFeedItem item = feed.items.get( 0 );
		
		System.assertEquals( 'RSS Tutorial', item.title );
		System.assertEquals( 'http://www.w3schools.com/xml/xml_rss.asp', item.link );
		System.assertEquals( 'New RSS tutorial on W3Schools', item.description );
		System.assertEquals( '1234', item.id );
		
		Test.stopTest();
		
	}
	
	@IsTest
	static void test_rss_feed_download_with_options() {
		
		// The RSS sample was taken from http://www.w3schools.com/xml/xml_rss.asp and modified
    	// to only include one item
		String httpResponse = '<?xml version="1.0" encoding="UTF-8" ?> <rss version="2.0"> <channel> <title>W3Schools Home Page</title> <link>http://www.w3schools.com</link> <description>Free web building tutorials</description> <item> <title>RSS Tutorial</title> <link>http://www.w3schools.com/xml/xml_rss.asp</link> <description>New RSS tutorial on W3Schools</description> <guid>1234</guid> </item> </channel> </rss>';
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout( httpResponse ) );
	
		Test.startTest();
		
		// Create new options that shift the keys and assert that they were
		// set properly
		
		RSSFeedDownloadService.RSSOptions options = new RSSFeedDownloadService.RSSOptions(); 
			
		options.feedTitleKey = 'link';
		options.feedLinkKey = 'title';
		options.feedDescriptionKey = 'description';
		
		options.feedItemIdKey = 'link';
		options.feedItemTitleKey = 'title';
		options.feedItemLinkKey = 'description';
		options.feedItemDescriptionKey = 'guid';
		options.feedItemPublishedDateKey = 'pubDate';
		 
		RSSFeedDownloadService.RSSFeed feed = RSSFeedDownloadService.downloadRSSFeed( 'link ignored due to mock callout', options );
			
		// Asert feed values	
			
		System.assert( feed != null, 'RSS feed should not be null' );

		System.assertEquals( 'W3Schools Home Page', feed.link );
		System.assertEquals( 'http://www.w3schools.com', feed.title );
		System.assertEquals( 'Free web building tutorials', feed.description );

		// Assert item values

		System.assert( feed.items != null, 'RSS feed items should not be null' );
		System.assert( feed.items.size() == 1, 'RSS feed items size should be equal to 1' );
		
		RSSFeedDownloadService.RSSFeedItem item = feed.items.get( 0 );
		
		System.assertEquals( 'RSS Tutorial', item.title );
		System.assertEquals( 'http://www.w3schools.com/xml/xml_rss.asp', item.id );
		System.assertEquals( 'New RSS tutorial on W3Schools', item.link );
		System.assertEquals( '1234', item.description );
		
		Test.stopTest();
		
	}
	
	@IsTest
	static void test_sharepoint_list_download_with_options() {
		
		// The RSS sample was taken from http://www.w3schools.com/xml/xml_rss.asp and modified
    	// to only include one item
		String httpResponse = '<?xml version="1.0" encoding="UTF-8"?> <feed xml:base="https://customdomain.sharepoint.com/_api/" xmlns="http://www.w3.org/2005/Atom" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml"> <id>d3542f4a-7437-4d8c-9895-8157a90be3bf</id> <title /> <updated>2016-11-08T01:58:34Z</updated> <entry m:etag="&quot;10&quot;"> <id>8df2c839-6de6-4f9a-b66d-fd1d0265166a</id> <category term="SP.Data.PagesItem" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" /> <link rel="edit" href="Web/Lists(guid\'956a34de-3ca7-4c6d-9113-0d65711356bc\')/Items(1)" /> <title /> <updated>2016-11-08T02:36:34Z</updated> <author> <name /> </author> <content type="application/xml"> <m:properties> <d:Id m:type="Edm.Int32">1</d:Id> <d:Title>Title</d:Title> <d:Summary>​text goes here</d:Summary> <d:Created m:type="Edm.DateTime">2016-10-31T15:11:06Z</d:Created> <d:FileRef>/mylink.aspx</d:FileRef> <d:GUID m:type="Edm.Guid">6c1909db-5d4c-4afb-89b0-c687f9822ed8</d:GUID> </m:properties> </content> </entry> <link rel="next" href="https://customdomain.sharepoint.com/_api/web/lists(guid\'956a34de-3ca7-4c6d-9113-0d65711356bc\')/items?%24skiptoken=Paged%3dTRUE%26p_Created%3d20161014%252016%253a22%253a33%26p_ID%3d924&amp;%24select=Title%2cSummary%2cCreated&amp;%24top=10&amp;%24orderby=Created+desc" /> </feed>';
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout( httpResponse ) );
	
		Test.startTest();
		
		// Create new options that shift the keys and assert that they were
		// set properly
		
		RSSFeedDownloadService.RSSOptions options = new RSSFeedDownloadService.RSSOptions(); 
		
		options.feedType = RSSFeedDownloadService.FEED_TYPE_SHAREPOINT_LIST;
		options.feedTitleKey = 'title';
		options.feedLinkKey = 'link';
		options.feedDescriptionKey = 'summary';
		
		options.feedItemIdKey = 'guid';
		options.feedItemTitleKey = 'title';
		options.feedItemLinkKey = 'fileref';
		options.feedItemDescriptionKey = 'summary';
		options.feedItemPublishedDateKey = 'created';
		 
		RSSFeedDownloadService.RSSFeed feed = RSSFeedDownloadService.downloadRSSFeed( 'link ignored due to mock callout', options );
			
		// Asert feed values	
			
		System.assert( feed != null, 'RSS feed should not be null' );

		// Assert item values

		System.assert( feed.items != null, 'RSS feed items should not be null' );
		System.assert( feed.items.size() == 1, 'RSS feed items size should be equal to 1' );
		
		RSSFeedDownloadService.RSSFeedItem item = feed.items.get( 0 );

		System.assertEquals( '6c1909db-5d4c-4afb-89b0-c687f9822ed8', item.id );		
		System.assertEquals( 'Title', item.title );
		System.assertEquals( 'https://customdomain.sharepoint.com/mylink.aspx', item.link );
		
		System.assert( 'text goes here' == item.description, 'Item description not equal' );
		
		Test.stopTest();
		
	}

	@isTest
	static void testRSSFeedSync() {
		
		String httpResponse = '<?xml version="1.0" encoding="UTF-8" ?> <rss version="2.0"> <channel> <title>W3Schools Home Page</title> <link>http://www.w3schools.com</link> <description>Free web building tutorials</description> <item> <title>RSS Tutorial</title> <link>http://www.w3schools.com/xml/xml_rss.asp</link> <description>New RSS tutorial on W3Schools</description> <guid>1234</guid> </item> </channel> </rss>';
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout( httpResponse ) );
	
		RSS_Feed__c feed = new RSS_Feed__c(
			Title__c = 'My Test RSS Feed',
			URL__c = 'http://myrandomurlfortestcase.org',
			Active__c = true,
			Sync_Schedule__c = '0 0 * * * ?'
		);
		
		insert feed;
			
		Test.startTest();
		
		// sync the feed
		RSSFeedSyncJob.syncFeed( feed );
		
		// get count of feed items for feed
		Integer count = [SELECT count() FROM RSS_Feed_Item__c WHERE RSS_Feed__c = :feed.Id];
		
		// Assert that we have one feed item persisted
		System.assertEquals( count, 1 );
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testRSSFeedSyncReschedule() {
		
		String httpResponse = '<?xml version="1.0" encoding="UTF-8" ?> <rss version="2.0"> <channel> <title>W3Schools Home Page</title> <link>http://www.w3schools.com</link> <description>Free web building tutorials</description> <item> <title>RSS Tutorial</title> <link>http://www.w3schools.com/xml/xml_rss.asp</link> <description>New RSS tutorial on W3Schools</description> <guid>1234</guid> </item> </channel> </rss>';
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout( httpResponse ) );
	
		RSS_Feed__c feed = new RSS_Feed__c(
			Title__c = 'My Test RSS Feed',
			URL__c = 'http://myrandomurlfortestcase.org',
			Active__c = true,
			Sync_Schedule__c = '0 0 * * * ?'
		);
		
		insert feed;
	
		feed.Sync_Schedule__c = '0 2 * * * ?';
		
		update feed;
	
		Test.startTest();
		
		// sync the feed
		RSSFeedSyncJob.syncFeed( feed );
		
		Test.stopTest();
		
	}
	
}