
@RestController
@RequiredArgsConstructor
@RequestMapping("/eis")
public class EisController {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final EisDcmsValidationService eisDCMSValidationService;

    @PostMapping("/getGstDetails/{gstIn}")
    @Operation(summary = "GSTIN Number Validation")
    public TransactionResponse<EncryptedResponse> getGstInDetails(@Valid @RequestBody EncryptedRequest encryptedRequest) {
        logger.info("Processing GSTIN validation with encrypted request: {}", encryptedRequest);
        return eisDCMSValidationService.getGstInDetails(encryptedRequest);
    }

    @PostMapping("/ecomflag")
    @Operation(summary = "DCMS Validation")
    public TransactionResponse<EncryptedResponse> getEcomFlagByDCMS(@Valid @RequestBody EncryptedRequest encryptedRequest) {
        logger.info("Processing card validation with encrypted request: {}", encryptedRequest);
        return eisDCMSValidationService.getEcomFlagByDCMS(encryptedRequest);
    }
}

@Service
@RequiredArgsConstructor
public class EisDcmsValidationService {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final ObjectMapper objectMapper;
    private final EncryptionDecryptionUtil encryptionDecryptionUtil;
    private final EPayTokenProvider ePayTokenProvider;
    private final DcmsServicesClient dcmsServicesClient;

    public TransactionResponse<EncryptedResponse> getGstInDetails(EncryptedRequest encryptedRequest) {
        try {
            logger.info("Starting GSTIN validation.");
            String decryptedRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(decryptedRequest, EisCardNumberRequest.class);
            
            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                logger.error("Invalid request: GSTIN is missing.");
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "Gstn"));
            }

            logger.info("Calling DCMS service for GSTIN validation.");
            Object flagResponse = dcmsServicesClient.getGstnValidate(eisCardNumberRequest);
            String responseValue = objectMapper.writeValueAsString(flagResponse);
            String encryptedResponse = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), responseValue);
            
            logger.info("GSTIN validation successful.");
            return TransactionResponse.<EncryptedResponse>builder()
                    .data(Collections.singletonList(new EncryptedResponse(encryptedResponse)))
                    .status(SUCCESS_RESPONSE_CODE)
                    .count(1L)
                    .build();
        } catch (JsonProcessingException e) {
            logger.error("Error processing JSON: {}", e.getMessage());
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }

    public TransactionResponse<EncryptedResponse> getEcomFlagByDCMS(EncryptedRequest encryptedRequest) {
        try {
            logger.info("Starting EIS DCMS CardNumber validation.");
            String decryptedRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(decryptedRequest, EisCardNumberRequest.class);
            
            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                logger.error("Invalid request: Card number is missing.");
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "cardNumberRequest"));
            }

            logger.info("Calling DCMS service for CardNumber validation.");
            Object flagResponse = dcmsServicesClient.getEisDCMSCardNumberValidate(eisCardNumberRequest);
            String responseValue = objectMapper.writeValueAsString(flagResponse);
            String encryptedResponse = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), responseValue);
            
            logger.info("EIS DCMS CardNumber validation successful.");
            return TransactionResponse.<EncryptedResponse>builder()
                    .data(Collections.singletonList(new EncryptedResponse(encryptedResponse)))
                    .status(SUCCESS_RESPONSE_CODE)
                    .count(1L)
                    .build();
        } catch (JsonProcessingException e) {
            logger.error("Error processing JSON: {}", e.getMessage());
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }
}
