import { LightningElement, wire } from 'lwc';
import {  MessageContext, publish, subscribe, unsubscribe } from 'lightning/messageService';
import myMessageChannel from '@salesforce/messageChannel/MyMessageChannel__c';

export default class MessangerA extends LightningElement {
    inputValue = '';
    subscription = null;
    @wire(MessageContext) Context;
    handleChange(event) {
        this.inputValue = event.target.value;
        let payload = {
            messageToSendFromA: {
                value: this.inputValue
            }
        };
        publish(this.Context, myMessageChannel, payload);
    }
    receivedMessageFromB;
    connectedCallback() {
        this.handleSubscribe();
    }
    handleSubscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(this.Context, myMessageChannel, (message) => {
                this.handleMessage(message);
            });
        }
    }
    handleMessage(message) {
        this.receivedMessageFromB = message.messageToSendFromB ? message.messageToSendFromB.value : 'No msg published';
    }
    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}