

public void validatedMerchantUser(String userName, String requestType) {
    logger.info("Validating merchant user with userName: {}", userName);

    MerchantUserDto merchantUser = merchantUserDao.getByUserNameOrEmailOrMobilePhoneAndStatus(
        userName, userName, userName, List.of(UserStatus.values())
    );

    UserStatus status = merchantUser.getStatus();

    // Determine valid statuses based on request type
    List<UserStatus> allowedStatuses = RESET_PASSWORD.name.equals(requestType)
        ? List.of(UserStatus.ACTIVE, UserStatus.EXPIRED)
        : List.of(UserStatus.ACTIVE);

    // Validate user status
    if (!allowedStatuses.contains(status)) {
        logger.info("Merchant user fetched with status: {}", status);
        throw new MerchantException(
            ErrorConstants.INVALID_ERROR_CODE,
            MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Merchant user status", "User is " + status)
        );
    }

    // First login check
    if (merchantUser.isFirstLogin()) {
        logger.info("Merchant user fetched with firstLogin flag, id: {}", merchantUser.getId());
        throw new MerchantException(ErrorConstants.FIRST_LOGIN_ERROR_CODE, ErrorConstants.FIRST_LOGIN_ERROR_MESSAGE);
    }

    logger.info("Merchant user validated successfully for userName: {}", userName);
}