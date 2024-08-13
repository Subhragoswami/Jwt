package com.jwt.repo;

import com.jwt.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface CategoryRepository extends JpaRepository<Category, UUID> {
//    @Query("SELECT c FROM Category c JOIN c.user u WHERE u.id = :userId")
//    List<Category> findCategoriesByUserId(@Param("userId") UUID userId);

    @Query("SELECT c FROM Category c ORDER BY c.id DESC")
    List<Category> findLast10Categories();
}
