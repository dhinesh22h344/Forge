package com.forge.habit.service;

import com.forge.achievement.service.AchievementService;
import com.forge.category.repository.CategoryRepository;
import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import com.forge.habit.dto.HabitRequest;
import com.forge.habit.dto.HabitResponse;
import com.forge.habit.entity.Habit;
import com.forge.habit.mapper.HabitMapper;
import com.forge.habit.repository.HabitRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class HabitService {

    private final HabitRepository habitRepository;
    private final CategoryRepository categoryRepository;
    private final HabitMapper habitMapper;
    private final AchievementService achievementService;

    public HabitService(
            HabitRepository habitRepository,
            CategoryRepository categoryRepository,
            HabitMapper habitMapper,
            AchievementService achievementService) {
        this.habitRepository = habitRepository;
        this.categoryRepository = categoryRepository;
        this.habitMapper = habitMapper;
        this.achievementService = achievementService;
    }

    public HabitResponse create(HabitRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        categoryRepository
                .findByIdAndUserId(request.categoryId(), userId)
                .orElseThrow(() -> ResourceNotFoundException.of("Category", request.categoryId()));

        Habit habit = new Habit(
                userId,
                request.categoryId(),
                request.name(),
                request.description(),
                request.icon(),
                request.emoji(),
                request.imageUrl(),
                request.priority(),
                request.difficulty(),
                request.repeatType(),
                request.repeatConfig(),
                request.goalValue(),
                request.goalUnit(),
                request.estimatedTimeMinutes(),
                request.color(),
                request.gradient(),
                request.startDate(),
                request.endDate(),
                request.notes(),
                request.tags(),
                request.folder());
        HabitResponse response = habitMapper.toResponse(habitRepository.save(habit));
        achievementService.evaluateForUser(userId);
        return response;
    }

    @Transactional(readOnly = true)
    public List<HabitResponse> list(UUID categoryId, Boolean archived) {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<Habit> habits;
        if (categoryId != null) {
            habits = habitRepository.findByUserIdAndCategoryIdOrderByCreatedAt(userId, categoryId);
        } else if (archived != null) {
            habits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, archived);
        } else {
            habits = habitRepository.findByUserIdOrderByCreatedAt(userId);
        }
        return habits.stream().map(habitMapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public HabitResponse get(UUID id) {
        return habitMapper.toResponse(findOwned(id));
    }

    public HabitResponse update(UUID id, HabitRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        Habit habit = findOwned(id);
        categoryRepository
                .findByIdAndUserId(request.categoryId(), userId)
                .orElseThrow(() -> ResourceNotFoundException.of("Category", request.categoryId()));

        habit.setCategoryId(request.categoryId());
        habit.setName(request.name());
        habit.setDescription(request.description());
        habit.setIcon(request.icon());
        habit.setEmoji(request.emoji());
        habit.setImageUrl(request.imageUrl());
        habit.setPriority(request.priority());
        habit.setDifficulty(request.difficulty());
        habit.setRepeatType(request.repeatType());
        habit.setRepeatConfig(request.repeatConfig());
        habit.setGoalValue(request.goalValue());
        habit.setGoalUnit(request.goalUnit());
        habit.setEstimatedTimeMinutes(request.estimatedTimeMinutes());
        habit.setColor(request.color());
        habit.setGradient(request.gradient());
        habit.setStartDate(request.startDate());
        habit.setEndDate(request.endDate());
        habit.setNotes(request.notes());
        habit.setTags(request.tags());
        habit.setFolder(request.folder());
        return habitMapper.toResponse(habit);
    }

    public HabitResponse setArchived(UUID id, boolean archived) {
        Habit habit = findOwned(id);
        habit.setArchived(archived);
        habit.setStatus(archived ? "ARCHIVED" : "ACTIVE");
        return habitMapper.toResponse(habit);
    }

    public void delete(UUID id) {
        habitRepository.delete(findOwned(id));
    }

    private Habit findOwned(UUID id) {
        UUID userId = SecurityUtils.getCurrentUserId();
        return habitRepository.findByIdAndUserId(id, userId).orElseThrow(() -> ResourceNotFoundException.of("Habit", id));
    }
}
