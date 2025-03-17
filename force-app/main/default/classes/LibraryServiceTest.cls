@isTest
public with sharing class LibraryServiceTest {
        
    @TestSetup
    private static void makeData() {
        Contact borrower = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');

        insert borrower;
    
        Library_Book__c book1 = new Library_Book__c(Title__c = 'Book Title One', Author__c = 'Author A', Available_Copies__c = 5, Total_Copies__c = 10);
        Library_Book__c book2 = new Library_Book__c(Title__c = 'Another Book Title', Author__c = 'Author B', Available_Copies__c = 3, Total_Copies__c = 8);
        Library_Book__c book3 = new Library_Book__c(Title__c = 'Book Title Three', Author__c = 'Author C', Available_Copies__c = 4, Total_Copies__c = 12);
        
        insert new List<Library_Book__c> {book1, book2, book3};
    }

    @isTest
    public static void testSearchBooks() {
        List<Library_Book__c> createdBooks = [SELECT Id FROM Library_Book__c];

        Test.startTest();
        List<Library_Book__c> results = LibraryService.searchBooks('Book');
        Test.stopTest();
        
        Assert.areEqual(3, results.size(), 'There should be 3 books found.');
    }

    @isTest
    public static void testSearchBooksNoResults() {
        Test.startTest();
            List<Library_Book__c> results = LibraryService.searchBooks('NonExistentBook');
        Test.stopTest();
        
        Assert.areEqual(0, results.size());
    }

    @isTest
    public static void testLoanBook(){
        List<Id> bookIds = new List<Id>();
        Id borrowerId = [SELECT Id FROM Contact].Id;

        for(Library_Book__c lb : [SELECT Id FROM Library_Book__c]){
            bookIds.add(lb.Id);
        }

        Test.startTest();
            LibraryService.loanBook(bookIds, borrowerId);
        Test.stopTest();

        List<Library_Book_Loan__c> lbl = [SELECT Id FROM Library_Book_Loan__c];

        Assert.areEqual(3, lbl.size());
    }

    @isTest
    public static void testLoanBookException(){

        List<Id> bookIds = new List<Id>();
        Boolean exceptionCaught = false;
        for(Library_Book__c lb : [SELECT Id FROM Library_Book__c]){
            bookIds.add(lb.Id);
        }
        Id borrowerId = bookIds[0];
        Test.startTest();
            try{
                LibraryService.loanBook(bookIds, borrowerId);
            }catch(Exception e){
                exceptionCaught = true;
            }
        Test.stopTest();

        List<Library_Book_Loan__c> lbl = [SELECT Id FROM Library_Book_Loan__c];

        Assert.areEqual(0, lbl.size());
        Assert.isTrue(exceptionCaught);
    }

    @isTest
    public static void testLoanReturn(){
        List<Id> bookIds = new List<Id>();
        Id borrowerId = [SELECT Id FROM Contact].Id;

        for(Library_Book__c lb : [SELECT Id FROM Library_Book__c]){
            bookIds.add(lb.Id);
        }
        LibraryService.loanBook(bookIds, borrowerId);

        List<Library_Book_Loan__c> lbl = [SELECT Id FROM Library_Book_Loan__c];

        Test.startTest();
            Library_Book_Loan__c singleLbl = lbl[0];
            singleLbl.Loan_End_Date__c = Date.today();
            update singleLbl;
        Test.stopTest();

        List<Library_Book_Loan__c> lblAfterTrigger = [SELECT Id FROM Library_Book_Loan__c];

        Assert.areEqual(2, lblAfterTrigger.size());
    }

    @isTest
    public static void testEndLoanBook(){
        List<Id> bookIds = new List<Id>();
        Id borrowerId = [SELECT Id FROM Contact].Id;

        for(Library_Book__c lb : [SELECT Id FROM Library_Book__c]){
            bookIds.add(lb.Id);
        }
        LibraryService.loanBook(bookIds, borrowerId);
        List<Library_Book_Loan__c> lbl = [SELECT Id FROM Library_Book_Loan__c];

        Test.startTest();
            LibraryService.endBookLoan(lbl[0].Id);
        Test.stopTest();

        List<Library_Book_Loan__c> lblAfterEnd = [SELECT Id FROM Library_Book_Loan__c];

        Assert.areEqual(2, lbl.size());
    }
}
