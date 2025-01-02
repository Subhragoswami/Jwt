package com.epay.merchant.entity;


import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.util.UUID;

@Entity
@Getter
@Setter
@Builder
@Table(name = "login_audit")
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class LoginAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private UUID userId;
    private String requestType;
    private boolean status;
    private String reason;
    @CreatedDate
    private Long createdAt;
}


----------------------------------------------







package com.epay.merchant.service;

import com.epay.merchant.dao.LoginDao;
import com.epay.merchant.dto.ErrorDto;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.exception.ValidationException;
import com.epay.merchant.model.request.MerchantLoginRequest;
import com.epay.merchant.model.response.MerchantResponse;
import com.epay.merchant.repository.MerchantUserRepository;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.MerchantConstant;
import com.epay.merchant.util.enums.ProcessStatus;
import com.epay.merchant.util.enums.RequestType;
import com.epay.merchant.util.enums.UserStatus;
import com.epay.merchant.validator.MerchantLoginValidator;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.MessageFormat;
import java.util.List;
import java.util.UUID;

/**
 * Class Name: LoginService
 * *
 * Description: Validate the UserName and Password to login
 * *
 * Author: Ravi Rathore
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */

@Service
@RequiredArgsConstructor
public class LoginService {

    private final MerchantLoginValidator merchantLoginValidator;
    private final TokenService tokenService;
    private final LoginDao loginDao;
    private final MerchantUserRepository merchantUserRepository;
    LoggerUtility log = LoggerFactoryUtility.getLogger(this.getClass());

    /**
     * Validates the user based on the provided validation request.
     *
     * @param merchantLoginRequest the login validation request containing user login details with captcha.
     * @return MerchantResponse containing success or failure details.
     */
    public MerchantResponse<String> merchantLogin(MerchantLoginRequest merchantLoginRequest) {
        try {
            merchantLoginValidator.validateMerchantLoginRequest(merchantLoginRequest);
            MerchantUserDto merchantUserDto = loginDao.getMerchantUser(merchantLoginRequest.getUserName());
            return MerchantResponse.<String>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(List.of(MessageFormat.format(MerchantConstant.SUCCESS_MESSAGE, "Login User Found"))).build();
        } catch (ValidationException | MerchantException e) {
            List<ErrorDto> errorMessages = (e instanceof ValidationException)
                    ? ((ValidationException) e).getErrorMessages()
                    : ((MerchantException) e).getErrorMessages();
            tokenService.updateMerchantUserForLogin(merchantLoginRequest.getUserName(), false, errorMessages.toString(), RequestType.LOGIN.getName());
            log.error("Login Validation Failed for userName {} ", merchantLoginRequest.getUserName());
            throw e;
        } catch (Exception e) {
            tokenService.updateMerchantUserForLogin(merchantLoginRequest.getUserName(), false, e.getMessage(), RequestType.LOGIN.getName());
            log.error("Login Validation Failed for userName {} ", merchantLoginRequest.getUserName(), e.getMessage());
            throw new MerchantException(ErrorConstants.GENERATION_ERROR_CODE, ErrorConstants.GENERATION_ERROR_MESSAGE);
        }
    }
}



-----------------------


package com.epay.merchant.dao;

import com.epay.merchant.config.MerchantConfig;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.entity.*;
import com.epay.merchant.entity.response.UserMenuPermissionEntityDetails;
import com.epay.merchant.exception.MerchantException;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.model.response.UserProfileResponse;
import com.epay.merchant.repository.*;
import com.epay.merchant.util.*;
import com.epay.merchant.util.enums.NotificationType;
import com.epay.merchant.util.enums.UserStatus;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Class Name: MerchantUserDao
 * *
 * Description:
 * *
 * Author: Vikram Deshpande
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */
@Component
@RequiredArgsConstructor
public class MerchantUserDao {

    private final MerchantUserRepository merchantUserRepository;
    private final UserMenuPermissionRepository userMenuPermissionRepository;
    private final DefaultUserPermissionRepository defaultUserPermissionRepository;
    private final MenuInfoRepository menuInfoRepository;
    private final MerchantEntityUserRepository merchantEntityUserRepository;
    private final MerchantUserRoleDao merchantUserRoleDao;
    private final NotificationDao notificationDao;
    private final MerchantMapper merchantMapper;
    private final MerchantConfig merchantConfig;
    private final PasswordGenerator passwordGenerator;
    private final LoginDao loginDao;

