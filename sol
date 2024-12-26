package com.epay.merchant.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

/**
 * Class Name: UserMenuPermission
 * *
 * Description:
 * *
 * Author: Bhoopendra Rajput
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */
@EqualsAndHashCode(callSuper = true)
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "USER_MENU_PERMISSION")
public class UserMenuPermission extends AuditEntityByDate {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(nullable = false, updatable = false, unique = true)
    private UUID id;
    private UUID permissionId;
    private UUID userId;
    private UUID menuId;

}
