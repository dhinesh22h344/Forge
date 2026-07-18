package com.forge.habit.repository;

import com.forge.habit.entity.Habit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitRepository extends JpaRepository<Habit, UUID> {

    List<Habit> findByUserIdOrderByCreatedAt(UUID userId);

    List<Habit> findByUserIdAndCategoryIdOrderByCreatedAt(UUID userId, UUID categoryId);

    List<Habit> findByUserIdAndArchivedOrderByCreatedAt(UUID userId, boolean archived);

    Optional<Habit> findByIdAndUserId(UUID id, UUID userId);

    long countByUserIdAndArchived(UUID userId, boolean archived);
}
