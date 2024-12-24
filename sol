  /**
     * Fetches all merchant information with pagination
     */
    public MerchantResponse<MerchantInfoResponse> getAllMerchantInfo(Pageable pageable) {
        log.info("Fetching all merchant information");
        Page<MerchantInfoDto> merchantInfo = merchantInfoDao.getALl(pageable);
        log.info("Fetched MerchantInfoDto page");
        //Mapping DTO to Response Object
        List<MerchantInfoResponse> merchantInfoResponseList = merchantMapper.mapMerchantInfoDTOListToResponseList(merchantInfo.getContent());
        //Building the response
        return MerchantResponse.<MerchantInfoResponse>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(merchantInfoResponseList).count(merchantInfo.stream().count()).total(merchantInfo.getTotalElements()).build();
    }

    /**
     * Method to handle the password change logic
     */
    public MerchantResponse<String> changePassword(PasswordChangeRequest passwordChangeRequest){
        log.info("Starting password change process for user: {}", passwordChangeRequest.getUserName());
        passwordValidator.validatePasswordChangeRequest(passwordChangeRequest);
        log.info("Password change request validated successfully");
        //TODO: DECRYPTION and ENCRYPTION of passwords
        merchantInfoDao.updatePasswordDetails(passwordChangeRequest);
        //TODO: Send sms and email for password change
        return MerchantResponse.<String>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(List.of("Password Changed Successfully")).count(1L).total(1L).build();
    }
