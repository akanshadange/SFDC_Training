import { LightningElement,wire,track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountManagerController.getAccounts';
export default class AccountManagerFetch extends LightningElement {
    @track accounts;
    @track columns = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency'},
        { label: 'Phone',fieldName:'Phone' },
        { label: 'Rating',fieldName:'Rating'}
    ];
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }  
}