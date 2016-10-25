global class RSSFeedMockHttpCallout implements HttpCalloutMock {
    
    public static String FEED_TITLE = 'W3Schools Home Page';
    public static String FEED_DESCRIPTION = 'Free web building tutorials';
    public static String FEED_LINK = 'http://www.w3schools.com';
    
    public static String ITEM_TITLE = 'RSS Tutorial';
    public static String ITEM_DESCRIPTION = 'New RSS tutorial on W3Schools';
    public static String ITEM_LINK = 'http://www.w3schools.com/xml/xml_rss.asp';
    public static String ITEM_GUID = '1234';
    
    global HttpResponse respond( HttpRequest request ) {
    	
    	HttpResponse response = new HttpResponse();
    	
    	response.setStatus( 'OK' );
    	response.setStatusCode( 200 );
    	
    	// The RSS sample was taken from http://www.w3schools.com/xml/xml_rss.asp and modified
    	// to only include one item
    	response.setBody( '<?xml version="1.0" encoding="UTF-8" ?> <rss version="2.0"> <channel> <title>W3Schools Home Page</title> <link>http://www.w3schools.com</link> <description>Free web building tutorials</description> <item> <title>RSS Tutorial</title> <link>http://www.w3schools.com/xml/xml_rss.asp</link> <description>New RSS tutorial on W3Schools</description> <guid>1234</guid> </item> </channel> </rss>' );
    	
    	return response;
    	
    }
    
}