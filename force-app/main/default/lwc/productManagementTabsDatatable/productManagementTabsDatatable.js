import { LightningElement, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProducts from '@salesforce/apex/ProductController.getProducts';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Product2.Description';
import PRODUCT_SKU_CODE_FIELD from '@salesforce/schema/Product2.ProductCode';

const COLUMNS = [
    {
        label: 'Product Name',
        fieldName: 'url',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'name'
            },
            target: '_blank'
        }
    },
    {
        label: 'Description',
        fieldName: 'description',
        type: 'text',
    },
    {
        label: 'Product Code',
        fieldName: 'productCode',
        type: 'text',
    },
    {
        label: 'Entries',
        fieldName: 'pricebookName',
        type: 'text',
    },
    {
        label: 'Price',
        fieldName: 'unitPrice',
        type: 'text',
    }
];

export default class ProductManagementTabsDatatable extends LightningElement {
    columns = COLUMNS
    @track isLoading = true
    @track products
    @track errors

    constructor() {
        super();
        console.log('constructor');
    }

    connectedCallback() {
        console.log('connected');
        this._fetchProducts();
        this.isLoading = false
    }

    renderedCallback() {
        console.log('rendered');
    }

    _fetchProducts() {
        fetchProducts().then((data) => {
            this.products = data
            console.log('products>>> ' + JSON.stringify(this.products));
        })
        .catch((error) => {
            this.errors = this.reduceErrors(error);
            this.displayMessage('Error!', this.errors.toString(), 'error');
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

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors
            .filter(error => !!error)
            .map(error => {
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                } else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                } else if (typeof error.message === 'string') {
                    return error.message;
                }
                return error.statusText;
            })
            .reduce((prev, curr) => prev.concat(curr), [])
            .filter(message => !!message)
        );
    }
}

// import { LightningElement, wire } from 'lwc';
// import { getListUi } from 'lightning/uiListApi';

// import CONTACT_OBJECT from '@salesforce/schema/Contact';
// import NAME_FIELD from '@salesforce/schema/Contact.Name';

// export default class ProductManagementTabsDatatable extends LightningElement {
//     @wire(getListUi, {
//         objectApiName: CONTACT_OBJECT,
//         listViewApiName: 'All_Recipes_Contacts',
//         sortBy: NAME_FIELD,
//         pageSize: 10
//     })
//     listView;

//     get contacts() {
//         return this.listView.data.records;
//     }
// }