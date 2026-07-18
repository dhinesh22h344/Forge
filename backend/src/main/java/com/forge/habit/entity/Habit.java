package com.forge.habit.entity;

import com.forge.common.audit.BaseEntity;
import com.forge.common.json.JsonMapConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.hibernate.type.SqlTypes;

/**
 * The core aggregate of the app. `tags` (text[]) and `folder` (plain string) are deliberately
 * NOT their own relational tables here, unlike the original ERD sketch in
 * docs/architecture/database-schema.md — a dedicated Tag/Folder CRUD surface would double the
 * screens needed to ship this milestone for a feature that's just "group by a label the user
 * typed." Revisit if tags need their own color/icon or cross-habit analytics.
 */
@Entity
@Table(name = "habits")
@SQLDelete(sql = "UPDATE habits SET deleted_at = now() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public class Habit extends BaseEntity {

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "category_id", nullable = false)
    private UUID categoryId;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;

    @Column
    private String icon;

    @Column
    private String emoji;

    @Column(name = "image_url")
    private String imageUrl;

    /** 1 (low) - 3 (high) */
    @Column(nullable = false)
    private short priority = 2;

    /** 1 (easiest) - 5 (hardest) */
    @Column(nullable = false)
    private short difficulty = 3;

    @Column(name = "repeat_type", nullable = false)
    private String repeatType;

    /** Shape depends on repeat_type — e.g. {"days":["MON","WED","FRI"]} for SPECIFIC_DAYS. */
    @Convert(converter = JsonMapConverter.class)
    @Column(name = "repeat_config", columnDefinition = "text")
    private Map<String, Object> repeatConfig = Map.of();

    @Column(name = "goal_value", precision = 10, scale = 2)
    private BigDecimal goalValue;

    @Column(name = "goal_unit")
    private String goalUnit;

    @Column(name = "estimated_time_minutes")
    private Integer estimatedTimeMinutes;

    @Column(nullable = false)
    private String color;

    @Column
    private String gradient;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column
    private String notes;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(columnDefinition = "text[]")
    private List<String> tags = List.of();

    @Column
    private String folder;

    @Column(nullable = false)
    private String status = "ACTIVE";

    @Column(name = "is_archived", nullable = false)
    private boolean archived = false;

    protected Habit() {}

    public Habit(
            UUID userId,
            UUID categoryId,
            String name,
            String description,
            String icon,
            String emoji,
            String imageUrl,
            short priority,
            short difficulty,
            String repeatType,
            Map<String, Object> repeatConfig,
            BigDecimal goalValue,
            String goalUnit,
            Integer estimatedTimeMinutes,
            String color,
            String gradient,
            LocalDate startDate,
            LocalDate endDate,
            String notes,
            List<String> tags,
            String folder) {
        this.userId = userId;
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.icon = icon;
        this.emoji = emoji;
        this.imageUrl = imageUrl;
        this.priority = priority;
        this.difficulty = difficulty;
        this.repeatType = repeatType;
        this.repeatConfig = repeatConfig == null ? Map.of() : repeatConfig;
        this.goalValue = goalValue;
        this.goalUnit = goalUnit;
        this.estimatedTimeMinutes = estimatedTimeMinutes;
        this.color = color;
        this.gradient = gradient;
        this.startDate = startDate;
        this.endDate = endDate;
        this.notes = notes;
        this.tags = tags == null ? List.of() : tags;
        this.folder = folder;
    }

    public UUID getUserId() {
        return userId;
    }

    public UUID getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(UUID categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getEmoji() {
        return emoji;
    }

    public void setEmoji(String emoji) {
        this.emoji = emoji;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public short getPriority() {
        return priority;
    }

    public void setPriority(short priority) {
        this.priority = priority;
    }

    public short getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(short difficulty) {
        this.difficulty = difficulty;
    }

    public String getRepeatType() {
        return repeatType;
    }

    public void setRepeatType(String repeatType) {
        this.repeatType = repeatType;
    }

    public Map<String, Object> getRepeatConfig() {
        return repeatConfig;
    }

    public void setRepeatConfig(Map<String, Object> repeatConfig) {
        this.repeatConfig = repeatConfig == null ? Map.of() : repeatConfig;
    }

    public BigDecimal getGoalValue() {
        return goalValue;
    }

    public void setGoalValue(BigDecimal goalValue) {
        this.goalValue = goalValue;
    }

    public String getGoalUnit() {
        return goalUnit;
    }

    public void setGoalUnit(String goalUnit) {
        this.goalUnit = goalUnit;
    }

    public Integer getEstimatedTimeMinutes() {
        return estimatedTimeMinutes;
    }

    public void setEstimatedTimeMinutes(Integer estimatedTimeMinutes) {
        this.estimatedTimeMinutes = estimatedTimeMinutes;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getGradient() {
        return gradient;
    }

    public void setGradient(String gradient) {
        this.gradient = gradient;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags == null ? List.of() : tags;
    }

    public String getFolder() {
        return folder;
    }

    public void setFolder(String folder) {
        this.folder = folder;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isArchived() {
        return archived;
    }

    public void setArchived(boolean archived) {
        this.archived = archived;
    }
}
