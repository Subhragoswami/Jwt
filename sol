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





