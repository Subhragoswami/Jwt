package com.epay.merchant.validator;

import com.epay.merchant.dao.AdminDao;
import com.epay.merchant.dao.MerchantUserDao;
import com.epay.merchant.dto.ErrorDto;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.model.request.MerchantEntityGroupRequest;
import com.epay.merchant.model.request.UserEntityMappingRequest;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.enums.MerchantUserRoles;
import com.epay.merchant.util.enums.UserStatus;
import lombok.RequiredArgsConstructor;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import static com.epay.merchant.util.ErrorConstants.*;

/**
 * Class Name: AdminDetailsValidator
 * *
 * Description:
 * *
 * Author: V1018344(RahulP)
 * Copyright (c) 2024 [State Bank of India]
 * ALl rights reserved
 * *
 * Version: 1.0
 */

@Component
@RequiredArgsConstructor
public class AdminValidator extends BaseValidator {

    private final AdminDao adminDao;
    private final MerchantUserDao merchantUserDao;

    public void entityValidator(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        errorDtoList = new ArrayList<>();
        validateMandatory(merchantEntityGroupRequest);
        validatedEntityId(merchantEntityGroupRequest);
        validatedMId(merchantEntityGroupRequest);
    }

    public void userEntityRequestValidator(UserEntityMappingRequest userEntityMappingRequest) {
        errorDtoList = new ArrayList<>();
        validateMandatoryFields(userEntityMappingRequest);
        validateUserData(userEntityMappingRequest);
        validateEntityId(userEntityMappingRequest.getEntityId());
    }

    private void validateUserData(UserEntityMappingRequest userEntityMappingRequest) {
        boolean isUserNamePresent = StringUtils.isNotEmpty(userEntityMappingRequest.getUserName());
        boolean isUserIdPresent = ObjectUtils.isNotEmpty(userEntityMappingRequest.getUserId());
        validateValues(isUserNamePresent, isUserIdPresent);
        if(isUserNamePresent) {
            adminDao.isMerchantUserExistWithRoles(userEntityMappingRequest.getUserName(), List.of(MerchantUserRoles.ADMIN.name(), MerchantUserRoles.SUPER_ADMIN.name()));
        } else if(isUserIdPresent){
            adminDao.isMerchantUserExistWithRoles(userEntityMappingRequest.getUserId(), List.of(MerchantUserRoles.ADMIN.name(), MerchantUserRoles.SUPER_ADMIN.name()));
        }else {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, ROLE, "Reason : only ADMIN and SUPER_ADMIN are allowed")).build());
        }

    }

    private void validatedMId(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        validateMappedEntityMIds(merchantEntityGroupRequest);
        validateMIds(merchantEntityGroupRequest);
    }

    private void validateMappedEntityMIds(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        List<String> mIdsAlreadyMapped = adminDao.findMappedEntityMIds(merchantEntityGroupRequest.getMIds());
        if (CollectionUtils.isNotEmpty(mIdsAlreadyMapped)) {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.ALREADY_EXIST_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.ALREADY_EXIST_ERROR_MESSAGE, "MId " + Arrays.toString(mIdsAlreadyMapped.toArray()) + " are already Mapped")).build());
        }
        throwIfErrors();
    }

    private void validateMIds(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        List<String> invalidsMIds = adminDao.findInvalidsMIds(merchantEntityGroupRequest.getMIds());
        if (CollectionUtils.isNotEmpty(invalidsMIds)) {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "MId", "MId " + Arrays.toString(invalidsMIds.toArray()) + " are not valid")).build());
        }
        throwIfErrors();
    }

    private void validatedEntityId(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        boolean entityIdPresent = adminDao.isEntityIdPresent(merchantEntityGroupRequest.getEntityId());
        if (entityIdPresent) {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.ALREADY_EXIST_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.ALREADY_EXIST_ERROR_MESSAGE, "EntityId")).build());
        }
        throwIfErrors();
    }

    private void validateMandatory(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        checkMandatoryField(merchantEntityGroupRequest.getEntityId(), "EntityId");
        checkMandatoryCollection(merchantEntityGroupRequest.getMIds(), "Mapping MId List");
        throwIfErrors();
    }

    private void validateMandatoryFields(UserEntityMappingRequest userEntityMappingRequest) {
        checkMandatoryField(userEntityMappingRequest.getEntityId(), ENTITY_ID);
        throwIfErrors();
    }

    private void validateValues(boolean isUserNamePresent, boolean isUserIdPresent) {
        if (isUserNamePresent == isUserIdPresent) {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.MANDATORY_FOUND_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.MANDATORY_ERROR_MESSAGE, "value of userName or UserId")).build());
        }
    }

    private void validateEntityId(String entityId) {
        if (!adminDao.isEntityIdPresent(entityId)) {
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, ENTITY_ID, ENTITY_ID_NOT_VALID)).build());
        }
        throwIfErrors();
    }
}


