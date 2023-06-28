import { LightningElement, track, wire,api } from 'lwc';
import getContacts from '@salesforce/apex/BPallWealthCCRController.getContacts';
import getRelatedContacts from '@salesforce/apex/BPallWealthCCRController.getRelatedContacts'; 
import getRelatedRole from '@salesforce/apex/BPallWealthCCRController.getRelatedRole'; 
import getContactSelection from '@salesforce/apex/BPallWealthCCRController.getRelatedContacts'; 
import { NavigationMixin } from 'lightning/navigation';  
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { createRecord } from 'lightning/uiRecordApi';
//import { updateRecord } from "lightning/uiRecordApi";
import CCR_OBJECT from '@salesforce/schema/FinServ__ContactContactRelation__c'; 
import RelatedRole_FIELD from '@salesforce/schema/FinServ__ContactContactRelation__c.FinServ__Role__c';
import ContactFieldId from '@salesforce/schema/FinServ__ContactContactRelation__c.FinServ__Contact__c'; 
import RelatedContactFieldId from '@salesforce/schema/FinServ__ContactContactRelation__c.FinServ__RelatedContact__c'; 
import CCRIds from '@salesforce/schema/FinServ__ContactContactRelation__c.Id'; 
import LightningConfirm from "lightning/confirm";
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';


const columns = [
{ label: 'Related Member', fieldName: 'Contact_Name__c' },
{ label: 'Related Role', fieldName: 'Related_Role__c' },
{ label: 'Contact Name', fieldName: 'RelatedContactName__c' },

{
    type: "button", label: 'Delete', initialWidth: 110, typeAttributes: {
        label: 'Delete',
        name: 'Delete',
        title: 'Delete',
        disabled: false,
        value: 'delete',
        iconPosition: 'left',
        iconName:'utility:delete',
        variant:'destructive'
    }
}
];

