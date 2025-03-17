
import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import endBookLoan from '@salesforce/apex/LibraryService.endBookLoan';

export default class BookLoanEndLoan extends LightningElement {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.endBookLoan();
    }
    
    get recordId() {
        return this._recordId;
    }

    endBookLoan() {
        endBookLoan({
                bookLoanId: this.recordId
            })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Loan ended',
                    variant: 'success'
                }));
                window.location.href = '/lightning/o/Library_Book_Loan__c/list';
            })
            .catch(error => {
                console.error('Error deleting loan:', JSON.stringify(error));
            });
    }
}