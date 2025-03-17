public with sharing class LibraryService {

    @AuraEnabled
    public static List<Library_Book__c> searchBooks(String searchTerm){
        List<Library_Book__c> libraryBookList = new List<Library_Book__c>();

        try{
            String searchTermLike =  String.escapeSingleQuotes('%' + searchTerm + '%');
            libraryBookList = [SELECT Id, Title__c, Author__c, Available_Copies__c, Total_Copies__c FROM Library_Book__c WHERE Title__c LIKE :searchTermLike OR Author__c LIKE :searchTermLike LIMIT 20];
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return libraryBookList;
    }

    @AuraEnabled
    public static void loanBook(List<Id> bookIds, Id borrowerId){
        List<Library_Book_Loan__c> bookLoansToInsert = new List<Library_Book_Loan__c>();

        try{
            for(Id bookId : bookIds){
                Library_Book_Loan__c libraryBookLoan = new Library_Book_Loan__c();
                libraryBookLoan.Borrower__c = borrowerId;
                libraryBookLoan.Book__c = bookId;
                libraryBookLoan.Loan_Start_Date__c = Date.today();

                bookLoansToInsert.add(libraryBookLoan);
            }

            insert bookLoansToInsert;

        }catch(Exception e){
            throw new AuraHandledException('No stock available');
        }       
    }

    @AuraEnabled
    public static void endBookLoan(Id bookLoanId){
        Library_Book_Loan__c libraryBookLoan = new Library_Book_Loan__c();
        libraryBookLoan.Id = bookLoanId;
        libraryBookLoan.Loan_End_Date__c = Date.today();

        update libraryBookLoan;
    }
}