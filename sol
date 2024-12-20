package com.epay.merchant.service;

import com.epay.merchant.dao.MerchantInfoDao;
import com.epay.merchant.dto.MerchantInfoDto;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.model.response.MerchantInfoResponse;
import com.epay.merchant.model.response.MerchantResponse;
import com.epay.merchant.util.MerchantConstant;
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
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.*;

class MerchantInfoServiceTest {

    @InjectMocks
    private MerchantInfoService merchantInfoService;

    @Mock
    private MerchantInfoDao merchantInfoDao;

    @Mock
    private MerchantMapper merchantMapper;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetAllMerchantInfo() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 10);
        MerchantInfoDto dto1 = new MerchantInfoDto("1", "Merchant1", "ACTIVE");
        MerchantInfoDto dto2 = new MerchantInfoDto("2", "Merchant2", "INACTIVE");

        List<MerchantInfoDto> dtoList = List.of(dto1, dto2);
        Page<MerchantInfoDto> page = new PageImpl<>(dtoList, pageable, dtoList.size());

        MerchantInfoResponse response1 = new MerchantInfoResponse("1", "Merchant1", "ACTIVE");
        MerchantInfoResponse response2 = new MerchantInfoResponse("2", "Merchant2", "INACTIVE");

        List<MerchantInfoResponse> responseList = List.of(response1, response2);

        when(merchantInfoDao.getALl(pageable)).thenReturn(page);
        when(merchantMapper.mapMerchantInfoDTOListToResponseList(dtoList)).thenReturn(responseList);

        // Act
        MerchantResponse<MerchantInfoResponse> result = merchantInfoService.getAllMerchantInfo(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(MerchantConstant.RESPONSE_SUCCESS, result.getStatus());
        assertEquals(2, result.getCount());
        assertEquals(2, result.getTotal());
        assertEquals(responseList, result.getData());

        // Verify interactions
        verify(merchantInfoDao, times(1)).getALl(pageable);
        verify(merchantMapper, times(1)).mapMerchantInfoDTOListToResponseList(dtoList);
    }

    @Test
    void testGetAllMerchantInfo_EmptyResult() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 10);
        Page<MerchantInfoDto> emptyPage = Page.empty();

        when(merchantInfoDao.getALl(pageable)).thenReturn(emptyPage);
        when(merchantMapper.mapMerchantInfoDTOListToResponseList(Collections.emptyList())).thenReturn(Collections.emptyList());

        // Act
        MerchantResponse<MerchantInfoResponse> result = merchantInfoService.getAllMerchantInfo(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(MerchantConstant.RESPONSE_SUCCESS, result.getStatus());
        assertEquals(0, result.getCount());
        assertEquals(0, result.getTotal());
        assertEquals(Collections.emptyList(), result.getData());

        // Verify interactions
        verify(merchantInfoDao, times(1)).getALl(pageable);
        verify(merchantMapper, times(1)).mapMerchantInfoDTOListToResponseList(Collections.emptyList());
    }

    @Test
    void testGetAllMerchantInfo_NullPage() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 10);

        when(merchantInfoDao.getALl(pageable)).thenReturn(null);

        // Act
        MerchantResponse<MerchantInfoResponse> result = merchantInfoService.getAllMerchantInfo(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(MerchantConstant.RESPONSE_SUCCESS, result.getStatus());
        assertEquals(0, result.getCount());
        assertEquals(0, result.getTotal());
        assertEquals(Collections.emptyList(), result.getData());

        // Verify interactions
        verify(merchantInfoDao, times(1)).getALl(pageable);
        verifyNoInteractions(merchantMapper);
    }
}





..................



package com.epay.merchant.dao;

import com.epay.merchant.dto.MerchantInfoDto;
import com.epay.merchant.entity.MerchantInfo;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.repository.MerchantInfoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class MerchantInfoDaoTest {

    @Mock
    private MerchantInfoRepository merchantInfoRepository;

    @Mock
    private MerchantMapper merchantMapper;

    @InjectMocks
    private MerchantInfoDao merchantInfoDao;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void getALl_ShouldReturnPageOfMerchantInfoDto() {
        // Mock data
        Pageable pageable = PageRequest.of(0, 10);
        MerchantInfo entity1 = new MerchantInfo();
        entity1.setMId("M001");
        entity1.setMerchantName("Merchant One");
        entity1.setStatus("ACTIVE");

        MerchantInfo entity2 = new MerchantInfo();
        entity2.setMId("M002");
        entity2.setMerchantName("Merchant Two");
        entity2.setStatus("INACTIVE");

        List<MerchantInfo> entities = Arrays.asList(entity1, entity2);
        Page<MerchantInfo> mockPage = new PageImpl<>(entities, pageable, 2);

        MerchantInfoDto dto1 = new MerchantInfoDto("M001", "Merchant One", "ACTIVE");
        MerchantInfoDto dto2 = new MerchantInfoDto("M002", "Merchant Two", "INACTIVE");

        // Mock behaviors
        when(merchantInfoRepository.findAll(pageable)).thenReturn(mockPage);
        when(merchantMapper.mapMerchantInfoEntityToMerchantInfoDto(entity1)).thenReturn(dto1);
        when(merchantMapper.mapMerchantInfoEntityToMerchantInfoDto(entity2)).thenReturn(dto2);

        // DAO call
        Page<MerchantInfoDto> resultPage = merchantInfoDao.getALl(pageable);

        // Assertions
        assertEquals(2, resultPage.getContent().size());
        assertEquals(dto1, resultPage.getContent().get(0));
        assertEquals(dto2, resultPage.getContent().get(1));

        // Verify interactions
        verify(merchantInfoRepository, times(1)).findAll(pageable);
        verify(merchantMapper, times(2)).mapMerchantInfoEntityToMerchantInfoDto(any(MerchantInfo.class));
    }
}
