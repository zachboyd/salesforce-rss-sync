global class RSSFeedMockHttpCallout implements HttpCalloutMock {
    
    public String httpResponse { get; set; }
    
    public RSSFeedMockHttpCallout( String httpResponse ) {
    	this.httpResponse = httpResponse;
    }
    
    global HttpResponse respond( HttpRequest request ) {
    	
    	HttpResponse response = new HttpResponse();
    	
    	response.setStatus( 'OK' );
    	response.setStatusCode( 200 );
    	
    	response.setBody( this.httpResponse );
    	
    	return response;
    	
    }
    
}