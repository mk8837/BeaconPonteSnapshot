import { LightningElement, track, wire,api } from 'lwc';
import getAccounts from '@salesforce/apex/BPallWealthACRController.getAccounts';
import getAccounts2 from '@salesforce/apex/BPallWealthACRController.getAccountsim';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from "lightning/confirm";
import Contact_FIELD from '@salesforce/schema/AccountContactRelation.ContactId';
import Roles_FIELD from '@salesforce/schema/AccountContactRelation.Roles';



const columns = [
    { label: 'Member Name', fieldName: 'Name__c' },
    { label: 'Roles', fieldName: 'Roles' },
    //{ label: 'Birthdate', fieldName: 'Birthdate__c' },

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

export default class BPallWealthACR extends NavigationMixin(LightningElement) {
    @api recordId;

    @track accounts;
    @track error;
    @track isShowModal = false;

    fields = [Contact_FIELD,Roles_FIELD];
    @track addnewmemberScreen = false;
    @track data;
    @track wireResult;
    @track error;
    columns = columns;

    @wire(getAccounts, { accId: "$recordId" })
    wiredAccounts(result) {
        this.wireResult = result;
        if (result) {
            //this.data = result;
            this.data = result.data;
        } else if (result.error) {
            this.error = result.error;
        }
    }


    handleLoad() {
        getAccounts2({accId : this.recordId})
        
            .then(result => {
                console.log('result2'+result)    
                this.data = result;
            })
            .catch(error => {
                this.error = error;
            });
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
                    //return refreshApex(this.wireResult);
                    this.handleLoad();
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


    //to add row
    addRow() {
        //event.preventDefault(); 
             this.Related_Role = '';
            this.RelatedContact = '';
            this.selectedContactId = '';
       
        this.addnewmemberScreen = true;
        this.isShowModal = true;
       
        
    }

    hideRow() {  
        this.isShowModal = false;
    }


    @api handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
      fields.AccountId = this.recordId;
      console.log('recordId============'+this.recordId);
        this.template.querySelector('lightning-record-form').submit(fields);
        this.showToast('Success!!', 'Record Created successfully!!', 'success', 'dismissable');      
        
        this.isShowModal = false;
        
         
    }

    handleComplete() { 

        this.handleLoad();
    }


  

    // @api callRowAction(event) {
    //     const recId = event.detail.row.Id;
    //     const actionName = event.detail.action.name;
    //     if (actionName === 'Edit') {
    //         this.handleAction(recId, 'edit');
    //     } else if (actionName === 'Delete') {
    //         this.handleDeleteRow(recId);
    //     } 
    // }

    handleAction(recordId, mode) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: mode
            }
        })
    }

    @api handleDeleteRow(recordIdToDelete) {
        deleteRecord(recordIdToDelete)
            .then(result => {
                this.showToast('Success!!', 'Record deleted successfully!!', 'success', 'dismissable');
                //return refreshApex(this.wireResult);
                this.handleLoad();
            }).catch(error => {
                this.error = error;
            });
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
   
        
        
}