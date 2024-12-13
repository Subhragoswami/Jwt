import com.google.code.kaptcha.impl.DefaultKaptcha;
import com.google.code.kaptcha.util.Config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Properties;

@Configuration
public class CaptchaConfig {

    @Bean
    public DefaultKaptcha captchaProducer() {
        DefaultKaptcha captcha = new DefaultKaptcha();
        Properties properties = new Properties();

        properties.setProperty("kaptcha.border", "no");
        properties.setProperty("kaptcha.textproducer.font.color", "black");
        properties.setProperty("kaptcha.textproducer.char.space", "5");
        properties.setProperty("kaptcha.image.width", "200");
        properties.setProperty("kaptcha.image.height", "50");
        properties.setProperty("kaptcha.textproducer.font.size", "40");
        properties.setProperty("kaptcha.textproducer.char.length", "6");

        Config config = new Config(properties);
        captcha.setConfig(config);

        return captcha;
    }
}

.……


import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface CaptchaRepository extends JpaRepository<Captcha, UUID> {
    Optional<Captcha> findByRequestId(String requestId);
}

......


import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
public class Captcha {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private String captchaText;

    @Column(nullable = false)
    private LocalDateTime expiryTime;

    @Column(nullable = false, unique = true)
    private String requestId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestType requestType;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // Getters and setters
    // Constructor
}



.......


import com.google.code.kaptcha.impl.DefaultKaptcha;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.UUID;

@Service
public class CaptchaService {

    @Autowired
    private DefaultKaptcha captchaProducer;

    @Autowired
    private CaptchaRepository captchaRepository;

    public CaptchaResponse generateCaptcha(String requestId, RequestType requestType) throws Exception {
        // Generate Captcha Text
        String captchaText = captchaProducer.createText();

        // Generate Captcha Image
        BufferedImage image = captchaProducer.createImage(captchaText);

        // Convert image to Base64
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        ImageIO.write(image, "jpg", outputStream);
        String base64Image = Base64.getEncoder().encodeToString(outputStream.toByteArray());

        // Save to database
        Captcha captcha = new Captcha();
        captcha.setCaptchaText(captchaText);
        captcha.setRequestId(requestId);
        captcha.setRequestType(requestType);
        captcha.setExpiryTime(LocalDateTime.now().plusMinutes(5));
        captcha.setCreatedAt(LocalDateTime.now());

        captchaRepository.save(captcha);

        return new CaptchaResponse(
                captcha.getId(),
                base64Image,
                captcha.getExpiryTime()
        );
    }
}



.......




import java.time.LocalDateTime;
import java.util.UUID;

public class CaptchaResponse {
    private UUID id;
    private String captchaImage;
    private LocalDateTime expiryTime;

    // Constructor, Getters, Setters
}



.......


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/merchant")
public class CaptchaController {

    @Autowired
    private CaptchaService captchaService;

    @PostMapping("/captcha")
    public ResponseEntity<?> createCaptcha(@RequestBody CaptchaRequest request) {
        try {
            // Validate request
            if (request.getRequestId() == null || request.getRequestType() == null) {
                return ResponseEntity.badRequest().body(new ErrorResponse("INVALID_INPUT", "Both fields are mandatory."));
            }

            // Generate Captcha
            CaptchaResponse response = captchaService.generateCaptcha(request.getRequestId(), request.getRequestType());

            return ResponseEntity.ok().body(new SuccessResponse(response));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(new ErrorResponse("SERVER_ERROR", e.getMessage()));
        }
    }
}



........




public class CaptchaRequest {
    private String requestId;
    private RequestType requestType;

    // Getters and Setters
}



.....

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

    @Column(nullable = false)
    private String captchaText;

    @Column(nullable = false)
    private LocalDateTime expiryTime;

    @Column(nullable = false, unique = true)
    private UUID requestId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestType requestType;

    private boolean isVerified;

    @CreatedDate
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdDate;

    @LastModifiedDate
    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedDate;
}
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS PUBLIC.Users(
        id UUID NOT NULL DEFAULT UUID_GENERATE_V4(),
        created_at TIMESTAMP WITHOUT TIME ZONE,
        updated_at TIMESTAMP WITHOUT TIME ZONE,
        event_code VARCHAR NOT NULL,
        first_name VARCHAR NOT NULL,
        last_name VARCHAR NOT NULL,
        user_email VARCHAR NOT NULL,
        is_active BOOLEAN DEFAULT true,
        rules_opt_in BOOLEAN ,
        consent_to_contact BOOLEAN ,
        mktg_email_consent BOOLEAN ,
        email_received_at TIMESTAMP WITHOUT TIME ZONE,
        CONSTRAINT user_id_PK PRIMARY KEY(ID)
);

CREATE TABLE IF NOT EXISTS PUBLIC.Event(
        id UUID NOT NULL DEFAULT UUID_GENERATE_V4(),
        created_at TIMESTAMP WITHOUT TIME ZONE,
        updated_at TIMESTAMP WITHOUT TIME ZONE,
        event_name VARCHAR,
        zone VARCHAR NOT NULL,
        general_office VARCHAR NOT NULL,
        event_code VARCHAR NOT NULL,
        event_location VARCHAR,
        event_start_date TIMESTAMP WITHOUT TIME ZONE,
        event_end_date TIMESTAMP WITHOUT TIME ZONE,
        CONSTRAINT event_id_PK PRIMARY KEY(ID)
);
..,??):₹₹.):):!!:.!!.!:!:!.!:
snshsjd



.....
..

....




-- liquibase formatted sql

-- ChangeSet author:your_name date:2024-06-13
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS PUBLIC.captcha_management (
    id UUID NOT NULL DEFAULT uuid_generate_v4(),
    captcha_text VARCHAR NOT NULL,
    expiry_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    request_id UUID NOT NULL UNIQUE,
    request_type VARCHAR NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    created_date TIMESTAMP WITHOUT TIME ZONE,
    updated_date TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT captcha_management_pk PRIMARY KEY (id)
);

-- Add comments or constraints (optional)
COMMENT ON TABLE PUBLIC.captcha_management IS 'Table for Captcha Management';
COMMENT ON COLUMN PUBLIC.captcha_management.id IS 'Primary key UUID';
COMMENT ON COLUMN PUBLIC.captcha_management.captcha_text IS 'Text for the captcha';
COMMENT ON COLUMN PUBLIC.captcha_management.expiry_time IS 'Expiry time of the captcha';
COMMENT ON COLUMN PUBLIC.captcha_management.request_id IS 'Unique request ID for identifying captcha';
COMMENT ON COLUMN PUBLIC.captcha_management.request_type IS 'Type of request for captcha';
COMMENT ON COLUMN PUBLIC.captcha_management.is_verified IS 'Flag indicating if captcha is verified';
COMMENT ON COLUMN PUBLIC.captcha_management.created_date IS 'Timestamp when the captcha record is created';
COMMENT ON COLUMN PUBLIC.captcha_management.updated_date IS 'Timestamp when the captcha record is last updated';


