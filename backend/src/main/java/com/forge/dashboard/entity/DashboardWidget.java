package com.forge.dashboard.entity;

import com.forge.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.UUID;

/**
 * One row per widget per user. No `config` column yet (the ERD sketch in
 * docs/architecture/database-schema.md includes one for future per-widget options like a daily
 * goal target) — add it when a widget actually needs configuration rather than carrying an
 * unused jsonb column through M1-M3.
 */
@Entity
@Table(name = "dashboard_widgets")
public class DashboardWidget extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "widget_type", nullable = false)
    private String widgetType;

    @Column(nullable = false)
    private int position;

    @Column(name = "is_visible", nullable = false)
    private boolean isVisible = true;

    protected DashboardWidget() {}

    public DashboardWidget(UUID userId, String widgetType, int position, boolean isVisible) {
        this.userId = userId;
        this.widgetType = widgetType;
        this.position = position;
        this.isVisible = isVisible;
    }

    public UUID getUserId() {
        return userId;
    }

    public String getWidgetType() {
        return widgetType;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public boolean isVisible() {
        return isVisible;
    }

    public void setVisible(boolean visible) {
        isVisible = visible;
    }
}
