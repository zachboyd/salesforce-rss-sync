public class RSSFeedDownloadService {
	
	public class RSSFeed {
		
		public String title { get; set; }
		public String link { get; set; }
		public String description { get; set; }	
		
		public List<RSSFeedItem> items { get; set; }
		
		public RSSFeed() {
			items = new List<RSSFeedItem>();
		}
		
	} 
	
	public class RSSFeedItem {
		
		public String guid { get; set; }
		public String title { get; set; }
		public String link { get; set; }
		public String description { get; set; }
		
	}
	
	public static RSSFeed downloadRSSFeed( String url ) {
	
		Http http = new Http();
		
		HttpRequest request = new HttpRequest();
		
		request.setMethod( 'GET' );
		
		// set endpoint for RSS feed
		request.setEndpoint( url );
		
		// send requset
		HttpResponse response = http.send( request );
		
		return parseDocument( response.getBodyDocument() );
	
	}
	
	private static RSSFeed parseDocument( Dom.Document document ) {
		
		DOM.XmlNode rss = document.getRootElement();
		
		RSSFeed feed = new RSSFeed();
		
		// extract RSS channel and add channel items
		
		for( DOM.XmlNode rootChild : rss.getChildren() ) {
			
			// the RSS feed should contain one channel
			if( rootChild.getName() == 'channel' ) {
				
				for( DOM.XmlNode channelChild : rootChild.getChildren() ) {
					
					if( channelChild.getName() == 'title' ) {
						feed.title = channelChild.getText();
					}
					else if( channelChild.getName() == 'link' ) {
						feed.link = channelChild.getText();
					}
					else if( channelChild.getName() == 'description' ) {
						feed.description = channelChild.getText();
					}
					else if( channelChild.getName() == 'item' ) {
						
						// create feed item
						RSSFeedItem item = new RSSFeedItem();
						
						// handle feed items
						for( DOM.XmlNode itemChild : channelChild.getChildren() ) {
							
							if( itemChild.getName() == 'title' ) {
								item.title = itemChild.getText();
							}
							else if( itemChild.getName() == 'link' ) {
								item.link = itemChild.getText();
							}
							else if( itemChild.getName() == 'description' ) {
								item.description = itemChild.getText();
							}	
							else if( itemChild.getName() == 'guid' ) {
								item.guid = itemChild.getText();
							}		
							
						}		
						
						// add item to list
						feed.items.add( item );				
												
					}
					
				}
				
			}
			
		}
		
		return feed;
		
	}
	
}