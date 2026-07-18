package com.forge.category.mapper;

import com.forge.category.dto.CategoryResponse;
import com.forge.category.entity.Category;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {

    public CategoryResponse toResponse(Category category) {
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getColor(),
                category.getGradient(),
                category.getIcon(),
                category.getDescription(),
                category.getCreatedAt(),
                category.getUpdatedAt());
    }
}
