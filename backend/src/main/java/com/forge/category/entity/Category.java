package com.forge.category.entity;

import com.forge.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.UUID;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "categories")
@SQLDelete(sql = "UPDATE categories SET deleted_at = now() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public class Category extends BaseEntity {

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(nullable = false)
    private String name;

    /** Hex color, e.g. #6C5CE7 */
    @Column(nullable = false)
    private String color;

    /** Optional "#start,#end" gradient spec, rendered client-side. */
    @Column
    private String gradient;

    /** Icon identifier resolved to a glyph/asset client-side (e.g. "dumbbell", "book"). */
    @Column(nullable = false)
    private String icon;

    @Column
    private String description;

    protected Category() {}

    public Category(UUID userId, String name, String color, String gradient, String icon, String description) {
        this.userId = userId;
        this.name = name;
        this.color = color;
        this.gradient = gradient;
        this.icon = icon;
        this.description = description;
    }

    public UUID getUserId() {
        return userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
