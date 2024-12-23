package com.epay.merchant.dao;

import com.epay.merchant.config.MerchantConfig;
import com.epay.merchant.dto.MerchantInfoDto;
import com.epay.merchant.entity.MerchantInfo;
import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.entity.PasswordManagement;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.model.request.PasswordChangeRequest;
import com.epay.merchant.repository.MerchantInfoRepository;
import com.epay.merchant.repository.MerchantUserRepository;
import com.epay.merchant.repository.PasswordManagementRepository;
import com.epay.merchant.util.DateTimeUtils;
import com.epay.merchant.util.EncryptionDecryptionUtil;
import com.epay.merchant.util.enums.PasswordManagementType;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Class Name: MerchantInfoDao
 * *
 * Description:
 * *
 * Author: Subhra Goswami
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */
@Repository
@RequiredArgsConstructor
public class MerchantInfoDao {
    private final MerchantInfoRepository merchantInfoRepository;
    private final MerchantUserRepository merchantUserRepository;
    private final PasswordManagementRepository passwordManagementRepository;
    private final MerchantConfig merchantConfig;
    private final MerchantMapper mapper;

    public Page<MerchantInfoDto> getALl(Pageable pageable){
       return merchantInfoRepository.findAll(pageable).map(this::convertEntityToDTO);
    }

    public MerchantUser saveUser(MerchantUser merchantUser) {
        return merchantUserRepository.save(merchantUser);
    }

    public MerchantUser getUser(String userName) {
        return merchantUserRepository.findByUserNameOrEmailOrMobilePhone(userName, userName, userName);
    }

    public PasswordManagement savePasswordDetails(PasswordManagement passwordManagement) {
        return passwordManagementRepository.save(passwordManagement);
    }

    @Transactional
    public void updatePasswordDetails(PasswordChangeRequest passwordChangeRequest){
        MerchantUser merchantUser = getUser(passwordChangeRequest.getUserName());
        merchantUser.setPassword(EncryptionDecryptionUtil.hashValue(passwordChangeRequest.getNewPassword()));
        merchantUser.setLastPasswordChange(DateTimeUtils.getCurrentTimeInMills());
        merchantUser.setPasswordExpiryTime(DateTimeUtils.getFutureDateByMonth(merchantConfig.getPasswordExpiryMonths()));
        merchantUser = saveUser(merchantUser);
        List<PasswordManagement> passwordManagementList =  passwordManagementRepository.findLastPasswordsByUserId(merchantUser.getId(), PageRequest.of(0, 5));
        passwordManagementList.getFirst().setStatus(PasswordManagementType.EXPIRED);
        savePasswordDetails(PasswordManagement.builder().userId(merchantUser.getId()).status(PasswordManagementType.COMPLETED).previousPassword(merchantUser.getPassword()).requestType(PasswordManagementType.CHANGE_PASSWORD).build());
    }
    
    private MerchantInfoDto convertEntityToDTO(MerchantInfo merchantInfo) {
        return mapper.mapMerchantInfoEntityToMerchantInfoDto(merchantInfo);
    }

    public Page<MerchantInfoDto> getAllAccessMerchantInfoForMerchantUser(String userName, Pageable pageable) {
        return merchantInfoRepository.findAccessMerchantInfoForMerchantUser(userName, pageable).map(this::convertEntityToDTO);
    }
}
