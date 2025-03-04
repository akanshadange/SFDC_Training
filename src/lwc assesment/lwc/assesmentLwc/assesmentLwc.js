import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountsServices.getAccounts';
import createAccount from '@salesforce/apex/AccountsServices.createAccount';
import createContact from '@salesforce/apex/ContactsServices.createContact';
import { refreshApex } from '@salesforce/apex';

export default class AccountAndContactManager extends LightningElement {
    @track accounts = []; 
    @track isAccountModalOpen = false; 
    @track isContactModalOpen = false; 
    @track accountName = ''; 
    @track accountPhone = '';
    @track accountRating = '';
    @track contactFirstName = ''; 
    @track contactLastName = '';
    @track contactEmail = '';
    @track errorMessage = ''; 
    @track contactErrorMessage = '';

    columns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Rating', fieldName: 'Rating' },

    ];

    @wire(getAccounts) wiredAccounts({ data, error }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }

    handleOpenAccountModal() {
        this.isAccountModalOpen = true;
        this.errorMessage = '';
    }

    handleAccountInputChange(event) {
        const field = event.target.name;
        if (field === 'AccountName') {
            this.accountName = event.target.value;
        } else if (field === 'AccountPhone') {
            this.accountPhone = event.target.value;
        } else if (field === 'AccountRating') {
            this.accountRating = event.target.value;
        }
    }

    closeAccountModal() {
        this.isAccountModalOpen = false;
    }

    handleSaveAccount() {
        if (!this.accountName || !this.accountPhone || !this.accountRating) {
            this.errorMessage = 'All fields are required.';
        } else {
            this.errorMessage = '';
            createAccount({
                name: this.accountName,
                phone: this.accountPhone,
                rating: this.accountRating
            })
            .then(() => {
                refreshApex(this.wiredAccounts); 
                this.closeAccountModal(); 
                this.handleOpenContactModal(); 
            })
            .catch(error => {
                this.errorMessage = 'Error creating account: ' + error.body.message;
                console.error('Error creating account:', error);
            });
        }
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'createContact') {
            const accountId = event.detail.row.Id;
            this.handleOpenContactModal(accountId);
        }
    }

    handleOpenContactModal() {
        this.isContactModalOpen = true;
        this.contactFirstName = '';
        this.contactLastName = '';
        this.contactEmail = '';
        this.contactErrorMessage = '';
    }

    handleContactInputChange(event) {
        const field = event.target.name;
        if (field === 'FirstName') {
            this.contactFirstName = event.target.value;
        } else if (field === 'LastName') {
            this.contactLastName = event.target.value;
        } else if (field === 'Email') {
            this.contactEmail = event.target.value;
        }
    }

    closeContactModal() {
        this.isContactModalOpen = false;
    }

    handleSaveContact() {
        if (!this.contactFirstName || !this.contactLastName || !this.contactEmail) {
            this.contactErrorMessage = 'All fields are required.';
        } else {
            this.contactErrorMessage = '';
            createContact({
                firstName: this.contactFirstName,
                lastName: this.contactLastName,
                email: this.contactEmail
            })
            .then(() => {
                refreshApex(this.wiredAccounts); 
                this.closeContactModal(); 
            })
            .catch(error => {
                this.contactErrorMessage = 'Error creating contact: ' + error.body.message;
                console.error('Error creating contact:', error);
            });
        }
    }
}