public class AllwealthSnapshotFlowHelper {
    @InvocableMethod(label='Get Accountant and Estate Attorney Info')
    public static List<SnapshotInfoWrapper> getSnapshotInfo(List<Id> recordId) {
        List<SnapshotInfoWrapper> snapshotInfoList = new List<SnapshotInfoWrapper>();
        
        Set<String> addingConID = new Set<String>();
        List<AccountContactRelation> acrs =[SELECT Id, Account.Name,ContactId, Contact.Name,Roles,Name__c FROM AccountContactRelation WHERE Account.Id =: recordId];
        for(AccountContactRelation acr : acrs){
            addingConID.add(acr.ContactId);
        }
        
        
            SnapshotInfoWrapper snapshotInfo = new SnapshotInfoWrapper();
            snapshotInfo.accountId = recordId[0];
        
        
        
            List<FinServ__AccountAccountRelation__c> accountantsAAR = [SELECT Id, FinServ__RelatedAccount__r.Name, FinServ__RelatedAccount__r.Phone, FinServ__Role__r.Name   
                                                        FROM FinServ__AccountAccountRelation__c
                                                         WHERE FinServ__Account__r.Id = :recordId
                                                       	 AND FinServ__Role__r.Name ='Accountant'];
              
        
            List<FinServ__ContactContactRelation__c> accountants = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
                                             
                                                                    FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c Where FinServ__RelatedContact__r.Id IN : addingConID And FinServ__Role__r.Name ='Accountant' ];
            if (accountants.size() > 0) {
                snapshotInfo.accountantName = accountants[0].FinServ__RelatedContact__r.Name;
                snapshotInfo.accountantPhone = accountants[0].FinServ__RelatedContact__r.Phone;  
            } 
        
       		 else if (accountantsAAR.size() > 0){
                snapshotInfo.accountantName = accountantsAAR[0].FinServ__RelatedAccount__r.Name;
                snapshotInfo.accountantPhone = accountantsAAR[0].FinServ__RelatedAccount__r.Phone;
            }
        
        List<FinServ__AccountAccountRelation__c> estateAttorneysAAR = [SELECT Id, FinServ__RelatedAccount__r.Name, FinServ__RelatedAccount__r.Phone, FinServ__Role__r.Name   
                                                        FROM FinServ__AccountAccountRelation__c
                                                         WHERE FinServ__Account__r.Id = :snapshotInfo.accountId
                                                       	 AND FinServ__Role__r.Name ='Estate Attorney'];
        
        List<FinServ__ContactContactRelation__c> estateAttorneys = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
                                                                        FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c Where FinServ__RelatedContact__r.Id IN : addingConID And FinServ__Role__r.Name = 'Estate Attorney' ];
            if (estateAttorneys.size() > 0) { 
                snapshotInfo.EstateAttorneyName = estateAttorneys[0].FinServ__RelatedContact__r.Name;
                snapshotInfo.EstateAttorneyPhone = estateAttorneys[0].FinServ__RelatedContact__r.Phone;  
            }
         else if (estateAttorneysAAR.size() > 0){
                snapshotInfo.EstateAttorneyName = estateAttorneysAAR[0].FinServ__RelatedAccount__r.Name;
                snapshotInfo.EstateAttorneyPhone = estateAttorneysAAR[0].FinServ__RelatedAccount__r.Phone;
            }
            snapshotInfoList.add(snapshotInfo); 
        return snapshotInfoList;
    }

    public class SnapshotInfoWrapper {
        @InvocableVariable(required=true)
        public Id accountId;

        @InvocableVariable
        public String accountantName;

        @InvocableVariable
        public String accountantPhone;

        @InvocableVariable
        public String EstateAttorneyName;

        @InvocableVariable
        public String EstateAttorneyPhone; 
    }
}