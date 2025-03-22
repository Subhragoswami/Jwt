import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
     * Get all banks
     *
     * @return MerchantResponse containing the list of all banks
     */
    @GetMapping("/bank")
    public MerchantResponse<BankResponse> getAllBanks() {
        log.info("Received request to fetch all banks");
        MerchantResponse<BankResponse> response = adminService.getAllBanks();
        log.info("Returning response with all banks: {}", response);
        return response;
    }

    /**
     * Get all branches of a bank
     *
     * @param bankId ID of the bank
     * @return MerchantResponse containing the list of branches
     */
    @GetMapping("/bank/branch/{bankId}")
    public MerchantResponse<BranchResponse> getAllBranches(@PathVariable String bankId) {
        log.info("Received request to fetch all branches for bank ID: {}", bankId);
        MerchantResponse<BranchResponse> response = adminService.getAllBranches(bankId);
        log.info("Returning response with all branches: {}", response);
        return response;
    }

    /**
     * Service method to fetch all banks
     *
     * @return MerchantResponse containing the list of all banks
     */
    public MerchantResponse<BankResponse> getAllBanksFromService() {
        log.info("Fetching all banks from DAO");
        List<BankResponse> bankResponse = adminDao.getAllBanks();
        log.info("Fetched all banks: {}", bankResponse);
        return MerchantResponse.<BankResponse>builder().data(bankResponse).build();
    }

    /**
     * Service method to fetch all branches of a bank
     *
     * @param bankId ID of the bank
     * @return MerchantResponse containing the list of branches
     */
    public MerchantResponse<BranchResponse> getAllBranchesFromService(String bankId) {
        log.info("Fetching all branches from DAO for bank ID: {}", bankId);
        List<BranchResponse> branchResponse = adminDao.getAllBranches(bankId);
        log.info("Fetched branches: {}", branchResponse);
        return MerchantResponse.<BranchResponse>builder().data(branchResponse).build();
    }

    /**
     * Fetch all banks using external service client
     *
     * @return List of BankResponse
     */
    public List<BankResponse> fetchAllBanksFromExternalService() {
        log.info("Fetching all banks from external service");
        List<BankResponse> response = adminServicesClient.getAllBanks().getData();
        log.info("Received bank details from external service: {}", response);
        return response;
    }

    /**
     * Fetch all branches of a bank using external service client
     *
     * @param bankId ID of the bank
     * @return List of BranchResponse
     */
    public List<BranchResponse> fetchAllBranchesFromExternalService(String bankId) {
        log.info("Fetching all branches for bank ID {} from external service", bankId);
        List<BranchResponse> response = adminServicesClient.getAllBranches(bankId).getData();
        log.info("Received branch details from external service: {}", response);
        return response;
    }
}
