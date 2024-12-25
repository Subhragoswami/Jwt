else if(PasswordManagementType.RESET_PASSWORD.name().equals(type) && !MerchantStatus.EXPIRED.name().equals(status) || !MerchantStatus.ACTIVE.name().equals(status)) {
             {
                errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Status", "Reason : status must be active or expired")).build());
            }
