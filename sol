
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/admin")
public class AdminController {

    private static final Logger log = LoggerFactory.getLogger(AdminController.class);
    private final AdminService adminService;
    private final AdminDao adminDao;
    private final AdminServicesClient adminServicesClient;

    public AdminController(AdminService adminService, AdminDao adminDao, AdminServicesClient adminServicesClient) {
        this.adminService = adminService;
        this.adminDao = adminDao;
        this.adminServicesClient = adminServicesClient;
    }

    /**
     * Get bank details by IFSC Code
     *
     * @param ifscCode IFSC Code of the bank
     * @return MerchantResponse with bank details
     */
    @GetMapping("/bank/{ifscCode}")
    public MerchantResponse<BankDetailsResponse> getBankDetailsByIfscCode(@PathVariable String ifscCode) {
        log.info("Received request to get bank details for IFSC Code: {}", ifscCode);
        MerchantResponse<BankDetailsResponse> response = adminService.getBankDetailsByIfscCode(ifscCode);
        log.info("Returning bank details response: {}", response);
        return response;
    }

    /**
     * Service method to fetch bank details by IFSC Code
     *
     * @param ifscCode IFSC Code of the bank
     * @return MerchantResponse with bank details
     */
    public MerchantResponse<BankDetailsResponse> getBankDetailsByIfscCode(String ifscCode) {
        log.info("Fetching bank details from DAO for IFSC Code: {}", ifscCode);
        BankDetailsResponse bankDetailsResponse = adminDao.getBankDetailsByIfscCode(ifscCode);
        log.info("Fetched bank details: {}", bankDetailsResponse);
        return MerchantResponse.<BankDetailsResponse>builder().data(List.of(bankDetailsResponse)).build();
    }

    /**
     * Fetch bank details using external service client
     *
     * @param ifsc IFSC Code of the bank
     * @return BankDetailsResponse
     */
    public BankDetailsResponse getBankDetailsByIfscCode(String ifsc) {
        log.info("Fetching bank details from external service for IFSC Code: {}", ifsc);
        BankDetailsResponse response = adminServicesClient.getBankDetailsByIfscCode(ifsc).getData().getFirst();
        log.info("Received bank details from external service: {}", response);
        return response;
    }

    /**
     * Approve Bank Account
     *
     * @param bankAccountApprovalRequest MerchantBankAccountApprovalRequest
     * @return MerchantResponse with approval status
     * Description - Merchant will use this API to approve a bank account
     */
    @PutMapping("/bank/approval")
    @Operation(summary = "Update Bank Account")
    public MerchantResponse<String> approvedBankAccount(@Valid @RequestBody MerchantBankAccountApprovalRequest bankAccountApprovalRequest) {
        log.info("Received request to approve bank account: {}", bankAccountApprovalRequest);
        MerchantResponse<String> response = adminService.approvedBankAccount(bankAccountApprovalRequest);
        log.info("Returning approved bank account response: {}", response);
        return response;
    }

    /**
     * Map a user to an entity.
     * Destination: AdminDao.updateUserRole
     *
     * @param userEntityMappingRequest UserEntityMappingRequest
     * @return MerchantResponse with mapping status
     */
    public MerchantResponse<String> userEntityMapping(UserEntityMappingRequest userEntityMappingRequest) {
        log.info("Received request to map entity with details: {}", userEntityMappingRequest);

        // Step 1: Validate the request
        adminValidator.userEntityRequestValidator(userEntityMappingRequest);

        // Step 2: Perform action based on user role
        adminDao.updateUserRole(
                userEntityMappingRequest.getUserId(),
                userEntityMappingRequest.getUserName(),
                userEntityMappingRequest.getEntityId()
        );

        // Step 3: Build and return the response
        MerchantResponse<String> response = MerchantResponse.<String>builder()
                .status(MerchantConstant.RESPONSE_SUCCESS)
                .data(List.of("Role has been updated successfully"))
                .count(1L)
                .total(1L)
                .build();

        log.info("Returning merchant success response: {}", response);
        return response;
    }
}
