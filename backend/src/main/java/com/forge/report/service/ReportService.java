package com.forge.report.service;

import com.forge.category.entity.Category;
import com.forge.category.repository.CategoryRepository;
import com.forge.common.validation.SecurityUtils;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habit.service.RepeatScheduleEvaluator;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.habitlog.service.StreakService;
import com.forge.report.dto.CategoryPerformanceResponse;
import com.forge.report.dto.HeatmapDayResponse;
import com.forge.report.dto.ReportOverviewResponse;
import com.forge.report.dto.ReportRange;
import com.forge.report.dto.WeekdayStatResponse;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Milestone 7: Reports. Every stat here is derived on read from habits + habit_logs, the same
 * "compute, don't store" approach as StreakService — acceptable at current scale, revisit with a
 * materialized rollup if a very-long-lived ALL-range user makes this a hot path.
 */
@Service
@Transactional(readOnly = true)
public class ReportService {

    /** difficulty (1-5) * this = XP per completion — kept in sync with HabitLogService's constant
     * of the same name; both describe the same award, just at different points in time. */
    private static final long XP_PER_DIFFICULTY_POINT = 10;

    /** Caps how far back ALL (and any other range) can reach, independent of how old the user's
     * oldest habit is — keeps heatmap/category-performance cost bounded. */
    private static final long MAX_LOOKBACK_DAYS = 365;

    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final RepeatScheduleEvaluator scheduleEvaluator;
    private final StreakService streakService;

    public ReportService(
            HabitRepository habitRepository,
            HabitLogRepository habitLogRepository,
            CategoryRepository categoryRepository,
            UserRepository userRepository,
            RepeatScheduleEvaluator scheduleEvaluator,
            StreakService streakService) {
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.categoryRepository = categoryRepository;
        this.userRepository = userRepository;
        this.scheduleEvaluator = scheduleEvaluator;
        this.streakService = streakService;
    }

    public ReportOverviewResponse overview(ReportRange range) {
        UUID userId = SecurityUtils.getCurrentUserId();
        User user = userRepository.findById(userId).orElseThrow();
        List<Habit> habits = habitRepository.findByUserIdOrderByCreatedAt(userId);
        LocalDate today = LocalDate.now();
        LocalDate start = resolveStart(range, habits, today);

        List<HabitLog> logs = habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, start, today);
        Map<UUID, Habit> habitsById = habits.stream().collect(Collectors.toMap(Habit::getId, h -> h));

        long totalCompletions = 0;
        long totalMissed = 0;
        long xpEarned = 0;
        for (HabitLog log : logs) {
            Habit habit = habitsById.get(log.getHabitId());
            if (habit == null) continue;
            if ("COMPLETED".equals(log.getStatus())) {
                totalCompletions++;
                xpEarned += habit.getDifficulty() * XP_PER_DIFFICULTY_POINT;
            } else if ("MISSED".equals(log.getStatus())) {
                totalMissed++;
            }
        }