---------------------------------






package com.epay.merchant.dao;

import com.epay.merchant.dto.MerchantEntityGroupDto;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.dto.OnboardingDto;
import com.epay.merchant.entity.*;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.model.request.OnboardingRequest;
import com.epay.merchant.repository.*;
import com.epay.merchant.util.enums.MerchantStatus;
import com.epay.merchant.util.enums.MerchantUserRoles;
import com.epay.merchant.util.enums.UserStatus;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Class Name: MerchantDAO
 * *
 * Description:
 * *
 * Author: V1017903(bhushan wadekar)
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */
@Component
@RequiredArgsConstructor
public class AdminDao {

    private final LoggerUtility log = LoggerFactoryUtility.getLogger(AdminDao.class);

    private final MerchantRepository merchantRepository;
    private final MerchantUserDao merchantUserDao;
    private final MerchantEntityGroupRepository merchantEntityGroupRepository;
    private final MerchantMapper mapper;
    private final MerchantUserRepository merchantUserRepository;
    private final MerchantEntityUserRepository merchantEntityUserRepository;
    private final UserMenuPermissionRepository userMenuPermissionRepository;
    private final MerchantUserRoleRepository merchantUserRoleRepository;

    /**
     * Creating onboarding records in database.
     *
     * @param onboardingRequest OnboardingDto
     * @return OnboardingDto
     */
    @Transactional
    public OnboardingDto onboardingMerchantAndMerchantUser(OnboardingRequest onboardingRequest) {
        // Step 1 : Onboard Merchant
        MerchantInfo merchantInfo = mapper.mapMerchantDtoToEntity(onboardingRequest.getMerchant());
        merchantInfo.setStatus(MerchantStatus.ACTIVE.name());
        merchantInfo = merchantRepository.save(merchantInfo);
        // Step 2 : Onboard Merchant User
        MerchantUserDto merchantUserDto = merchantUserDao.saveMerchantUser(onboardingRequest.getUser(), merchantInfo.getMId());
        // Step 3 : Build Onboarding response
        return OnboardingDto.builder().merchant(mapper.mapMerchantInfoEntityToDto(merchantInfo)).user(merchantUserDto).build();
    }

    public boolean isMerchantExistByMId(String mId) {
        return merchantRepository.existsBymIdAndStatus(mId, MerchantStatus.ACTIVE.name());
    }

    public boolean isMerchantUserExist(String userName, String email, String mobilePhone) {
        return merchantUserDao.existsByUserNameOrEmailOrMobilePhoneAndStatus(userName, email, mobilePhone, UserStatus.ACTIVE);
    }

    public boolean isMerchantUserExistWithRoles(String userName, List<String> roles) {
        return merchantUserDao.existsByUserNameOrEmailOrMobilePhoneAndRoles(userName, roles);
    }

    public boolean isMerchantUserExistWithRoles(UUID userId, List<String> roles) {
        return merchantUserDao.existsByUserIdAndRoles(userId, roles);
    }

    public Page<MerchantUserDto> findAllMerchantUsersByMId(String mId, Pageable pageable) {
        return merchantUserDao.getAllMerchantUsersByMId(mId, pageable);
    }

