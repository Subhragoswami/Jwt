@RestController
@RequestMapping("/user")
@Slf4j
public class ValidationController {

    private final ValidationService validationService;
    private final ValidationValidator validationValidator;
    private final CaptchaValidator captchaValidator;

    public ValidationController(ValidationService validationService, ValidationValidator validationValidator, CaptchaValidator captchaValidator) {
        this.validationService = validationService;
        this.validationValidator = validationValidator;
        this.captchaValidator = captchaValidator;
    }

    /**
     * Merchant User with Validation during Login.
     * This endpoint validates the merchant user and checks captcha during login.
     *
     * @param userCaptchaValidationRequest The request object containing user details and captcha.
     * @return A MerchantResponse containing the result of the validation.
     */
    @PostMapping("/captcha")
    @Operation(summary = "Merchant User with Validation during Login",
            description = "Merchant User and captcha Validation during Login via userName, Email, or MobileNumber fields")
    public MerchantResponse<String> validateUserWithCaptcha(@Valid @RequestBody UserCaptchaValidationRequest userCaptchaValidationRequest) {
        log.info("Received request for User Validation: {}", userCaptchaValidationRequest);
        return validationService.validateUserWithCaptcha(userCaptchaValidationRequest);
    }

    /**
     * Validates the merchant user and captcha.
     *
     * @param userCaptchaValidationRequest The request object containing user details and captcha.
     * @return A MerchantResponse containing the validation result.
     */
    public MerchantResponse<String> validateUserWithCaptcha(UserCaptchaValidationRequest userCaptchaValidationRequest) {
        log.info("Validating user request for user: {}", userCaptchaValidationRequest.getUserName());
        validationValidator.validateUserCaptchaValidationRequest(userCaptchaValidationRequest);
        return buildSuccessResponse(USER_VALIDATED);
    }

    /**
     * Performs validation for user and captcha details.
     *
     * @param userCaptchaValidationRequest The request object containing user details and captcha.
     */
    public void validateUserCaptchaValidationRequest(UserCaptchaValidationRequest userCaptchaValidationRequest) {
        log.debug("Starting validation for {}", userCaptchaValidationRequest);
        List<ErrorDto> errorDtoList = new ArrayList<>();
        validateRequestType(userCaptchaValidationRequest.getRequestType());
        validatedMerchantUser(userCaptchaValidationRequest.getUserName());
        captchaValidator.captchaValueValidation(userCaptchaValidationRequest.getRequestId(), userCaptchaValidationRequest.getCaptchaText());
    }

    /**
     * Validates both the access to the merchant ID (MID) and checks if the MID is active.
     * This method ensures that the logged-in user has access to the MID and that the MID is in an active state.
     *
     * @param userName The username of the logged-in user.
     * @param mId      The merchant ID to check for access and active status.
     * @return A MerchantResponse containing the result of the access validation and active status check.
     */
    @GetMapping("/access/active/{userName}/{mId}")
    @Operation(summary = "Merchant User MID Access validation and Check MID is Active or not for Logged in User")
    public MerchantResponse<String> validateActiveMIdAccess(
            @Parameter(description = "Username of the logged-in user", required = true) @PathVariable String userName,
            @Parameter(description = "MID of the merchant to be validated and checked for active status", required = true) @PathVariable String mId) {
        log.info("Received request for MID access validation and active status for user: {}, MID: {}", userName, mId);
        return validationService.validateActiveMId(userName, mId);
    }

    private MerchantResponse<String> buildSuccessResponse(String message) {
        return new MerchantResponse<>(message, "SUCCESS");
    }
}
