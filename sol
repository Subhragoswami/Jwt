package com.epay.merchant.entity;

import com.epay.merchant.util.enums.RequestType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.GenericGenerator;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;


import java.time.LocalDateTime;
import java.util.Date;
import java.util.UUID;

@Entity
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "captcha_management")
@EntityListeners(AuditingEntityListener.class)
public class Captcha {
    @Id
    @GeneratedValue(generator = "uuid")
    @GenericGenerator(name = "uuid", strategy = "uuid2")
    @Column(unique = true)
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String captchaImage;

    @Column(nullable = false)
    private Long expiryTime;

    @Column(nullable = false, unique = true)
    private UUID requestId;

    @Column(nullable = false)
    private String requestType;

    private boolean isVerified;

    @CreatedDate
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdDate;

    @LastModifiedDate
    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedDate;
}
-- liquibase formatted sql
-- changeset Subhra:1
CREATE TABLE captcha_management (
    id RAW(16) DEFAULT SYS_GUID() PRIMARY KEY NOT NULL,
    captcha_image CLOB NOT NULL,
    expiry_time NUMBER,
    request_id RAW(16) NOT NULL UNIQUE,
    request_type VARCHAR2(255) NOT NULL,
    is_verified NUMBER(1) DEFAULT 0,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);
