trigger APIResponseTrigger on API_Response__c (after insert) {

    List<Case> casesToUpdate = new List<Case>();
    Pattern p = Pattern.compile('\\b(CHG|INC)\\d{7,}\\b');

    for (API_Response__c responseRecord : Trigger.new) {

        if ((responseRecord.Message__c == 'API_ChangeRequestService CreateCR' || responseRecord.Message__c == 'API_IncidentService createIncident')
            && responseRecord.Code__c == 'Created'
            && responseRecord.Http_Response__c != null) {

            HttpRequestResponseModel.CRCreateResponse deserialized =
                (HttpRequestResponseModel.CRCreateResponse)
                JSON.deserialize(
                    responseRecord.Http_Response__c,
                    HttpRequestResponseModel.CRCreateResponse.class
                );

            String externalNumber = '';
            if (deserialized != null && deserialized.result != null && deserialized.result.response != null) {
                Matcher m = p.matcher(deserialized.result.response);
                if (m.find()) {
                    externalNumber = m.group();
                }
            }

            if (externalNumber != '' && responseRecord.Internal_Record_Identifier__c != null) {
                Case c = new Case();
                c.Id = responseRecord.Internal_Record_Identifier__c;
                c.Customer_Rec_Id__c = externalNumber;
                casesToUpdate.add(c);
            }
        }
    }

    if (!casesToUpdate.isEmpty()) {
        update casesToUpdate;
    }
}