 /**
 * Class Name: CardController
 * 
 * Description: This controller handles BIN check verification for card transactions.
 * 
 * Author: NIRMAL GURJAR
 * 
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved.
 * 
 * Version: 1.0
 */
@RestController
@AllArgsConstructor
@RequestMapping("/cards")
public class CardController {
    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());
    private final CardService cardService;

    /**
     * Endpoint: /cards/binCheck
     * 
     * Description: Validates card number by performing a BIN check.
     * 
     * @param encryptedRequest The encrypted request containing card BIN details.
     * @return TransactionResponse containing encrypted BIN check result.
     */
    @PostMapping("/binCheck")
    @Operation(summary = "Card Number Verification")
    public TransactionResponse<EncryptedResponse> binCheck(@RequestBody EncryptedRequest encryptedRequest) {
        logger.info("Received request for BIN check.");
        try {
            logger.debug("Processing BIN check with encrypted request: {}", encryptedRequest);
            TransactionResponse<EncryptedResponse> response = cardService.binCheck(encryptedRequest);
            logger.info("BIN check request processed successfully.");
            return response;
        } catch (Exception e) {
            logger.error("Error during BIN check: {}", e.getMessage());
            throw e;
        }
    }
}








/**
 * Performs a BIN check by decrypting the request, validating the card BIN, and calling an admin service.
 * 
 * @param encryptedRequest The encrypted request containing the card BIN.
 * @return A TransactionResponse containing the encrypted BIN check result.
 */
public TransactionResponse<EncryptedResponse> binCheck(EncryptedRequest encryptedRequest) {
    logger.info("Preparing to fetch BIN check status.");

    try {
        // Decrypting request
        String decryptedCardBin = encryptionDecryptionUtil.decryptData(ePayTokenProvider.getToken(), encryptedRequest.getEncryptedRequest());
        logger.debug("Decrypted card BIN data: {}", decryptedCardBin);

        // Convert decrypted data to request object
        BinCheckRequest binCheckRequest = convertDecryptDataToBinCheckRequest(decryptedCardBin);
        logger.info("Calling Admin Service for BIN check.");

        // Call Admin Services Client
        TransactionResponse<BinCheckResponse> binCheckResponse = adminServicesClient.binCheckRequest(binCheckRequest);

        // Check for failure response
        if (binCheckResponse.getStatus() == RESPONSE_FAILURE) {
            logger.warn("Invalid card details received during BIN check.");
            throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE, MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Card details", "Invalid card."));
        }

        // Convert response to JSON string
        String responseJson = convertBinCheckResponseToString(binCheckResponse);
        logger.info("Encrypting response from BIN check.");

        // Encrypt response
        String encryptedResponse = encryptionDecryptionUtil.encryptData(ePayTokenProvider.getToken(), responseJson);
        EncryptedResponse response = EncryptedResponse.builder().encryptedResponse(encryptedResponse).build();

        logger.info("BIN check completed successfully.");
        return TransactionResponse.<EncryptedResponse>builder()
                .status(RESPONSE_SUCCESS)
                .count(1L)
                .data(Collections.singletonList(response))
                .build();
    } catch (JsonProcessingException e) {
        logger.error("JSON Processing error during BIN check: {}", e.getMessage());
        throw new TransactionException(ErrorConstants.JSON_ERROR_CODE, MessageFormat.format(ErrorConstants.JSON_ERROR_MESSAGE, "BIN check request"));
    } catch (Exception e) {
        logger.error("Unexpected error during BIN check: {}", e.getMessage());
        throw new TransactionException(ErrorConstants.SYSTEM_ERROR_CODE, "Unexpected error occurred during BIN check.");
    }
}

/**
 * Converts decrypted card BIN data into a BinCheckRequest object.
 * 
 * @param decryptedCardBin The decrypted card BIN data as a JSON string.
 * @return BinCheckRequest object.
 */
private BinCheckRequest convertDecryptDataToBinCheckRequest(String decryptedCardBin) {
    try {
        return mapper.readValue(decryptedCardBin, BinCheckRequest.class);
    } catch (JsonProcessingException e) {
        logger.error("Error parsing decrypted BIN check request: {}", e.getMessage());
        throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE, MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Decrypt request", "Requested data is mismatched."));
    }
}

/**
 * Converts a BIN check response object into a JSON string.
 * 
 * @param binCheckResponse The response object containing BIN check results.
 * @return The JSON string representation of the response.
 */
private String convertBinCheckResponseToString(TransactionResponse<BinCheckResponse> binCheckResponse) {
    try {
        return mapper.writeValueAsString(binCheckResponse.getData().getFirst());
    } catch (JsonProcessingException e) {
        logger.error("Error converting BIN check response to JSON: {}", e.getMessage());
        throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE, MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Encrypt response", "Requested data is mismatched."));
    }
}
