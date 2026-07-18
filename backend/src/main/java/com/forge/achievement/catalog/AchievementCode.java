package com.forge.achievement.catalog;

import com.forge.achievement.dto.AchievementStats;

/**
 * The full achievement catalog. Each constant carries its own unlock predicate (constant-specific
 * method body) — this is the "rule engine": {@link com.forge.achievement.service.AchievementService}
 * just computes an {@link AchievementStats} snapshot once and asks every code whether it's
 * satisfied, rather than each achievement re-deriving its own stats.
 *
 * <p>Hidden achievements are real system achievements whose title/description aren't revealed to
 * the client until unlocked (see AchievementResponse masking in AchievementService#list).
 */
public enum AchievementCode {
    FIRST_STEP("First Step", "Complete a habit for the first time.", "flag_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.totalCompletions() >= 1;
        }
    },
    CENTURY_CLUB("Century Club", "Reach 100 total completions.", "workspace_premium_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.totalCompletions() >= 100;
        }
    },
    WEEK_WARRIOR("Week Warrior", "Reach a 7-day streak on any habit.", "local_fire_department_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.bestHabitStreak() >= 7;
        }
    },
    MOMENTUM("Momentum", "Reach a 30-day streak on any habit.", "local_fire_department_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.bestHabitStreak() >= 30;
        }
    },
    UNSTOPPABLE("Unstoppable", "Reach a 100-day streak on any habit.", "whatshot_rounded", true) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.bestHabitStreak() >= 100;
        }
    },
    RISING_STAR("Rising Star", "Reach level 5.", "bolt_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.level() >= 5;
        }
    },
    VETERAN("Veteran", "Reach level 10.", "military_tech_rounded", true) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.level() >= 10;
        }
    },
    SYSTEMS_BUILDER("Systems Builder", "Create 5 categories.", "grid_view_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.categoryCount() >= 5;
        }
    },
    HABIT_ARCHITECT("Habit Architect", "Track 10 active habits at once.", "architecture_rounded", false) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.activeHabitCount() >= 10;
        }
    },
    FLAWLESS("Flawless", "Complete every scheduled habit for 7 days straight.", "diamond_rounded", true) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.bestPerfectDayStreak() >= 7;
        }
    },
    ETERNAL_FLAME("Eternal Flame", "Reach a 365-day streak on any habit.", "local_fire_department_rounded", true) {
        @Override
        public boolean isSatisfiedBy(AchievementStats stats) {
            return stats.bestHabitStreak() >= 365;
        }
    };

    private final String title;
    private final String description;
    private final String icon;
    private final boolean hidden;

    AchievementCode(String title, String description, String icon, boolean hidden) {
        this.title = title;
        this.description = description;
        this.icon = icon;
        this.hidden = hidden;
    }

    public abstract boolean isSatisfiedBy(AchievementStats stats);

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getIcon() {
        return icon;
    }

    public boolean isHidden() {
        return hidden;
    }
}
