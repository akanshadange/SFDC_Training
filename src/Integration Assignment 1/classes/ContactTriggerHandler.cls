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
    public override void afterInsert() {
        List<Contact> newConList = (List<Contact>)Trigger.New;
        Map<Id,contact> oldcontact=(Map<Id,Contact>)Trigger.oldMap;
        handleContactUpdates(newConList,null);
        countcontacts(newConList, null);
    }
    public override void afterUpdate() {
        List<Contact> newConList = (List<Contact>)Trigger.New;
        Map<Id,contact> oldcontact=(Map<Id,Contact>)Trigger.oldMap;
        handleContactUpdates(newConList,oldcontact);
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
    //API Calling for addresss verfication
    public static void handleContactUpdates(List<contact> newConList,Map<Id,Contact> oldcontact){
        Set<Id> contactIdsSet = new Set<Id>();
        if(!newConList.isEmpty()){
            for (Contact con : newConList) {
                if((oldcontact == null && String.isNotBlank(con.MailingStreet) && String.isNotBlank(con.MailingCity) && String.isNotBlank(con.MailingState) && con.MailingPostalCode != null) ||
                  (oldcontact != null && oldcontact.containsKey(con.Id) && (oldcontact.get(con.Id).MailingStreet != con.MailingStreet || oldcontact.get(con.Id).MailingCity != con.MailingCity || oldcontact.get(con.Id).MailingState != con.MailingState || oldcontact.get(con.Id).MailingPostalCode != con.MailingPostalCode))) {
                    contactIdsSet.add(con.Id);
                }
            }
        }
        if(!RecursionPrevention.isUpdateInitiatedByCallout && !contactIdsSet.isEmpty()) {
            validateAddress(contactIdsSet);
        }
    }
    @future(callout=true)
    private static void validateAddress(Set<Id> contactIds) {
        List<Contact> contactList = [SELECT Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,Address_Verified__c FROM Contact WHERE Id IN:contactIds];
        List<Contact> contactListToUpdate = new List<Contact>();
        if (!contactList.isEmpty()) {
            for(Contact con: contactList) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://us-street.api.smarty.com/street-address?auth-id=3a0905f3-b429-fa33-ddcd-50aee387d520&auth-token=DR9oq2t4oscRhSS3wXMN' + 
                                '&street=' + EncodingUtil.urlEncode(con.MailingStreet, 'UTF-8') + 
                                '&city=' + EncodingUtil.urlEncode(con.MailingCity, 'UTF-8') +
                                '&state=' + EncodingUtil.urlEncode(con.MailingState, 'UTF-8') +
                                '&zipcode=' + EncodingUtil.urlEncode(con.MailingPostalCode, 'UTF-8') +'&candidates=1'); 
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() == 200) {
                    List<Object> responseBody = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    if (!responseBody.isEmpty()) {
                        con.Address_Verified__c = true;
                    } else {
                        con.Address_Verified__c = false;
                    }
                } else {
                    con.Address_Verified__c = false;
                }
                contactListToUpdate.add(con);
            } 
        }
        RecursionPrevention.isUpdateInitiatedByCallout=true;
        if(!contactListToUpdate.isEmpty()) {
            update contactListToUpdate;
        }
        RecursionPrevention.isUpdateInitiatedByCallout=false;
    }
    public static void countcontacts(List<contact>newConList ,Map<Id,contact> oldcontact){
        set<id> accids= new set<id>();
                try{
       if(!newConList.isEmpty()){
            for (Contact con : newConList) {
                if((oldcontact == null && con.AccountId!=null) ||
                  (oldcontact != null && oldcontact.get(con.Id).AccountId != con.AccountId )) {
                    accids.add(con.Id);
                }
            }
        }
     List<Account> acc = [Select id, No_Of_Contacts__c,(Select id from Contacts) from Account where id IN: accids];
        if(acc!=null){
        for(Account accValue:acc){
            accValue.No_Of_Contacts__c = accValue.Contacts.size();
        } 
        }
        if(!acc.isempty()){
        update acc;
        }
        }
        catch(exception e){
            System.debug('Get Message'+e.getMessage());
        }
    }
}