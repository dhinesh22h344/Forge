package com.forge.dashboard.service;

import com.forge.common.validation.SecurityUtils;
import com.forge.dashboard.dto.DashboardSummaryResponse;
import com.forge.dashboard.dto.DashboardWidgetDto;
import com.forge.dashboard.entity.DashboardWidget;
import com.forge.dashboard.repository.DashboardWidgetRepository;
import com.forge.habit.entity.Habit;
import com.forge.habit.entity.HabitReminder;
import com.forge.habit.repository.HabitReminderRepository;
import com.forge.habit.repository.HabitRepository;
import com.forge.habit.service.RepeatScheduleEvaluator;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.habitlog.service.StreakService;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class DashboardService {

    private static final int RECENT_ACTIVITY_LIMIT = 5;
    private static final int UPCOMING_REMINDERS_LIMIT = 5;

    private final DashboardWidgetRepository widgetRepository;
    private final UserRepository userRepository;
    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final HabitReminderRepository habitReminderRepository;
    private final RepeatScheduleEvaluator scheduleEvaluator;
    private final StreakService streakService;

    public DashboardService(
            DashboardWidgetRepository widgetRepository,
            UserRepository userRepository,
            HabitRepository habitRepository,
            HabitLogRepository habitLogRepository,
            HabitReminderRepository habitReminderRepository,
            RepeatScheduleEvaluator scheduleEvaluator,
            StreakService streakService) {
        this.widgetRepository = widgetRepository;
        this.userRepository = userRepository;
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.habitReminderRepository = habitReminderRepository;
        this.scheduleEvaluator = scheduleEvaluator;
        this.streakService = streakService;
    }

    @Transactional(readOnly = true)
    public DashboardSummaryResponse getSummary() {
        UUID userId = SecurityUtils.getCurrentUserId();
        User user = userRepository.findById(userId).orElseThrow();
        List<Habit> activeHabits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, false);
        LocalDate today = LocalDate.now();

        var streak = streakService.computeUserStreak(userId);

        List<Habit> scheduledToday = activeHabits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, today)).toList();
        List<HabitLog> todayLogs = habitLogRepository.findByUserIdAndLogDate(userId, today);
        Map<UUID, HabitLog> todayLogByHabit = todayLogs.stream().collect(java.util.stream.Collectors.toMap(HabitLog::getHabitId, l -> l));
        long todayCompleted = scheduledToday.stream()
                .filter(h -> {
                    HabitLog log = todayLogByHabit.get(h.getId());
                    return log != null && "COMPLETED".equals(log.getStatus());
                })
                .count();

        List<Double> weeklyRates = weeklyCompletionRates(activeHabits, userId, today);
        List<DashboardSummaryResponse.RecentActivityItem> recentActivity = recentActivity(activeHabits, userId);
        List<DashboardSummaryResponse.UpcomingReminderItem> upcomingReminders = upcomingReminders(activeHabits);

        return new DashboardSummaryResponse(
                streak.currentStreak(),
                streak.bestStreak(),
                (int) todayCompleted,
                scheduledToday.size(),
                user.getXp(),
                user.getLevel(),
                weeklyRates,
                recentActivity,
                upcomingReminders,
                null);
    }

    private List<Double> weeklyCompletionRates(List<Habit> activeHabits, UUID userId, LocalDate today) {
        LocalDate weekStart = today.minusDays(6);
        List<HabitLog> logs = habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, weekStart, today);
        Map<String, HabitLog> logsByHabitDate =
                logs.stream().collect(java.util.stream.Collectors.toMap(l -> l.getHabitId() + "|" + l.getLogDate(), l -> l));

        List<Double> rates = new java.util.ArrayList<>();
        for (LocalDate date = weekStart; !date.isAfter(today); date = date.plusDays(1)) {
            final LocalDate d = date;
            List<Habit> scheduled = activeHabits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, d)).toList();
            if (scheduled.isEmpty()) {
                rates.add(0d);
                continue;
            }
            long completed = scheduled.stream()
                    .filter(h -> {
                        HabitLog log = logsByHabitDate.get(h.getId() + "|" + d);
                        return log != null && "COMPLETED".equals(log.getStatus());
                    })
                    .count();
            rates.add((double) completed / scheduled.size());
        }
        return rates;
    }

    private List<DashboardSummaryResponse.RecentActivityItem> recentActivity(List<Habit> activeHabits, UUID userId) {
        Map<UUID, Habit> habitsById = activeHabits.stream().collect(java.util.stream.Collectors.toMap(Habit::getId, h -> h));
        LocalDate since = LocalDate.now().minusDays(14);
        return habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, since, LocalDate.now()).stream()
                .filter(l -> "COMPLETED".equals(l.getStatus()) && l.getCompletedAt() != null && habitsById.containsKey(l.getHabitId()))
                .sorted(Comparator.comparing(HabitLog::getCompletedAt).reversed())
                .limit(RECENT_ACTIVITY_LIMIT)
                .map(l -> new DashboardSummaryResponse.RecentActivityItem(
                        habitsById.get(l.getHabitId()).getName(),
                        l.getCompletedAt().toString(),
                        java.util.Objects.requireNonNullElse(habitsById.get(l.getHabitId()).getIcon(), "check_circle")))
                .toList();
    }

    private List<DashboardSummaryResponse.UpcomingReminderItem> upcomingReminders(List<Habit> activeHabits) {
        if (activeHabits.isEmpty()) return List.of();
        Map<UUID, Habit> habitsById = activeHabits.stream().collect(java.util.stream.Collectors.toMap(Habit::getId, h -> h));
        List<UUID> habitIds = activeHabits.stream().map(Habit::getId).toList();
        LocalDateTime now = LocalDateTime.now();
        DayOfWeek today = now.getDayOfWeek();
        String todayAbbrev = today.name().substring(0, 3);

        // Approximation: only looks at today's remaining reminders, not future days — a full
        // multi-day lookahead needs the same per-day schedule evaluation as weeklyCompletionRates
        // and isn't worth the cost until Milestone 9 (Notifications) needs real scheduling.
        return habitIds.stream()
                .flatMap(id -> habitReminderRepository.findByHabitId(id).stream())
                .filter(HabitReminder::isActive)
                .filter(r -> r.getDaysOfWeek().isEmpty() || r.getDaysOfWeek().stream().anyMatch(todayAbbrev::equalsIgnoreCase))
                .filter(r -> r.getLocalTime().isAfter(LocalTime.from(now.toLocalTime())))
                .sorted(Comparator.comparing(HabitReminder::getLocalTime))
                .limit(UPCOMING_REMINDERS_LIMIT)
                .map(r -> new DashboardSummaryResponse.UpcomingReminderItem(
                        habitsById.get(r.getHabitId()).getName(),
                        now.toLocalDate().atTime(r.getLocalTime()).toInstant(ZoneOffset.UTC).toString()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<DashboardWidgetDto> getWidgetLayout() {
        UUID userId = SecurityUtils.getCurrentUserId();
        return widgetRepository.findByUserIdOrderByPosition(userId).stream()
                .map(w -> new DashboardWidgetDto(w.getWidgetType(), w.getPosition(), w.isVisible()))
                .toList();
    }

    /** Full replace — the client always sends the complete layout, so this stays a delete+insert rather than a diff. */
    public void saveWidgetLayout(List<DashboardWidgetDto> layout) {
        UUID userId = SecurityUtils.getCurrentUserId();
        widgetRepository.deleteByUserId(userId);
        widgetRepository.flush();
        List<DashboardWidget> widgets =
                layout.stream().map(dto -> new DashboardWidget(userId, dto.widgetType(), dto.position(), dto.isVisible())).toList();
        widgetRepository.saveAll(widgets);
    }
}
