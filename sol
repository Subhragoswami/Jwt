/**
 * Converts a decrypted JSON string into a MerchantPricingRequestDto object.
 * @param decryptedRequest The decrypted request JSON string.
 * @return The deserialized MerchantPricingRequestDto object.
 * @throws TransactionException If the JSON cannot be parsed.
 */
private MerchantPricingRequestDto toObject(String decryptedRequest) {
    try {
        return objectMapper.readValue(decryptedRequest, MerchantPricingRequestDto.class);
    } catch (JsonProcessingException e) {
        throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE,  
            MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Encrypt request", "Requested data is mismatched."));
    }
}

/**
 * Converts a MerchantFeeDto object into a JSON string.
 * @param merchantFeeDto The merchant fee data transfer object.
 * @return The serialized JSON string representation of the object.
 * @throws TransactionException If the object cannot be converted to JSON.
 */
private String convertMerchantFeeToJson(MerchantFeeDto merchantFeeDto) {
    try {
        return objectMapper.writeValueAsString(merchantFeeDto);
    } catch (JsonProcessingException e) {
        throw new TransactionException(ErrorConstants.INVALID_ERROR_CODE,  
            MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Encrypt request", "Requested data is mismatched."));
    }
}

/**
 * Builds a MerchantFeeDto response object using request and pricing information.
 * @param merchantPricingRequestDto The pricing request details.
 * @param merchantPricingInfo The calculated pricing information.
 * @return A MerchantFeeDto object with populated fee details.
 */
private MerchantFeeDto buildMerchantFeeDto(MerchantPricingRequestDto merchantPricingRequestDto, MerchantPricingInfo merchantPricingInfo) {
    logger.info("Building Merchant Fee response.");
    return MerchantFeeDto.builder()
            .mId(merchantPricingRequestDto.getMId())
            .gtwMapsId(merchantPricingRequestDto.getGtwMapsId())
            .payModeCode(merchantPricingRequestDto.getPayModeCode())
            .payProcType(merchantPricingRequestDto.getPayProcType())
            .merchPostedAmt(merchantPricingRequestDto.getTransactionAmount())
            .atrn(merchantPricingRequestDto.getAtrn())
            .merchantFeeAbs(merchantPricingInfo.getMerchantFeeAbs())
            .otherFeeAbs(merchantPricingInfo.getOtherFeeAbs())
            .gtwFeeAbs(merchantPricingInfo.getGtwFeeAbs())
            .aggServiceFeeAbs(merchantPricingInfo.getAggServiceFeeAb())
            .postAmount(merchantPricingInfo.getPostAmount())
            .customerBearableAmt(merchantPricingInfo.getCustomerBearableAmt())
            .customerBearableServiceTax(merchantPricingInfo.getCustomerBearableServiceTax())
            .merchantBearableAmt(merchantPricingInfo.getMerchantBearableAmt())
            .merchantBearableServiceTax(merchantPricingInfo.getMerchantBearableServiceTax())
            .build();
}

/**
 * Calculates various fees (merchant, other, gateway, aggregator service) based on the given pricing structure.
 * @param pricingStructure The pricing structure details.
 * @param merchPostedAmt The transaction amount.
 * @return A MerchantPricingInfo object containing calculated fees.
 */
private MerchantPricingInfo computeMerchantFees(MerchantPricingResponseDto pricingStructure, BigDecimal merchPostedAmt) {
    logger.info("Fee calculation started.");

    BigDecimal merchantFeeAbs = calculateFee(pricingStructure.getMerchantFeeApplicable(), pricingStructure.getMerchantFeeType(), pricingStructure.getMerchantFee(), merchPostedAmt);
    BigDecimal otherFeeAbs = calculateFee(pricingStructure.getOtherFeeApplicable(), pricingStructure.getOtherFeeType(), pricingStructure.getOtherFee(), merchPostedAmt);
    BigDecimal gtwFeeAbs = calculateFee(pricingStructure.getGtwFeeApplicable(), pricingStructure.getGtwFeeType(), pricingStructure.getGtwFee(), merchPostedAmt);
    BigDecimal aggServiceFeeAbs = calculateFee(pricingStructure.getAggServiceFeeApplicable(), pricingStructure.getAggServiceFeeType(), pricingStructure.getAggServiceFee(), merchPostedAmt);

    return MerchantPricingInfo.builder()
            .merchantFeeAbs(merchantFeeAbs)
            .otherFeeAbs(otherFeeAbs)
            .gtwFeeAbs(gtwFeeAbs)
            .aggServiceFeeAb(aggServiceFeeAbs)
            .build();
}

/**
 * Fetches the merchant pricing structure from an external service.
 * @param merchantPricingRequestDto The request containing merchant pricing details.
 * @return The retrieved MerchantPricingResponseDto object.
 * @throws ValidationException If the response status is a failure.
 */
private MerchantPricingResponseDto fetchMerchantPricingStructure(MerchantPricingRequestDto merchantPricingRequestDto) {
    logger.info("Fetching pricing structure for merchantPricingRequestDto: {}", merchantPricingRequestDto);

    TransactionResponse<MerchantPricingResponseDto> pricingStructureResponse = adminServicesClient.getMerchantPricingStructure(merchantPricingRequestDto);

    if (pricingStructureResponse.getStatus() == ResponseStatus.FAIL.ordinal()) {
        logger.debug("Error in pricingStructureResponse: {}", pricingStructureResponse);
        throw new ValidationException(pricingStructureResponse.getErrors());
    }

    return pricingStructureResponse.getData().getFirst();
}
