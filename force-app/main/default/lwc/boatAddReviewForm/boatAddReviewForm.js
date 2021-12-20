import { api, LightningElement, track } from 'lwc';

import BOAT_REVIEW_OBJECT from '@salesforce/schema/BoatReview__c';
import NAME_FIELD from '@salesforce/schema/BoatReview__c.Name';
import COMMENT_FIELD from '@salesforce/schema/BoatReview__c.Comment__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const SUCCESS_TITLE = 'Review Created!';
const SUCCESS_VARIANT = 'success';

export default class BoatAddReviewForm extends LightningElement {
    
    @track boatId;
    @track rating;
    boatReviewObject = BOAT_REVIEW_OBJECT;
    nameField = NAME_FIELD;
    commentField = COMMENT_FIELD;
    labelSubject = 'Review Subject';
    labelRating = 'Rating';
    
    @api
    get recordId() {
        return this.boatId;
    }

    set recordId(value) {
        this.setAttribute('boatId', value);        
        this.boatId = value;
    }
    
    // Gets user rating input from stars component
    handleRatingChanged(event) {
        this.rating = event.detail.rating;
    }
    
    // Custom submission handler to properly set Rating
    // This function must prevent the anchor element from navigating to a URL.
    // form to be submitted: lightning-record-edit-form
    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Rating__c = this.rating;
        fields.Boat__c = this.boatId;        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    
    handleSuccess() {
        const toast = new ShowToastEvent({
            title: SUCCESS_TITLE,
            variant: SUCCESS_VARIANT,
        });
        this.dispatchEvent(toast);
        this.handleReset();
        const createReviewEvent = new CustomEvent('createreview');
        this.dispatchEvent(createReviewEvent);        
    }
    
    handleReset() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => { field.reset(); });
        }
    }
}