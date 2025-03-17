public class LibraryBookLoanTriggerHandler {

    public static void handleLoan(List<Library_Book_Loan__c> loanRecords) {
        Set<Id> bookIds = new Set<Id>();
    
        for (Library_Book_Loan__c loan : loanRecords) {
            if (loan.Book__c != null) {
                bookIds.add(loan.Book__c);
            }
        }
    
        if (!bookIds.isEmpty()) {
            List<Library_Book__c> booksToUpdate = new List<Library_Book__c>();

            Map<Id, Library_Book__c> books = new Map<Id, Library_Book__c>(
                [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Id IN :bookIds]
            );
    
            for (Library_Book_Loan__c loan : loanRecords) {
                Library_Book__c book = books.get(loan.Book__c);
                
                if (book != null) {
                    if (book.Available_Copies__c <= 0) {
                        throw new NoAvailableCopiesException('No stock available');
                    }
    
                    book.Available_Copies__c--;

                    booksToUpdate.add(book);
                }
            }
    
            if (!booksToUpdate.isEmpty()) {
                update booksToUpdate;
            }
        }
    }

    public static void handleLoanReturn(List<Library_Book_Loan__c> oldLoans, List<Library_Book_Loan__c> newLoans) {
        Set<Id> bookIds = new Set<Id>();
        List<Library_Book_Loan__c> loansToDelete = new List<Library_Book_Loan__c>();
        List<Library_Book__c> booksToUpdate = new List<Library_Book__c>();

        for (Integer i = 0; i < newLoans.size(); i++) {
            Library_Book_Loan__c newLoan = newLoans[i];
            Library_Book_Loan__c oldLoan = oldLoans[i];

            if (oldLoan.Loan_End_Date__c == null && newLoan.Loan_End_Date__c != null) {
                bookIds.add(newLoan.Book__c);
                loansToDelete.add(new Library_Book_Loan__c(Id = newLoans[i].Id));
            }
        }

        if (!bookIds.isEmpty()) {
            Map<Id, Library_Book__c> books = new Map<Id, Library_Book__c>(
                [SELECT Id, Available_Copies__c FROM Library_Book__c WHERE Id IN :bookIds]
            );

            for (Library_Book_Loan__c loan : newLoans) {
                Library_Book__c book = books.get(loan.Book__c);
                if (book != null) {
                    book.Available_Copies__c++;
                    booksToUpdate.add(book);
                }
            }

            if (!booksToUpdate.isEmpty()) {
                update booksToUpdate;
            }

            if (!loansToDelete.isEmpty()) {
                delete loansToDelete;
            }
        }
    }
    
}
