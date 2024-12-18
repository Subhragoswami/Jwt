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

