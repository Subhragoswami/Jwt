package com.jwt.repo;

import com.jwt.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    public User findByUsername(String username);
    public boolean existsByEmail(String email);
}
