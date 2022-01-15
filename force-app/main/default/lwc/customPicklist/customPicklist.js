import { LightningElement, api } from 'lwc';
import currentUserId from '@salesforce/user/Id';

export default class CustomPicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api owner;

    get isDisabled() {
        return this.owner != currentUserId
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }
}