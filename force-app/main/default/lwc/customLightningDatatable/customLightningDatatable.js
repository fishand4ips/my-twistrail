import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './picklist-template.html';
import {loadStyle} from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomTableAnother';

export default class CustomLightningDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'owner'],
        }
    };

    constructor() {
        super();
        loadStyle(this, CustomDataTableResource)
    }
}