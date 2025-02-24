
/**
 * Class Name: TransactionDao
 *
 * Description: This DAO class handles all transaction-related database operations, 
 * including transaction validation, retrieval, saving, and updating.
 *
 * Author: NIRMAL GURJAR
 *
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved.
 *
 * Version: 1.0
 */
@Component
@RequiredArgsConstructor
public class TransactionDao {

    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());

    private final TransactionRepository transactionRepository;
    private final ViewRecentTxnRepository viewRecentTxnRepository;
    private final ObjectMapper objectMapper;
    private final TransactionViewRefundRepository transactionViewRefundRepository;
    private final TransactionMapper transactionMapper;

    /**
     * Counts the number of transactions that match the given filters.
     *
     * @param orderNo       The order number.
     * @param sbiepayOrderId SBI Pay Order ID.
     * @param atrn          The ATRN number.
     * @param bankRefNo     The bank reference number.
     * @param startDate     The start date in milliseconds.
     * @param endDate       The end date in milliseconds.
     * @param status        The transaction status.
     * @return The count of matching transactions.
     */
    public Long countTransactionsWithFilters(String orderNo, String sbiepayOrderId, String atrn, String bankRefNo, Long startDate, Long endDate, String status) {
        return transactionViewRefundRepository.countTransactionsWithFilters(orderNo, sbiepayOrderId, atrn, bankRefNo, startDate, endDate, status);
    }

    /**
     * Counts the number of transactions for a given merchant ID within a date range.
     *
     * @param mId       The merchant ID.
     * @param startDate The start date (formatted as a string).
     * @param endDate   The end date (formatted as a string).
     * @return The count of transactions within the date range.
     */
    public Long countTransactionsWithFilters(String mId, String startDate, String endDate) {
        return viewRecentTxnRepository.countTransactionsByMidAndDateRange(mId, startDate, endDate);
    }

    /**
     * Counts the number of orders and refund transactions for a given merchant within a date range.
     *
     * @param mID             The merchant ID.
     * @param startMilliseconds The start date in milliseconds.
     * @param endMilliseconds   The end date in milliseconds.
     * @return The count of orders and refund transactions.
     */
    public Long countOrderAndRefundTransactionsWithFilters(String mID, long startMilliseconds, long endMilliseconds) {
        return transactionRepository.countOrderAndRefundTransactionsWithFilters(mID, startMilliseconds, endMilliseconds);
    }

    /**
     * Checks if a transaction is valid for booking based on its status.
     *
     * @param sbiOrderRefNumber The SBI order reference number.
     * @param statusList        A list of valid transaction statuses.
     * @return True if the transaction is valid for booking, otherwise false.
     */
    public boolean isTransactionValidForBooking(String sbiOrderRefNumber, List<String> statusList) {
        return transactionRepository hii.countBySbiOrderRefNumberAndTransactionStatusInNative(sbiOrderRefNumber, statusList) > 0;
    }

    /**
     * Retrieves RFC (Request for Comments) data based on an alternative hash.
     *
     * @param altHash The alternative hash.
     * @return An object array containing RFC data.
     */
    public Object[] getRfc(String altHash) {
        logger.info("Fetching data from MerchantOrderPayment and Order table.");
        return transactionRepository.rfcCount(altHash);
    }
}
