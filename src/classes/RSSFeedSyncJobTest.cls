@isTest
public class RSSFeedSyncJobTest {

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
	
}