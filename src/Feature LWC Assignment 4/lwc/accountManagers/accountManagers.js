import { LightningElement,track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountManagerController.getAccounts';
    const columns = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency'},
        { label: 'Phone',fieldName:'Phone' },
        { label: 'Rating',fieldName:'Rating'}
    ];
export default class AccountManagers extends LightningElement {
    @track columns =columns;
    @track data=[];
    connectedCallback(){
        getAccounts()
        .then(result =>{
            this.data=result;
        })
        .catch(error =>{
            console.log("error occured");
        })
    } 
}