import { LightningElement } from 'lwc';

export default class ParentComponents extends LightningElement {
    parentgreetings;

    submitClickHandler(event) {
        this.parentgreetings = this.refs.greetings.value;
        console.log('hii');
    }
}