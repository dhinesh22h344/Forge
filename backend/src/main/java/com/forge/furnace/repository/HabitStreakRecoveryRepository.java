package com.forge.furnace.repository;

import com.forge.furnace.entity.HabitStreakRecovery;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HabitStreakRecoveryRepository extends JpaRepository<HabitStreakRecovery, UUID> {

    Optional<HabitStreakRecovery> findTopByHabitIdOrderByCreatedAtDesc(UUID habitId);
}
