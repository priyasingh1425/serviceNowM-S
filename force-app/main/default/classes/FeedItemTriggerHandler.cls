public with sharing class FeedItemTriggerHandler {
    public static void afterInsert(List<FeedItem> newRecords) {
        if (TriggerBypass.isFeedItemTriggerBypassed()) {
            return;
        }
        List<FeedItem> records = new List<FeedItem>();
        for (FeedItem record : newRecords) {
            if (record.ParentId != null && record.ParentId.getSObjectType() == Case.SObjectType) {
                records.add(record);
            }
        }

        if (!records.isEmpty()) {
            System.enqueueJob(new CreateRequestQueueable(new List<Case>(), new List<Task>(), records, false, false, false));
        }
    }
}
