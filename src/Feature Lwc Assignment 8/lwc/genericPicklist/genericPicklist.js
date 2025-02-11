import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class PicklistComponent extends LightningElement {
    @api objectApiName; 
    @api picklistField;  
    @track picklistValues = [];   
    error; 
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$fieldApiNameWithObject'})
    picklistValuesHandler({ error, data }) {
        if (data) {
            console.log('Fetched Picklist Values:', data.values);
            this.picklistValues = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log(this.picklistValues);
            this.error = undefined; 
        } else if (error) {
            console.error('Error fetching picklist values:', error);
            this.error = error.body.message;  
        }
    }
    get fieldApiNameWithObject(){
        return `${this.objectApiName}.${this.picklistField}`;
    }
    get recordTypeId(){
        return this.objectInfo.data?.defaultRecordTypeId;
    }
    handleObjectApiNameChange(event) {
        this.objectApiName = event.target.value;
       console.log('Updated Object API Name:', this.objectApiName);
    }
    handlePicklistFieldChange(event) {
        this.picklistField = event.target.value;
        console.log('Updated Picklist Field API Name:', this.picklistField);
    }
}