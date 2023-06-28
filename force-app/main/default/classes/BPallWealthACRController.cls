public with sharing class BPallWealthACRController {
    @AuraEnabled(Cacheable = true)
    public static List<AccountContactRelation> getAccounts(String accId){
      return [SELECT Id, Account.Name, Contact.Name,Roles,Name__c, Birthdate__c FROM AccountContactRelation WHERE Account.Id =: accId];
      
    }

    @AuraEnabled
    public static List<AccountContactRelation> getAccountsim(String accId){
      return [SELECT Id, Account.Name, Contact.Name,Roles,Name__c, Birthdate__c FROM AccountContactRelation WHERE Account.Id =: accId];
      
    }
 
}