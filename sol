 MerchantEntityGroup entityGroup = adminDao.findMidbyEntityId(userEntityMappingRequest.getEntityId());
package com.epay.merchant.entity;

/*
 * Class Name: MerchantEntityGroup
 * *
 * Description:
 * *
 * Author: V1018344
 * Copyright (c) 2024 [State Bank of India]
 * ALl rights reserved
 * *
 * Version: 1.0
 */


import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;


@EqualsAndHashCode(callSuper = true)
@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Builder
@Table(name = "merchant_entity_group")
public class MerchantEntityGroup extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(name = "MID")
    private String mId;
    private String entityId;

}

