package com.jwt.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jwt.dao.CategoryDao;
import com.jwt.entity.Category;
import com.jwt.exceptions.CustomException;
import com.jwt.model.request.CategoryRequest;
import com.jwt.model.response.CategoryResponse;
import com.jwt.model.response.ResponseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class CategoryService {
    private final CategoryDao categoryDao;
    private final ObjectMapper mapper;

    public ResponseDto<String> createCategory(CategoryRequest categoryRequest){
        if(ObjectUtils.isEmpty(categoryRequest)){
            throw new CustomException("","requestBody is empty");
        }
        Category category = mapper.convertValue(categoryRequest, Category.class);
        categoryDao.save(category);
        return ResponseDto.<String>builder().status(0).data(List.of("Category Created")).build();
    }

    public ResponseDto<CategoryResponse> getAll(){
        List<Category> categoryList = categoryDao.getAll();
        List<CategoryResponse> categoryResponseList = categoryList.stream().map((cat) -> mapper.convertValue(cat, CategoryResponse.class)).collect(Collectors.toList());
        return ResponseDto.<CategoryResponse>builder().data(categoryResponseList).build();
    }
}
