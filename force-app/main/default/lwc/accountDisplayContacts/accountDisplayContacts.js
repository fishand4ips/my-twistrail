import { track, api, LightningElement } from 'lwc';
import getRelatedList from '@salesforce/apex/RelatedContactsController.getRelatedList';
import saveContacts from '@salesforce/apex/RelatedContactsController.saveContacts'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountDisplayContacts extends LightningElement {

    @api value;
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
        if (this.recordId) {
            this.fetchRelatedRecordInfo(this.recordId);
        }
    }

    fetchRelatedRecordInfo(recordId) {
        getRelatedList({recordId: recordId})
        .then(result => {
            this.addLinkIntoContacts(result);
            this.contacts = result;
        }) 
        .catch(error => {
            this.error = error;
            console.log('error: ' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = true;
        }) 
    }

    addLinkIntoContacts(contacts) {
        return contacts.map(contact => {
            contact["link"] = '/' + contact.id
            return contact
        })
    }

    handleSave() {
        this.isLoading = false;
        this.updateContacts();
        this.handleMode();
    }

    updateContacts() {
        saveContacts({contactsInfo: this.contacts})
        .then(() => {
            this.fetchRelatedRecordInfo(this.recordId);
            this.displayMessage('Success', 'Contacts was successfully updated!', 'success');
        })
        .catch((error) => {
            console.error('error>>> ' + JSON.stringify(error));
            this.isLoading = true;
            this.displayMessage('Error', error.body.message, 'error');
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

    handleValue(event) {
        this.contacts.forEach(contact => {
            if (contact.id == event.target.dataset.id) {
                contact.accountId = event.detail.value;
            }
        })
    }
}