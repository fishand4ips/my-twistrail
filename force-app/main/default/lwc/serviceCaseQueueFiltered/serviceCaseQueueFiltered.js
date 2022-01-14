import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getUserCases from '@salesforce/apex/ServiceCaseQueueService.getUserCases';
import updateCase from '@salesforce/apex/ServiceCaseQueueService.updateCase';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';

const COLUMNS = [{
        label: 'Case Number',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: CASE_NUMBER_FIELD.fieldApiName
            },
            target: '_blank'
        }
    },
    {
        label: 'Owner Name',
        type: 'text',
        fieldName: 'OwnerName',
        typeAttributes: {
            fields: ['Owner.Name'],
        }
    },
    {
        label: 'Status',
        fieldName: STATUS_FIELD.fieldApiName,
        type: 'picklist',
        wrapText: true,
        typeAttributes: {
            placeholder: 'Choose Status',
            value: { fieldName: 'Status' },
            context: { fieldName: 'Id' },
            options: [
                { label: 'Working', value: 'Working' },
                { label: 'New', value: 'New' },
                { label: 'Escalated', value: 'Escalated' },
                { label: 'Closed', value: 'Closed' },
            ],
            variant: 'label-hidden',
            name: 'Status',
            label: 'Status'
        },
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        }
    },
    {
        label: 'Priority',
        fieldName: PRIORITY_FIELD.fieldApiName,
        type: 'text',
        actions: [
            { label: 'High', checked: true, name: 'high', cellAttributes: { class: { fieldName: 'serviceCaseQueueFiltered' } } },
            { label: 'Medium', checked: false, name: 'medium', cellAttributes: { class: { fieldName: 'serviceCaseQueueFiltered' } } },
            { label: 'Low', checked: false, name: 'low', cellAttributes: { class: { fieldName: 'serviceCaseQueueFiltered' } } }
        ],
        cellAttributes: {
            iconName: {
                fieldName: 'priorityIcon'
            },
            iconPosition: 'left',
            iconAlternativeText: 'Priority Icon'
        }
    },
    {
        label: 'Origin',
        fieldName: ORIGIN_FIELD.fieldApiName,
        type: 'text',
    }
];

export default class ServiceCaseQueueFiltered extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    @api channelName = '/data/ChangeEvents';
    @track errorMessage;
    @track options = [];
    @track records;
    lastSavedData;
    error;
    wiredRecords;
    showSpinner = false;
    draftValues = [];
    privateChildren = {};
    subscription = {};
    url;

    renderedCallback() {
        if (!this.isComponentLoaded) {
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    connectedCallback() {
        this.navigateToHome();
        this.handleSubscribe();
        this.registerErrorListener();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
        window.removeEventListener('click', () => {});
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-picklist', context);
    }

    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    navigateToHome() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__app',
            attributes: {
                appTarget: 'c__Microcontroller',
            }
        }).then(url => {
            this.url = url;
        });
    }

    handleChannelName(event) {
        this.channelName = event.target.value;
    }

    handleSubscribe() {
        const replayId = -1;
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            this.handleNotification(response);
        };
        subscribe(this.channelName, replayId, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            this.handleNotification(response);
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    handleNotification(response) {
        if (response.hasOwnProperty('data')) {
            let jsonObj = response.data;
            if (jsonObj.hasOwnProperty('payload')) {
                let changeType = response.data.payload.ChangeEventHeader.changeType;
                const row = document.querySelector('body');
                if (changeType == 'CREATE') {
                    row.classList.add('create-animate');
                    row.classList.remove('delete-animate');
                } else if (changeType == 'DELETE') {
                    row.classList.add('delete-animate');
                    row.classList.remove('create-animate');
                }
                refreshApex(this.wiredRecords);
            }
        }
    }

    getRow(response) {
        let recordId = response.data.payload.ChangeEventHeader.recordIds[0];
        const currentRow = this.template.querySelector(`[data-row-key-value='${recordId}']`);
        if (currentRow) currentRow.classList.add('create-animate');
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.options = data.values.map(item => {
                return {
                    label: item.label,
                    value: item.value
                };
            });
        } else if (error) {
            this.errorMessage = `Failed to retrieve picklist values. ${this.reduceErrors(error)}`;
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    @wire(getUserCases)
    wiredUserCasesRecord(result) {
        this.wiredRecords = result;
        const { data, error } = result;
        if (data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.records.forEach(record => {

                record.linkName = '/' + record.Id;
                record.OwnerName = record.Owner.Name;
                record.statusClass = 'slds-cell-edit';

                if (record.Priority === 'High') {
                    record.priorityIcon = 'utility:log_a_call';
                } else if (record.Priority === 'Medium') {
                    record.priorityIcon = 'utility:note';
                } else if (record.Priority === 'Low') {
                    record.priorityIcon = 'utility:open';
                }
            });
            this.error = undefined;
        } else if (error) {
            this.records = undefined;
            this.error = error;
        } else {
            this.error = undefined;
            this.records = undefined;
        }
        this.lastSavedData = this.records;
        this.showSpinner = false;
    }

    handleItemRegister(event) {
        event.stopPropagation();
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        event.preventDefault();
        this.value = event.detail.value;
        this.showSpinner = true;
    }

    handleCancel(event) {
        event.preventDefault();
        this.records = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        this.draftValues = [];
    }

    handleCellChange(event) {
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Status':
                updatedItem = {
                    Id: dataRecieved.context,
                    Status: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'statusClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.records));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        this.handleWindowOnclick(dataRecieved.context);
        switch (dataRecieved.label) {
            case 'Status':
                this.setClassesOnData(
                    dataRecieved.context,
                    'statusClass',
                    'slds-cell-edit'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.records = JSON.parse(JSON.stringify(this.records));
        this.records.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    handleSave(event) {
        event.preventDefault();
        this.showSpinner = true;
        let currentStatus = event.detail.draftValues[0].Status;
        let currentServiceFlowComplited;
        this.records.forEach(record => {
            if (record.Id == event.detail.draftValues[0].Id) {
                currentServiceFlowComplited = record.Service_Flow_Completed__c;
            }
        })
        updateCase({ data: this.draftValues })
            .then(() => {
                if (!currentServiceFlowComplited && currentStatus === 'Closed') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating or refreshing records',
                            message: 'Service Flow not completed',
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                    return;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case updated successfully',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredRecords).then(() => {
                    this.records.forEach(record => {
                        record.statusClass = 'slds-cell-edit';
                    });
                    this.draftValues = [];
                    this.showSpinner = false;
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.log('error : ' + JSON.stringify(error));
                this.showSpinner = false;
            });
    }

    handleClickRefresh() {
        this.showSpinner = true;
        updateCase({ data: this.draftValues })
            .then(() => {
                refreshApex(this.wiredRecords).then(() => {
                    this.draftValues = [];
                    this.showSpinner = false;
                });
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('Refresh error: ' + JSON.stringify(error));
            });
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