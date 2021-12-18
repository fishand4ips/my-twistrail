import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class BoatSearch extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    
    handleLoading() {
        this.isLoading = true;
    }
    
    handleDoneLoading() {
        this.isLoading = false;
    }
    
    searchBoats(event) {
        let boatTypeId = event.detail.boatTypeId;
        this.template.querySelector('c-boat-search-results').searchBoats(boatTypeId);
        this.handleDoneLoading();
    }
    
    createNewBoat() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Boat__c',
                actionName: 'new'
            }
        });        
    }
}