export default class BPallWealthCCR extends NavigationMixin(LightningElement) {
@api recordId;
@track confirmation;
@track contactId;    

@track addnewmemberScreen = false;
@track data;
@track wireResult;
@track error;
@track optionsArray= [];
@track optionsArray1= [];

@track optionsArrayselectedContact =[];
@api availableActions = [];
@track Related_Role;
@track selectedContactName;

@track isNew;

@track CCRId;


columns = columns;


@wire(getContacts, { accId: "$recordId" })
wiredAccounts(result) {
    this.wireResult = result;
    console.log('this.wireResult====='+this.wireResult);
    if (result.data) {
        this.data = result.data;
    } else if (result.error) {
        this.error = result.error;
    }
}



async handleConfirmClick(event) {
    const actionName = event.detail.action.name;
    console.log('============>'+JSON.stringify(event.detail));
    console.log('actionName===========>'+actionName)
    if (actionName === 'Edit') {
        this.addRow();
        this.Related_Role = event.detail.row.FinServ__Role__c;
        this.RelatedContact = event.detail.row.FinServ__Contact__c;
        this.selectedContactId = event.detail.row.FinServ__RelatedContact__c;
        this.selectedContactName = event.detail.row.Contact_Name__c;
        this.CCRId = event.detail.row.Id;
        this.isNew = false;

        

    }
    else if(actionName === 'Delete') {
    console.log('============>'+JSON.stringify(event.detail));
    var recordIdToDelete = event.detail.row.Id;
    const result = await LightningConfirm.open({
        message: "Are you sure you want to delete this?",
        variant: "default", // headerless
        label: "Delete a record"
    });

    // Confirm has been closed

    // result is true if OK was clicked
    
    if (result) {
        deleteRecord(recordIdToDelete)
            .then(result => {
                this.showToast('Success', 'Record deleted successfully!', 'success', 'dismissable');
                return refreshApex(this.wireResult);
            })
            .catch(error => {
                this.error = error;
            });
    } else {
        // and false if cancel was clicked
       // this.handleErrorAlertClick();
    }
}

}
a
get options(){
    return this.optionsArray;
}

createLookupContactAction() {
    console.log("Selected Contact Id: " + this.selectedContactId);
    console.log("Related Role: " + this.Related_Role);
    console.log("Related Contact: " + this.RelatedContact);


    if(this.isNew === true){
        const fields = {};
        fields[RelatedRole_FIELD.fieldApiName] = this.Related_Role;
        fields[ContactFieldId.fieldApiName] = this.RelatedContact;
        fields[RelatedContactFieldId.fieldApiName] = this.selectedContactId;
    
        const recordInput = {
            apiName: CCR_OBJECT.objectApiName,
            fields: fields
        };
        console.log("Record Input: " + JSON.stringify(recordInput));
    createRecord(recordInput)
        .then(contactobj => {
            console.log("ContactContactRelation created successfully: " + JSON.stringify(contactobj));
            this.contactId = contactobj.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'ContactContactRelation created successfully..!',
                    variant: 'success'
                })
            );
            this.addnewmemberScreen = false; 
            this.selectedContactId = '';
    this.Related_Role = '';
    this.RelatedContact = '';
            return refreshApex(this.wireResult);         
            
    
        })
        .catch(error => {
            console.error("Error creating record: " + JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    else if(this.isNew === false) {

        const fieldsforUpdate = {};
        fieldsforUpdate[RelatedRole_FIELD.fieldApiName] = this.Related_Role;
        fieldsforUpdate[ContactFieldId.fieldApiName] = this.RelatedContact;
        fieldsforUpdate[RelatedContactFieldId.fieldApiName] = this.selectedContactId;
        fieldsforUpdate[CCRIds.fieldApiName] = this.CCRId;
        
        const recordInputForUpdate = {
            //apiName: CCR_OBJECT.objectApiName,
            fields: fieldsforUpdate
        };
        console.log("Record Input: " + JSON.stringify(recordInputForUpdate));
        updateRecord(recordInputForUpdate)
        .then(contactobj => {
            this.contactId = contactobj.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'ContactContactRelation Updated successfully..!',
                    variant: 'success'
                })
            );
            this.addnewmemberScreen = false; 
            return refreshApex(this.wireResult);         
    
        })
        .catch(error => {
            console.error("Error updating record: " + JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

    }

}
    

handleContactSelection(event){
    this.selectedContactId = event.detail.value; 
    console.log("the selected record id is"+event.detail);
    

}
handleChangedRole(event){
    this.Related_Role = event.detail.value;
    console.log("the selected Role id is"+event.detail.value);
}
handleRelatedMemberChange(event){
    this.RelatedContact = event.detail.value;
    console.log("the selected Role id is"+event.detail.value);
}




//to add row
addRow() {
    this.isNew = true;
    console.log('Record========'+this.recordId);
    getRelatedContacts({ accId: this.recordId })
    .then( result=> {
        let arr = [];
        for( var i = 0 ; i< result.length ; i++){
            arr.push({ label : result[i].Name , value: result[i].Id })
        }
        this.optionsArray = arr;
        console.log('optionsArray'+this.optionsArray);

    });

    //to add related role
    getRelatedRole()
    .then( result1=> {
        let arr1 = [];
        for( var i = 0 ; i< result1.length ; i++){
            arr1.push({ label : result1[i].Name , value: result1[i].Id })
        }
        this.optionsArray1 = arr1;
        console.log('optionsArray'+this.optionsArray1);

    })

    getContactSelection({ accId: this.recordId })
    .then( resultselectedContact=> {
        let arr1 = [];
        for( var i = 0 ; i< resultselectedContact.length ; i++){
            arr1.push({ label : resultselectedContact[i].Name , value: resultselectedContact[i].Id })
        }
        this.optionsArrayselectedContact= arr1;
        console.log('optionsArrayselectedContact'+this.optionsArrayselectedContact);

    })
    this.addnewmemberScreen = true;
}
hideRow() {  
    this.addnewmemberScreen = false;
    this.selectedContactId = '';
    this.Related_Role = '';
    this.RelatedContact = '';
}

editCCR(event) {
        const recId = event.detail.row.Id; 
        console.log('recId===>'+recId)
        this.handleAction(recId, 'edit');
        console.log('recId2===>'+recId)
    } 

handleAction(recordId, mode) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'FinServ__ContactContactRelation__c',
            actionName: mode
        }
    })
}

showToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(evt);
}

handleSubmitqf() { 
    // Perform your data submission logic here // 
    //Navigate to the Visualforce page 
    const vfPageUrl = '/apex/allWEALTHSnapshot?id=' + encodeURIComponent(this.recordId);
    this[NavigationMixin.Navigate]({
         type:'standard__webPage', 
         attributes: {
    
        url: vfPageUrl
    } });
    if (this.availableActions.find((action) => action === 'FINISH')) {
    const navigateNextEvent = new FlowNavigationFinishEvent();
    this.dispatchEvent(navigateNextEvent);
    } 
}
}