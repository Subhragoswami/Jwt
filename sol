package com.epay.merchant.service;

import com.epay.merchant.config.MerchantConfig;
import com.epay.merchant.dao.CaptchaDao;
import com.epay.merchant.entity.Captcha;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.model.request.CaptchaRequest;
import com.epay.merchant.model.response.CaptchaResponse;
import com.epay.merchant.model.response.MerchantResponse;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.validator.CaptchaValidator;
import com.google.code.kaptcha.impl.DefaultKaptcha;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import lombok.RequiredArgsConstructor;
import ma.glasnost.orika.MapperFacade;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.MessageFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import static com.epay.merchant.util.AppConstants.RESPONSE_SUCCESS;

@Service
@RequiredArgsConstructor
public class CaptchaService {

    private final CaptchaDao captchaDao;
    private final DefaultKaptcha captchaProducer;
    private final CaptchaValidator captchaValidator;
    private final MerchantConfig merchantConfig;
    private final MapperFacade orikaMapper;

    LoggerUtility logger = LoggerFactoryUtility.getLogger(CaptchaService.class);

    public MerchantResponse<CaptchaResponse> createCaptcha(CaptchaRequest captchaRequest) {
        logger.info("Starting captcha generation for requestId: {}", captchaRequest.getRequestId());
        captchaValidator.requestValidator(captchaRequest);
        try {
            String captchaText = captchaProducer.createText();
            logger.info("generated captcha text: {}", captchaText);
            BufferedImage image = captchaProducer.createImage(captchaText);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            ImageIO.write(image, "jpg", outputStream);
            String base64Image = Base64.getEncoder().encodeToString(outputStream.toByteArray());
            Captcha captcha = buildCaptcha(base64Image, captchaRequest.getRequestId(), captchaRequest.getRequestType());
            captcha = captchaDao.save(captcha);
            CaptchaResponse captchaResponse = orikaMapper.map(captcha, CaptchaResponse.class);
            return MerchantResponse.<CaptchaResponse>builder()
                    .data(List.of(captchaResponse))
                    .status(RESPONSE_SUCCESS)
                    .count(1L)
                    .total(1L)
                    .build();
        } catch (IOException e) {
            throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE, MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, "Captcha"));
        }
    }

    private Captcha buildCaptcha(String captchaText, UUID requestId, String requestType) {
        return Captcha.builder()
                .captchaImage(captchaText)
                .requestId(requestId)
                .requestType(requestType)
                .expiryTime(LocalDateTime.now().plusMinutes(merchantConfig.getExpiryTime()).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli())
                .build();
    }

}
