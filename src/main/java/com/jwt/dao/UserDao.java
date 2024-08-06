package com.jwt.dao;

import com.jwt.model.User;
import com.jwt.repo.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;

import javax.transaction.Transactional;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
@Slf4j
public class UserDao {

    private final UserRepository userRepository;
    public void saveUser(User user) {
        userRepository.save(user);
    }
    public boolean checkUser(String email){
       return userRepository.existsByEmail(email);
    }

    public Optional<User> getUserById(UUID id){
       return userRepository.findById(id);
    }

    public User updateUser(User user){
        return userRepository.save(user);
    }
}
