/**
* Original code provided by @DouglasCAyers and modified to support
* this data model
*
* https://github.com/DouglasCAyers/sfdc-process-builder-scheduler
*/
public class RSSScheduleInvocable {
    
    @InvocableMethod( label = 'Schedule Jobs' )
    public static List<String> scheduleJobs( List<ID> recordIds ) {

        List<RSS_Feed__c> records = new List<RSS_Feed__c>([
            SELECT
                id, name, sync_schedule__c
            FROM
                RSS_Feed__c
            WHERE
                id IN :recordIds
                AND
                active__c = true
        ]);

        System.debug( 'Scheduling processes: ' + records );

        List<String> jobIds = new List<String>();

        if ( records.size() > 0 ) {

            // before schedule the job, look to see
            // if the job has already been scheduled

            Set<String> jobNames = new Set<String>();
            for ( RSS_Feed__c record : records ) {
                jobNames.add( record.name );
            }

            Set<String> cronJobNames = new Set<String>();
            for ( CronTrigger cronTrigger : [
                SELECT
                    id, state, cronJobDetail.name
               	FROM
                    CronTrigger
                WHERE
                    cronJobDetail.name IN :jobNames
            ]) {
                cronJobNames.add( cronTrigger.cronJobDetail.name );
            }

            for ( RSS_Feed__c record : records ) {

                // if job has not already been scheduled then schedule it
                if ( !cronJobNames.contains( record.name ) ) {

                    System.debug( 'Scheduling job: ' + record );

                    String jobId = System.schedule(
                        record.name,
                        record.sync_schedule__c,
                        new RSSFeedSyncSchedulableJob( record.id )
                    );

                    jobIds.add( jobId );

                } else {

                    System.debug( LoggingLevel.WARN, 'Job has already been scheduled: ' + record.name );

                }

            }

        }

        return jobIds;
    }
    
}