import { LightningElement,api,wire  } from 'lwc';
import { FlowNavigationFinishEvent,FlowNavigationBackEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';  
import getorgNodeCount from '@salesforce/apex/AllWEALTHSnapshot.getVariableValue';

export default class PreviewSnapshotComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api availableActions = [];
    @api orgNodeCount;
    
             
    handleSubmit() {
        this.template.querySelector('c-b-p-all-wealth-a-c-r').handleSubmit();
    }
handleSubmitqf() { 
        // Perform your data submission logic here // 
        //Navigate to the Visualforce page
        getorgNodeCount({recordId : this.recordId})
            .then(result => {
                console.log('result2'+result)    
                this.orgNodeCount = result;
                console.log('this.orgNodeCount===='+this.orgNodeCount);
                if(this.orgNodeCount > 13){
                    const vfPageUrl = '/apex/allWEALTHSnapshot?id=' + encodeURIComponent(this.recordId);
                    console.log('if this.orgNodeCount===='+this.orgNodeCount);
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
                else {
                    console.log('else this.orgNodeCount===='+this.orgNodeCount);
                    const vfPageUrlNew = '/apex/AllWealthSinglePage?id=' + encodeURIComponent(this.recordId);
                    this[NavigationMixin.Navigate]({
                        type:'standard__webPage', 
                        attributes: {
                       url: vfPageUrlNew
                   } });
                   if (this.availableActions.find((action) => action === 'FINISH')) {
                   const navigateNextEvent = new FlowNavigationFinishEvent();
                   this.dispatchEvent(navigateNextEvent);
                   } 
                }
            })
            .catch(error => {
                this.error = error;
            });

        
        
       
    }
    handlePrevious() {
        if (this.availableActions.find((action) => action === "BACK")) {
          const navigateBackEvent = new FlowNavigationBackEvent();
          this.dispatchEvent(navigateBackEvent);
        }
    }
}