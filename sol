public class EisDcmsValidationService {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final ObjectMapper objectMapper;
    private final EncryptionDecryptionUtil encryptionDecryptionUtil;
    private final EPayTokenProvider ePayTokenProvider;
    private final DcmsServicesClient dcmsServicesClient;

    public TransactionResponse<EncryptedResponse> getGstInDetails(EncryptedRequest encryptedRequest) {
        try {
            logger.info("GSTN Validation.");
            String DecryptRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(DecryptRequest, EisCardNumberRequest.class);
            //1.Validate request Param.
            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "Gstn"));
            }

            Object flagResponse = dcmsServicesClient.getGstnValidate(eisCardNumberRequest);
            String Value = objectMapper.writeValueAsString(flagResponse);
            String response = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), Value);
            EncryptedResponse encryptedResponse = EncryptedResponse.builder().encryptedResponse(response).build();

            return TransactionResponse.<EncryptedResponse>builder().data(Collections.singletonList(encryptedResponse)).status(SUCCESS_RESPONSE_CODE).count(1L).build();
        } catch (JsonProcessingException e) {
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }

    public TransactionResponse<EncryptedResponse> getEcomFlagByDCMS(EncryptedRequest encryptedRequest) {
        try {
            logger.info("EIS DCSM CardNumber Validation.");
            String DecryptRequest = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
            EisCardNumberRequest eisCardNumberRequest = objectMapper.readValue(DecryptRequest, EisCardNumberRequest.class);
            //1.Validate request Param.
            if (eisCardNumberRequest.getCardNumber().isEmpty()) {
                throw new TransactionException(ErrorConstants.NOT_FOUND_ERROR_CODE, MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "cardNumberRequest"));
            }

            Object flagResponse = dcmsServicesClient.getEisDCMSCardNumberValidate(eisCardNumberRequest);
            String Value = objectMapper.writeValueAsString(flagResponse);
            String response = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), Value);
            EncryptedResponse encryptedResponse = EncryptedResponse.builder().encryptedResponse(response).build();

            return TransactionResponse.<EncryptedResponse>builder().data(Collections.singletonList(encryptedResponse)).status(SUCCESS_RESPONSE_CODE).count(1L).build();
        } catch (JsonProcessingException e) {
            throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "encrypted Request"));
        }
    }
