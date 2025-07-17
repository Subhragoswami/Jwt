@Test
void testChangePasswordValidationExceptionWithMandatoryErrorCode() {
    PasswordChangeRequest request = new PasswordChangeRequest();
    request.setUserName("testUser");
    request.setOldPassword("encryptedOldPwd");
    request.setNewPassword("encryptedNewPwd");
    request.setConfirmPassword("encryptedNewPwd");

    ErrorDto mandatoryError = new ErrorDto(MANDATORY_ERROR_CODE, "Mandatory field missing");
    ValidationException validationException = new ValidationException(List.of(mandatoryError));

    // Mock passwordValidator to throw ValidationException
    doThrow(validationException).when(passwordValidator).validateChangePassword(any());

    ValidationException thrown = assertThrows(
            ValidationException.class,
            () -> passwordService.changePassword(request)
    );

    assertEquals(validationException, thrown);
    verify(passwordManagementDao, never()).saveAudit(anyString(), any(), anyBoolean(), anyString());
}


@Test
void testChangePasswordValidationExceptionWithoutMandatoryErrorCode() {
    PasswordChangeRequest request = new PasswordChangeRequest();
    request.setUserName("testUser");
    request.setOldPassword("encryptedOldPwd");
    request.setNewPassword("encryptedNewPwd");
    request.setConfirmPassword("encryptedNewPwd");

    ErrorDto nonMandatoryError = new ErrorDto("SOME_OTHER_ERROR_CODE", "Invalid password format");
    ValidationException validationException = new ValidationException(List.of(nonMandatoryError));

    // Mock passwordValidator to throw ValidationException
    doThrow(validationException).when(passwordValidator).validateChangePassword(any());

    ValidationException thrown = assertThrows(
            ValidationException.class,
            () -> passwordService.changePassword(request)
    );

    assertEquals(validationException, thrown);
    // verify handlePasswordFailure is called
    verify(passwordManagementDao).saveAudit(eq("testUser"), eq(RequestType.CHANGE_PASSWORD), eq(false), anyString());
}


private Object safe(Object value, Object defaultValue) {
    return ObjectUtils.isEmpty(value) ? defaultValue : value;
}

protected List<Object> convertToListOfObject(MerchantPayout merchantPayout) {
    return List.of(
        safe(merchantPayout.getMerchantId(), ""),
        safe(merchantPayout.getMerchantName(), ""),
        safe(merchantPayout.getOrderAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getCurrencyCode(), ""),
        safe(merchantPayout.getSettlementAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getSettlementCurrency(), ""),
        safe(merchantPayout.getCommissionPayable(), BigDecimal.ZERO),
        safe(merchantPayout.getMerchantGstBearableAbs(), BigDecimal.ZERO),
        safe(merchantPayout.getPayoutAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getRefundAdjusted(), BigDecimal.ZERO),
        safe(merchantPayout.getTdrOnRefundAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getGstOnRefundAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getNetRefundAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getNetPayoutAmount(), BigDecimal.ZERO),
        safe(merchantPayout.getPayoutDate(), ""),
        safe(merchantPayout.getTransactionCount(), BigDecimal.ZERO),
        safe(merchantPayout.getChargebackAdjusted(), BigDecimal.ZERO)
    );
}

protected List<Object> convertToListOfObject(TransactionRefund transactionRefund) {
    return List.of(
        safe(transactionRefund.getSettlementFileNumber(), ""),
        safe(transactionRefund.getSettlementTime(), ""),
        safe(transactionRefund.getMerchantId(), ""),
        safe(transactionRefund.getMerchantName(), ""),
        safe(transactionRefund.getOrderRefNumber(), ""),
        safe(transactionRefund.getAtrnNum(), ""),
        safe(transactionRefund.getCreatedDate(), ""),
        safe(transactionRefund.getCurrencyCode(), ""),
        safe(transactionRefund.getOrderAmount(), BigDecimal.ZERO),
        safe(transactionRefund.getRefundCurrency(), ""),
        safe(transactionRefund.getSettlementAmount(), BigDecimal.ZERO),
        safe(transactionRefund.getCommissionPayable(), 0),
        safe(transactionRefund.getMerchantGstBearableAbs(), BigDecimal.ZERO),
        safe(transactionRefund.getNetRefundAmount(), 0),
        safe(transactionRefund.getChannelBank(), ""),
        safe(transactionRefund.getGatewayTraceNumber(), ""),
        safe(transactionRefund.getPayMode(), ""),
        safe(transactionRefund.getRefundType(), ""),
        safe(transactionRefund.getRefundBookingDate(), ""),
        safe(transactionRefund.getArrnNum(), "")
    );
}
