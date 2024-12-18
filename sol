   public MerchantResponse<MerchantUserResponse> getAllUser(String mid, Pageable pageable) {
        logger.info("getting userList based on mid: {}", mid);
        if (!adminDao.existsByMid(mid)) {
            throw new MerchantException(ErrorConstants.INVALID_ERROR_CODE, MessageFormat.format(ErrorConstants.INVALID_ERROR_CODE_MESSAGE, "mid", "mid is not exists in record"));
        }
        Page<MerchantUser> merchantUsers = adminDao.findByMid(mid, pageable);
        List<MerchantUserResponse> merchantUserResponseList = merchantUsers.getContent().stream()
                .map(user -> orikaMapper.map(user, MerchantUserResponse.class)).toList();
        return MerchantResponse.<MerchantUserResponse>builder()
                .status(RESPONSE_SUCCESS)
                .data(merchantUserResponseList)
                .count(merchantUsers.stream().count())
                .total(merchantUsers.getTotalElements())
                .build();
    }


.......






package com.epay.merchant.dao;

import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class AdminDao {
    private final AdminRepository adminRepository;

    public boolean existsByMid(String mid){
        return adminRepository.existsByMid(mid);
    };

    public Page<MerchantUser> findByMid(String mid, Pageable pageable){
        return adminRepository.findByMid(mid, pageable);
    }

}


.............




package com.epay.merchant.dao;

import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.repository.AdminRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class AdminDaoTest {

    @Mock
    private AdminRepository adminRepository;

    @InjectMocks
    private AdminDao adminDao;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testFindByMid_ReturnsPageOfMerchantUsers() {
        // Arrange
        String mid = "merchant123";
        Pageable pageable = PageRequest.of(0, 10);

        MerchantUser merchantUser = new MerchantUser();
        merchantUser.setId(1L);
        merchantUser.setMid(mid);
        merchantUser.setUsername("testUser");

        Page<MerchantUser> mockPage = new PageImpl<>(Collections.singletonList(merchantUser));
        when(adminRepository.findByMid(mid, pageable)).thenReturn(mockPage);

        // Act
        Page<MerchantUser> result = adminDao.findByMid(mid, pageable);

        // Assert
        assertEquals(1, result.getTotalElements());
        assertEquals(merchantUser, result.getContent().get(0));
        verify(adminRepository, times(1)).findByMid(mid, pageable);
    }

    @Test
    void testFindByMid_ReturnsEmptyPage() {
        // Arrange
        String mid = "merchant123";
        Pageable pageable = PageRequest.of(0, 10);

        Page<MerchantUser> mockPage = Page.empty();
        when(adminRepository.findByMid(mid, pageable)).thenReturn(mockPage);

        // Act
        Page<MerchantUser> result = adminDao.findByMid(mid, pageable);

        // Assert
        assertEquals(0, result.getTotalElements());
        verify(adminRepository, times(1)).findByMid(mid, pageable);
    }
}