    public List<String> findMappedEntityMIds(List<String> mIds) {
        return merchantEntityGroupRepository.findExistingMIds(mIds);
    }

    public List<String> findInvalidsMIds(List<String> mIds) {
        List<String> inActiveMIds = new ArrayList<>(mIds);
        List<String> activeMIds = merchantRepository.findActiveMIds(mIds);
        inActiveMIds.removeAll(activeMIds);
        return inActiveMIds;
    }

    public boolean isEntityIdPresent(String entityId) {
        return merchantEntityGroupRepository.existsByEntityId(entityId);
    }

    public MerchantEntityGroupDto saveMerchantEntityGroup(MerchantEntityGroupDto merchantEntityGroupDto) {
        List<MerchantEntityGroup> merchantEntityGroups = merchantEntityGroupDto.getMIds().stream().map(mId -> MerchantEntityGroup.builder().entityId(merchantEntityGroupDto.getEntityId()).mId(mId).build()).collect(Collectors.toList());
        merchantEntityGroupRepository.saveAll(merchantEntityGroups);
        return merchantEntityGroupDto;
    }

    public MerchantUserDto findByUserNameOrEmailOrMobilePhone(String userName) {
        return merchantUserDao.getByUserName(userName, UserStatus.ACTIVE);
    }

    public MerchantUserDto findByUserId(UUID id){
        Optional<MerchantUser> merchantUser = merchantUserRepository.findById(id);
        return mapper.mapMerchantUserEntityToDto(merchantUser.get());
    }

    public String findUserRoleByUserId(UUID id) {
        return merchantUserRepository.findUserRoleByUserId(id);
    }

    public void updateUserRole(MerchantUserDto userDto, String entityId) {
        String userRole = findUserRoleByUserId(userDto.getId());
        if (MerchantUserRoles.SUPER_ADMIN.name().equals(userRole)) {
            log.info("User is a SUPER_ADMIN. Updating entityId for userId: {}", userDto.getId());
            merchantEntityUserRepository.updateEntityIdForUser(userDto.getId(), entityId);
        } else if (MerchantUserRoles.ADMIN.name().equals(userRole)) {
            log.info("User is an ADMIN. Upgrading role and saving entityId for userId: {}", userDto.getId());
            findOrSaveMerchantUser(userDto, entityId);
        }
    }

    @Transactional
    public void findOrSaveMerchantUser(MerchantUserDto merchantUserDto, String entityId) {
        MerchantUser merchantUser = mapper.mapMerchantUserDtoToEntity(merchantUserDto);
        UUID roleId = findRoleIdByRoleName(MerchantUserRoles.SUPER_ADMIN.name());
        merchantUser.setRole(roleId);
        merchantUser = merchantUserRepository.save(merchantUser);
        merchantEntityUserRepository.deleteByUserId(merchantUser.getId());
        MerchantEntityUser newEntityUser = MerchantEntityUser.builder().userId(merchantUser.getId()).entityId(entityId).mId(merchantEntityGroupRepository.findByEntityId(entityId).getMId()).build();
        merchantEntityUserRepository.save(newEntityUser);
        updateUserMenuPermission(merchantUser.getId(), roleId);
    }

    public void updateUserMenuPermission(UUID userId, UUID roleId){
        if(!ObjectUtils.isEmpty(userMenuPermissionRepository.findByUserId(userId))){
            userMenuPermissionRepository.deleteByUserId(userId);
        }
        merchantUserDao.createMerchantUserMenuPermissions(userId, roleId);
    }

    public UUID findRoleIdByRoleName(String role){
        Optional<MerchantUserRole> merchantUserRole = merchantUserRoleRepository.findByRole(role);
        return merchantUserRole.get().getId();
    }

    public MerchantUser saveMerchantUser(MerchantUserDto merchantUserDto){
        MerchantUser merchantUser = mapper.mapMerchantUserDtoToEntity(merchantUserDto) ;
        return merchantUserRepository.save(merchantUser);
    }

