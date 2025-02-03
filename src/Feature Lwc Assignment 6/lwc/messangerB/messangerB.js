import { LightningElement, wire } from 'lwc';
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe, publish } from 'lightning/messageService';
import myMessageChannel from '@salesforce/messageChannel/MyMessageChannel__c';

export default class MessangerB extends LightningElement {
    inputValue = '';
    subscription = null;

    @wire(MessageContext) Context;

    handleChange(event) {
        this.inputValue = event.target.value;
        let payload = {
            messageToSendFromB: {
                value: this.inputValue
            }
        };
        publish(this.Context, myMessageChannel, payload);
    }

    receivedMessagefromA;

    connectedCallback() {
        this.handleSubscribe();
    }

    handleSubscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(this.Context, myMessageChannel, (message) => {
                this.handleMessage(message);
            }, { scope: APPLICATION_SCOPE });
        }
    }

    handleMessage(message) {
        this.receivedMessagefromA = message.messageToSendFromA ? message.messageToSendFromA.value : 'No msg published';
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}