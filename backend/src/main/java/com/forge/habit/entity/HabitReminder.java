package com.forge.habit.entity;

import com.forge.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** A habit can have multiple reminders (spec: "Multiple Reminders"), each independently toggleable. */
@Entity
@Table(name = "habit_reminders")
public class HabitReminder extends BaseEntity {

    @Column(name = "habit_id", nullable = false, updatable = false)
    private UUID habitId;

    @Column(name = "local_time", nullable = false)
    private LocalTime localTime;

    /** e.g. ["MON","WED","FRI"]. Empty means "every day this habit repeats". */
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "days_of_week", columnDefinition = "text[]")
    private List<String> daysOfWeek = List.of();

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    protected HabitReminder() {}

    public HabitReminder(UUID habitId, LocalTime localTime, List<String> daysOfWeek) {
        this.habitId = habitId;
        this.localTime = localTime;
        this.daysOfWeek = daysOfWeek == null ? List.of() : daysOfWeek;
    }

    public UUID getHabitId() {
        return habitId;
    }

    public LocalTime getLocalTime() {
        return localTime;
    }

    public void setLocalTime(LocalTime localTime) {
        this.localTime = localTime;
    }

    public List<String> getDaysOfWeek() {
        return daysOfWeek;
    }

    public void setDaysOfWeek(List<String> daysOfWeek) {
        this.daysOfWeek = daysOfWeek == null ? List.of() : daysOfWeek;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
