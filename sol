 @PostMapping("/password/change")
    @Operation(summary = "changing password for specific user.", description = "changing password for specific user.")
    public MerchantResponse<String> changePassword(@RequestBody PasswordChangeRequest passwordChangeRequest){
        return merchantService.changePassword(passwordChangeRequest);
    }

    public MerchantResponse<String> changePassword(PasswordChangeRequest passwordChangeRequest){
        passwordValidator.validatePasswordChangeRequest(passwordChangeRequest);
        //TODO: DECRYPTION and ENCRYPTION of passwords
        merchantInfoDao.updatePasswordDetails(passwordChangeRequest);
        //TODO: Send sms and email for password change
        return MerchantResponse.<String>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(List.of("Password Changed Successfully")).count(1L).total(1L).build();
    }
