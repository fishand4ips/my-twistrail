import { track, api, LightningElement } from 'lwc';
import getRelatedList from '@salesforce/apex/RelatedContactsController.getRelatedList';
import saveContacts from '@salesforce/apex/RelatedContactsController.saveContacts'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountDisplayContacts extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api title;
    @track isLoading = false;
    @track contacts;
    @track error;
    @track modeBtn = 'Edit';
    @track modeEdit = false;
    @track disabledSaveBtn = true;

    connectedCallback() {
        this.fetchRelatedRecordInfo(this.recordId);
    }

    fetchRelatedRecordInfo(recordId) {
        getRelatedList({recordId: recordId})
        .then(result => {
            this.contacts = result;
            console.log('success: '+ JSON.stringify(result));
        }) 
        .catch(error => {
            this.error = error;
            console.log('error: ' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = true;
        }) 
    }

    handleSave() {
        this.updateContacts();
        this.handleMode();
    }

    updateContacts() {
        console.log('before save>>> ' + JSON.stringify(this.contacts));
        saveContacts({contactsInfo: this.contacts})
        .then((result) => {
            this.displayMessage('Success', 'Contacts was successfully updated!', 'success');
            console.log('result>>> ' + result);
        })
        .catch((error) => {
            this.displayMessage('Error', error.body.message, 'error');
            console.error('error>>> ' + JSON.stringify(error));
        })
    }

    handleMode() {
        this.modeBtn = this.modeBtn == 'Edit' ? 'View' : 'Edit';
        this.modeEdit = !this.modeEdit;
    }

    handleChange(event) {
        if (event) {
            this.disabledSaveBtn = false;
        }
        event.preventDefault();
        const fieldName = event.target.dataset.field;
        this.contacts.forEach(contact => {
            if (contact.id == event.target.dataset.id) {
                contact[fieldName] = event.target.value;
            }
        })
    }

    displayMessage(eventTitle, eventMessage, eventVariant) {
        const evt = new ShowToastEvent({
            title: eventTitle,
            message: eventMessage,
            variant: eventVariant,
        });
        this.dispatchEvent(evt);
    }
}