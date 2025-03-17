import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import searchBooks from '@salesforce/apex/LibraryService.searchBooks';
import loanBook from '@salesforce/apex/LibraryService.loanBook';

export default class BookLoanManagementLWC extends LightningElement {

    @track
    books = [];
    @track
    selectedBooks = [];
    searchTerm = '';
    borrowerId = null;
    bulkLoan = false;
    process = false;
    delayTimeout;

    handleSearch(event) {
        this.searchTerm = event.target.value;

        if (this.searchTerm.length > 1) {

            clearTimeout(this.delayTimeout);

            this.delayTimeout = setTimeout(() => {
                if (this.searchText.length > 1) {
                    this.fetchBooks();
                } else {
                    this.books = [];
                }
            }, 300);

            this.searchBooks();
        } else {
            this.books = [];
        }
    }

    searchBooks() {
        searchBooks({
                searchTerm: this.searchTerm
            })
            .then(result => {
                this.books = result;
                this.books = this.books.map(book => {
                    return {
                        ...book,
                        disableCheckbox: book.Available_Copies__c === 0,
                        checked: this.selectedBooks.some(selectedBook => selectedBook.Id === book.Id)
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching books:', JSON.stringify(error));
            });
    }

    handleRecordChange(event) {
        this.borrowerId = event.detail.recordId;
    }

    handleCheckboxChange(event) {
        var bookId = event.target.value;
        event.target.checked ? this.addBook(bookId) : this.removeBook(bookId);

    }

    addBook(bookId) {
        const book = this.books.find(book => book.Id === bookId);
        this.selectedBooks.push(book);
    }

    removeBook(bookId) {
        let index = this.selectedBooks.findIndex(book => book.Id === bookId);

        if (index !== -1) {
            this.selectedBooks.splice(index, 1);
        }

    }

    handleButtonAction(event) {
        const bookId = [event.target.dataset.id];
        this.loanBook(bookId);
    }

    handleBulkLoanChecked(event) {
        this.bulkLoan = event.target.checked;
    }

    handleRemove(event) {
        console.log(event.target.dataset.id);
        const bookId = event.target.dataset.id;
        this.removeBook(bookId);
    }

    handleButtonActionMultiLoan() {
        const bookIds = this.selectedBooks.map(book => book.Id);
        this.loanBook(bookIds);
    }

    loanBook(bookIds) {
        this.process = true;
        loanBook({
                bookIds: bookIds,
                borrowerId: this.borrowerId
            })
            .then(result => {
                this.searchBooks();
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Loan created',
                    variant: 'success'
                }));
                this.process = false;
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
                this.process = false;
            });
    }

    get disableLoanActionButton() {
        return this.borrowerId == null;
    }

    get isBulkLoan() {
        return this.bulkLoan;
    }

    get hasBooks() {
        return this.books.length > 0;
    }

    get isProcessing() {
        return this.process;
    }
}