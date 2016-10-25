@IsTest
public class RSSFeedSyncJobTest {

	@IsTest
	static void testRSSFeedSync() {
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout() );
		
		RSS_Feed__c feed = createRssFeed();
		 
		Test.startTest();
		
		// sync the feed
		RSSFeedSyncJob.syncFeed( feed );
		
		// get count of feed items for feed
		Integer count = [SELECT count() FROM RSS_Feed_Item__c WHERE RSS_Feed__c = :feed.Id];
		
		// Assert that we have one feed item persisted
		System.assertEquals( count, 1 );
		
		Test.stopTest();
		
	}
	
	private static RSS_Feed__c createRssFeed() {
		
		RSS_Feed__c feed = new RSS_Feed__c(
			Name = RSSFeedMockHttpCallout.FEED_TITLE,
			URL__c = RSSFeedMockHttpCallout.FEED_LINK,
			Active__c = true
		);
		
		insert feed;
		
		return feed;
		
	}

}