package com.epay.merchant.service;

import com.epay.merchant.dao.CaptchaDao;
import com.epay.merchant.entity.Captcha;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.model.request.CaptchaRequest;
import com.epay.merchant.model.response.CaptchaResponse;
import com.epay.merchant.model.response.ResponseDto;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.enums.RequestType;
import com.epay.merchant.validator.CaptchaValidator;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.code.kaptcha.impl.DefaultKaptcha;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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

    private final ObjectMapper mapper;

    private final DefaultKaptcha captchaProducer;

    private final CaptchaValidator captchaValidator;

    LoggerUtility logger = LoggerFactoryUtility.getLogger(CaptchaService.class);

    public ResponseDto<CaptchaResponse> createCaptcha(CaptchaRequest captchaRequest) {
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
            CaptchaResponse captchaResponse = mapper.convertValue(captcha, CaptchaResponse.class);
            return ResponseDto.<CaptchaResponse>builder()
                    .data(List.of(captchaResponse))
                    .status(RESPONSE_SUCCESS)
                    .count(1L)
                    .total(1L)
                    .build();
        } catch (Exception e) {
            throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE, MessageFormat.format(ErrorConstants.GENERATION_ERROR_MESSAGE, "Captcha"));
        }
    }

    private Captcha buildCaptcha(String captchaText, UUID requestId, String requestType) {
        Captcha captcha = new Captcha();
        captcha.setCaptchaImage(captchaText);
        captcha.setRequestId(requestId);
        captcha.setRequestType(requestType);
        captcha.setExpiryTime(LocalDateTime.now().plusMinutes(5).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
        return captcha;
    }

}



..........


use builder and service should have DTO reference only

Please read expiry time from application.properties

and use orikamapper for mapping don't use objectMapper

.................


package com.continuum.cms.mapper;

import com.continuum.cms.entity.VendorPreference;
import com.continuum.cms.model.request.PreferenceDetailsRequest;
import ma.glasnost.orika.MapperFactory;
import ma.glasnost.orika.impl.DefaultMapperFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class VendorPreferenceMapper {

    private final MapperFactory mapperFactory;

    @Autowired
    public VendorPreferenceMapper() {
        this.mapperFactory = new DefaultMapperFactory.Builder().build();
        configureMapper();
    }

    private void configureMapper() {
        mapperFactory.classMap(PreferenceDetailsRequest.class, VendorPreference.class)
                .byDefault()
                .register();
    }

    public <T> T mapPreferenceDetailsToVendorPreference(Object source, Class<T> targetType) {
        return mapperFactory.getMapperFacade().map(source, targetType);
    }
}

