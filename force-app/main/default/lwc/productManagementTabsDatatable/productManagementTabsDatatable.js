// import { LightningElement, track } from 'lwc';
// import { refreshApex } from '@salesforce/apex';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// const COLUMNS = [
//     {
//         label: 'Opportunity Name',
//         fieldName: 'linkName',
//         type: 'url',
//         typeAttributes: {
//             label: { fieldName: 'Name' },
//             target: '_self'
//         }
//     },
//     {
//         label: 'Account Name',
//         fieldName: 'AccountId',
//         type: 'lookup',
//         typeAttributes: {
//             placeholder: 'Choose Account',
//             object: 'Opportunity',
//             fieldName: 'AccountId',
//             label: 'Account',
//             value: { fieldName: 'AccountId' },
//             context: { fieldName: 'Id' },
//             variant: 'label-hidden',
//             name: 'Account',
//             fields: ['Account.Name'],
//             target: '_self'
//         },
//         editable: true,
//         cellAttributes: {
//             class: { fieldName: 'accountNameClass' }
//         }
//     },
//     {
//         label: 'Stage',
//         fieldName: 'StageName',
//         type: 'picklist',
//         editable: true,
//         typeAttributes: {
//             placeholder: 'Choose Stage',
//             options: [
//                 { label: 'Needs Analysis', value: 'Needs Analysis' },
//                 { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
//                 { label: 'Perception Analysis', value: 'Perception Analysis' },
//                 { label: 'Prospecting', value: 'Prospecting' },
//                 { label: 'Value Proposition', value: 'Value Proposition' }
//             ],
//             value: { fieldName: 'StageName' },
//             context: { fieldName: 'Id' },
//             variant: 'label-hidden',
//             name: 'Stage',
//             label: 'Stage'
//         },
//         cellAttributes: {
//             class: { fieldName: 'stageClass' }
//         }
//     },
//     {
//         label: 'Amount',
//         fieldName: 'Amount',
//         type: 'currency',
//         editable: true
//     },
//     {
//         label: 'Close Date',
//         fieldName: 'CloseDate',
//         type: 'date-local',
//         typeAttributes: {
//             day: 'numeric',
//             month: 'numeric',
//             year: 'numeric'
//         },
//         editable: true
//     }
// ];

// export default class ProductManagementTabsDatatable extends LightningElement {
//     @track isLoading = true

//     constructor() {
//         super();
//         console.log('constructor');
//     }

//     connectedCallback() {
//         console.log('connected');
//     }

//     renderedCallback() {
//         console.log('rendered');
//     }
// }

import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import NAME_FIELD from '@salesforce/schema/Contact.Name';

export default class ProductManagementTabsDatatable extends LightningElement {
    @wire(getListUi, {
        objectApiName: CONTACT_OBJECT,
        listViewApiName: 'All_Recipes_Contacts',
        sortBy: NAME_FIELD,
        pageSize: 10
    })
    listView;

    get contacts() {
        return this.listView.data.records;
    }
}