
    private void validateMandatoryFields(UserEntityMappingRequest userEntityMappingRequest){
        checkMandatoryField(userEntityMappingRequest.getEntityId(), "entity Id");
        checkMandatoryField(userEntityMappingRequest.getUserName(), "user name");
        checkMandatoryField(String.valueOf(userEntityMappingRequest.getUserId()), "user Id");
    }

package com.epay.merchant.model.request;

import lombok.*;

import java.util.UUID;

@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
@NoArgsConstructor
public class UserEntityMappingRequest {
    private UUID userId;
    private String userName;
    private String entityId;
}

    @PostMapping("/entity/mapping")
    public MerchantResponse<String> mapEntity(@RequestBody UserEntityMappingRequest userEntityMappingRequest){
        return adminService.mapEntity(userEntityMappingRequest);
    }
