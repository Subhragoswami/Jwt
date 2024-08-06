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
import java.util.Optional;
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
        User user = userDao.getUserById(id).orElseThrow(() -> new RuntimeException("user is not present"));
        log.info("getting user details");
        UserResponse userResponse = objectMapper.convertValue(user, UserResponse.class);
        return ResponseDto.<UserResponse>builder().data(List.of(userResponse)).build();
    }

    public ResponseDto<String> updateUser(UUID userId, UserRequest userRequest){
        User user =userDao.getUserById(userId).orElseThrow(() -> new RuntimeException("user is not present"));
        log.info("updating user details");
        if(ObjectUtils.isNotEmpty(userRequest)){
            mergeNonNullFields(user,userRequest);
        }
        user = userDao.updateUser(user);
        return ResponseDto.<String>builder().data(List.of("updated successfully")).build();
    }

    private void mergeNonNullFields(User user, UserRequest userRequest){
        Optional.ofNullable(userRequest.getEmail()).ifPresent(user::setEmail);
        Optional.ofNullable(userRequest.getPassword()).ifPresent(user::setPassword);
        Optional.ofNullable(userRequest.getRol()).ifPresent(user::setRol);
    }
}
