@RequiredArgsConstructor
@Service
public class MerchantPayoutService {

    private final LoggerUtility log = LoggerFactoryUtility.getLogger(this.getClass());
    private final MerchantPayoutDao merchantPayoutDao;
    private final FileGeneratorService fileGeneratorService;
    private final FileService fileService;
    private final ReportManagementDao reportManagementDao;

    /**
     * Generates Merchant Payout Report and uploads it to S3
     *
     * @param id    UUID for report
     * @param rfsId List of UUIDs to fetch data
     * @return ReportingResponse<String>
     */
    public ReportingResponse<String> generateMerchantPayoutReport(UUID id, List<UUID> rfsId) {
        log.info("Generating Merchant Payout Report for ReportID: {} and RfsIDs: {}", id, rfsId);

        List<MerchantPayout> list = merchantPayoutDao.getMerchantPayoutData(rfsId);
        log.info("Fetched Merchant Payout data of size: {}", list.size());

        List<List<Object>> fileData = list.stream()
                .map(this::convertToListOfObject)
                .toList();

        buildReport(
                ReportFormat.CSV,
                getMerchantPayoutHeaders(),
                fileData,
                Report.MERCHANT_WISE_PAYOUT_MIS,
                id
        );

        return ReportingResponse.<String>builder()
                .status(ReportingConstant.RESPONSE_SUCCESS)
                .data(List.of("REPORT_GENERATED_SUCCESSFULLY"))
                .build();
    }

    /**
     * Generates Transaction Refund Report and uploads it to S3
     *
     * @param id    UUID for report
     * @param rfsId List of UUIDs to fetch data
     * @return ReportingResponse<String>
     */
    public ReportingResponse<String> generateTransactionRefund(UUID id, List<UUID> rfsId) {
        log.info("Generating Transaction Refund Report for ReportID: {} and RfsIDs: {}", id, rfsId);

        List<TransactionRefund> list = merchantPayoutDao.getTransactionRefundData(rfsId);
        log.info("Fetched Transaction Refund data of size: {}", list.size());

        List<List<Object>> fileData = list.stream()
                .map(this::convertToListOfObject)
                .toList();

        buildReport(
                ReportFormat.CSV,
                getTransactionRefundHeaders(),
                fileData,
                Report.TRANSACTION_WISE_REFUND_MIS,
                id
        );

        return ReportingResponse.<String>builder()
                .status(ReportingConstant.RESPONSE_SUCCESS)
                .data(List.of("REPORT_GENERATED_SUCCESSFULLY"))
                .build();
    }

    /**
     * Builds the report, uploads it to S3, and saves report details in DB
     *
     * @param reportFormat Format of the report (CSV, XLSX etc.)
     * @param header       Report headers
     * @param fileData     Report data rows
     * @param report       Report type
     * @param id           Report UUID
     */
    protected void buildReport(
            ReportFormat reportFormat,
            List<String> header,
            List<List<Object>> fileData,
            Report report,
            UUID id
    ) {
        log.info("Building report: {} with format: {}", report, reportFormat);

        FileModel fileModel = fileGeneratorService.buildFileModel(
                reportFormat,
                header,
                fileData,
                Map.of("headers", header, "rows", fileData)
        );

        ReportFile reportFile = fileGeneratorService.generateFile(reportFormat, report, fileModel);

        String s3FileName = fileService.uploadFile(reportFile.getName(), reportFile.getContent());
        log.info("Report uploaded to S3 with file name: {}", s3FileName);

        ReportManagementDto reportManagementDto = ReportManagementDto.builder()
                .reportId(id)
                .mId("0")
                .durationFromDate(0L)
                .durationToDate(0L)
                .format(ReportFormat.CSV)
                .status(ReportStatus.GENERATED)
                .remarks("Report request from operation service")
                .filePath(s3FileName)
                .build();

        reportManagementDao.saveReport(reportManagementDto);
        log.info("Report metadata saved in DB for ReportID: {}", id);
    }
}


@RequiredArgsConstructor
@Repository
public class MerchantPayoutDao {

    private final LoggerUtility log = LoggerFactoryUtility.getLogger(this.getClass());
    private final MerchantPayoutRepository merchantPayoutRepository;
    private final TransactionRefundDao transactionRefundDao;

    /**
     * Fetches Merchant Payout data from DB
     *
     * @param rfsId List of UUIDs
     * @return List of MerchantPayout
     */
    public List<MerchantPayout> getMerchantPayoutData(List<UUID> rfsId) {
        log.info("Fetching Merchant Payout data for RfsIDs: {}", rfsId);
        List<MerchantPayout> data = merchantPayoutRepository.getMerchantPayout(rfsId);
        log.info("Fetched Merchant Payout rows: {}", data.size());
        return data;
    }

    /**
     * Fetches Transaction Refund data from DB
     *
     * @param rfsId List of UUIDs
     * @return List of TransactionRefund
     */
    public List<TransactionRefund> getTransactionRefundData(List<UUID> rfsId) {
        log.info("Fetching Transaction Refund data for RfsIDs: {}", rfsId);
        List<TransactionRefund> data = transactionRefundDao.getTransactionRefundData(rfsId);
        log.info("Fetched Transaction Refund rows: {}", data.size());
        return data;
    }
}