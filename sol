package com.epay.merchant.validator;

import com.epay.merchant.dao.AdminDao;
import com.epay.merchant.dao.MerchantUserDao;
import com.epay.merchant.dto.ErrorDto;
import com.epay.merchant.dto.MerchantUserDto;
import com.epay.merchant.entity.MerchantUser;
import com.epay.merchant.model.request.UserEntityMappingRequest;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.enums.MerchantStatus;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Optional;


@Component
@RequiredArgsConstructor
public class UserEntityValidator extends BaseValidator {

    private final AdminDao adminDao;
    private final MerchantUserDao merchantUserDao ;

    public void UserEntityRequestValidator(UserEntityMappingRequest userEntityMappingRequest){
        errorDtoList = new ArrayList<>();
        validateMandatoryFields(userEntityMappingRequest);
        boolean isUserNamePresent = StringUtils.isNotEmpty(userEntityMappingRequest.getUserName());
        boolean isUserIdPresent = ObjectUtils.isNotEmpty(userEntityMappingRequest.getUserId());
        validateValues(isUserNamePresent, isUserIdPresent);
        Optional<MerchantUser> merchantUser;
        MerchantUserDto merchantUserDto;
        if(isUserNamePresent && adminDao.isMerchantUserExist(userEntityMappingRequest.getUserName(), userEntityMappingRequest.getUserName(), userEntityMappingRequest.getUserName())){
            merchantUserDto = merchantUserDao.findByUserNameOrEmailOrMobilePhone(userEntityMappingRequest.getUserName(), userEntityMappingRequest.getUserName(), userEntityMappingRequest.getUserName());
            statusCheck(merchantUserDto.getStatus().name());
        }else{
            merchantUser = merchantUserDao.findByUserId(userEntityMappingRequest.getUserId());
            statusCheck(merchantUser.get().getStatus());
        }
        validateEntityId(userEntityMappingRequest.getEntityId());
    }

    private void validateMandatoryFields(UserEntityMappingRequest userEntityMappingRequest){
        checkMandatoryField(userEntityMappingRequest.getEntityId(), "entity Id");
        throwIfErrors();
    }

    private void validateValues(boolean isUserNamePresent, boolean isUserIdPresent){
        if(isUserNamePresent == isUserIdPresent){
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.MANDATORY_FOUND_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.MANDATORY_ERROR_MESSAGE, "value of userName or UserId")).build());
        }
    }

    private void statusCheck(String status){
        if(!MerchantStatus.ACTIVE.name().equals(status)){
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "status", "Reason : status should be active")).build());
        }
    }

    private void validateEntityId(String entityId){
        if(!adminDao.isEntityIdPresent(entityId)){
            errorDtoList.add(ErrorDto.builder().errorCode(ErrorConstants.INVALID_ERROR_CODE).errorMessage(MessageFormat.format(ErrorConstants.INVALID_ERROR_MESSAGE, "entity Id", "Reason : entity Id is not present")).build());
        }
        throwIfErrors();
    }
}


package com.epay.merchant.validator;

import com.epay.merchant.dto.ErrorDto;
import com.epay.merchant.exception.ValidationException;
import com.epay.merchant.util.ErrorConstants;
import com.epay.merchant.util.MerchantConstant;
import com.epay.merchant.util.enums.RequestType;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;

import java.text.MessageFormat;
import java.util.*;
import java.util.regex.Pattern;

import static com.epay.merchant.util.ErrorConstants.INVALID_ERROR_CODE;
import static com.epay.merchant.util.ErrorConstants.INVALID_ERROR_MESSAGE;

/**
 * Class Name:BaseValidator
 * *
 * Description:
 * *
 * Author: Bhoopendra Rajput
 * <p>
 * Copyright (c) 2024 [State Bank of India]
 * All right reserved
 * *
 * Version:1.0
 */

public class BaseValidator {

    List<ErrorDto> errorDtoList;

    void checkMandatoryField(String value, String fieldName) {
        if (StringUtils.isEmpty(value)) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void checkMandatoryField(UUID value, String fieldName) {
        if (ObjectUtils.isEmpty(value)) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void checkMandatoryCollection(Collection collection, String fieldName) {
        errorDtoList.clear();
        if (CollectionUtils.isEmpty(collection)) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void checkMandatoryObject(Objects value, String fieldName) {
        if (ObjectUtils.isEmpty(value)) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void checkMandatoryFields(String fieldName, String... values) {
        boolean allEmpty = Arrays.stream(values).allMatch(StringUtils::isEmpty);
        if (allEmpty) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void checkMandatoryDateField(Long date, String fieldName) {
        if (ObjectUtils.isEmpty(date) || date < 0) {
            addError(fieldName, ErrorConstants.MANDATORY_FOUND_ERROR_CODE, ErrorConstants.MANDATORY_ERROR_MESSAGE);
        }
    }

    void validateEnumFieldValue(String value) {
        RequestType.getRequestType(value);
    }

    void validateFieldLength(String value, int maxLength, String fieldName) {
        if (StringUtils.isNotEmpty(value) && value.length() > maxLength) {
            addError(fieldName, ErrorConstants.INVALID_ERROR_CODE, "Max allowed length is " + maxLength);
        }
    }

    void validateDateFieldForPastDate(Long date, String fieldName) {
        if (date < MerchantConstant.MIN_TIMESTAMP || System.currentTimeMillis() < date) {
            addError(ErrorConstants.INVALID_ERROR_CODE, ErrorConstants.INVALID_ERROR_MESSAGE, fieldName, "Given date is greater then current date or not having format");
        }
    }

    void validateDateFieldForFutureDate(Long date, String fieldName) {
        if (date > MerchantConstant.MAX_TIMESTAMP || System.currentTimeMillis() > date) {
            addError(ErrorConstants.INVALID_ERROR_CODE, ErrorConstants.INVALID_ERROR_MESSAGE, fieldName, "Given date is less then current date or not having format");
        }
    }

    void validateFieldWithRegex(String value, int maxLength, String regex, String fieldName, String message) {
        if (StringUtils.isNotEmpty(value) && (value.length() > maxLength || validate(value, regex))) {
            addError(fieldName, ErrorConstants.INVALID_ERROR_CODE, message + " " + maxLength);
        }
    }

    void validateFieldWithRegex(String value, String regex, String fieldName, String message) {
        if (StringUtils.isNotEmpty(value) && validate(value, regex)) {
            addError(fieldName, ErrorConstants.INVALID_ERROR_CODE, message);
        }
    }

    void validateFieldValue(String value, String validValue, String fieldName) {
        if (!validValue.equalsIgnoreCase(value)) {
            addError(INVALID_ERROR_CODE, INVALID_ERROR_MESSAGE, fieldName, "Valid Values are " + validValue);
        }
    }

    void addError(String fieldName, String errorCode, String errorMessage) {
        errorDtoList.add(ErrorDto.builder().errorCode(errorCode).errorMessage(MessageFormat.format(errorMessage, fieldName)).build());
    }


    void addError(String errorCode, String errorMessage, Object... fieldNames) {
        errorDtoList.add(ErrorDto.builder().errorCode(errorCode).errorMessage(MessageFormat.format(errorMessage, fieldNames)).build());
    }

    void throwIfErrors() {
        if (!errorDtoList.isEmpty()) {
            throw new ValidationException(new ArrayList<>(errorDtoList));
        }
    }

    boolean validate(String value, String regex) {
        return !Pattern.matches(regex, value);
    }
}
