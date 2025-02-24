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
     * Checks if a transaction is valid for booking based on its status.
     *
     * @param sbiOrderRefNumber The SBI order reference number.
     */
    public void isTransactionValidForBooking(String sbiOrderRefNumber) {
        List<String> statusList = List.of(
                TransactionStatus.BOOKED.name(), 
                TransactionStatus.PAYMENT_INITIATION_START.name(), 
                TransactionStatus.PAYMENT_IN_VERIFICATION.name(), 
                TransactionStatus.PAYMENT_VERIFIED.name()
        );

        boolean isExist = transactionRepository.existsBySbiOrderRefNumberAndTransactionStatusIn(sbiOrderRefNumber, statusList);
        if (isExist) {
            throw new ValidationException(ErrorConstants.INVALID_ERROR_CODE, 
                MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Order State", "Duplicate request for Order."));
        }
    }

    /**
     * Saves a transaction to the database.
     *
     * @param transactionDto The transaction DTO containing transaction details.
     * @return The saved transaction DTO.
     */
    public TransactionDto saveTransaction(TransactionDto transactionDto) {
        MerchantOrderPayment merchantOrderPayment = transactionMapper.transactionDtoToEntity(transactionDto);
        MerchantOrderPayment merchantOrderPaymentData = transactionRepository.save(merchantOrderPayment);
        return transactionMapper.TransactionEntityToDto(merchantOrderPaymentData);
    }

    /**
     * Retrieves transactions for a given merchant ID within a specific date range.
     *
     * @param mID      The merchant ID.
     * @param fromDate The start date in milliseconds.
     * @param toDate   The end date in milliseconds.
     * @param pageable The pagination details.
     * @return A list of transactions.
     */
    public List<MerchantOrderPayment> findTransactionsByMerchantIdAndDateRange(String mID, Long fromDate, Long toDate, Pageable pageable) {
        return transactionRepository.findTransactionsByMerchantIdAndDateRange(mID, fromDate, toDate, pageable);
    }

    /**
     * Retrieves transaction and order details for payment verification.
     *
     * @param paymentPushVerificationRequest The decrypted payment verification request.
     * @return A list of object arrays containing transaction and order details.
     */
    public List<Object[]> getTransactionAndOrderDetail(PaymentVerificationRequestDto paymentPushVerificationRequest) {
        logger.info("Fetching data from transaction and order table.");
        List<Object[]> transactionAndOrderData = transactionRepository.fetchTransactionAndOrderDetail(
                paymentPushVerificationRequest.getAtrnNumber(),
                paymentPushVerificationRequest.getOrderRefNumber(),
                paymentPushVerificationRequest.getSbiOrderRefNumber(),
                paymentPushVerificationRequest.getOrderAmount()
        ).orElseThrow(() -> new TransactionException(ErrorConstants.SQL_SYNTAX_ERROR_CODE, 
                MessageFormat.format(ErrorConstants.SQL_SYNTAX_ERROR_MESSAGE, "MerchantOrderPayment and Order")));

        if (transactionAndOrderData.isEmpty()) {
            throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE, 
                MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Payment request", "Requested data is mismatched."));
        }

        logger.info("Fetched data from transaction and order table.");
        return transactionAndOrderData;
    }

    /**
     * Retrieves recent transaction details for a merchant within a given date range.
     *
     * @param mID     The merchant ID.
     * @param toDate  The end date.
     * @param fromDate The start date.
     * @param pageable The pagination details.
     * @return A list of transaction summaries.
     */
    public List<TransactionSummary> getRecentTransaction(String mID, String toDate, String fromDate, Pageable pageable) {
        logger.info("Fetching recent transaction data from view recent txn.");
        List<ViewRecentTxn> viewRecentTxnList = viewRecentTxnRepository.findTransactionsByMidAndDateRange(mID, toDate, fromDate, pageable)
                .orElseThrow(() -> new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, 
                        MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "Recent MerchantOrderPayment")));
        return buildRecentTxn(viewRecentTxnList);
    }

    /**
     * Maps recent transactions to transaction summary DTOs.
     *
     * @param recentTxnList List of recent transactions.
     * @return A list of transaction summaries.
     */
    private List<TransactionSummary> buildRecentTxn(List<ViewRecentTxn> recentTxnList) {
        logger.info("Mapping view recent txn to recent txn dto.");
        return recentTxnList.stream().map(txn -> 
            TransactionSummary.builder()
                .txnCount(txn.getCount())
                .totalOrderAmount(BigDecimal.valueOf(txn.getAmount()))
                .totalTxnFee(txn.getTax())
                .creationDate(formatDate(txn.getCreationDate()))
                .refundAmount(txn.getRefundAmount())
                .refundCount(txn.getRefundCount())
                .build()
        ).collect(Collectors.toList());
    }

    /**
     * Updates the status of a transaction.
     *
     * @param transactionUpdateRequest The transaction update request.
     * @param mID The merchant ID.
     * @return The updated transaction DTO.
     */
    public TransactionDto updateTransactionStatus(TransactionUpdateRequest transactionUpdateRequest, String mID) {
        logger.debug("Starting transaction status update.");
        Optional<MerchantOrderPayment> transactionByAtrn = transactionRepository.findByAtrnNumberAndMerchantId(transactionUpdateRequest.getAtrn(), mID);
        
        if (transactionByAtrn.get().getAtrnNumber() == null || 
            transactionByAtrn.get().getPaymentStatus().equalsIgnoreCase(String.valueOf(TransactionStatus.SUCCESS)) || 
            transactionByAtrn.get().getPaymentStatus().equalsIgnoreCase(String.valueOf(TransactionStatus.FAILED))) {
            
            throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE, 
                MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Atrn", "Atrn status is already updated."));
        }

        transactionByAtrn.get().setTransactionStatus(String.valueOf(TransactionStatus.FAILED));
        transactionByAtrn.get().setPaymentStatus(String.valueOf(TransactionStatus.FAILED));
        transactionByAtrn.get().setUpdatedDate(DateTimeUtils.currentTimeMillis());
        transactionByAtrn.get().setFailReason(transactionUpdateRequest.getFailReason());

        MerchantOrderPayment merchantOrderPayment = objectMapper.convertValue(transactionByAtrn.get(), MerchantOrderPayment.class);
        MerchantOrderPayment merchantOrderPaymentData = transactionRepository.save(merchantOrderPayment);
        
        logger.debug("Updated transaction status: " + merchantOrderPaymentData);
        return objectMapper.convertValue(merchantOrderPaymentData, TransactionDto.class);
    }

    /**
     * Retrieves filtered transactions based on various criteria.
     *
     * @param orderNo      The order number.
     * @param sbiepayOrderId SBI Pay Order ID.
     * @param atrn         The ATRN number.
     * @param bankRefNo    The bank reference number.
     * @param startDate    The start date.
     * @param endDate      The end date.
     * @param status       The transaction status.
     * @param pageable     The pagination details.
     * @return A list of filtered transactions.
     */
    public List<ViewTransactionAndRefund> getFilteredTransaction(String orderNo, String sbiepayOrderId, String atrn, String bankRefNo, Long startDate, Long endDate, String status, Pageable pageable) {
        return transactionViewRefundRepository.findTransactionsWithFilters(orderNo, sbiepayOrderId, atrn, bankRefNo, startDate, endDate, status, pageable);
    }

    /**
     * Retrieves a transaction by ATRN number.
     *
     * @param atrn The ATRN number.
     * @return The transaction DTO.
     */
    public TransactionDto findByAtrnNumber(String atrn) {
        MerchantOrderPayment merchantOrderPayment = transactionRepository.findByAtrnNumber(atrn)
                .orElseThrow(() -> new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, 
                        MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "MerchantOrderPayment detail")));
        return transactionMapper.TransactionEntityToDto(merchantOrderPayment);
    }
}
