public class RSSFeedSyncSchedulableJob implements Schedulable {
	
    private Id recordId { get; set; }
    
    public RSSFeedSyncSchedulableJob( Id recordId ) {        
        this.recordId = recordId;        
    }
    
    public void execute( SchedulableContext context ) {
		
		// create new instance of this call and enqueue job
		RSSFeedSyncJob job = new RSSFeedSyncJob( this.recordId );
		
        // enqueue job for execution
        System.enqueueJob( job );
        
	}
    
}