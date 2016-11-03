/**
* Original code provided by @DouglasCAyers and modified to support
* this data model
*
* https://github.com/DouglasCAyers/sfdc-process-builder-scheduler
*/
public class RSSScheduleAbortInvocable {
    
    @InvocableMethod( label = 'Abort Jobs' )
    public static void abortJobs( List<ID> recordIds ) {

        List<RSS_Feed__c> records = new List<RSS_Feed__c>([
            SELECT
                id, name, sync_schedule__c
            FROM
                RSS_Feed__c
            WHERE
                id IN :recordIds
        ]);

        System.debug( 'Aborting process schedules: ' + records );

        if ( records.size() > 0 ) {

            Set<String> jobNames = new Set<String>();
            for ( RSS_Feed__c record : records ) {
                jobNames.add( record.name );
            }

            for ( List<CronTrigger> cronTriggers : [
                SELECT
                    id, state, cronJobDetail.name
                FROM
                    CronTrigger
                WHERE
                    cronJobDetail.name IN :jobNames
            ]) {

                System.debug( 'CronTriggers to abort: ' + cronTriggers );

                for ( CronTrigger cronTrigger : cronTriggers ) {

                    try {

                        System.debug( 'Aborting job: ' + cronTrigger );
                        System.abortJob( cronTrigger.id );

                    } catch ( Exception e ) {

                        System.debug( LoggingLevel.ERROR, 'Error trying to abort job: ' + cronTrigger + ': ' + e.getStackTraceString() );

                    }

                }

            }

        }

    }
    
}