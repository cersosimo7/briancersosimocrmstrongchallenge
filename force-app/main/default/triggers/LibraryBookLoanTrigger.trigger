trigger LibraryBookLoanTrigger on Library_Book_Loan__c (before insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LibraryBookLoanTriggerHandler.handleLoan(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            LibraryBookLoanTriggerHandler.handleLoanReturn(Trigger.old, Trigger.new);
        }
    }
}
