package com.forge.dashboard.repository;

import com.forge.dashboard.entity.DashboardWidget;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DashboardWidgetRepository extends JpaRepository<DashboardWidget, UUID> {

    List<DashboardWidget> findByUserIdOrderByPosition(UUID userId);

    void deleteByUserId(UUID userId);
}
