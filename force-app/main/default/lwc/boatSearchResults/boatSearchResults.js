import { api, LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';

const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT = 'Ship it!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error';
const ERROR_VARIANT = 'error';

export default class BoatSearchResults extends LightningElement {
    @api selectedBoatId;
    columns = [
        { label: 'Name', fieldName: 'Name', editable: true },
        { label: 'Length', fieldName: 'Length__c', type: 'number'},
        { label: 'Price', fieldName: 'Price__c', type: 'currency'},
        { label: 'Description', fieldName: 'Description__c'},        
    ];
    boatTypeId = '';
    @track boats;
    @track isLoading = false;
    @track draftValues = [];
  
    @wire(MessageContext)
    messageContext;

    @wire(getBoats, {boatTypeId: '$boatTypeId'})
    wiredBoats({data, error}) {
        if (data) {
            this.boats = data;
        } else if (error) {
            console.log('data.error')
            console.log(error)
        }
    }
  
    @api
    searchBoats(boatTypeId) {
        this.isLoading = true;
        this.notifyLoading(this.isLoading);
        this.boatTypeId = boatTypeId;
    }
  
    @api
    async refresh() {
        this.isLoading = true;
        this.notifyLoading(this.isLoading);      
        await refreshApex(this.boats);
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }
  
    updateSelectedTile(event) {
        this.selectedBoatId = event.detail.boatId;
        this.sendMessageService(this.selectedBoatId)
    }
  
    sendMessageService(boatId) { 
        publish(this.messageContext, BOATMC, { recordId: boatId });
    }
  
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        updateBoatList({data: updatedFields})
        .then(result => {
            const toast = new ShowToastEvent({
                title: SUCCESS_TITLE,
                message: MESSAGE_SHIP_IT,
                variant: SUCCESS_VARIANT,
            });
            this.dispatchEvent(toast);
            this.draftValues = [];
            return this.refresh();
        })
        .catch(error => {
            const toast = new ShowToastEvent({
                title: ERROR_TITLE,
                message: error.message,
                variant: ERROR_VARIANT,
            });
            this.dispatchEvent(toast);
        })
        .finally(() => {
            
        });
    }

    notifyLoading(isLoading) {
        if (isLoading) {
            this.dispatchEvent(new CustomEvent('loading'));
        } else {
            this.dispatchEvent(CustomEvent('doneloading'));
        }        
    }
}