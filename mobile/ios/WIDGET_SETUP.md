# iOS home-screen widget — one-time Xcode setup

This machine only has the Command Line Tools installed, not full Xcode, so the
WidgetKit extension target below could not be wired up automatically — adding
an Xcode target means editing `Runner.xcodeproj/project.pbxproj` (build
phases, code signing, target membership), and doing that by hand without
Xcode available to open and verify the result risks silently corrupting the
project file for everyone. `ForgeWidget.swift` is ready; it just needs an
Xcode target to live in. On a Mac with Xcode installed:

1. **Bump the deployment target.** WidgetKit needs iOS 14+; this project is
   currently pinned to 13.0 (`Runner.xcodeproj` → target `Runner` → Build
   Settings → iOS Deployment Target, all 3 configs — Debug/Release/Profile).
   Set it to 14.0 or higher.

2. **Bootstrap CocoaPods**, since no `ios/Podfile` exists yet in this repo —
   nobody has built this app for iOS before. Run `flutter build ios
   --no-codesign` once from `mobile/`, or `pod install` from `ios/` after a
   `flutter pub get`, to generate it.

3. **File → New → Target → Widget Extension.** Name it `ForgeWidget`. Leave
   "Include Configuration Intent" unchecked (this widget is static — it
   just mirrors data, no user-configurable options).

4. **Replace the generated Swift file's contents** with
   `ios/ForgeWidget/ForgeWidget.swift` (already written, targets the
   `group.com.forge.forge.widget` App Group — see below).

5. **Add the App Group capability to *both* targets** (Runner and
   ForgeWidget): select each target → Signing & Capabilities → + Capability
   → App Groups → add `group.com.forge.forge.widget`. Xcode creates and
   wires the entitlements files for you — don't hand-create them.

6. **Set the widget extension's own deployment target** to match Runner
   (14.0+) if Xcode didn't already inherit it.

7. Build and run. `HomeWidgetSync` (Dart side) already writes
   `currentStreak`/`todayCompleted`/`todayTotal` into that App Group every
   time the dashboard reloads — add the widget from the iOS home screen's
   long-press → + menu to see it.

## What's already done (no Xcode needed)

- `ios/ForgeWidget/ForgeWidget.swift` — the widget's `TimelineProvider` and
  `View`, reading the same three keys the Android widget reads.
- `ios/Runner/Info.plist` — registered the `forgeapp://` URL scheme the
  widget's tap target opens (`CFBundleURLTypes`).
- `lib/main.dart` — calls `HomeWidget.setAppGroupId(...)` on startup (a
  no-op on Android, required on iOS so the plugin knows which App Group's
  shared storage to write into).
- `lib/core/home_widget/home_widget_sync.dart` — `iOSAppGroupId` constant;
  keep it in sync with whatever App Group id you actually create in step 5
  if it ever changes.
