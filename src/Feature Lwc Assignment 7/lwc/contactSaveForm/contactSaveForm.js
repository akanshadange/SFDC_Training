import { LightningElement, track, api } from 'lwc';
import createContact from '@salesforce/apex/ContactService.createContact';

export default class ContactSaveForm extends LightningElement {
    @track isModalOpen = true; 
    @track firstName;
    @track lastName;
    @track email;
    @track errorMessage;
    @api accountId;

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'FirstName') {
            this.firstName = event.target.value;
        } else if (field === 'LastName') {
            this.lastName = event.target.value;
        } else if (field === 'Email') {
            this.email = event.target.value;
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleSaveContact() {
        if (!this.lastName) {
            this.errorMessage = 'Last Name is required.';
        } else if (!this.email) {
            this.errorMessage = 'Email is required.';
        } else if (!this.validateEmail(this.email)) {
            this.errorMessage = 'Invalid Email Format';
        } else {
            this.errorMessage = null;
            this.createContactInApex();
        }
    }

    validateEmail(email) {
        const regexPattern = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        return regexPattern.test(email);
    }
    createContactInApex() {
        createContact({ accountId: this.accountId, firstName: this.firstName, lastName: this.lastName, email: this.email })
            .then(() => {
                this.dispatchEvent(new CustomEvent('contactcreated')); 
                this.closeModal();
            })
            .catch(error => {
                this.errorMessage = error.body.message || 'An error occurred while creating the contact.';
                console.error('Error creating contact: ', error);
            });
    }
}