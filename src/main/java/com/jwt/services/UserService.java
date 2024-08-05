package com.jwt.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jwt.dao.UserDao;
import com.jwt.model.User;
import com.jwt.model.request.UserRequest;
import com.jwt.model.response.ResponseDto;
import com.jwt.model.response.UserResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {
    private final UserDao userDao;
    private final ObjectMapper objectMapper;

    public ResponseDto<String> createUser(UserRequest userRequest) {
        if (ObjectUtils.isEmpty(userRequest)) {
            throw new RuntimeException();
        }
        User user = objectMapper.convertValue(userRequest, User.class);
        boolean flag = userDao.checkUser(user.getEmail());
        if (flag) {
            throw new RuntimeException("email is already present");
        } else {
            userDao.saveUser(user);
        }
        return ResponseDto.<String>builder().data(List.of("user created")).build();
    }

    public ResponseDto<UserResponse> allUser(UUID id){
        User user = userDao.getUserById(id);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        log.info("jkl; : {}", user.getEmail());
        UserResponse userResponse = objectMapper.convertValue(user, UserResponse.class);
        return ResponseDto.<UserResponse>builder().data(List.of(userResponse)).build();
    }

}
