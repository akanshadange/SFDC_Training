import { LightningElement } from 'lwc';

export default class ParentComponents extends LightningElement {
    parentgreetings;

    handleChange(event) {
        this.parentgreetings = event.target.value;
    }
}