        long totalScheduled = 0;
        for (LocalDate date = start; !date.isAfter(today); date = date.plusDays(1)) {
            final LocalDate d = date;
            totalScheduled += habits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, d)).count();
        }
        double completionRate = totalScheduled == 0 ? 0 : (double) totalCompletions / totalScheduled;

        var userStreak = streakService.computeUserStreak(userId);
        long activeHabitCount = habitRepository.countByUserIdAndArchived(userId, false);

        return new ReportOverviewResponse(
                range.name(),
                totalCompletions,
                totalMissed,
                completionRate,
                userStreak.currentStreak(),
                userStreak.bestStreak(),
                xpEarned,
                user.getLevel(),
                activeHabitCount);
    }

    public List<HeatmapDayResponse> heatmap(ReportRange range) {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<Habit> habits = habitRepository.findByUserIdOrderByCreatedAt(userId);
        LocalDate today = LocalDate.now();
        LocalDate start = resolveStart(range, habits, today);

        Map<LocalDate, Long> completedByDate = completedCountsByDate(userId, start, today);

        List<HeatmapDayResponse> days = new ArrayList<>();
        for (LocalDate date = start; !date.isAfter(today); date = date.plusDays(1)) {
            final LocalDate d = date;
            long scheduled = habits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, d)).count();
            long completed = Math.min(completedByDate.getOrDefault(d, 0L), scheduled);
            double rate = scheduled == 0 ? 0 : (double) completed / scheduled;
            days.add(new HeatmapDayResponse(d, (int) scheduled, (int) completed, rate));
        }
        return days;
    }

    public List<CategoryPerformanceResponse> categoryPerformance(ReportRange range) {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<Category> categories = categoryRepository.findByUserIdOrderByCreatedAt(userId);
        List<Habit> habits = habitRepository.findByUserIdOrderByCreatedAt(userId);
        LocalDate today = LocalDate.now();
        LocalDate start = resolveStart(range, habits, today);

        List<HabitLog> logs = habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, start, today);
        Map<UUID, List<HabitLog>> logsByHabit = logs.stream().collect(Collectors.groupingBy(HabitLog::getHabitId));

        List<CategoryPerformanceResponse> result = new ArrayList<>();
        for (Category category : categories) {
            List<Habit> categoryHabits = habits.stream().filter(h -> h.getCategoryId().equals(category.getId())).toList();

            long scheduled = 0;
            long completed = 0;
            for (Habit habit : categoryHabits) {
                List<HabitLog> habitLogs = logsByHabit.getOrDefault(habit.getId(), List.of());
                for (LocalDate date = start; !date.isAfter(today); date = date.plusDays(1)) {
                    if (!scheduleEvaluator.isScheduledOn(habit, date)) continue;
                    scheduled++;
                    final LocalDate d = date;
                    boolean done = habitLogs.stream().anyMatch(l -> l.getLogDate().equals(d) && "COMPLETED".equals(l.getStatus()));
                    if (done) completed++;
                }
            }
            double rate = scheduled == 0 ? 0 : (double) completed / scheduled;
            result.add(new CategoryPerformanceResponse(
                    category.getId().toString(), category.getName(), category.getColor(), categoryHabits.size(), completed, scheduled, rate));
        }
        return result;
    }

    public List<WeekdayStatResponse> weekdayBreakdown(ReportRange range) {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<Habit> habits = habitRepository.findByUserIdOrderByCreatedAt(userId);
        LocalDate today = LocalDate.now();
        LocalDate start = resolveStart(range, habits, today);

        Map<LocalDate, Long> completedByDate = completedCountsByDate(userId, start, today);

        Map<DayOfWeek, long[]> tally = new EnumMap<>(DayOfWeek.class);
        for (DayOfWeek dow : DayOfWeek.values()) tally.put(dow, new long[2]);

        for (LocalDate date = start; !date.isAfter(today); date = date.plusDays(1)) {
            final LocalDate d = date;
            long scheduled = habits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, d)).count();
            long completed = Math.min(completedByDate.getOrDefault(d, 0L), scheduled);
            long[] arr = tally.get(d.getDayOfWeek());
            arr[0] += scheduled;
            arr[1] += completed;
        }

        return java.util.Arrays.stream(DayOfWeek.values())
                .map(dow -> {
                    long[] arr = tally.get(dow);
                    double rate = arr[0] == 0 ? 0 : (double) arr[1] / arr[0];
                    return new WeekdayStatResponse(dow.name().substring(0, 3), rate);
                })
                .toList();
    }

    private Map<LocalDate, Long> completedCountsByDate(UUID userId, LocalDate start, LocalDate today) {
        return habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, start, today).stream()
                .filter(l -> "COMPLETED".equals(l.getStatus()))
                .collect(Collectors.groupingBy(HabitLog::getLogDate, Collectors.counting()));
    }

    private LocalDate resolveStart(ReportRange range, List<Habit> habits, LocalDate today) {
        LocalDate start = range.startDate(today, habits);
        LocalDate floor = today.minusDays(MAX_LOOKBACK_DAYS);
        return start.isBefore(floor) ? floor : start;
    }
}
