import SwiftUI
import WidgetKit

/// Mirrors the Android `ForgeWidgetProvider` — shows today's completion count and current
/// streak, kept in sync by the Flutter side's `HomeWidgetSync`
/// (lib/core/home_widget/home_widget_sync.dart) every time the dashboard summary reloads.
/// Reads straight from the shared App Group `UserDefaults` suite the `home_widget` plugin
/// writes into (see `HomeWidgetSync.iOSAppGroupId` — must match the App Group configured on
/// both this target and Runner in Xcode).
private let appGroupId = "group.com.forge.forge.widget"

struct ForgeWidgetEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let todayCompleted: Int
    let todayTotal: Int
}

struct ForgeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForgeWidgetEntry {
        ForgeWidgetEntry(date: Date(), currentStreak: 5, todayCompleted: 2, todayTotal: 4)
    }

    func getSnapshot(in context: Context, completion: @escaping (ForgeWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForgeWidgetEntry>) -> Void) {
        let entry = currentEntry()
        // The widget only changes when the app writes new data (see HomeWidgetSync), which
        // calls WidgetCenter.reloadTimelines itself via HomeWidget.updateWidget — this hourly
        // entry is just a safety net so the widget doesn't look stale if that call is missed.
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> ForgeWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return ForgeWidgetEntry(
            date: Date(),
            currentStreak: defaults?.integer(forKey: "currentStreak") ?? 0,
            todayCompleted: defaults?.integer(forKey: "todayCompleted") ?? 0,
            todayTotal: defaults?.integer(forKey: "todayTotal") ?? 0
        )
    }
}

struct ForgeWidgetView: View {
    var entry: ForgeWidgetEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1, green: 0.478, blue: 0.271), Color(red: 1, green: 0.753, blue: 0.408)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.currentStreak > 0 ? "\(entry.currentStreak)-day streak" : "Start a streak today")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(
                    entry.todayTotal > 0
                        ? "\(entry.todayCompleted) of \(entry.todayTotal) done today"
                        : "No habits scheduled today"
                )
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // Scheme registered in Runner/Info.plist's CFBundleURLTypes — see ios/WIDGET_SETUP.md.
        .widgetURL(URL(string: "forgeapp://widget"))
    }
}

struct ForgeWidget: Widget {
    let kind: String = "ForgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForgeWidgetProvider()) { entry in
            ForgeWidgetView(entry: entry)
        }
        .configurationDisplayName("Forge Streak")
        .description("Today's completion count and current streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
