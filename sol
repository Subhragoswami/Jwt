/**
 * Class Name: MerchantOrderHybridFeeDao
 * 
 * Description: This DAO class is responsible for persisting merchant order hybrid fee details 
 *              into the database. It interacts with the repository to save pricing-related information.
 * 
 * Author: NIRMAL GURJAR
 * 
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved.
 * 
 * Version: 1.0
 */

@Component
@RequiredArgsConstructor
public class MerchantOrderHybridFeeDao {

    private final LoggerUtility logger = LoggerFactoryUtility.getLogger(this.getClass());

    private final MerchantOrderHybridFeeRepository merchantOrderHybridFeeRepository;

    /**
     * Saves merchant order hybrid fee details to the database.
     * 
     * @param merchantPricingRequestDto The request DTO containing merchant pricing details.
     * @param merchantPricingInfo The calculated merchant pricing information.
     * @param pricingStructure The pricing structure associated with the merchant.
     */
    public void savePricingInfo(MerchantPricingRequestDto merchantPricingRequestDto, 
                                MerchantPricingInfo merchantPricingInfo, 
                                MerchantPricingResponseDto pricingStructure) {
        logger.info("Saving Merchant Order Hybrid Fee.");

        merchantOrderHybridFeeRepository.save(
            MerchantOrderHybridFee.builder()
                .atrn(merchantPricingRequestDto.getAtrn())
                .mId(merchantPricingRequestDto.getMId())
                .bearableEntity(pricingStructure.getBearableEntity())
                .bearableComponent(pricingStructure.getBearableComponent())
                .bearableAmountCutoff(merchantPricingInfo.getBearableCutOffAmt())
                .bearableRateType(pricingStructure.getBearableType())
                .bearablePercentageRate(pricingStructure.getBearablePercentageRate())
                .bearableFlatRate(pricingStructure.getBearableFlatRate())
                .merchantFeeBearableAbs(merchantPricingInfo.getMerchantBearableAmt())
                .customerFeeBearableAbs(merchantPricingInfo.getCustomerBearableAmt())
                .merchantStBearableAbs(merchantPricingInfo.getMerchantBearableServiceTax())
                .customerStBearableAbs(merchantPricingInfo.getCustomerBearableServiceTax())
                .bearableLimit(pricingStructure.getBearableLimit())
                .createDate(new Date())
                .createdBy("1")  // TODO: Replace hardcoded values with dynamic user ID
                .createdBySessionId("1") // TODO: Replace with actual session ID
                .processFlag(pricingStructure.getProcessFlag())
                .build()
        );
    }
}
