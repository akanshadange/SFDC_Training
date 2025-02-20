import { LightningElement,wire,track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
export default class AccountManager extends LightningElement {
    @track accounts;
    @track columns = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency'}];
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }  
}