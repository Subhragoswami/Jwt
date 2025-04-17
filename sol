void validateMerchantUser(OtpGenerationRequest otpGenerationRequest) {
    String requestType = otpGenerationRequest.getRequestType();
    String userName = otpGenerationRequest.getUserName();

    List<UserStatus> allowedStatuses = switch (requestType) {
        case "RESET_PASSWORD" -> List.of(UserStatus.ACTIVE, UserStatus.EXPIRED);
        case "CHANGE_PASSWORD" -> List.of(UserStatus.EXPIRED);
        default -> List.of(UserStatus.ACTIVE);
    };

    boolean merchantUserExists = otpManagementDao.isValidMerchantUserExists(userName, allowedStatuses);

    if (!merchantUserExists) {
        addError("Merchant User", ErrorConstants.NOT_FOUND_ERROR_CODE, ErrorConstants.NOT_FOUND_ERROR_MESSAGE);
    }

    throwIfErrors();
}
