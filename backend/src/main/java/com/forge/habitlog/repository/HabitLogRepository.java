package com.forge.habitlog.repository;

import com.forge.habitlog.entity.HabitLog;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitLogRepository extends JpaRepository<HabitLog, UUID> {

    Optional<HabitLog> findByHabitIdAndLogDate(UUID habitId, LocalDate logDate);

    List<HabitLog> findByHabitIdOrderByLogDateDesc(UUID habitId);

    List<HabitLog> findByUserIdAndLogDate(UUID userId, LocalDate logDate);

    List<HabitLog> findByUserIdAndLogDateBetweenOrderByLogDate(UUID userId, LocalDate start, LocalDate end);

    List<HabitLog> findByHabitIdAndLogDateBetweenOrderByLogDate(UUID habitId, LocalDate start, LocalDate end);

    long countByUserIdAndStatus(UUID userId, String status);
}
