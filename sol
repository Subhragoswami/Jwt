  private void validStatusCheck(String status, String type) {
        log.info("Validating status");
        if(type.equals(String.valueOf(PasswordManagementType.CHANGE_PASSWORD))) {
            if (!status.equals(String.valueOf(MerchantStatus.EXPIRED))) {
                errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Status", "Reason : status is not valid for changing password")).build());
            }
            throwIfErrors();
        }else if(type.equals(String.valueOf(PasswordManagementType.RESET_PASSWORD))) {
            if (!status.equals(String.valueOf(MerchantStatus.ACTIVE)) || !status.equals(String.valueOf(MerchantStatus.EXPIRED))) {
                errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Status", "Reason : status is not valid for changing password")).build());
            }
            throwIfErrors();
        }
    }
