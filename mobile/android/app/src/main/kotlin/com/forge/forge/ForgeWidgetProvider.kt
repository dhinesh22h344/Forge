package com.forge.forge

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Shows today's completion count and current streak on the home screen, kept in sync by the
 * Flutter side's `HomeWidgetSync` (lib/core/home_widget/home_widget_sync.dart) every time the
 * dashboard summary reloads. `widgetData` is the shared prefs file the `home_widget` plugin
 * writes to from Dart — see the base class's `onUpdate`.
 */
class ForgeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val streak = widgetData.getInt("currentStreak", 0)
        val completed = widgetData.getInt("todayCompleted", 0)
        val total = widgetData.getInt("todayTotal", 0)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.forge_widget).apply {
                setTextViewText(
                    R.id.forge_widget_streak,
                    if (streak > 0) "$streak-day streak" else "Start a streak today"
                )
                setTextViewText(
                    R.id.forge_widget_today,
                    if (total > 0) "$completed of $total done today" else "No habits scheduled today"
                )
                setOnClickPendingIntent(
                    R.id.forge_widget_container,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
