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




..............




  /**
     * Generates and saves a captcha, then returns the response.
     */
    public MerchantResponse<CaptchaResponse> generateCaptcha(CaptchaRequest captchaRequest) {
        //Step 1 : Validate Captcha Request
        captchaValidator.requestValidator(captchaRequest);
        RequestType requestType = RequestType.getRequestType(captchaRequest.getRequestType());
        //Step 2 : Generate Captcha Image and convert into Base 64
        String base64Image = generateCaptchaImage();
        //Step 3 : Save the Captcha into DB
        CaptchaDto captchaDto = captchaDao.save(base64Image, captchaRequest.getRequestId(), requestType);
        //Step 4 : Build the Merchant Response
        return MerchantResponse.<CaptchaResponse>builder().data(List.of(captchaMapper.mapCaptchaDtoToCaptchaResponse(captchaDto))).status(RESPONSE_SUCCESS).build();
    }
