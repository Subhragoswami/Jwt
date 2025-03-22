import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URI;

public class BankServiceClient {

    private static final Logger log = LoggerFactory.getLogger(BankServiceClient.class);
    private final WebClient webClient;
    private static final String BANK_ENDPOINT = "/bank";
    private static final String BRANCH_DETAILS_ENDPOINT = "/bank/branch/";

    public BankServiceClient(WebClient webClient) {
        this.webClient = webClient;
    }

    private String getBaseUrl() {
        return "https://example.com/api"; // Replace with actual base URL
    }

    private WebClient getWebClient() {
        return this.webClient;
    }

    /**
     * Fetch bank details using IFSC code
     *
     * @param ifscCode IFSC code of the bank
     * @return MerchantResponse containing BankDetailsResponse
     */
    public MerchantResponse<BankDetailsResponse> getBankDetailsByIfscCode(String ifscCode) {
        URI uri = URI.create(getBaseUrl() + BANK_ENDPOINT + "/" + ifscCode);
        log.info("Fetching bank details for IFSC Code: {}", ifscCode);

        MerchantResponse<BankDetailsResponse> response = getWebClient().get()
                .uri(uri)
                .retrieve()
                .onStatus(
                        httpStatusCode -> httpStatusCode.is4xxClientError() || httpStatusCode.is5xxServerError(),
                        clientResponse -> {
                            log.error("Error fetching bank details for IFSC Code: {}. Status: {}", ifscCode, clientResponse.statusCode());
                            return Mono.error(new MerchantException(ErrorConstants.GENERIC_ERROR_CODE, ErrorConstants.GENERIC_ERROR_MESSAGE));
                        }
                )
                .bodyToMono(new ParameterizedTypeReference<MerchantResponse<BankDetailsResponse>>() {})
                .block();

        log.info("Received bank details for IFSC Code {}: {}", ifscCode, response);
        return response;
    }

    /**
     * Fetch all banks
     *
     * @return MerchantResponse containing a list of BankResponse
     */
    public MerchantResponse<BankResponse> getAllBanks() {
        URI uri = URI.create(getBaseUrl() + BANK_ENDPOINT);
        log.info("Fetching all banks");

        MerchantResponse<BankResponse> response = getWebClient().get()
                .uri(uri)
                .retrieve()
                .onStatus(
                        httpStatusCode -> httpStatusCode.is4xxClientError() || httpStatusCode.is5xxServerError(),
                        clientResponse -> {
                            log.error("Error fetching bank list. Status: {}", clientResponse.statusCode());
                            return Mono.error(new MerchantException(ErrorConstants.GENERIC_ERROR_CODE, ErrorConstants.GENERIC_ERROR_MESSAGE));
                        }
                )
                .bodyToMono(new ParameterizedTypeReference<MerchantResponse<BankResponse>>() {})
                .block();

        log.info("Received bank list: {}", response);
        return response;
    }

    /**
     * Fetch all branches of a specific bank
     *
     * @param bankId ID of the bank
     * @return MerchantResponse containing a list of BranchResponse
     */
    public MerchantResponse<BranchResponse> getAllBranches(String bankId) {
        URI uri = URI.create(getBaseUrl() + BRANCH_DETAILS_ENDPOINT + bankId);
        log.info("Fetching branches for bank ID: {}", bankId);

        MerchantResponse<BranchResponse> response = getWebClient().get()
                .uri(uri)
                .retrieve()
                .onStatus(
                        httpStatusCode -> httpStatusCode.is4xxClientError() || httpStatusCode.is5xxServerError(),
                        clientResponse -> {
                            log.error("Error fetching branches for bank ID: {}. Status: {}", bankId, clientResponse.statusCode());
                            return Mono.error(new MerchantException(ErrorConstants.GENERIC_ERROR_CODE, ErrorConstants.GENERIC_ERROR_MESSAGE));
                        }
                )
                .bodyToMono(new ParameterizedTypeReference<MerchantResponse<BranchResponse>>() {})
                .block();

        log.info("Received branch details for bank ID {}: {}", bankId, response);
        return response;
    }
}
