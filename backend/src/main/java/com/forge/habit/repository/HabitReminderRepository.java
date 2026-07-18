package com.forge.habit.repository;

import com.forge.habit.entity.HabitReminder;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitReminderRepository extends JpaRepository<HabitReminder, UUID> {

    List<HabitReminder> findByHabitId(UUID habitId);

    java.util.Optional<HabitReminder> findByHabitIdAndId(UUID habitId, UUID id);

    void deleteByHabitIdAndId(UUID habitId, UUID id);
}
