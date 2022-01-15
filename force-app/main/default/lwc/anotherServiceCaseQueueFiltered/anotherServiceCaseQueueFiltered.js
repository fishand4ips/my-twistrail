import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';
import getUserCases from '@salesforce/apex/ServiceCaseQueueService.getUserCases'
import { refreshApex } from '@salesforce/apex';
import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import CASE_OBJECT from '@salesforce/schema/Case';

const columns = [
    {label: 'Owner', fieldName: 'OwnerName', hideDefaultActions: true},
    {label: 'Case number', fieldName: 'recordLink', type: 'url', hideDefaultActions: true, typeAttributes: { 
        label: { fieldName: 'CaseNumber' }, 
        target: "_blank" }
    },
    {label: 'Status', type: 'picklist', fieldName: 'Status', hideDefaultActions: true, typeAttributes: { 
        options: [], 
        value: {fieldName: 'Status'},
        context: {fieldName: 'Id' }, 
        owner: {fieldName: 'OwnerId'}}
    },
    {label: 'Origin', fieldName: 'Origin', hideDefaultActions: true},
    {label: 'Priority', fieldName: 'Priority', hideDefaultActions: true},
    {label: 'Assign to me', type: 'button', typeAttributes: {  
        label: 'Assign',  
        name: 'Assign',  
        disabled: {fieldName: 'isAssigned'},  
        value: 'assign',  
        iconPosition: 'left'  
    }}
];

export default class ServiceCaseQueueFiltered extends LightningElement {
    @track data;
    @track error;
    @api channelName = '/data/ChangeEvents';
    _caseRecordTypeId;
    wiredResults;
    draftValues = [];
    columnsList = columns;
    showLoadingSpinner = false;
    isPicklistValuesExist = false;
    subscription = {};

    connectedCallback(){
        subscribe(this.channelName, -1, this.handleEvent).then(response => {
            console.log('Successfully subscribed to channel');
            this.subscription = response;
        });

        onError(error => {
            console.error('Received error from server: ', error);
        });
    }

    handleEvent = event => {
        return this.refresh();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    @wire(getUserCases)
    wiredCases(wiredResults){
        this.wiredResults = wiredResults;
        const {data, error} = wiredResults;
        if (data) {
            this.data = data.map(el => ({
                ...el, 
                recordLink: `/${el.Id}`, 
                OwnerName: el.Owner.Name,
                isAssigned: el.OwnerId === currentUserId}));
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT})
    objectInfo({error, data}){
        if (data){
            this._caseRecordTypeId = data.defaultRecordTypeId;
        } else if (error){
            console.log(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$_caseRecordTypeId', fieldApiName: STATUS_FIELD})
    getStatusPicklistValues({ error, data }) {
        if (data) {
            this.columnsList[2].typeAttributes.options = data.values;
            this.isPicklistValuesExist = true;
        } else if (error) {
            console.log(error);
        }
    }

    callRowAction( event ) {  
        const recId =  event.detail.row.Id;
        const actionName = event.detail.action.name;
        if ( actionName === 'Assign' ) {
            let updatedItem = { Id: recId, Status: null };
            this.handleSave(updatedItem);
        }
    }

    handleSave(updatedItem) {
        this.showLoadingSpinner = true;
        const fields = {}; 
        fields[ID_FIELD.fieldApiName] = updatedItem.Id;
        updatedItem.Status != null 
            ? fields[STATUS_FIELD.fieldApiName] = updatedItem.Status 
            : fields[OWNERID_FIELD.fieldApiName] = currentUserId;
        
        const recordInput = {fields};

        updateRecord(recordInput).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case updated',
                    variant: 'success'
                })
            );
            this.showLoadingSpinner = false
            this.draftValues = []
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.showLoadingSpinner = false
        });
    }

    picklistChanged(event){
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Status: dataRecieved.value };
        this.handleSave(updatedItem);
    }

    async refresh() {
        this.showLoadingSpinner = true;
        await refreshApex(this.wiredResults);
        this.showLoadingSpinner = false
    }

}