    public void deleteByUserId(UUID userId){
        merchantEntityUserRepository.deleteByUserId(userId);
    }
}





-----------------------





package com.epay.merchant.service;

import com.epay.merchant.dao.AdminDao;
import com.epay.merchant.dto.MerchantDto;
import com.epay.merchant.dto.MerchantEntityGroupDto;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.dto.OnboardingDto;
import com.epay.merchant.mapper.MerchantEntityGroupMapper;
import com.epay.merchant.mapper.MerchantMapper;
import com.epay.merchant.model.request.MerchantEntityGroupRequest;
import com.epay.merchant.model.request.OnboardingRequest;
import com.epay.merchant.model.request.UserEntityMappingRequest;
import com.epay.merchant.model.response.MerchantEntityGroupResponse;
import com.epay.merchant.model.response.MerchantResponse;
import com.epay.merchant.model.response.MerchantUserResponse;
import com.epay.merchant.model.response.OnboardingResponse;
import com.epay.merchant.util.MerchantConstant;
import com.epay.merchant.util.enums.MerchantStatus;
import com.epay.merchant.util.enums.NotificationType;
import com.epay.merchant.validator.AdminValidator;
import com.epay.merchant.validator.OnboardingValidator;
import com.sbi.epay.encryptdecrypt.util.enums.HashAlgorithm;
import com.sbi.epay.logging.utility.LoggerFactoryUtility;
import com.sbi.epay.logging.utility.LoggerUtility;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;


/**
 * Class Name: AdminService
 * *
 * Description:
 * *
 * Author: Bhoopendra Rajput
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */
@Service
@RequiredArgsConstructor
public class AdminService {

    private final LoggerUtility log = LoggerFactoryUtility.getLogger(this.getClass());
    private final OnboardingValidator onboardingValidator;
    private final AdminValidator adminValidator;
    private final AdminDao adminDao;
    private final MerchantEntityGroupMapper merchantEntityGroupMapper;
    private final MerchantMapper merchantMapper;
    private final UserEntityValidator userEntityValidator;


    /**
     * Processing Onboarding request.
     *
     * @param onboardingRequest OnboardingDto
     * @return OnboardingDto
     */
    public MerchantResponse<OnboardingResponse> onboardingMerchant(OnboardingRequest onboardingRequest) {
        //Step 1 : OnboardingRequest validation
        onboardingValidator.validateOnboardingRequest(onboardingRequest);
        //Step 2 : Set up the default value for Merchant
        setMerchantDefaultValues(onboardingRequest.getMerchant());
        //Step 3 : Save the Merchant and Merchant User Data in DB
        OnboardingDto onboardingDto = adminDao.onboardingMerchantAndMerchantUser(onboardingRequest);
        //Step 5 : Build MerchantResponse and return to caller
        return MerchantResponse.<OnboardingResponse>builder().data(List.of(OnboardingResponse.builder().merchant(onboardingDto.getMerchant()).user(onboardingDto.getUser()).build())).status(MerchantConstant.RESPONSE_SUCCESS).count(1L).build();
    }

    public MerchantResponse<MerchantEntityGroupResponse> createMerchantEntityGroup(MerchantEntityGroupRequest merchantEntityGroupRequest) {
        //Step 1 : MerchantEntityGroupRequest validation
        adminValidator.entityValidator(merchantEntityGroupRequest);
        MerchantEntityGroupDto merchantEntityGroupDto = merchantEntityGroupMapper.mapEntityRequestToMerchantEntityGroupDto(merchantEntityGroupRequest);
        //Step 2 : Save Merchant Entity Group
        merchantEntityGroupDto = adminDao.saveMerchantEntityGroup(merchantEntityGroupDto);
        //Step 3 : Build MerchantResponse and return to caller
        return MerchantResponse.<MerchantEntityGroupResponse>builder().data(List.of(merchantEntityGroupMapper.mapMerchantEntityGroupDtoToEntityResponse(merchantEntityGroupDto))).status(MerchantConstant.RESPONSE_SUCCESS).count(1L).build();
    }

