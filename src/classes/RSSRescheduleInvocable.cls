/**
* Original code provided by @DouglasCAyers and modified to support
* this data model
*
* https://github.com/DouglasCAyers/sfdc-process-builder-scheduler
*/
public class RSSRescheduleInvocable {
    
    @InvocableMethod( label = 'Reschedule Jobs' )
    public static List<String> rescheduleJobs( List<ID> recordIds ) {

        System.debug( 'Rescheduling jobs: ' + recordIds );

        RSSScheduleAbortInvocable.abortJobs( recordIds );

        List<String> jobIds = RSSScheduleInvocable.scheduleJobs( recordIds );

        System.debug( 'Rescheduled job ids: ' + jobIds );

        return jobIds;
        
    }
    
}