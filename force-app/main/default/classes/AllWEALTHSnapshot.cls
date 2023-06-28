public with sharing class AllWEALTHSnapshot {
    
    public List<Wealth_Planning__c> wealthPlanningFields { get; set; }   
    public List<Account> accountFields { get; set; }
    public String query { get; set; }
    public String accountant { get; set; }
    public String accountantPhone { get; set; }
    public String estateAttorney { get; set; }
    public String estateAttorneyPhone { get; set; }
   
 Integer orgNodeCount = 0;
    public String getAccountHierarchyJSON() { 
        try
        {
    
            String recordId = ApexPages.currentPage().getParameters().get('id');
            accountant = '';
            accountantPhone = '';
            estateAttorney = '';
            estateAttorneyPhone = '';
            accountFields = [Select Id, FinServ__PrimaryContact__r.Name,Primary_Advisor__c,
                             FinServ__PrimaryContact__r.FirstName,Secondary_Contact__r.Name,
                             Secondary_Contact__r.FirstName, Owner.Name,Associate_Wealth_Advisor__r.Name,
                             CSA__r.Name,Associate_Wealth_Advisor__r.Phone,CSA__r.Phone,Owner.Phone
                             From Account Where Account.Id = :recordId];
            
         
            
            wealthPlanningFields = [SELECT Id, Net_Worth_Estimate__c, Beacon_Pointe_Portfolio__c, Risk_Profile__c, Asset_Allocation__c, 
                                    Risk_Description__c, Outside_Firm_Name_1__c, Outside_Firm_Name_2__c, Outside_Amount_Managed__c,
                                    Outside_Amount_Managed_2__c, Bank_Name__c, Bank_Name_2__c, Life_Insurer__c, Long_Term_Care_Plan__c,
                                    Primary_Will_Date__c, Secondary_Will_Date__c, Primary_Trusted_Contact_on_File__c,
                                    Secondary_Trusted_Contact_on_File__c, Credit_Freeze__c, Outside_Firm_Contact_Name__c,
                                    Top_Agreed_Upon_Goal_1__c, Top_Agreed_Upon_Goal_2__c, Top_Agreed_Upon_Goal_3__c, 
                                    Top_Agreed_Upon_Goal_4__c, Client_2_Top_Value_1__c, Client_2_Top_Value_2__c,Outside_Firm_Name_3__c,
                                    Outside_Amount_Managed_3__c,Outside_Firm_Contact_Phone__c,Outside_Firm_Contact_Name_2__c,Outside_Firm_Contact_2_Phone__c,
                                    Outside_Firm_Contact_Name_3__c,Outside_Firm_Contact_3_Phone__c,            
                                    Client_2_Top_Value_3__c, Health_wealth_or_family_concerns__c, Family_discussion_desired__c,
                                    Family_education_desired__c,Client_1_Top_Value_1__c,Client_1_Top_Value_2__c,Client_1_Top_Value_3__c FROM Wealth_Planning__c WHERE Household_Client__c =: recordId];
            
            // Retrieve the root account and its child accounts and contacts
            List<AccountContactRelation> accountContactRelations = [SELECT Id, Account.Name,ContactId, 
                                                                    Contact.Name,Contact.BirthDate,Roles,
                                                                    Birthdate__c,Contact.FinServ__Gender__c 
                                                                    FROM AccountContactRelation WHERE
                                                                    Account.Id =: recordId AND 
                                                                    Roles EXCLUDES ('Primary Contact','Secondary Contact') ];
             Set<String> addingConID = new Set<String>();
            Map<String,Object> secondaryContactMap = new Map<String,Object>();
            Map<String,AccountContactRelation> acrChildMap = new Map<String,AccountContactRelation>();
            List<Map<String, Object>> hierarchy = new List<Map<String, Object>>();
            
            
            List<AccountContactRelation> primaryACR =[SELECT Id, Contact.Name, Roles FROM AccountContactRelation
                                                      WHERE Roles includes ('Primary Contact') AND Account.Id =: recordId];
            List<AccountContactRelation> secondaryCont =[Select Id,Contact.Name,Roles From AccountContactRelation
                                                         Where Roles includes ('Secondary Contact') AND Account.Id =: recordId ];
            If(primaryACR.size() > 0){
                addingConID.add(primaryACR[0].ContactId);
                Map<String,Object> primaryContactMap = new Map<String,Object>(); 
                primaryContactMap.put('Id',primaryACR[0].contactId);
                if(secondaryCont.size()>0 && secondaryCont[0].Contact.Name!=null){
                    addingConID.add(secondaryCont[0].ContactId);
                    primaryContactMap.put('Name',(primaryACR[0].Contact.Name +' '+' & '+' '+secondaryCont[0].Contact.Name));
                }
                else{primaryContactMap.put('Name',(primaryACR[0].Contact.Name));}
                primaryContactMap.put('Manager','');
                primaryContactMap.put('Class', 'primaryMember');
                hierarchy.add(primaryContactMap);
                 orgNodeCount++;
                Map<String,Object> impRelatives = new Map<String,Object>(); 
                impRelatives.put('Id','ImportantRelatives');
                impRelatives.put('Name','Important Relatives');
                impRelatives.put('DOB','');
                impRelatives.put('Gender', '');
                impRelatives.put('Manager', primaryACR[0].ContactId);
                
                impRelatives.put('Class', 'importantRelative1');
                hierarchy.add(impRelatives);
                 orgNodeCount++;
            }
            
           
            for(AccountContactRelation  acr : accountContactRelations){
                
                addingConID.add(acr.ContactId);
                
                String formattedDate;
                string gender ;
                if (acr.Contact.FinServ__Gender__c != null && acr.Contact.FinServ__Gender__c =='Male') {
                    gender = '(M) ';
                } 
                else if (acr.Contact.FinServ__Gender__c !=null && acr.Contact.FinServ__Gender__c == 'Female') {
                    gender = '(F) ';   
                }
                
                if (acr.Birthdate__c != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(acr.Birthdate__c.year(),acr.Birthdate__c.month(),acr.Birthdate__c.day());
                    formattedDate = dateTimeOfBirth.format(' (yyyy)');
                }
                
                
                If(acr.Roles.contains('Primary Contact')){
                    primaryACR[0] = acr;
                }
                
                
                If(acr.Roles.contains('Important Relative')){
                    Map<String,Object> ImporRelativeParent = new Map<String,Object>(); 
                    ImporRelativeParent.put('Id',acr.contactId);
                    if(gender != null){
                        ImporRelativeParent.put('Name',(gender+' '+ acr.Contact.Name ));
                    }
                    if(formattedDate!=null){
                        ImporRelativeParent.put('Name',(acr.Contact.Name +' '+formattedDate ));
                    }
                    if(gender != null && formattedDate!=null){
                        ImporRelativeParent.put('Name',(gender+' '+ acr.Contact.Name +' '+formattedDate ));
                    }
                    if(gender == null && formattedDate==null){
                        ImporRelativeParent.put('Name',(acr.Contact.Name));
                    }
                    
                    ImporRelativeParent.put('DOB',acr.Birthdate__c);
                    ImporRelativeParent.put('Gender', acr.Contact.FinServ__Gender__c);
                    ImporRelativeParent.put('Manager', 'ImportantRelatives');
                    
                    ImporRelativeParent.put('Class', 'importantrelativeChild');
                    hierarchy.add(ImporRelativeParent);
                     orgNodeCount++;
                }
                If(acr.Roles.contains('Son') || acr.Roles.contains('Daughter')){
                    system.debug('acr'+' '+acr);
                    acrChildMap.put(acr.ContactId,acr);
                    
                }
                 
            }
          
            List<FinServ__ContactContactRelation__c> accountants = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
           FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Role__r.Name = 'Accountant' ];
        
            List<FinServ__AccountAccountRelation__c> accAcc = [Select Id,FinServ__Role__r.Name,FinServ__RelatedAccount__r.Name,FinServ__RelatedAccount__r.Phone From FinServ__AccountAccountRelation__c Where  FinServ__Role__r.Name = 'Accountant' AND FinServ__Account__r.Id =:recordId];
            
            if(accountants.size()>0){
                accountant = accountants[0].FinServ__RelatedContact__r.Name;
                accountantPhone = accountants[0].FinServ__RelatedContact__r.Phone;
            }
            else if(accAcc.size()>0){
                accountant = accAcc[0].FinServ__RelatedAccount__r.Name;
                accountantPhone = accAcc[0].FinServ__RelatedAccount__r.Phone;
                
            }
            
            List<FinServ__ContactContactRelation__c> estateAttorneys = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
                                                        FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c  Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Role__r.Name = 'Estate Attorney'];
             List<FinServ__AccountAccountRelation__c> estateAttorneysAcc = [Select Id,FinServ__Role__r.Name,FinServ__RelatedAccount__r.Name,FinServ__RelatedAccount__r.Phone From FinServ__AccountAccountRelation__c Where  FinServ__Role__r.Name = 'Estate Attorney' AND FinServ__Account__r.Id =:recordId];
            if(estateAttorneys.size()>0){
                estateAttorney = estateAttorneys[0].FinServ__RelatedContact__r.Name;
                estateAttorneyPhone =estateAttorneys[0].FinServ__RelatedContact__r.Phone;
            }
           else if(estateAttorneysAcc.size()>0){
                  estateAttorney = estateAttorneysAcc[0].FinServ__RelatedAccount__r.Name;
               estateAttorneyPhone =estateAttorneysAcc[0].FinServ__RelatedAccount__r.Phone;
            }
            List<FinServ__ContactContactRelation__c> contactContactRecord =[SELECT Id,FinServ__Contact__r.Birthdate, 
                                                                            FinServ__Contact__r.Birth_Date__c,FinServ__Contact__r.FinServ__Gender__c,
                                                                            FinServ__RelatedContact__r.FinServ__Gender__c,FinServ__Contact__r.Name,
                                                                            FinServ__RelatedContact__r.Birthdate,FinServ__Contact__r.Id,
                                                                            FinServ__Role__r.Name, FinServ__RelatedContact__r.Name,FinServ__RelatedContact__r.Id
                                                                            FROM FinServ__ContactContactRelation__c Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Active__c = True];
            Map<String,Object> processAcrRecord = new Map<String,Object>(); 
            for(FinServ__ContactContactRelation__c  conconRecord : contactContactRecord){
                
                string acrGender;
                string acrDate;
                string ccrDate;
                string ccrGender;  
                if (conconRecord.FinServ__Contact__r.FinServ__Gender__c  != null && conconRecord.FinServ__Contact__r.FinServ__Gender__c =='Male') {
                    acrGender = '(M) ';
                } 
                else if (conconRecord.FinServ__Contact__r.FinServ__Gender__c !=null && conconRecord.FinServ__Contact__r.FinServ__Gender__c == 'Female') {
                    acrGender = '(F) ';   
                }
                if (conconRecord.FinServ__Contact__r.Birthdate != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(conconRecord.FinServ__Contact__r.Birthdate.year(),conconRecord.FinServ__Contact__r.Birthdate.month(),conconRecord.FinServ__Contact__r.Birthdate.day());
                    acrDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                }
                if (conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c!= null && conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c =='Male') {
                    ccrGender = '(M) ';
                } 
                else if (conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c !=null && conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c == 'Female') {
                    ccrGender = '(F) ';   
                }
                if (conconRecord.FinServ__RelatedContact__r.Birthdate != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(conconRecord.FinServ__RelatedContact__r.Birthdate.year(),conconRecord.FinServ__RelatedContact__r.Birthdate.month(),conconRecord.FinServ__RelatedContact__r.Birthdate.day());
                    ccrDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                }
                
                if(conconRecord.FinServ__Role__r.Name.contains('Spouse')){
                    AccountContactRelation acr = acrChildMap.get(conconRecord.FinServ__Contact__r.Id);
                    
                    
                    processAcrRecord.put(conconRecord.FinServ__Contact__r.Id,conconRecord.FinServ__Contact__r.Id);
                    
                    if(acr != null){
                        Map<String,Object> impRelativess = new Map<String,Object>(); 
                        impRelativess.put('Id',conconRecord.FinServ__Contact__r.Id);
                        
                        String AcrCcrName;
                        String AcrContactName = acr.Contact.Name;
                        String CcrContactName = conconRecord.FinServ__RelatedContact__r.Name;
                        // Check if Acr's gender and date are not null
                        if (acrGender != null && acrDate != null) {
                            AcrCcrName = acrGender +' '+ AcrContactName  +' '+ acrDate;
                        } else if (acrGender != null) {
                            AcrCcrName = acrGender +' '+ AcrContactName;
                        } else if (acrDate != null) {
                            AcrCcrName = AcrContactName +' '+  acrDate;
                        } else {
                            AcrCcrName = AcrContactName;
                        }
                        
                        // Check if Ccr's gender and date are not null
                        if (ccrGender != null && ccrDate != null) {
                            AcrCcrName += ' &' +' '+ ccrGender +' '+ CcrContactName  +' '+ ccrDate;
                        } else if (ccrGender != null) {
                            AcrCcrName += ' &' +' '+ ccrGender +' '+ CcrContactName;
                        } else if (ccrDate != null) {
                            AcrCcrName += ' &' +' '+ CcrContactName +' '+ ccrDate;
                        } else {
                            AcrCcrName += ' &' +' '+ CcrContactName;
                        }
                        
                        
                        
                        impRelativess.put('Name', AcrCcrName);
                        impRelativess.put('DOB',acr.Birthdate__c);
                        impRelativess.put('Manager',primaryACR[0].ContactId);
                        impRelativess.put('Gender', acr.Contact.FinServ__Gender__c);
                        
                        impRelativess.put('Class', 'primaryMemberChild');
                        hierarchy.add(impRelativess);
                       //  orgNodeCount++;
                    }
                    
                }
                if(conconRecord.FinServ__Role__r.Name.contains('Father') || conconRecord.FinServ__Role__r.Name.contains('Mother')){
                    AccountContactRelation acr = acrChildMap.get(conconRecord.FinServ__Contact__r.Id);
                    if(acr != null){
                        Map<String,Object> child = new Map<String,Object>(); 
                        child.put('Id',conconRecord.FinServ__RelatedContact__r.Id);
                        if(ccrGender !=null){
                            child.put('Name',ccrGender+' '+conconRecord.FinServ__RelatedContact__r.Name);
                        }
                        if(ccrDate !=null){
                            child.put('Name',conconRecord.FinServ__RelatedContact__r.Name+' '+ccrDate);
                        }
                        if(ccrDate !=null && ccrGender !=null){
                            child.put('Name',ccrGender+' '+conconRecord.FinServ__RelatedContact__r.Name+' '+ccrDate);
                        }
                        if(ccrDate ==null && ccrGender ==null){
                            child.put('Name',conconRecord.FinServ__RelatedContact__r.Name);
                        }
                        child.put('DOB',ccrDate);
                        child.put('Gender', ccrGender);
                        child.put('Manager',conconRecord.FinServ__Contact__r.Id);
                        
                        child.put('Class', 'PrimaryGrandChild');
                        hierarchy.add(child);
                         orgNodeCount++;
                    }
                } 
            }
            for(String acrContactId: acrChildMap.keyset()){
                if(!processAcrRecord.containsKey(acrContactId)){
                    AccountContactRelation acr = acrChildMap.get(acrContactId);
                    system.debug('rt'+' '+acr.contact.Name);
                    system.debug('rt'+' '+acr.contact.Id);
                    string gender;
                    string formattedDate;
                    if (acr.Contact.FinServ__Gender__c   != null && acr.Contact.FinServ__Gender__c =='Male') {
                        gender = '(M) ';
                    } 
                    else if (acr.Contact.FinServ__Gender__c !=null && acr.Contact.FinServ__Gender__c == 'Female') {
                        gender = '(F) ';   
                    }
                    if (acr.Contact.Birthdate != null) {
                        DateTime dateTimeOfBirth = DateTime.newInstance(acr.Contact.Birthdate.year(),acr.Contact.Birthdate.month(),acr.Contact.Birthdate.day());
                        formattedDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                    }
                    Map<String,Object> impRelativess = new Map<String,Object>(); 
                    impRelativess.put('Id',acr.Contact.Id);
                    
                    if(gender !=null){
                        impRelativess.put('Name',( gender+' '+acr.Contact.Name ));
                    }
                    if(formattedDate!=null){
                        impRelativess.put('Name',( acr.Contact.Name+' '+formattedDate ));                        
                    }
                    if(gender !=null && formattedDate!=null){
                        impRelativess.put('Name',( gender+' '+acr.Contact.Name+' '+formattedDate));
                    }
                    if(gender ==null && formattedDate == null){
                        impRelativess.put('Name',( acr.Contact.Name));
                        
                    }
                    impRelativess.put('DOB',acr.Birthdate__c);
                    impRelativess.put('Manager',primaryACR[0].ContactId);
                    impRelativess.put('Gender', acr.Contact.FinServ__Gender__c);
                    
                    impRelativess.put('Class', 'primaryMemberChild');
                    hierarchy.add(impRelativess);
                     orgNodeCount++;
                }
                system.debug('primaryMemberChild'+orgNodeCount);
            }
            
       
            // Serialize the hierarchy as JSON and return it
            return JSON.serialize(hierarchy);
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error has occurred. Please Contact Admin.'));
            return null;
        }
        
    }
    
         @AuraEnabled
        public static Integer getVariableValue(String recordId) {
            // Retrieve the value from the Apex class variable
            Integer orgNodeCount = 0;// Your logic to retrieve the value;
           
          
    
          
            // Retrieve the root account and its child accounts and contacts
            List<AccountContactRelation> accountContactRelations = [SELECT Id, Account.Name,ContactId, 
                                                                    Contact.Name,Contact.BirthDate,Roles,
                                                                    Birthdate__c,Contact.FinServ__Gender__c 
                                                                    FROM AccountContactRelation WHERE
                                                                    Account.Id = :recordId AND 
                                                                    Roles EXCLUDES ('Primary Contact','Secondary Contact') ];
             Set<String> addingConID = new Set<String>();
            Map<String,Object> secondaryContactMap = new Map<String,Object>();
            Map<String,AccountContactRelation> acrChildMap = new Map<String,AccountContactRelation>();
            List<Map<String, Object>> hierarchy = new List<Map<String, Object>>();
            
            
            List<AccountContactRelation> primaryACR =[SELECT Id, Contact.Name, Roles FROM AccountContactRelation
                                                      WHERE Roles includes ('Primary Contact') AND Account.Id = :recordId];
            List<AccountContactRelation> secondaryCont =[Select Id,Contact.Name,Roles From AccountContactRelation
                                                         Where Roles includes ('Secondary Contact') AND Account.Id = :recordId ];
            If(primaryACR.size() > 0){
                addingConID.add(primaryACR[0].ContactId);
                Map<String,Object> primaryContactMap = new Map<String,Object>(); 
                primaryContactMap.put('Id',primaryACR[0].contactId);
                if(secondaryCont.size()>0 && secondaryCont[0].Contact.Name!=null){
                    addingConID.add(secondaryCont[0].ContactId);
                    primaryContactMap.put('Name',(primaryACR[0].Contact.Name +' '+' & '+' '+secondaryCont[0].Contact.Name));
                }
                else{primaryContactMap.put('Name',(primaryACR[0].Contact.Name));}
                primaryContactMap.put('Manager','');
                primaryContactMap.put('Class', 'primaryMember');
                hierarchy.add(primaryContactMap);
                orgNodeCount++;
                Map<String,Object> impRelatives = new Map<String,Object>(); 
                impRelatives.put('Id','ImportantRelatives');
                impRelatives.put('Name','Important Relatives');
                impRelatives.put('DOB','');
                impRelatives.put('Gender', '');
                impRelatives.put('Manager', primaryACR[0].ContactId);
                
                impRelatives.put('Class', 'importantRelative1');
                hierarchy.add(impRelatives);
                orgNodeCount++;
                system.debug('PrimaryorgNodeCount'+orgNodeCount);
            }
            
           
            for(AccountContactRelation  acr : accountContactRelations){
                
                addingConID.add(acr.ContactId);
                
                String formattedDate;
                string gender ;
                if (acr.Contact.FinServ__Gender__c != null && acr.Contact.FinServ__Gender__c =='Male') {
                    gender = '(M) ';
                } 
                else if (acr.Contact.FinServ__Gender__c !=null && acr.Contact.FinServ__Gender__c == 'Female') {
                    gender = '(F) ';   
                }
                
                if (acr.Birthdate__c != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(acr.Birthdate__c.year(),acr.Birthdate__c.month(),acr.Birthdate__c.day());
                    formattedDate = dateTimeOfBirth.format(' (yyyy)');
                }
                
                
                If(acr.Roles.contains('Primary Contact')){
                    primaryACR[0] = acr;
                }
                
                
                If(acr.Roles.contains('Important Relative')){
                    Map<String,Object> ImporRelativeParent = new Map<String,Object>(); 
                    ImporRelativeParent.put('Id',acr.contactId);
                    if(gender != null){
                        ImporRelativeParent.put('Name',(gender+' '+ acr.Contact.Name ));
                    }
                    if(formattedDate!=null){
                        ImporRelativeParent.put('Name',(acr.Contact.Name +' '+formattedDate ));
                    }
                    if(gender != null && formattedDate!=null){
                        ImporRelativeParent.put('Name',(gender+' '+ acr.Contact.Name +' '+formattedDate ));
                    }
                    if(gender == null && formattedDate==null){
                        ImporRelativeParent.put('Name',(acr.Contact.Name));
                    }
                    
                    ImporRelativeParent.put('DOB',acr.Birthdate__c);
                    ImporRelativeParent.put('Gender', acr.Contact.FinServ__Gender__c);
                    ImporRelativeParent.put('Manager', 'ImportantRelatives');
                    
                    ImporRelativeParent.put('Class', 'importantrelativeChild');
                    hierarchy.add(ImporRelativeParent);
                    orgNodeCount++;
                    system.debug('importantChild'+orgNodeCount);
                }
                If(acr.Roles.contains('Son') || acr.Roles.contains('Daughter')){
                    system.debug('acr'+' '+acr);
                    acrChildMap.put(acr.ContactId,acr);
                    //orgNodeCount++;
                }
                 
            }
          
            List<FinServ__ContactContactRelation__c> accountants = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
           FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Role__r.Name = 'Accountant' ];
        
          
            
            List<FinServ__ContactContactRelation__c> estateAttorneys = [SELECT Id,FinServ__RelatedContact__r.Name,FinServ__Role__r.Name, 
                                                        FinServ__Contact__r.Name,FinServ__RelatedContact__r.Phone FROM FinServ__ContactContactRelation__c  Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Role__r.Name = 'Estate Attorney'];
            
            List<FinServ__ContactContactRelation__c> contactContactRecord =[SELECT Id,FinServ__Contact__r.Birthdate, 
                                                                            FinServ__Contact__r.Birth_Date__c,FinServ__Contact__r.FinServ__Gender__c,
                                                                            FinServ__RelatedContact__r.FinServ__Gender__c,FinServ__Contact__r.Name,
                                                                            FinServ__RelatedContact__r.Birthdate,FinServ__Contact__r.Id,
                                                                            FinServ__Role__r.Name, FinServ__RelatedContact__r.Name,FinServ__RelatedContact__r.Id
                                                                            FROM FinServ__ContactContactRelation__c Where FinServ__Contact__r.Id IN : addingConID AND FinServ__Active__c = True];
            Map<String,Object> processAcrRecord = new Map<String,Object>(); 
            for(FinServ__ContactContactRelation__c  conconRecord : contactContactRecord){
                
                string acrGender;
                string acrDate;
                string ccrDate;
                string ccrGender;  
                if (conconRecord.FinServ__Contact__r.FinServ__Gender__c  != null && conconRecord.FinServ__Contact__r.FinServ__Gender__c =='Male') {
                    acrGender = '(M) ';
                } 
                else if (conconRecord.FinServ__Contact__r.FinServ__Gender__c !=null && conconRecord.FinServ__Contact__r.FinServ__Gender__c == 'Female') {
                    acrGender = '(F) ';   
                }
                if (conconRecord.FinServ__Contact__r.Birthdate != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(conconRecord.FinServ__Contact__r.Birthdate.year(),conconRecord.FinServ__Contact__r.Birthdate.month(),conconRecord.FinServ__Contact__r.Birthdate.day());
                    acrDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                }
                if (conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c!= null && conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c =='Male') {
                    ccrGender = '(M) ';
                } 
                else if (conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c !=null && conconRecord.FinServ__RelatedContact__r.FinServ__Gender__c == 'Female') {
                    ccrGender = '(F) ';   
                }
                if (conconRecord.FinServ__RelatedContact__r.Birthdate != null) {
                    DateTime dateTimeOfBirth = DateTime.newInstance(conconRecord.FinServ__RelatedContact__r.Birthdate.year(),conconRecord.FinServ__RelatedContact__r.Birthdate.month(),conconRecord.FinServ__RelatedContact__r.Birthdate.day());
                    ccrDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                }
                
                if(conconRecord.FinServ__Role__r.Name.contains('Spouse')){
                    AccountContactRelation acr = acrChildMap.get(conconRecord.FinServ__Contact__r.Id);
                    
                    
                    processAcrRecord.put(conconRecord.FinServ__Contact__r.Id,conconRecord.FinServ__Contact__r.Id);
                    
                    if(acr != null){
                        Map<String,Object> impRelativess = new Map<String,Object>(); 
                        impRelativess.put('Id',conconRecord.FinServ__Contact__r.Id);
                        
                        String AcrCcrName;
                        String AcrContactName = acr.Contact.Name;
                        String CcrContactName = conconRecord.FinServ__RelatedContact__r.Name;
                        // Check if Acr's gender and date are not null
                        if (acrGender != null && acrDate != null) {
                            AcrCcrName = acrGender +' '+ AcrContactName  +' '+ acrDate;
                        } else if (acrGender != null) {
                            AcrCcrName = acrGender +' '+ AcrContactName;
                        } else if (acrDate != null) {
                            AcrCcrName = AcrContactName +' '+  acrDate;
                        } else {
                            AcrCcrName = AcrContactName;
                        }
                        
                        // Check if Ccr's gender and date are not null
                        if (ccrGender != null && ccrDate != null) {
                            AcrCcrName += ' &' +' '+ ccrGender +' '+ CcrContactName  +' '+ ccrDate;
                        } else if (ccrGender != null) {
                            AcrCcrName += ' &' +' '+ ccrGender +' '+ CcrContactName;
                        } else if (ccrDate != null) {
                            AcrCcrName += ' &' +' '+ CcrContactName +' '+ ccrDate;
                        } else {
                            AcrCcrName += ' &' +' '+ CcrContactName;
                        }
                        
                        
                        
                        impRelativess.put('Name', AcrCcrName);
                        impRelativess.put('DOB',acr.Birthdate__c);
                        impRelativess.put('Manager',primaryACR[0].ContactId);
                        impRelativess.put('Gender', acr.Contact.FinServ__Gender__c);
                        
                        impRelativess.put('Class', 'primaryMemberChild');
                        hierarchy.add(impRelativess);
                        //orgNodeCount++;
                        system.debug('primaryMemberChild====='+orgNodeCount);
                    }
                    
                }
                if(conconRecord.FinServ__Role__r.Name.contains('Father') || conconRecord.FinServ__Role__r.Name.contains('Mother')){
                    AccountContactRelation acr = acrChildMap.get(conconRecord.FinServ__Contact__r.Id);
                    if(acr != null){
                        Map<String,Object> child = new Map<String,Object>(); 
                        child.put('Id',conconRecord.FinServ__RelatedContact__r.Id);
                        if(ccrGender !=null){
                            child.put('Name',ccrGender+' '+conconRecord.FinServ__RelatedContact__r.Name);
                        }
                        if(ccrDate !=null){
                            child.put('Name',conconRecord.FinServ__RelatedContact__r.Name+' '+ccrDate);
                        }
                        if(ccrDate !=null && ccrGender !=null){
                            child.put('Name',ccrGender+' '+conconRecord.FinServ__RelatedContact__r.Name+' '+ccrDate);
                        }
                        if(ccrDate ==null && ccrGender ==null){
                            child.put('Name',conconRecord.FinServ__RelatedContact__r.Name);
                        }
                        child.put('DOB',ccrDate);
                        child.put('Gender', ccrGender);
                        child.put('Manager',conconRecord.FinServ__Contact__r.Id);
                        
                        child.put('Class', 'PrimaryGrandChild');
                        hierarchy.add(child);
                        orgNodeCount++;
                        system.debug('PrimaryGrandChild'+orgNodeCount);
                    }
                } 
            }
            for(String acrContactId: acrChildMap.keyset()){
                if(!processAcrRecord.containsKey(acrContactId)){
                    AccountContactRelation acr = acrChildMap.get(acrContactId);
                    system.debug('rt'+' '+acr.contact.Name);
                    system.debug('rt'+' '+acr.contact.Id);
                    string gender;
                    string formattedDate;
                    if (acr.Contact.FinServ__Gender__c   != null && acr.Contact.FinServ__Gender__c =='Male') {
                        gender = '(M) ';
                    } 
                    else if (acr.Contact.FinServ__Gender__c !=null && acr.Contact.FinServ__Gender__c == 'Female') {
                        gender = '(F) ';   
                    }
                    if (acr.Contact.Birthdate != null) {
                        DateTime dateTimeOfBirth = DateTime.newInstance(acr.Contact.Birthdate.year(),acr.Contact.Birthdate.month(),acr.Contact.Birthdate.day());
                        formattedDate = dateTimeOfBirth.format(' (MM/dd/yyyy)');
                    }
                    Map<String,Object> impRelativess = new Map<String,Object>(); 
                    impRelativess.put('Id',acr.Contact.Id);
                    
                    if(gender !=null){
                        impRelativess.put('Name',( gender+' '+acr.Contact.Name ));
                    }
                    if(formattedDate!=null){
                        impRelativess.put('Name',( acr.Contact.Name+' '+formattedDate ));                        
                    }
                    if(gender !=null && formattedDate!=null){
                        impRelativess.put('Name',( gender+' '+acr.Contact.Name+' '+formattedDate));
                    }
                    if(gender ==null && formattedDate == null){
                        impRelativess.put('Name',( acr.Contact.Name));
                        
                    }
                    impRelativess.put('DOB',acr.Birthdate__c);
                    impRelativess.put('Manager',primaryACR[0].ContactId);
                    impRelativess.put('Gender', acr.Contact.FinServ__Gender__c);
                    
                    impRelativess.put('Class', 'primaryMemberChild');
                    hierarchy.add(impRelativess);
                    orgNodeCount++;
                    system.debug('primaryMemberChild=='+orgNodeCount);
                }
                 System.debug('org nodes: ' + orgNodeCount);
               
            }
            System.debug('Total org nodes: ' + orgNodeCount);
                      // Serialize the hierarchy as JSON and return it
     
    // Serialize the hierarchy as JSON and return it
            return orgNodeCount;
        }
            
}
