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
