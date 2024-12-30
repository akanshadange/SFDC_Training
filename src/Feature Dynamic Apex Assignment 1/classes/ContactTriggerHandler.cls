/*
Description  : Manage All Events Related To Contacts.
Created By 	 : Akansha Dange
Created Date : 5-12-2024
*/

public virtual class ContactTriggerHandler extends TriggerHandler {

    // Implement the beforeInsert method
    public override void beforeInsert() {
        List<Contact> newConList = (List<Contact>)Trigger.New;
        Map<Id, Contact> oldConMap = (Map<Id, Contact>)Trigger.oldMap;
        checkContactEmailDomain(newConList, null);
        processContactRecords(newConList);
    }

    // Implement the beforeUpdate method
    public override void beforeUpdate() {
        List<Contact> newConList = (List<Contact>)Trigger.New;
        Map<Id, Contact> oldConMap = (Map<Id, Contact>)Trigger.oldMap;
        checkContactEmailDomain(newConList, oldConMap);
        processContactRecords(newConList);
    }
    public static void checkContactEmailDomain(List<Contact> newConList, Map<Id, Contact> oldConMap) {
        if (!newConList.isEmpty()) {
            Set<Id> setOfAccountIds = new Set<Id>();
            for (Contact con : newConList) {
                if (con.AccountId != null && con.Email != null && 
                   (oldConMap == null || con.Email != oldConMap.get(con.Id).Email || con.AccountId != oldConMap.get(con.Id).AccountId)) {
                    setOfAccountIds.add(con.AccountId);
                }
            }

            if (!setOfAccountIds.isEmpty()) {
                Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Domain__c FROM Account WHERE Id IN :setOfAccountIds]);
                for (Contact con : newConList) {
                    if (con.AccountId != null && con.Email != null && accountMap.containsKey(con.AccountId)) {
                        Account acc = accountMap.get(con.AccountId);
                        if (acc != null && acc.Domain__c != null) {
                            String domain = acc.Domain__c.toLowerCase();
                            if (!con.Email.endsWith('@' + domain)) {
                                con.addError('Email domain must match the associated Account domain: ' + domain);
                            }
                        }
                    }
                }
            }
        }
    }

    // Process RecordId__c and set Object_Name__c and Picklist_Field__c
    public static void processContactRecords(List<Contact> contactRecords) {
        for (Contact contact : contactRecords) {
            if (String.isNotBlank(contact.RecordId__c)) {
                String recordId = contact.RecordId__c;
                String objectName = getObjectNameFromRecordId(recordId);
                if (objectName != null) {
                    contact.Object_Name__c = objectName;
                    String picklistValues = getPicklistFieldNamesForObject(objectName);
                    contact.Picklist_Field__c = picklistValues;
                } else {
                    contact.addError('The entered Record ID is invalid or does not belong to any object.');
                }
            }
        }
    }

    // Get the object name based on the Record ID
    public static String getObjectNameFromRecordId(String recordId) {
        if (recordId != null && recordId.length() == 18) {
            String objectPrefix = recordId.substring(0, 3);
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            for (String key : globalDescribeMap.keySet()) {
                Schema.SObjectType sObjectType = globalDescribeMap.get(key);
                if (sObjectType.getDescribe().getKeyPrefix() == objectPrefix) {
                    return sObjectType.getDescribe().getName();
                }
            }
        }
        return null; 
    }

    // Retrieve the picklist values for a given object
    public static String getPicklistFieldNamesForObject(String objectName) {
        String picklistFieldNames = '';
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        if (globalDescribeMap.containsKey(objectName)) {
            Schema.SObjectType sObjectType = globalDescribeMap.get(objectName);
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            for (Schema.SObjectField field : fieldsMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                    picklistFieldNames += fieldDescribe.getName() + '\n';
                }
            }
        }
        return picklistFieldNames;
    }
}