import { LightningElement, api, track } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import PHONE  from '@salesforce/schema/Account.Phone';
import Rating from '@salesforce/schema/Account.Rating';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FIRST_NAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/Contact.LastName';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';

export default class accountInformationComponents extends LightningElement {
    @api recordId; 
    @track isCreatingContact = false;  
    @track isCreateButtonVisible = true;  
    @track accountId;  
    firstNameField = FIRST_NAME_FIELD;
    lastNameField = LAST_NAME_FIELD;
    phoneField = PHONE_FIELD;
    emailField = EMAIL_FIELD;
    fieldList = [NAME_FIELD,WEBSITE_FIELD,PHONE,Rating ];
    handleContactSuccess(event) {
        this.isCreatingContact = false;
        this.isCreateButtonVisible = false;  
        console.log('Contact created successfully');
    }
    handleContactError(event) {
        console.error('Error creating contact', event.detail);
    }
    handleCreateNewContact() {
        this.isCreatingContact = true;
        this.isCreateButtonVisible = false;  
    }
    handleClick(){
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Contact created successfully',
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
    handleCancel(){
        this.isCreatingContact = false;
        this.isCreateButtonVisible = true;  
    }
    
}