public with sharing class CreateRequestQueueable implements Queueable, Database.AllowsCallouts {

    private List<Case> casesList;
    private List<Task> taskList;
    private List<FeedItem> notesIds;
    private Boolean isCaseUpdate;
    private Boolean isTaskUpdate;
    private Boolean priorityUpdate;

    public CreateRequestQueueable(List<Case> casesList, List<Task> taskList, List<FeedItem> notesIds, Boolean isCaseUpdate, Boolean isTaskUpdate, Boolean priorityUpdate) {
        this.casesList = casesList;
        this.taskList = taskList;
        this.notesIds = notesIds;
        this.isCaseUpdate = isCaseUpdate;
        this.isTaskUpdate = isTaskUpdate;
        this.priorityUpdate = priorityUpdate;
    }

    public void execute(QueueableContext qc) {
        List<Account> accounts = [
            SELECT Id FROM Account
            WHERE Name = :CityIntegrationConstants.ACCOUNT_NAME
            AND RecordType.Name = :CityIntegrationConstants.ACCOUNT_RT_CUSTOMER
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            return;
        }
        Account acc = accounts[0];

        processCases(acc);
        processTasks();
        processFeedItems();
    }

    private void processCases(Account acc) {
        if (casesList.isEmpty()) {
            return;
        }

        Map<Id, Schema.RecordTypeInfo> rtMap = Case.SObjectType.getDescribe().getRecordTypeInfosById();

        for (Case c : casesList) {
            String recordTypeName = getRecordTypeName(rtMap, c.RecordTypeId);

            if (isCaseUpdate) {
                processCaseUpdate(c, recordTypeName, acc);
            } else if (priorityUpdate) {
                API_IncidentService.updatePriorityOnIncidents(c);
            } 
        }
    }

    private void processCaseUpdate(Case c, String recordTypeName, Account acc) {
        if (recordTypeName == CityIntegrationConstants.RT_CHANGE_REQUEST) {
            processChangeRequestUpdate(c, acc);
        } else if (recordTypeName == CityIntegrationConstants.RT_EXTERNAL_CUSTOMER_SUPPORT) {
            processExternalCustomerSupportUpdate(c, acc);
        }
    }

    private void processChangeRequestUpdate(Case c, Account acc) {
        if (c.Status == CityIntegrationConstants.STATUS_RESOLVED) {
            API_ChangeRequestService.closeChangeRequest(c);
        } else if (c.Technical_Approved__c == true && isEligibleForChangeRequest(c, acc)) {
            API_ChangeRequestService.createCR(c);
        }
    }

    private void processExternalCustomerSupportUpdate(Case c, Account acc) {
        if (c.Status == CityIntegrationConstants.STATUS_RESOLVED) {
            API_IncidentService.resolveIncidents(c);
        } else if (isEligibleForIncidentCreation(c, acc)) {
            API_IncidentService.createIncident(c);
        } else {
            API_IncidentService.updateIncidentStatus(c);
        }
    }

    private void processTasks() {
        if (taskList.isEmpty() || !isTaskUpdate) {
            return;
        }

        for (Task t : taskList) {
            API_ChangeRequestService.updateTaskStatus(t);
        }
    }

    private void processFeedItems() {
        if (notesIds.isEmpty()) {
            return;
        }

        Set<Id> noteIds = new Set<Id>();
        for (FeedItem notes : notesIds) {
            if (notes != null && notes.Id != null) {
                noteIds.add(notes.Id);
            }
        }

        if (noteIds.isEmpty()) {
            return;
        }

        List<FeedItem> feedItems = [
            SELECT Id, ParentId, Body, Visibility, Type
            FROM FeedItem
            WHERE Id IN :noteIds
            ORDER BY CreatedDate ASC
        ];

        if (feedItems.isEmpty()) {
            return;
        }

        processSingleFeedItem(feedItems[0]);

        if (feedItems.size() > 1) {
            List<FeedItem> remaining = new List<FeedItem>();
            for (Integer i = 1; i < feedItems.size(); i++) {
                remaining.add(new FeedItem(Id = feedItems[i].Id));
            }
            System.enqueueJob(new CreateRequestQueueable(new List<Case>(), new List<Task>(), remaining, false, false, false));
        }
    }

    private void processSingleFeedItem(FeedItem notes) {
        if (!isValidFeedItem(notes)) {
            return;
        }

        Id caseId = (Id) notes.ParentId;
        List<Case> parentCases = [SELECT Customer_Rec_Id__c FROM Case WHERE Id = :caseId LIMIT 1];
        if (parentCases.isEmpty()) {
            return;
        }
        String serviceNumber = parentCases[0].Customer_Rec_Id__c;

        if (String.isBlank(serviceNumber)) {
            return;
        }

        routeWorkNoteByServiceNumber(notes, serviceNumber);
    }

    private void routeWorkNoteByServiceNumber(FeedItem notes, String serviceNumber) {
        if (serviceNumber.startsWith(CityIntegrationConstants.PREFIX_INCIDENT)) {
            API_IncidentService.createWorkNote(notes, serviceNumber);
        } else if (serviceNumber.startsWith(CityIntegrationConstants.PREFIX_CHANGE) || serviceNumber.startsWith(CityIntegrationConstants.PREFIX_CHANGE_TASK)) {
            API_ChangeRequestService.createWorkNote(notes, serviceNumber);
        }
    }

    private String getRecordTypeName(Map<Id, Schema.RecordTypeInfo> rtMap, Id recordTypeId) {
        Schema.RecordTypeInfo rtInfo = rtMap.get(recordTypeId);
        return rtInfo != null ? rtInfo.getDeveloperName() : null;
    }

    private Boolean isValidFeedItem(FeedItem notes) {
        return notes.ParentId != null
            && notes.ParentId.getSObjectType() == Case.SObjectType
            && notes.Visibility == 'AllUsers'
            && notes.Type == 'TextPost';
    }

    private Boolean isEligibleForChangeRequest(Case c, Account acc) {
        return c.Origin != CityIntegrationConstants.ORIGIN_API
            && CityIntegrationConstants.ELIGIBLE_PRIORITIES.contains(c.Priority)
            && c.AccountId == acc.Id;
    }

    private Boolean isEligibleForIncidentCreation(Case c, Account acc) {
        return c.Origin != CityIntegrationConstants.ORIGIN_API
            && c.Status == CityIntegrationConstants.STATUS_PARKED
            && c.Status_Reason__c == CityIntegrationConstants.STATUS_REASON_WAITING
            && CityIntegrationConstants.ELIGIBLE_PRIORITIES.contains(c.Priority)
            && c.AccountId == acc.Id;
    }
}
