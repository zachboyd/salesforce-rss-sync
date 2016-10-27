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
		
		public String id { get; set; }
		public String title { get; set; }
		public String link { get; set; }
		public String description { get; set; }
		public String publishedDate { get; set; }
		
	}
	
	public class RSSOptions {
		
		public String feedType { get; set; } 
		
		public String feedTitleKey { get; set; }
		public String feedLinkKey { get; set; }
		public String feedDescriptionKey { get; set; }
		
		public String feedItemIdKey { get; set; }
		public String feedItemTitleKey { get; set; }
		public String feedItemLinkKey { get; set; }
		public String feedItemDescriptionKey { get; set; }
		public String feedItemPublishedDateKey { get; set; }
        
        public RSSOptions() {
            
            // set default values
            
            feedType = 'Standard';
             
            feedTitleKey = 'title';
            feedLinkKey = 'link';
            feedDescriptionKey = 'description';
            
            feedItemIdKey = 'guid';
            feedItemTitleKey = 'title';
            feedItemLinkKey = 'link';
            feedItemDescriptionKey = 'description';
            feedItemPublishedDateKey = 'pubDate';
            
        }
		
	}
	
	public static RSSFeed downloadRSSFeed( String url ) {
		return downloadRSSFeed( url, new RSSOptions() );
	}
	
	public static RSSFeed downloadRSSFeed( String url, RSSOptions options ) {
	
		Http http = new Http();
		
		HttpRequest request = new HttpRequest();
		
		request.setMethod( 'GET' );
		
		// set endpoint for RSS feed
		request.setEndpoint( url );
		
		// send requset
		HttpResponse response = http.send( request );
        
        // check feed type and invoke correct parser
        if( options.feedType == 'Sharepoint List' ) {
            return parseSharepointList( response.getBodyDocument(), options );
        }
		
        // default to standard RSS feed
		return parseRssFeed( response.getXmlStreamReader(), options );
		
	}
	
	/**
	* Method to parse RSS feed. Since certain RSS feeds use CDATA tags we need
	* to use the XMLStreamReader instead of Dom.Document
	*/
	private static RSSFeed parseRssFeed( XmlStreamReader reader, RSSOptions options ) {
				
		boolean isSafeToGetNextXmlElement = true;
		
		while( isSafeToGetNextXmlElement ) {
			
			if( reader.getEventType() == XmlTag.START_ELEMENT ) {

				// the RSS feed should contain one channel
				if( reader.getLocalName() == 'channel' ) {
					return parseRssChannel( reader, options );
				}			
									
			}
			
			if( reader.hasNext() ) {
				reader.next();
			}
			else {
				isSafeToGetNextXmlElement = false;				
				break;
			}
						
		}
		
		return null;
		
	}
	
	private static RSSFeed parseRssChannel( XmlStreamReader reader, RSSOptions options ) {
		
		RSSFeed feed = new RSSFeed();
		
		boolean isSafeToGetNextXmlElement = true;
		
		while( isSafeToGetNextXmlElement ) {
			
			if( reader.getEventType() == XmlTag.START_ELEMENT ) {
				
				if( reader.getLocalName() == options.feedTitleKey ) {
					feed.title = parseString( reader );									
				}
				else if( reader.getLocalName() == options.feedLinkKey ) {
                    feed.link = parseString( reader );									
				}
				else if( reader.getLocalName() == options.feedDescriptionKey ) {
					feed.description = parseString( reader );
				}
				else if( reader.getLocalName() == 'item' ) {
					feed.items.add( parseRssItem( reader, options ) );
				}			
									
			}
			
			if( reader.hasNext() ) {
				reader.next();
			}
			else {
				isSafeToGetNextXmlElement = false;				
				break;
			}
						
		}
		
		return feed;
		
	}
	
	private static RSSFeedItem parseRssItem( XmlStreamReader reader, RSSOptions options ) {
		                
		RSSFeedItem item = new RSSFeedItem();
		
		boolean isSafeToGetNextXmlElement = true;
		
		while( isSafeToGetNextXmlElement ) {
			
            if( reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'item' ) {
                isSafeToGetNextXmlElement = false;
                break;
            }             
			else if( reader.getEventType() == XmlTag.START_ELEMENT ) {
				
				if( reader.getLocalName() == options.feedItemTitleKey ) {
					item.title = parseString( reader );															
				}
				else if( reader.getLocalName() == options.feedItemLinkKey ) {
					item.link = parseString( reader );															
				}
				else if( reader.getLocalName() == options.feedItemDescriptionKey ) {
                    item.description = parseString( reader );
				}
				else if( reader.getLocalName() == options.feedItemIdKey ) {
					item.id = parseString( reader );
				}
				else if( reader.getLocalName() == options.feedItemPublishedDateKey ) {
					item.publishedDate = parseString( reader );
				}
				
			}
			
			if( reader.hasNext() ) {
				reader.next();
			}
			else {
				isSafeToGetNextXmlElement = false;				
				break;
			}
						
		}
		
		return item;
		
	}
	
    private static String parseString( XmlStreamReader reader ) {
        
        String returnVal = '';
        
        boolean isSafeToGetNextXmlElement = true;
        
        while( isSafeToGetNextXmlElement ) {
            
            if( reader.getEventType() == XmlTag.END_ELEMENT ) {
                break;
            } 
            else if( reader.getEventType() == XmlTag.CHARACTERS ) {
                returnVal = returnVal + reader.getText();
            } 
            else if( reader.getEventType() == XmlTag.CDATA ) {
                returnVal = reader.getText();
            }
            
            if ( reader.hasNext() ) {
                reader.next();
            } 
            else {
                isSafeToGetNextXmlElement = false;
                break;
            }
            
        }
        
        return returnVal;
        
    }
    
	private static RSSFeed parseSharepointList( Dom.Document document, RSSOptions options ) {
		
		DOM.XmlNode rss = document.getRootElement();
		
		RSSFeed feed = new RSSFeed();
		
		// store base url from an attribute in the xml 
		String baseUrl = '';
		
		for( DOM.XmlNode rootChild : rss.getChildren() ) {
			
			if( rootChild.getName() == 'entry' ) {
				
				for( DOM.XmlNode entryChild : rootChild.getChildren() ) {
					
					if( entryChild.getName() == 'content' ) {
						
						for( DOM.XmlNode contentChild : entryChild.getChildren() ) {

							if( contentChild.getName() == 'properties' ) {
								
								// create feed item
								RSSFeedItem item = new RSSFeedItem();
								
								for( DOM.XmlNode propertiesChild : contentChild.getChildren() ) {
								
									if( propertiesChild.getName() == options.feedItemTitleKey ) {
										item.title = propertiesChild.getText();
									}
									else if( propertiesChild.getName() == options.feedItemLinkKey ) {
										item.link = propertiesChild.getText();
									}
									else if( propertiesChild.getName() == options.feedItemDescriptionKey ) {
										item.description = propertiesChild.getText();
									}	
									else if( propertiesChild.getName() == options.feedItemIdKey ) {
										item.id = propertiesChild.getText();
									}	
								
								}
								
								// add item to list
								feed.items.add( item );		
								
							}
							
						}
						
					}
					
				}
				
			}
			else if( rootChild.getName() == 'link' ) {
				
				// use the 'next' link to identify the domain that the items live on since the 
				// url could have been using a Named Credential callout. This will allow us to link
				// the item appropriately
				
				baseUrl = rootChild.getAttribute( 'href', '' );
				
				Url url = new Url( baseUrl );
				
				baseUrl = url.getProtocol() + '://' + url.getHost();
				
			}
			
		}
		
		// Loop through all items and update link appropriately. The sharepoint api will only return
		// a relative url instead of a full url so we must prepend the base url
		
		for( RSSFeedItem item : feed.items ) {
			item.link = baseUrl + item.link;
		}
		
		return feed;
		
	}
	
}