    /**
     * Retrieves a paginated list of Merchant Users based on the provided mId
     */
    public MerchantResponse<MerchantUserResponse> getAllMerchantUsers(String mId, Pageable pageable) {
        log.info("getting userList based on mId: {}", mId);
        Page<MerchantUserDto> merchantUsers = adminDao.findAllMerchantUsersByMId(mId, pageable);
        log.info("Mapping users for Merchant ID: {}", mId);
        List<MerchantUserResponse> merchantUserResponseList = merchantMapper.mapMerchantUserDTOListToResponseList(merchantUsers.getContent());
        return MerchantResponse.<MerchantUserResponse>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(merchantUserResponseList).count(merchantUsers.stream().count()).total(merchantUsers.getTotalElements()).build();
    }

    /**
     * Maps a user to an entity based on the provided mapping request.
     */
    public MerchantResponse<String> userEntityMapping(UserEntityMappingRequest userEntityMappingRequest) {
        log.info("Step 1: Received request to map entity with details: {}", userEntityMappingRequest);

        // Step 1: Validate the request
        log.info("Step 2: Validating the UserEntityMappingRequest");
        adminValidator.userEntityRequestValidator(userEntityMappingRequest);

        // Step 2: Retrieve the user
        MerchantUserDto userDto = retrieveUser(userEntityMappingRequest);

        // Step 3: Perform action based on user role
        adminDao.updateUserRole(userDto, userEntityMappingRequest.getEntityId());

        // Step 4: Build and return the response
        return MerchantResponse.<String>builder().status(MerchantConstant.RESPONSE_SUCCESS).data(List.of("role has been updated successfully")).count(1L).total(1L).build();
    }

    /**
     * Retrieves the user based on userId or userName in the request.
     */
    private MerchantUserDto retrieveUser(UserEntityMappingRequest userEntityMappingRequest) {
        log.info("Step 3: Retrieving user based on request details");
        return userEntityMappingRequest.getUserId() != null
                ? adminDao.findByUserId(userEntityMappingRequest.getUserId())
                : adminDao.findByUserNameOrEmailOrMobilePhone(userEntityMappingRequest.getUserName());
    }

    /**
     * Setting default values if it is not present in onboarding request.
     *
     * @param merchant MerchantDto
     */
    private void setMerchantDefaultValues(MerchantDto merchant) {
        if (Arrays.stream(NotificationType.values()).noneMatch(nt -> StringUtils.equalsAnyIgnoreCase(merchant.getNotification(), nt.name()))) {
            merchant.setNotification(NotificationType.BOTH.name());
        }
        if (StringUtils.isEmpty(merchant.getEncryptedAlgo())) {
            merchant.setEncryptedAlgo(HashAlgorithm.SHA_512.toString());
        }
        if (ObjectUtils.isEmpty(merchant.getStatus())) {
            merchant.setStatus(MerchantStatus.ACTIVE);
        }
    }

}



