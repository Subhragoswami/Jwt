package com.epay.merchant.service;

import com.epay.merchant.dao.KeyDao;
import com.epay.merchant.document.pdf.PDFService;
import com.epay.merchant.externalservice.response.KMSAPIKeysResponse;
import com.epay.merchant.model.request.KeyGenerationRequest;
import com.epay.merchant.util.MerchantConstant;
import com.epay.merchant.util.PasswordGenerator;
import com.epay.merchant.util.enums.KeyType;
import com.epay.merchant.validator.KeyValidator;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class KeyServiceTest {

    @Mock
    private KeyDao keyDao;

    @Mock
    private PasswordGenerator passwordGenerator;

    @Mock
    private PDFService pdfService;

    @Mock
    private KeyValidator keyValidator;

    @InjectMocks
    private KeyService keyService;

    private LoggerUtility logger = LoggerFactoryUtility.getLogger(KeyService.class);

    private KeyGenerationRequest keyGenerationRequest;
    private KMSAPIKeysResponse kmsapiKeysResponse;
    private UUID keyId;

    @BeforeEach
    void setUp() {
        keyGenerationRequest = KeyGenerationRequest.builder()
                .mId("MID12345")
                .oldKeyExpiryInHr(24)
                .build();

        keyId = UUID.randomUUID();

        kmsapiKeysResponse = new KMSAPIKeysResponse();
        kmsapiKeysResponse.setApiKey("testApiKey");
        kmsapiKeysResponse.setApiKeySecret("testApiKeySecret");
        kmsapiKeysResponse.setId(keyId);
    }

    @Test
    void testApiKeyGeneration() {
        // Mocking the API response
        when(keyDao.generateApiKey(anyString())).thenReturn(kmsapiKeysResponse);
        when(passwordGenerator.generatePassword()).thenReturn("securePassword");
        when(pdfService.generatedPDF(anyMap(), anyString(), anyString())).thenReturn(new ByteArrayOutputStream());

        // Call the method
        ByteArrayOutputStream pdfStream = keyService.apiKeyGeneration(keyGenerationRequest);

        // Verify interactions and assertions
        assertNotNull(pdfStream);
        verify(keyDao, times(1)).generateApiKey("MID12345");
        verify(pdfService, times(1)).generatedPDF(anyMap(), anyString(), eq("api_key"));
    }

    @Test
    void testApiPdfFileGenerator() {
        // Mocking the password generation and PDF service
        when(passwordGenerator.generatePassword()).thenReturn("securePassword");
        when(pdfService.generatedPDF(anyMap(), anyString(), eq("api_key"))).thenReturn(new ByteArrayOutputStream());

        // Call the method
        ByteArrayOutputStream pdfStream = keyService.apiPdfFileGenerator("MID12345", "testApiKey", "testApiKeySecret", keyId);

        // Verify interactions and assertions
        assertNotNull(pdfStream);
        verify(passwordGenerator, times(1)).generatePassword();
        verify(pdfService, times(1)).generatedPDF(anyMap(), eq("securePassword"), eq("api_key"));
        verify(keyDao, times(1)).saveNotification(eq(KeyType.ENCRYPTION), eq(keyId), contains("Encryption Key PDF file Password is :"), eq("MID12345"));
    }
}
