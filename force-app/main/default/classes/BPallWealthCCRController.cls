public with sharing class BPallWealthCCRController {


  // add related contacts
  @AuraEnabled
    public static List<Contact> getRelatedContacts (String accId){
      System.debug('Id=======>'+accId);
        Set<String> addingConID = new Set<String>();
        List<AccountContactRelation> acrs =[SELECT Id, Account.Name,ContactId, Contact.Name,Roles,Name__c FROM AccountContactRelation WHERE Account.Id =: accId ];
        for(AccountContactRelation acr : acrs){
         addingConID.add(acr.ContactId);
        }
      return [SELECT Id,Name FROM Contact Where Id IN : addingConID];
      
      }

// add related Role
      @AuraEnabled
      public static List<FinServ__ReciprocalRole__c> getRelatedRole (){
          
        return [SELECT Id,Name, FinServ__InverseRole__c,FinServ__RelationshipType__c  FROM FinServ__ReciprocalRole__c];
        
        }

      


    @AuraEnabled(Cacheable = true)
    public static List<FinServ__ContactContactRelation__c> getContacts(String accId){

      system.debug('ContactContactRelation=========> '+accId);
        Set<String> addingConID = new Set<String>();
        List<AccountContactRelation> acrs =[SELECT Id, Account.Name,ContactId, Contact.Name,Roles,Name__c FROM AccountContactRelation WHERE Account.Id =: accId ];
        for(AccountContactRelation acr : acrs){
         addingConID.add(acr.ContactId);
            system.debug('Contact.Name'+acr.Contact.Name);
        }
      return [SELECT Id, FinServ__RelatedContact__c, FinServ__Role__c,FinServ__Contact__c,Contact_Name__c,Related_Role__c,RelatedContactName__c  FROM FinServ__ContactContactRelation__c Where FinServ__RelatedContact__r.Id IN : addingConID];
      
      }

}