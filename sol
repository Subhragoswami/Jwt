public List<TransactionSummaryReport> getTransactionSummaryReport(String mId, TransactionSummaryRequest transactionSummaryRequest) {
    log.info("Fetching transaction summary report for merchant ID: {} from {} to {}", 
             mId, transactionSummaryRequest.getFromDate(), transactionSummaryRequest.getToDate());

    List<TransactionSummaryReport> transactionSummaryReports = 
        transactionDashboardRepository.getTransactionSummaryReport(mId, transactionSummaryRequest.getFromDate(), transactionSummaryRequest.getToDate());

    if (transactionSummaryReports.isEmpty()) {
        log.info("No transaction summary record found for mId: {}, fromDate: {} and toDate: {}", 
                 mId, transactionSummaryRequest.getFromDate(), transactionSummaryRequest.getToDate());
        return transactionSummaryReports; // Return empty list if no data
    }

    for (TransactionSummaryReport transactionSummaryReport : transactionSummaryReports) {
        List<TransactionFailureSummaryReport> transactionDailyFailures = 
            transactionDashboardRepository.getTransactionFailureSummaryReport(mId, 
                                                                              transactionSummaryRequest.getFromDate(), 
                                                                              transactionSummaryRequest.getToDate());

        if (!transactionDailyFailures.isEmpty() && transactionSummaryReport.getTotalFailureCount() > 0) {
            for (TransactionFailureSummaryReport transactionDailyFailure : transactionDailyFailures) {
                double failurePercentage = (transactionDailyFailure.getFailureCount() * 100.0) / transactionSummaryReport.getTotalFailureCount();
                transactionDailyFailure.setFailurePercentage(BigDecimal.valueOf(failurePercentage).setScale(2, RoundingMode.HALF_UP).doubleValue());
            }
        }

        transactionSummaryReport.setTransactionDailyFailure(transactionDailyFailures);
    }

    log.info("Transaction summary report for merchant ID: {} fetched successfully.", mId);
    return transactionSummaryReports;
}
