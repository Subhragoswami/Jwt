package com.jwt.dao;

import com.jwt.entity.Category;
import com.jwt.repo.CategoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
@Slf4j
public class CategoryDao {
    private final CategoryRepository categoryRepository;

    public Category save(Category category){
        return categoryRepository.save(category);
    }
    public List<Category> getAll(){
        return categoryRepository.findAll();
    }
}
