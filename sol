import com.epay.merchant.config.MerchantConfig;
import com.epay.merchant.dao.CaptchaDao;
import com.epay.merchant.dto.CaptchaDto;
import com.epay.merchant.entity.CaptchaManagement;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.mapper.CaptchaMapper;
import com.epay.merchant.repository.CaptchaManagementRepository;
import com.epay.merchant.util.DateTimeUtils;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.enums.RequestType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.text.MessageFormat;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CaptchaDaoTest {

    @Mock
    private MerchantConfig merchantConfig;

    @Mock
    private CaptchaMapper captchaMapper;

    @Mock
    private CaptchaManagementRepository captchaManagementRepository;

    @InjectMocks
    private CaptchaDao captchaDao;

    private UUID requestId;
    private CaptchaManagement captchaManagement;

    @BeforeEach
    void setUp() {
        requestId = UUID.randomUUID();
        captchaManagement = new CaptchaManagement();
        captchaManagement.setId("123");
        captchaManagement.setRequestId(requestId.toString());
        captchaManagement.setVerified(false);
        captchaManagement.setCaptchaText("hashed_text");
        captchaManagement.setExpiryTime(System.currentTimeMillis() + 60000);
        captchaManagement.setCreatedAt(System.currentTimeMillis());
    }

    @Test
    void testExistsByRequestId_WhenExists() {
        when(captchaManagementRepository.existsByRequestId(requestId.toString()))
                .thenReturn(Optional.of(true));

        assertTrue(captchaDao.existsByRequestId(requestId));
        verify(captchaManagementRepository, times(1)).existsByRequestId(requestId.toString());
    }

    @Test
    void testExistsByRequestId_WhenNotExists() {
        when(captchaManagementRepository.existsByRequestId(requestId.toString()))
                .thenReturn(Optional.empty());

        assertFalse(captchaDao.existsByRequestId(requestId));
    }

    @Test
    void testExistByRequestIdAndVerified_WhenVerifiedExists() {
        when(captchaManagementRepository.existsByRequestIdAndVerifiedTrue(requestId.toString()))
                .thenReturn(Optional.of(true));

        assertTrue(captchaDao.existByRequestIdAndVerified(requestId));
        verify(captchaManagementRepository, times(1))
                .existsByRequestIdAndVerifiedTrue(requestId.toString());
    }

    @Test
    void testExistByRequestIdAndVerified_WhenVerifiedNotExists() {
        when(captchaManagementRepository.existsByRequestIdAndVerifiedTrue(requestId.toString()))
                .thenReturn(Optional.empty());

        assertFalse(captchaDao.existByRequestIdAndVerified(requestId));
    }

    @Test
    void testSave_NewCaptcha() {
        when(merchantConfig.getExpiryTime()).thenReturn(10);
        when(captchaManagementRepository.save(any(CaptchaManagement.class))).thenReturn(captchaManagement);
        when(captchaMapper.mapCaptchaEntityToCaptchaDto(any(CaptchaManagement.class)))
                .thenReturn(new CaptchaDto());

        CaptchaDto result = captchaDao.save("testCaptcha", requestId, RequestType.LOGIN, false);

        assertNotNull(result);
        verify(captchaManagementRepository, times(1)).save(any(CaptchaManagement.class));
    }

    @Test
    void testSave_WithRetry() {
        when(captchaManagementRepository.findActiveCaptcha(requestId.toString(), System.currentTimeMillis()))
                .thenReturn(Optional.of(captchaManagement));
        when(captchaManagementRepository.save(any(CaptchaManagement.class))).thenReturn(captchaManagement);
        when(merchantConfig.getExpiryTime()).thenReturn(10);
        when(captchaMapper.mapCaptchaEntityToCaptchaDto(any(CaptchaManagement.class)))
                .thenReturn(new CaptchaDto());

        CaptchaDto result = captchaDao.save("testCaptcha", requestId, RequestType.LOGIN, true);

        assertNotNull(result);
        verify(captchaManagementRepository, times(2)).save(any(CaptchaManagement.class)); 
    }

    @Test
    void testGetActiveCaptchaByRequestId_WhenCaptchaExists() {
        when(captchaManagementRepository.findActiveCaptcha(requestId.toString(), System.currentTimeMillis()))
                .thenReturn(Optional.of(captchaManagement));

        CaptchaManagement result = captchaDao.getActiveCaptchaByRequestId(requestId);

        assertNotNull(result);
        assertEquals(requestId.toString(), result.getRequestId());
        verify(captchaManagementRepository, times(1)).findActiveCaptcha(anyString(), anyLong());
    }

    @Test
    void testGetActiveCaptchaByRequestId_WhenCaptchaNotExists() {
        when(captchaManagementRepository.findActiveCaptcha(requestId.toString(), System.currentTimeMillis()))
                .thenReturn(Optional.empty());

        MerchantException exception = assertThrows(MerchantException.class, () -> 
            captchaDao.getActiveCaptchaByRequestId(requestId)
        );

        assertEquals(ErrorConstants.INVALID_ERROR_CODE, exception.getErrorCode());
        assertEquals(
            MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "Captcha.", "Captcha Expired, Invalid Request"),
            exception.getMessage()
        );
    }

    @Test
    void testSave_CaptchaEntity() {
        captchaDao.save(captchaManagement);
        verify(captchaManagementRepository, times(1)).save(captchaManagement);
    }
}
