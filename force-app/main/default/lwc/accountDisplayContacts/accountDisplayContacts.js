import { track, api, LightningElement } from 'lwc';
import getRelatedList from '@salesforce/apex/RelatedContactsController.getRelatedList';

export default class AccountDisplayContacts extends LightningElement {
    @api recordId
    @api title;
    loaded = true
    contacts = []
    @track error;

    connectedCallback() {
        this.fetchRelatedRecordInfo(this.recordId);
    }

    get isErrorOccurred() {
        return this.error
    }

    fetchRelatedRecordInfo(recordId) {
        getRelatedList({recordId: recordId})
        .then(result => {
            this.contacts = result.length == 0 ? 'No related Contatcts' : JSON.stringify(result);
            console.log('success: '+ JSON.stringify(result));
        }) 
        .catch(error => {
            this.error = JSON.stringify(error);
            console.log('error: ' + JSON.stringify(error));
        })
    }

    handleLoad() {
        this.isLoading = false;
    }
}