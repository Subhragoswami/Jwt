public void validatedMerchantUser(String userName, String requestType) {
    logger.info("Validating merchant user with userName: {}", userName);

    MerchantUserDto merchantUser = merchantUserDao.getByUserNameOrEmailOrMobilePhoneAndStatus(
        userName, userName, userName, List.of(UserStatus.values())
    );

    UserStatus status = merchantUser.getStatus();

    // Validation logic based on request type
    if (RESET_PASSWORD.name.equals(requestType)) {
        if (!(UserStatus.ACTIVE.equals(status) || UserStatus.EXPIRED.equals(status))) {
            logger.info("Merchant user fetched with status: {}", status);
            throw new MerchantException(
                ErrorConstants.INVALID_ERROR_CODE,
                MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Merchant user status", "User is " + status)
            );
        }
    } else {
        if (!UserStatus.ACTIVE.equals(status)) {
            logger.info("Merchant user fetched with status: {}", status);
            throw new MerchantException(
                ErrorConstants.INVALID_ERROR_CODE,
                MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Merchant user status", "User is " + status)
            );
        }
    }

    // First login check
    if (merchantUser.isFirstLogin()) {
        logger.info("Merchant user fetched with firstLogin flag, id: {}", merchantUser.getId());
        throw new MerchantException(ErrorConstants.FIRST_LOGIN_ERROR_CODE, ErrorConstants.FIRST_LOGIN_ERROR_MESSAGE);
    }

    logger.info("Merchant user validated successfully for userName: {}", userName);
}
