package com.forge.achievement.repository;

import com.forge.achievement.entity.UserAchievement;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAchievementRepository extends JpaRepository<UserAchievement, UUID> {

    List<UserAchievement> findByUserId(UUID userId);

    boolean existsByUserIdAndAchievementCode(UUID userId, String achievementCode);
}
