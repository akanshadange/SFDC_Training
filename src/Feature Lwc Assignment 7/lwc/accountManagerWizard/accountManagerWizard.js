import { LightningElement, wire, api, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountService.getAccounts';
import getContactsByAccountId from '@salesforce/apex/ContactService.getContactsByAccountId';
import { refreshApex } from '@salesforce/apex';

export default class AccountManagerWizard extends LightningElement {
    @api recordId;
    @track accountData; 
    @track contacts = []; 
    @track filteredContacts = []; 
    @track searchTerm = ''; 
    @track isModalOpen = false; 
    @track isContactFormOpen = false;
    wiredContactsResult;
    wiredAccountsResult; 
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' }
    ];
    @wire(getAccounts, { accId: '$recordId' })
    accounts(result) {
        this.wiredAccountsResult = result; 
        if (result.data) {
            this.accountData = result.data[0]; 
            this.fetchContacts();  
        } else if (result.error) {
            console.error('Error fetching account data:', result.error);
        }
    }
    @wire(getContactsByAccountId, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
            this.filteredContacts = result.data;
        } else if (result.error) {
            console.error('Error fetching contacts:', result.error);
        }
    }
    fetchContacts() {
        refreshApex(this.wiredAccountsResult); 
        refreshApex(this.wiredContactsResult);
    }
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.filteredContacts = this.contacts.filter(contact => 
            contact.Name.toLowerCase().includes(this.searchTerm.toLowerCase())
        );
    }
    handleOpenModal() {
        this.isModalOpen = true;
    }
    handleCreateNewContact() {
        this.isContactFormOpen = true;
    }
    handleContactCreated() {
        this.fetchContacts();  
    }
}