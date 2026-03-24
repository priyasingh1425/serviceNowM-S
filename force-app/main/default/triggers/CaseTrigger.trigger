trigger CaseTrigger on Case (after insert, before insert, after update) {

    HelperCaseTrigger triggerHandler = new HelperCaseTrigger();

    if (Trigger.isBefore && Trigger.isInsert) {
        triggerHandler.emailToCaseChanges(Trigger.New, Trigger.newMap);
        triggerHandler.checkForAssetBaseID(Trigger.New, Trigger.newMap);
        triggerHandler.stampCloneSource(Trigger.New);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        ChangeRequestHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        ChangeRequestHandler.afterUpdate(Trigger.oldMap, Trigger.new);
    }
}