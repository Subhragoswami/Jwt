package com.jwt.controller;

import com.jwt.model.request.UserRequest;
import com.jwt.model.response.ResponseDto;
import com.jwt.model.response.UserResponse;
import com.jwt.services.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/user")
public class Home {
    private final UserService userService;

    @PostMapping
    public ResponseDto<String> register(@RequestBody UserRequest userRequest) {
        log.info("creating user : {}", userRequest);
        return userService.createUser(userRequest);
    }


    @GetMapping("/{userId}")
    public ResponseDto<UserResponse> getUser(@PathVariable(required = false) UUID userId){
        log.info("getting user details");
        return userService.allUser(userId);
    }

    @PutMapping("/{userId}")
    public ResponseDto<String> updateUser(@PathVariable UUID userId,
                                          @RequestBody UserRequest UserRequest){
        log.info("updating user : {}", userId);
        return userService.updateUser(userId, UserRequest) ;
    }
}
