/**
 * Class Name: EisDcmsValidationService
 * 
 * Description: This service handles GSTIN and DCMS card number validation requests.
 * 
 * Author: NIRMAL GURJAR
 * 
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved.
 * 
 * Version: 1.0
 */
@Service
@RequiredArgsConstructor
public class EisDcmsValidationService {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final ObjectMapper objectMapper;
    private final EncryptionDecryptionUtil encryptionDecryptionUtil;
    private final EPayTokenProvider ePayTokenProvider;
    private final DcmsServicesClient dcmsServicesClient;

    /**
     * Method Name: getGstInDetails
     * 
     * Description: Validates the provided GSTIN number by decrypting the request, 
     * checking the input, and calling the external DCMS service.
     * 
     * @param encryptedRequest The encrypted request containing the GSTIN details.
     * @return TransactionResponse containing the encrypted response with GST validation details.
     */
    public TransactionResponse<EncryptedResponse> getGstInDetails(EncryptedRequest encryptedRequest) {
        logger.info("Starting GSTIN validation process.");
        try {
            logger.debug("Decrypting GSTIN request.");
            String decryptedRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(decryptedRequest, EisCardNumberRequest.class);

            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                logger.warn("GSTIN validation failed: Missing card number.");
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, 
                        MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "Gstn"));
            }

            logger.info("Calling DCMS service for GSTIN validation.");
            Object flagResponse = dcmsServicesClient.getGstnValidate(eisCardNumberRequest);
            String responseValue = objectMapper.writeValueAsString(flagResponse);
            String encryptedResponse = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), responseValue);

            logger.info("GSTIN validation completed successfully.");
            return TransactionResponse.<EncryptedResponse>builder()
                    .data(Collections.singletonList(EncryptedResponse.builder().encryptedResponse(encryptedResponse).build()))
                    .status(SUCCESS_RESPONSE_CODE)
                    .count(1L)
                    .build();
        } catch (JsonProcessingException e) {
            logger.error("Error processing JSON during GSTIN validation: {}", e.getMessage());
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, 
                    MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }

    /**
     * Method Name: getEcomFlagByDCMS
     * 
     * Description: Validates the provided card number by decrypting the request, 
     * checking the input, and calling the external DCMS service.
     * 
     * @param encryptedRequest The encrypted request containing the card number.
     * @return TransactionResponse containing the encrypted response with e-commerce flag validation details.
     */
    public TransactionResponse<EncryptedResponse> getEcomFlagByDCMS(EncryptedRequest encryptedRequest) {
        logger.info("Starting EIS DCMS card number validation process.");
        try {
            logger.debug("Decrypting EIS DCMS request.");
            String decryptedRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(decryptedRequest, EisCardNumberRequest.class);

            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                logger.warn("Card number validation failed: Missing card number.");
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, 
                        MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "cardNumberRequest"));
            }

            logger.info("Calling DCMS service for card number validation.");
            Object flagResponse = dcmsServicesClient.getEisDCMSCardNumberValidate(eisCardNumberRequest);
            String responseValue = objectMapper.writeValueAsString(flagResponse);
            String encryptedResponse = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), responseValue);

            logger.info("EIS DCMS card number validation completed successfully.");
            return TransactionResponse.<EncryptedResponse>builder()
                    .data(Collections.singletonList(EncryptedResponse.builder().encryptedResponse(encryptedResponse).build()))
                    .status(SUCCESS_RESPONSE_CODE)
                    .count(1L)
                    .build();
        } catch (JsonProcessingException e) {
            logger.error("Error processing JSON during EIS DCMS validation: {}", e.getMessage());
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, 
                    MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }
}



/**
 * Class Name: EisController
 * 
 * Description: This controller handles GSTIN validation and DCMS card number validation requests.
 * 
 * Author: NIRMAL GURJAR
 * 
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved.
 * 
 * Version: 1.0
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/eis")
public class EisController {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final EisDcmsValidationService eisDCMSValidationService;

    /**
     * Endpoint: /eis/getGstDetails/{gstIn}
     * 
     * Description: Validates the given GSTIN number after decrypting the request.
     * 
     * @param encryptedRequest The encrypted request containing GSTIN details.
     * @return TransactionResponse containing encrypted GST validation details.
     */
    @PostMapping("/getGstDetails/{gstIn}")
    @Operation(summary = "GSTIN Number Validation")
    public TransactionResponse<EncryptedResponse> getGstInDetails(@Valid @RequestBody EncryptedRequest encryptedRequest) {
        logger.info("Received request for GSTIN validation.");
        try {
            logger.debug("Processing GSTIN validation with encrypted request: {}", encryptedRequest);
            TransactionResponse<EncryptedResponse> response = eisDCMSValidationService.getGstInDetails(encryptedRequest);
            logger.info("GSTIN validation request processed successfully.");
            return response;
        } catch (Exception e) {
            logger.error("Error during GSTIN validation: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Endpoint: /eis/ecomflag
     * 
     * Description: Validates a card number against the DCMS system after decrypting the request.
     * 
     * @param encryptedRequest The encrypted request containing card details.
     * @return TransactionResponse containing encrypted card validation details.
     */
    @PostMapping("/ecomflag")
    @Operation(summary = "DCMS Validation")
    public TransactionResponse<EncryptedResponse> getEcomFlagByDCMS(@Valid @RequestBody EncryptedRequest encryptedRequest) {
        logger.info("Received request for EIS DCMS card number validation.");
        try {
            logger.debug("Processing DCMS validation with encrypted request: {}", encryptedRequest);
            TransactionResponse<EncryptedResponse> response = eisDCMSValidationService.getEcomFlagByDCMS(encryptedRequest);
            logger.info("EIS DCMS validation request processed successfully.");
            return response;
        } catch (Exception e) {
            logger.error("Error during EIS DCMS validation: {}", e.getMessage());
            throw e;
        }
    }
}
