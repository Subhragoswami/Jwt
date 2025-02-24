/**
 * Retrieves recent monthly transactions for a given merchant within a specified date range.
 * This method adjusts the provided date range to cover the entire month and fetches 
 * transactions accordingly.
 *
 * @param recentTransactionRequest The request containing the from-date and to-date.
 * @param mID The merchant ID for which transactions are to be fetched.
 * @param pageable The pagination details for fetching the transactions.
 * @return EPayResponseEntity<TransactionSummary> containing the list of transactions,
 *         the count of transactions retrieved, and the total count.
 * @throws ParseException If the date format is invalid.
 */
private EPayResponseEntity<TransactionSummary> recentMonthlyTransaction(
        RecentTransactionRequest recentTransactionRequest, String mID, Pageable pageable) throws ParseException {

    // Set the start date to the first day of the month
    Calendar startCalendar = Calendar.getInstance();
    startCalendar.setTime((Date) DateUtil.INPUT_FORMATTER.parse(recentTransactionRequest.getFromDate()));
    startCalendar.set(Calendar.DAY_OF_MONTH, 1); // Set to the first day of the month

    // Set the end date to the last day of the month
    Calendar endCalendar = Calendar.getInstance();
    endCalendar.setTime((Date) DateUtil.INPUT_FORMATTER.parse(recentTransactionRequest.getToDate()));
    endCalendar.set(Calendar.DAY_OF_MONTH, endCalendar.getActualMaximum(Calendar.DAY_OF_MONTH)); // Set to the last day of the month

    // Format the start and end dates
    String startDate = DateUtil.OUTPUT_FORMATTER.format((TemporalAccessor) startCalendar.getTime());
    String endDate = DateUtil.OUTPUT_FORMATTER.format((TemporalAccessor) endCalendar.getTime());

    logger.info("Fetching monthly transactions from db by mID and date range: {}, {}, {}", mID, startDate, endDate);

    // Retrieve the recent transactions based on the merchant ID and the monthly date range
    List<TransactionSummary> recentTxnList = transactionDao.getRecentTransaction(mID, startDate, endDate, pageable);

    // Fetch the
