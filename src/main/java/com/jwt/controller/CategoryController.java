package com.jwt.controller;

import com.jwt.model.request.CategoryRequest;
import com.jwt.model.response.CategoryResponse;
import com.jwt.model.response.ResponseDto;
import com.jwt.services.CategoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/category")
public class CategoryController {

    private final CategoryService categoryService;
    @PostMapping
    public ResponseDto<String> createCatagory(@RequestBody CategoryRequest categoryRequest){
        return categoryService.createCategory(categoryRequest);
    }

    @GetMapping
    public ResponseDto<CategoryResponse> getAllCategory(){
        return categoryService.getAll();
    }
}