    public MerchantUserDto getByUserNameOrEmailOrMobilePhoneAndStatus(String userName, String email, String phone, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, email, phone, userStatus);
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    public UserProfileResponse getMerchantUserProfile(String userName, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, userName, userName, userStatus);
        UserProfileResponse userProfileResponse = merchantMapper.mapMerchantUserEntityToProfileResponse(merchantUser);
        userProfileResponse.setRoleName(merchantUserRepository.findUserRoleByUserId(merchantUser.getId()));
        return userProfileResponse;
    }

    public List<UserMenuPermissionEntityDetails> getUserMenuPermission(UUID userId) {
        return userMenuPermissionRepository.findUserMenuPermissionByUserId(userId);
    }

    public MerchantUser save(MerchantUser merchantUser) {
        return merchantUserRepository.save(merchantUser);
    }

    public boolean existsByUserNameOrEmailOrMobilePhoneAndStatus(String userName, String email, String phone, UserStatus userStatus) {
        return merchantUserRepository.existsByUserNameOrEmailOrMobilePhoneAndStatus(userName, email, phone, userStatus);
    }

    public MerchantUserDto updateMerchantUserForPassword(String userName, String password, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, userName, userName, userStatus);
        merchantUser.setPassword(EncryptionDecryptionUtil.hashValue(password));
        merchantUser.setLastPasswordChange(DateTimeUtils.getCurrentTimeInMills());
        merchantUser.setPasswordExpiryTime(DateTimeUtils.getFutureDateByMonth(merchantConfig.getPasswordExpiryMonths()));
        merchantUser.setStatus(UserStatus.ACTIVE);
        merchantUser = save(merchantUser);
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    public boolean isUserHaveAccessToMId(String userName, List<String> mIds) {
        boolean isAccessable = merchantUserRepository.isUserHaveAccessOfMerchant(mIds, userName);
        if (!isAccessable) {
            isAccessable = merchantUserRepository.isUserHaveAccessOfEntityMerchant(mIds, userName);
        }
        return isAccessable;
    }

    @Transactional
    public MerchantUserDto saveMerchantUser(MerchantUserDto merchantUserDto, String... mIds) {
        //Step 1 : Password Generator
        String password = passwordGenerator.generatePassword();

        //Step 2 : Set Up Default Value
        setMerchantUserDefaultValues(merchantUserDto, password);

        //Step 3 : Save Merchant User
        MerchantUser merchantUser = merchantMapper.mapMerchantUserDtoToEntity(merchantUserDto);
        merchantUser = merchantUserRepository.save(merchantUser);

        //Step 4 : Assigned MIDs to Merchant User
        assignMerchantToUser(merchantUser.getId(), mIds);

        //Step 5 : Assigned Default Menu permission to Merchant User
        createMerchantUserMenuPermissions(merchantUser.getId(), merchantUser.getRole());

        //Step 5 : Send Notification
        sendNotification(merchantUser, password);

        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    public Page<MerchantUserDto> getAllMerchantUsersByMId(String mId, Pageable pageable) {
        return merchantUserRepository.findBymId(mId, pageable).map(this::convertEntityToDTO);
    }

    public String getUserRoleName(UUID roleId){
        return merchantUserRoleDao.getRoleNameById(roleId).getRole();
    }

    public void updateMerchantUserForLogin(MerchantUserDto merchantUserDto, boolean loginStatus) {
        MerchantUser merchantUser = merchantMapper.mapMerchantUserDtoToEntity(merchantUserDto);
        if(loginStatus){
            merchantUser.setLastSuccessLogin(System.currentTimeMillis());
            merchantUser.setLoginFailAttempt(0);
        } else {
            merchantUser.setLastFailLogin(System.currentTimeMillis());
            merchantUser.setLoginFailAttempt(merchantUser.getLoginFailAttempt()+1);
        }
        merchantUserRepository.save(merchantUser);
    }

    public void updateMerchantUserForLogin(MerchantUserDto merchantUserDto, boolean loginStatus, String errorReason, String requestType) {
        MerchantUser merchantUser = merchantMapper.mapMerchantUserDtoToEntity(merchantUserDto);

        if (loginStatus) {
            merchantUser.setLastSuccessLogin(System.currentTimeMillis());
            merchantUser.setLoginFailAttempt(0);
        } else {
            merchantUser.setLastFailLogin(System.currentTimeMillis());
            merchantUser.setLoginFailAttempt(merchantUser.getLoginFailAttempt() + 1);
        }

        merchantUserRepository.save(merchantUser);
        loginDao.saveLoginAudit(merchantUserDto.getId(), requestType, loginStatus, errorReason);
    }

    /**
     * Sending onboarding email and/or SMS.
     */
    private void sendNotification(MerchantUser merchantUser, String password) {
        notificationDao.sendUserCreationNotification(merchantUser.getId(), "User Created Successfully : " + password, MerchantConstant.RESPONSE_SUCCESS, NotificationType.BOTH);
    }

    private void assignMerchantToUser(UUID userId, String... mIds) {
        List<MerchantEntityUser> merchantEntityUsers = Arrays.stream(mIds).map(mId -> MerchantEntityUser.builder().userId(userId).mId(mId).build()).collect(Collectors.toList());
        merchantEntityUserRepository.saveAll(merchantEntityUsers);
    }

    private MerchantUser getMerchantUserByStatus(String userName, String email, String phone, UserStatus userStatus) {
        return merchantUserRepository.findByUserNameOrEmailOrMobilePhoneAndStatus(userName, email, phone, userStatus).orElseThrow(() -> new MerchantException(ErrorConstants.NOT_FOUND_ERROR_CODE, MessageFormat.format(ErrorConstants.NOT_FOUND_ERROR_MESSAGE, "Valid User")));
    }

    private MerchantUserDto convertEntityToDTO(MerchantUser merchantUser) {
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    /**
     * Creating Merchant User Permission for Admin User
     *
     * @param userId UUID
     */
    private void createMerchantUserMenuPermissions(final UUID userId, final UUID roleId) {
        List<DefaultUserPermission> defaultUserPermissions = defaultUserPermissionRepository.findByRoleId(roleId);
        List<MenuInfo> menuInfos = menuInfoRepository.findAll();
        List<UserMenuPermission> userMenuPermissions = new ArrayList<>();
        if (!CollectionUtils.isEmpty(menuInfos)) {
            menuInfos.forEach(menuInfo -> defaultUserPermissions.stream().filter(defaultUserPermission -> defaultUserPermission.getMenuId().equals(menuInfo.getId())).findFirst().ifPresent(defaultUserPermission -> userMenuPermissions.add(UserMenuPermission.builder().permissionId(defaultUserPermission.getPermissionId()).userId(userId).menuId(menuInfo.getId()).build())));
            userMenuPermissionRepository.saveAll(userMenuPermissions);
        }
    }

    /**
     * Setting default values if it is not present in onboarding request.
     *
     * @param user MerchantUserDto
     */
    private void setMerchantUserDefaultValues(MerchantUserDto user, String password) {
        String userName = EPayIdentityUtil.getUserPrincipal().getUsername();
        MerchantUser merchantUser = getMerchantUserByStatus(userName, userName, userName, UserStatus.ACTIVE);
        if (ObjectUtils.isEmpty(user.getRole())) {
            user.setRole(merchantUserRoleDao.getAdminRoleId().getId());
        }
        user.setParentUserId(merchantUser.getId());
        user.setStatus(UserStatus.ACTIVE);
        user.setPassword(EncryptionDecryptionUtil.hashValue(password));
        user.setPasswordExpiryTime(DateTimeUtils.getFutureDateByMonth(merchantConfig.getPasswordExpiryMonths()));
    }

}



-------------------



  public void updateMerchantUserForLogin(MerchantUserDto merchantUserDto, boolean loginStatus, String errorReason, String requestType) {
        merchantUserDao.updateMerchantUserForLogin(merchantUserDto, loginStatus, errorReason, requestType);
    }


---------------

  public void updateMerchantUserForLogin(String userName, boolean loginStatus, String errorReason, String requestType) {
        MerchantUserDto merchantUserDto = tokenDao.getMerchantUserDto(userName);
        tokenDao.updateMerchantUserForLogin(merchantUserDto, loginStatus, errorReason, requestType);
    }
