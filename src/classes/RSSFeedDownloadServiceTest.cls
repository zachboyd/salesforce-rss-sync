@IsTest
public class RSSFeedDownloadServiceTest {
    
    @IsTest
	static void testRSSFeedDownload() {
		
		// set http callout mock
		Test.setMock( HttpCalloutMock.class, new RSSFeedMockHttpCallout() );
	
		Test.startTest();
			
		// Asert feed values	
		
		RSSFeedDownloadService.RSSFeed feed = RSSFeedDownloadService.downloadRSSFeed( RSSFeedMockHttpCallout.FEED_LINK );
			
		System.assert( feed != null, 'RSS feed should not be null' );

		System.assertEquals( feed.title, RSSFeedMockHttpCallout.FEED_TITLE );
		System.assertEquals( feed.link, RSSFeedMockHttpCallout.FEED_LINK );
		System.assertEquals( feed.description, RSSFeedMockHttpCallout.FEED_DESCRIPTION );

		// Assert item values

		System.assert( feed.items != null, 'RSS feed items should not be null' );
		System.assert( feed.items.size() == 1, 'RSS feed items size should be equal to 1' );
		
		RSSFeedDownloadService.RSSFeedItem item = feed.items.get( 0 );
		
		System.assertEquals( item.title, RSSFeedMockHttpCallout.ITEM_TITLE );
		System.assertEquals( item.link, RSSFeedMockHttpCallout.ITEM_LINK );
		System.assertEquals( item.description, RSSFeedMockHttpCallout.ITEM_DESCRIPTION );
		System.assertEquals( item.guid, RSSFeedMockHttpCallout.ITEM_GUID );
		
		Test.stopTest();
		
	}
	
}