-------------------------



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
import java.util.*;
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

    public MerchantUserDto getByUserNameOrEmailOrMobilePhoneAndStatus(String userName, String email, String phone, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, email, phone, userStatus);
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    public MerchantUserDto getByUserName(String userName, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, userName, userName, userStatus);
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser);
    }

    public UserProfileResponse getMerchantUserProfile(String userName, UserStatus userStatus) {
        MerchantUser merchantUser = getMerchantUserByStatus(userName, userName, userName, userStatus);
        UserProfileResponse userProfileResponse = merchantMapper.mapMerchantUserEntityToProfileResponse(merchantUser);
        userProfileResponse.setRoleName(merchantUserRepository.findUserRoleByUserId(merchantUser.getId()));
        return userProfileResponse;
    }

    public MerchantUserDto findByUserIdAndStatus(UUID id, UserStatus status){
        Optional<MerchantUser> merchantUser =  merchantUserRepository.findByIdAndStatus(id, status);
        return merchantMapper.mapMerchantUserEntityToDto(merchantUser.get());
    }

    public boolean isExistsByUserId(UUID id){
        return merchantUserRepository.existsById(id);
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

    public boolean existsByUserNameOrEmailOrMobilePhoneAndRoles(String userName, List<String> roles){
        return merchantUserRepository.existsByUserNameOrEmailOrMobilePhoneAndRoles(userName, roles);
    }

    public boolean existsByUserIdAndRoles(UUID userId, List<String> roles){
        return merchantUserRepository.existsByUserIdAndRoles(userId, roles);
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
    public void createMerchantUserMenuPermissions(final UUID userId, final UUID roleId) {
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




------------------------------




package com.epay.merchant.repository;

import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.util.enums.UserStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Class Name: MerchantRepository
 * *
 * Description:
 * *
 * Author: Bhoopendra Rajput
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All rights reserved
 * *
 * Version:1.0
 */

@Repository
public interface MerchantUserRepository extends JpaRepository<MerchantUser, UUID> {

    @Query("select m FROM MerchantUser m, MerchantEntityUser meu, MerchantEntityGroup meg " + "WHERE m.id = meu.userId and ((meu.mId = :mid and meu.entityId is null) or (meg.entityId = meu.entityId and meg.mId = :mid ))")
    Page<MerchantUser> findBymId(@Param("mid") String mId, Pageable pageable);

    boolean existsByUserNameOrEmailOrMobilePhoneAndStatus(String userName, String email, String mobilePhone, UserStatus status);

    Optional<MerchantUser> findByUserNameOrEmailOrMobilePhoneAndStatus(String userName, String email, String mobilePhone, UserStatus status);

    Optional<MerchantUser> findByIdAndStatus(UUID id, UserStatus status);

    @Query("select count(m) > 0 FROM MerchantUser m WHERE (m.userName = :userName OR m.email = :userName OR m.mobilePhone = :userName) AND m.password = :password")
    boolean isMerchantUserExistsByUserNameOrEmailOrMobilePhoneAndPassword(@Param("userName") String userName, @Param("password") String password);

    @Query("SELECT r.role FROM MerchantUser u JOIN MerchantUserRole r ON u.role = r.id WHERE u.id = :userId")
    String findUserRoleByUserId(@Param("userId") UUID userId);

    @Query("select count(meu) > 0 from MerchantEntityUser meu , MerchantUser mu " +
            "where  meu.userId = mu.id and meu.mId IN (:mIds) and mu.userName = :userName")
    boolean isUserHaveAccessOfMerchant(@Param("mIds") List<String> mIds, @Param("userName") String userName);

    @Query("select count(meu) > 0 from MerchantEntityUser meu , MerchantUser mu , MerchantEntityGroup meg " +
            "where meu.userId = mu.id and meu.entityId is not null and meu.entityId = meg.entityId " +
            "and mu.userName = :userName and meg.mId IN (:mIds)")
    boolean isUserHaveAccessOfEntityMerchant(@Param("mIds") List<String> mIds, @Param("userName") String userName);

    @Query("SELECT CASE WHEN COUNT(mu) > 0 THEN TRUE ELSE FALSE END " +
            "FROM MerchantUser mu " +
            "JOIN MerchantUserRole mur ON mu.role = mur.id " +
            "WHERE (mu.userName = :userName OR mu.email = :userName OR mu.mobilePhone = :userName) " +
            "AND mur.role IN :roles")
    boolean existsByUserNameOrEmailOrMobilePhoneAndRoles(@Param("userName") String userName, @Param("roles") List<String> roles);

    @Query("SELECT CASE WHEN COUNT(mu) > 0 THEN TRUE ELSE FALSE END " +
            "FROM MerchantUser mu " +
            "JOIN MerchantUserRole mur ON mu.role = mur.id " +
            "WHERE mu.id = :userId AND mur.role IN :roles")
    boolean existsByUserIdAndRoles(@Param("userId") UUID userId, @Param("roles") List<String> roles);
}
