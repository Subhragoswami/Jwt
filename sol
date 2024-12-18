package com.epay.merchant.service;

import com.epay.merchant.dao.AdminDao;
import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.model.response.MerchantUserResponse;
import com.epay.merchant.model.response.ResponseDto;
import com.epay.merchant.util.ErrorConstants;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.text.MessageFormat;
import java.util.List;

import static com.epay.merchant.util.AppConstants.RESPONSE_SUCCESS;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final AdminDao adminDao;

    private final ObjectMapper objectMapper;

    public ResponseDto<MerchantUserResponse> getAllUser(String mid, Pageable pageable) {
        if (!adminDao.existsByMid(mid)) {
            throw new MerchantException(ErrorConstants.INVALID_ERROR_CODE, MessageFormat.format(ErrorConstants.INVALID_ERROR_CODE_MESSAGE, "mid"));
        }
        Page<MerchantUser> merchantUsers =adminDao.findByMid(mid, pageable);
        List<MerchantUserResponse> merchantUserResponseList = merchantUsers.getContent().stream()
                .map(user -> objectMapper.convertValue(user, MerchantUserResponse.class)).toList();
        return ResponseDto.<MerchantUserResponse>builder()
                .status(RESPONSE_SUCCESS)
                .data(merchantUserResponseList)
                .count(merchantUsers.stream().count())
                .total(merchantUsers.getTotalElements())
                .build();
    }
}

.........

package com.epay.merchant.service;

import com.epay.merchant.dao.AdminDao;
import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.model.response.MerchantUserResponse;
import com.epay.merchant.model.response.ResponseDto;
import com.epay.merchant.util.ErrorConstants;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.Collections;
import java.util.List;

import static com.epay.merchant.util.AppConstants.RESPONSE_SUCCESS;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminServiceTest {

    @Mock
    private AdminDao adminDao;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private AdminService adminService;

    private MerchantUser merchantUser;
    private MerchantUserResponse merchantUserResponse;

    @BeforeEach
    void setUp() {
        // Initialize test data
        merchantUser = new MerchantUser();
        merchantUser.setId(1L);
        merchantUser.setName("Test User");

        merchantUserResponse = new MerchantUserResponse();
        merchantUserResponse.setId(1L);
        merchantUserResponse.setName("Test User");
    }

    @Test
    void getAllUser_WhenMidExists_ReturnsResponseDto() {
        // Arrange
        String mid = "validMid";
        Pageable pageable = Pageable.unpaged();

        Page<MerchantUser> merchantUserPage = new PageImpl<>(List.of(merchantUser));

        when(adminDao.existsByMid(mid)).thenReturn(true);
        when(adminDao.findByMid(eq(mid), any(Pageable.class))).thenReturn(merchantUserPage);
        when(objectMapper.convertValue(merchantUser, MerchantUserResponse.class)).thenReturn(merchantUserResponse);

        // Act
        ResponseDto<MerchantUserResponse> response = adminService.getAllUser(mid, pageable);

        // Assert
        assertNotNull(response);
        assertEquals(RESPONSE_SUCCESS, response.getStatus());
        assertEquals(1, response.getData().size());
        assertEquals(1, response.getCount());
        assertEquals(1, response.getTotal());

        verify(adminDao, times(1)).existsByMid(mid);
        verify(adminDao, times(1)).findByMid(eq(mid), any(Pageable.class));
        verify(objectMapper, times(1)).convertValue(merchantUser, MerchantUserResponse.class);
    }

    @Test
    void getAllUser_WhenMidDoesNotExist_ThrowsMerchantException() {
        // Arrange
        String invalidMid = "invalidMid";
        Pageable pageable = Pageable.unpaged();

        when(adminDao.existsByMid(invalidMid)).thenReturn(false);

        // Act & Assert
        MerchantException exception = assertThrows(MerchantException.class, () -> {
            adminService.getAllUser(invalidMid, pageable);
        });

        assertEquals(ErrorConstants.INVALID_ERROR_CODE, exception.getErrorCode());
        assertTrue(exception.getMessage().contains("mid"));

        verify(adminDao, times(1)).existsByMid(invalidMid);
        verify(adminDao, never()).findByMid(any(), any());
        verify(objectMapper, never()).convertValue(any(), any());
    }

    @Test
    void getAllUser_WhenNoUsersFound_ReturnsEmptyResponse() {
        // Arrange
        String mid = "validMid";
        Pageable pageable = Pageable.unpaged();

        Page<MerchantUser> emptyPage = new PageImpl<>(Collections.emptyList());

        when(adminDao.existsByMid(mid)).thenReturn(true);
        when(adminDao.findByMid(eq(mid), any(Pageable.class))).thenReturn(emptyPage);

        // Act
        ResponseDto<MerchantUserResponse> response = adminService.getAllUser(mid, pageable);

        // Assert
        assertNotNull(response);
        assertEquals(RESPONSE_SUCCESS, response.getStatus());
        assertEquals(0, response.getData().size());
        assertEquals(0, response.getCount());
        assertEquals(0, response.getTotal());

        verify(adminDao, times(1)).existsByMid(mid);
        verify(adminDao, times(1)).findByMid(eq(mid), any(Pageable.class));
        verify(objectMapper, never()).convertValue(any(), any());
    }
}

