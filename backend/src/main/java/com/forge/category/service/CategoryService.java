package com.forge.category.service;

import com.forge.achievement.service.AchievementService;
import com.forge.category.dto.CategoryRequest;
import com.forge.category.dto.CategoryResponse;
import com.forge.category.entity.Category;
import com.forge.category.mapper.CategoryMapper;
import com.forge.category.repository.CategoryRepository;
import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;
    private final AchievementService achievementService;

    public CategoryService(CategoryRepository categoryRepository, CategoryMapper categoryMapper, AchievementService achievementService) {
        this.categoryRepository = categoryRepository;
        this.categoryMapper = categoryMapper;
        this.achievementService = achievementService;
    }

    public CategoryResponse create(CategoryRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        if (categoryRepository.existsByUserIdAndNameIgnoreCase(userId, request.name())) {
            throw new IllegalArgumentException("A category named '" + request.name() + "' already exists");
        }
        Category category = new Category(
                userId, request.name(), request.color(), request.gradient(), request.icon(), request.description());
        CategoryResponse response = categoryMapper.toResponse(categoryRepository.save(category));
        achievementService.evaluateForUser(userId);
        return response;
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> list() {
        UUID userId = SecurityUtils.getCurrentUserId();
        return categoryRepository.findByUserIdOrderByCreatedAt(userId).stream()
                .map(categoryMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public CategoryResponse get(UUID id) {
        return categoryMapper.toResponse(findOwned(id));
    }

    public CategoryResponse update(UUID id, CategoryRequest request) {
        Category category = findOwned(id);
        if (!category.getName().equalsIgnoreCase(request.name())
                && categoryRepository.existsByUserIdAndNameIgnoreCase(category.getUserId(), request.name())) {
            throw new IllegalArgumentException("A category named '" + request.name() + "' already exists");
        }
        category.setName(request.name());
        category.setColor(request.color());
        category.setGradient(request.gradient());
        category.setIcon(request.icon());
        category.setDescription(request.description());
        return categoryMapper.toResponse(category);
    }

    public void delete(UUID id) {
        categoryRepository.delete(findOwned(id));
    }

    private Category findOwned(UUID id) {
        UUID userId = SecurityUtils.getCurrentUserId();
        return categoryRepository.findByIdAndUserId(id, userId).orElseThrow(() -> ResourceNotFoundException.of("Category", id));
    }
}
