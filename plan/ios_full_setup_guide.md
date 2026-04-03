# Pauza iOS Full Setup Guide

Complete step-by-step instructions for configuring the Pauza Flutter app to run on iOS with full Screen Time integration and NFC support.

---

## Prerequisites

Before starting, ensure you have:

- **macOS** with **Xcode 15+** installed
- **Physical iPhone** running **iOS 16.0+** (Screen Time APIs do not work on simulator)
- **Apple Developer account** — Team ID: `3Y39BWVBCM`
- **Bundle Identifier**: `com.menace.pauza`
- **Screen Time enabled** on test device: Settings > Screen Time > Turn On Screen Time
- Flutter SDK installed and `flutter doctor` passing for iOS

---

## 1. Fix Podfile Deployment Target

The Podfile currently has the platform line commented out. Uncomment and set it to iOS 16.0.

1. Open `ios/Podfile`
2. Change line 2 from:
   ```ruby
   # platform :ios, '13.0'
   ```
   to:
   ```ruby
   platform :ios, '16.0'
   ```
3. Save the file

> **Why 16.0?** The `pauza_screen_time` plugin requires iOS 16+ for individual FamilyControls authorization (`AuthorizationCenter.requestAuthorization(for: .individual)`). The pbxproj already targets 16.0 for Debug/Release/Profile configs.

---

## 2. Apple Developer Portal Configuration

### 2.1 Enable capabilities on the App ID

1. Open [Apple Developer Portal](https://developer.apple.com/account/) > **Certificates, Identifiers & Profiles**
2. Go to **Identifiers**
3. Find the App ID for `com.menace.pauza`
4. In **Capabilities**, enable:
   - **App Groups** (if not already enabled)
   - **Near Field Communication Tag Reading**
5. In **App Groups**, ensure `group.com.menace.pauza` exists. If not, go to **Identifiers > App Groups** and register it
6. Save changes

### 2.2 Regenerate provisioning profiles

Since you use **automatic signing** (`CODE_SIGN_STYLE = Automatic` in pbxproj):

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project > **Runner** target > **Signing & Capabilities**
3. Toggle **Automatically manage signing** OFF, then back ON — this forces Xcode to regenerate profiles with the new capabilities
4. Verify no signing errors appear

If you ever switch to manual signing, download fresh profiles from the portal after enabling capabilities.

---

## 3. Verify Existing Runner Configuration

These are already configured but verify they haven't been accidentally removed:

### 3.1 Runner.entitlements (`ios/Runner/Runner.entitlements`)

Must contain:
```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.menace.pauza</string>
</array>
```

### 3.2 Info.plist (`ios/Runner/Info.plist`)

Must contain these keys:
```xml
<key>NFCReaderUsageDescription</key>
<string>Pauza uses NFC to scan supported tags when you start NFC-based actions.</string>

<key>NSCameraUsageDescription</key>
<string>Pauza uses your camera to scan linked QR codes for ending or pausing sessions.</string>

<key>AppGroupIdentifier</key>
<string>group.com.menace.pauza</string>

<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.menace.pauza.restriction_lifecycle_daily_sync</string>
</array>
```

### 3.3 Code signing entitlements linked in build settings

In `ios/Runner.xcodeproj/project.pbxproj`, all three build configurations (Debug, Release, Profile) must have:
```
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

> All of the above are already present in the current codebase. If any are missing, add them before proceeding.

---

## 4. Create Device Activity Monitor Extension

This extension enables reliable pause auto-resume and schedule enforcement even when the main app is backgrounded or terminated.

### 4.1 Add the target

1. Open `ios/Runner.xcworkspace` in Xcode
2. **File > New > Target...**
3. Search for **"Device Activity Monitor Extension"**
4. Click **Next**
5. Configure:
   - **Product Name**: `PauzaDeviceActivityMonitor`
   - **Team**: Select your team (ID `3Y39BWVBCM`)
   - **Language**: Swift
   - **Project**: Runner
   - **Embed in Application**: Runner
6. Click **Finish**
7. If Xcode asks "Activate PauzaDeviceActivityMonitor scheme?", click **Activate**

### 4.2 Set deployment target

1. Select the **PauzaDeviceActivityMonitor** target in the project navigator
2. Go to **General** tab
3. Set **Minimum Deployments** > **iOS** to **16.0**

### 4.3 Add App Groups capability

1. With **PauzaDeviceActivityMonitor** target still selected, go to **Signing & Capabilities**
2. Click **+ Capability**
3. Search for and add **App Groups**
4. Click the **+** under App Groups and add: `group.com.menace.pauza`
5. Verify same Team is selected and signing succeeds

### 4.4 Add AppGroupIdentifier to extension Info.plist

1. In the project navigator, find `PauzaDeviceActivityMonitor/Info.plist`
   - If no `Info.plist` exists, create one: **File > New > File... > Property List**, name it `Info.plist`, and add it to the `PauzaDeviceActivityMonitor` target
2. Add a new row:
   - **Key**: `AppGroupIdentifier`
   - **Type**: String
   - **Value**: `group.com.menace.pauza`

### 4.5 Replace the Swift source file

1. In the project navigator, find the generated Swift file inside `PauzaDeviceActivityMonitor/` (usually named `DeviceActivityMonitorExtension.swift`)
2. **Delete** the generated file (Move to Trash)
3. Copy the template file into the extension target:
   - Source: `../pauza_screen_time/docs/templates/PauzaDeviceActivityMonitorExtension.swift`
   - Right-click on the `PauzaDeviceActivityMonitor` group in Xcode > **Add Files to "Runner"...**
   - Navigate to `../pauza_screen_time/docs/templates/PauzaDeviceActivityMonitorExtension.swift`
   - **IMPORTANT**: Ensure **"Copy items if needed"** is checked
   - **IMPORTANT**: Ensure **Target Membership** only includes `PauzaDeviceActivityMonitor` (NOT Runner)
   - Click **Add**

### 4.6 Verify the extension entry point

The template file's class `PauzaDeviceActivityMonitorExtension` extends `DeviceActivityMonitor`. Xcode's extension target needs to know this is the principal class. Check the extension's `Info.plist` (or target build settings) for:
```
NSExtension > NSExtensionPrincipalClass = PauzaDeviceActivityMonitor.PauzaDeviceActivityMonitorExtension
```

If Xcode generated a default entry point, update it to match the template class name.

---

## 5. Create Shield Configuration Extension

This extension provides custom UI for the restriction shield (the screen shown when a blocked app is opened).

### 5.1 Add the target

1. **File > New > Target...**
2. Search for **"Shield Configuration Extension"**
3. Click **Next**
4. Configure:
   - **Product Name**: `PauzaShieldConfiguration`
   - **Team**: Same team (`3Y39BWVBCM`)
   - **Language**: Swift
   - **Project**: Runner
   - **Embed in Application**: Runner
5. Click **Finish**

### 5.2 Set deployment target

1. Select **PauzaShieldConfiguration** target
2. **General** > **Minimum Deployments** > **iOS**: **16.0**

### 5.3 Add App Groups capability

1. **Signing & Capabilities** > **+ Capability** > **App Groups**
2. Add: `group.com.menace.pauza`

### 5.4 Add AppGroupIdentifier to extension Info.plist

Same as Section 4.4:
- **Key**: `AppGroupIdentifier`
- **Value**: `group.com.menace.pauza`

### 5.5 Replace the Swift source file

1. Delete the generated Swift file in `PauzaShieldConfiguration/`
2. Add the template:
   - Source: `../pauza_screen_time/docs/templates/PauzaShieldConfigurationExtension.swift`
   - Right-click `PauzaShieldConfiguration` group > **Add Files to "Runner"...**
   - Check **"Copy items if needed"**
   - Target Membership: only `PauzaShieldConfiguration`
   - Click **Add**

### 5.6 Verify the extension entry point

Check extension's `Info.plist` for:
```
NSExtension > NSExtensionPrincipalClass = PauzaShieldConfiguration.PauzaShieldConfigurationExtension
```

---

## 6. Create Device Activity Report Extension

This extension renders native usage reports (screen time data) within the app.

### 6.1 Add the target

1. **File > New > Target...**
2. Search for **"Device Activity Report Extension"**
3. Click **Next**
4. Configure:
   - **Product Name**: `PauzaDeviceActivityReport`
   - **Team**: Same team (`3Y39BWVBCM`)
   - **Language**: Swift
   - **Project**: Runner
   - **Embed in Application**: Runner
5. Click **Finish**

### 6.2 Set deployment target

1. Select **PauzaDeviceActivityReport** target
2. **General** > **Minimum Deployments** > **iOS**: **16.0**

### 6.3 Replace the Swift source file

1. Delete the generated Swift file in `PauzaDeviceActivityReport/`
2. Add the template:
   - Source: `../pauza_screen_time/docs/templates/PauzaDeviceActivityReportExtension.swift`
   - Right-click `PauzaDeviceActivityReport` group > **Add Files to "Runner"...**
   - Check **"Copy items if needed"**
   - Target Membership: only `PauzaDeviceActivityReport`
   - Click **Add**

> **Note**: This extension does not need App Groups unless you plan to pass custom configuration data to the report view. The template reads from `DeviceActivityResults` directly.

### 6.4 Verify the extension entry point

The template uses `@main struct PauzaDeviceActivityReportExtension: DeviceActivityReportExtension`. Ensure no other `@main` attribute conflicts within this target. The Dart side passes `reportContext: 'daily'` which matches the template's context ID.

---

## 7. Verify Signing Across All Targets

After creating all 3 extensions, verify consistent signing:

1. In Xcode, select the **Runner** project (not a target)
2. For **each** of these 4 targets, go to **Signing & Capabilities**:
   - `Runner`
   - `PauzaDeviceActivityMonitor`
   - `PauzaShieldConfiguration`
   - `PauzaDeviceActivityReport`
3. Confirm for each:
   - **Team**: `3Y39BWVBCM` (same across all)
   - **Automatically manage signing**: ON (recommended)
   - **No signing errors**

> Extensions automatically get a bundle ID like `com.menace.pauza.PauzaDeviceActivityMonitor`. These child bundle IDs inherit the parent App ID's capabilities when using automatic signing.

---

## 8. Verify Extension Embedding

Xcode should auto-embed extensions, but verify:

1. Select **Runner** target > **General** tab
2. Scroll to **Frameworks, Libraries, and Embedded Content** (or **Embed Extensions**)
3. Confirm all 3 extensions appear:
   - `PauzaDeviceActivityMonitor.appex`
   - `PauzaShieldConfiguration.appex`
   - `PauzaDeviceActivityReport.appex`

If any are missing, click **+** and add them with **Embed & Sign**.

---

## 9. Clean Build and Run

From the project root (`pauza-app/`):

```bash
# Clean everything
flutter clean
flutter pub get

# Reinstall pods with updated platform target
cd ios
pod install --repo-update
cd ..

# Build and run on physical iOS device
flutter run -d <your_ios_device_id>
```

To find your device ID:
```bash
flutter devices
```

> **First build after adding extensions** will take longer. Subsequent builds are incremental.

If you encounter build errors:
- **"No such module 'DeviceActivity'"** — ensure the extension target's deployment target is iOS 16.0+
- **"Multiple commands produce..."** — clean the build folder: Xcode > Product > Clean Build Folder (Cmd+Shift+K)
- **Signing errors** — toggle automatic signing off/on for the affected target

---

## 10. Runtime Verification Checklist

Test each feature on a **physical iPhone** running iOS 16+:

### Screen Time / FamilyControls
- [ ] App launches without crash
- [ ] FamilyControls authorization prompt appears when requesting permission
- [ ] After granting, `checkIOSPermission(IOSPermission.familyControls)` returns `granted`
- [ ] App picker (FamilyActivityPicker) opens and returns selected app tokens
- [ ] Restrictions apply: opening a blocked app shows the shield screen
- [ ] Custom shield configuration (title, colors, buttons) appears correctly

### Pause & Auto-Resume
- [ ] `pauseEnforcement(Duration(minutes: 1))` clears restrictions immediately
- [ ] After 1 minute, restrictions re-apply automatically (even with app in background)
- [ ] Works even if the app is terminated during the pause interval

### Scheduled Restrictions
- [ ] Scheduled mode activates at the configured time
- [ ] Scheduled mode deactivates when the interval ends
- [ ] Schedule changes propagate correctly

### Usage Reports
- [ ] `IOSUsageReportView(reportContext: 'daily', ...)` renders screen time data
- [ ] Report shows actual usage data (not blank)

### NFC
- [ ] NFC scan flow starts on physical device
- [ ] iOS NFC reader prompt appears
- [ ] Tag can be read and data returned to the app

### Camera / QR
- [ ] Camera permission prompt appears for QR scanning
- [ ] QR codes can be scanned successfully

### Background Tasks
- [ ] Background task `com.menace.pauza.restriction_lifecycle_daily_sync` registers without error

---

## 11. Troubleshooting

### "Provisioning profile doesn't include the App Groups entitlement"
- Go to Apple Developer portal > App ID > enable App Groups
- Toggle automatic signing off/on in Xcode to regenerate profiles

### "Provisioning profile doesn't include NFC capability"
- Go to Apple Developer portal > App ID > enable Near Field Communication Tag Reading
- Toggle automatic signing off/on

### Extension doesn't seem to run (pause doesn't auto-resume)
- Verify the Device Activity Monitor extension target exists and is embedded
- Verify `AppGroupIdentifier` is set in both Runner's and the extension's Info.plist to the same value (`group.com.menace.pauza`)
- Verify App Groups capability is enabled on the extension target
- Check Console.app (filter by extension name) for runtime errors

### Shield shows default iOS UI instead of custom configuration
- Verify the Shield Configuration extension target exists and is embedded
- Verify `AppGroupIdentifier` matches across Runner and extension
- Verify `shieldConfiguration` key is being written to App Group UserDefaults (check via `configureShield()` Dart call)

### Usage report view is blank or doesn't render
- Verify the Device Activity Report extension exists and is embedded
- Verify the `reportContext` string in Dart matches the context ID in the extension (`"daily"`)
- Test with a time range that has actual device usage data

### NFC scan never starts
- Must be a physical device (not simulator)
- Verify `NFCReaderUsageDescription` in Info.plist
- Verify NFC entitlement (`TAG`) in Runner.entitlements
- Verify NFC capability enabled on App ID in Apple Developer portal
- Verify device supports NFC (iPhone 7 and later)

### Build fails with "No such module 'FamilyControls'"
- Extension deployment target must be iOS 16.0+
- Clean build folder (Cmd+Shift+K) and rebuild

### Works in Debug but fails in Release
- Release provisioning profile may be stale
- Regenerate distribution profile separately in Apple Developer portal
- Or toggle automatic signing off/on to refresh

---

## Quick Reference: Key Identifiers

| Item | Value |
|------|-------|
| Bundle ID | `com.menace.pauza` |
| Team ID | `3Y39BWVBCM` |
| App Group | `group.com.menace.pauza` |
| iOS Deployment Target | 16.0 |
| Background Task ID | `com.menace.pauza.restriction_lifecycle_daily_sync` |
| Pause Activity Name | `pauza_pause_auto_resume` |
| Schedule Activity Prefix | `pauza.schedule.mode.` |

## Quick Reference: Template Files

| Extension | Template Path (relative to monorepo root) |
|-----------|---------------------------------------------|
| Device Activity Monitor | `pauza_screen_time/docs/templates/PauzaDeviceActivityMonitorExtension.swift` |
| Shield Configuration | `pauza_screen_time/docs/templates/PauzaShieldConfigurationExtension.swift` |
| Device Activity Report | `pauza_screen_time/docs/templates/PauzaDeviceActivityReportExtension.swift` |

## Quick Reference: Shared UserDefaults Keys (App Group)

These keys are read/written by the plugin and extensions via `UserDefaults(suiteName: "group.com.menace.pauza")`:

| Key | Type | Purpose |
|-----|------|---------|
| `pausedUntilEpochMs` | Int64 | When the current pause expires |
| `activeSession` | Dictionary | Current restriction session (modeId, blockedAppIds, source) |
| `scheduleEnforcementEnabled` | Bool | Whether schedule-based enforcement is active |
| `modes` | Array | List of restriction modes with schedules |
| `lifecycleEvents` | Array | Event queue for restriction lifecycle |
| `lifecycleEventSeq` | Int64 | Sequence counter for lifecycle events |
| `sessionIdSeq` | Int64 | Sequence counter for session IDs |
| `shieldConfiguration` | Dictionary | Shield UI configuration (title, colors, icon) |
| `suppressedScheduleModeId` | String | Currently suppressed scheduled mode |
| `suppressedScheduleUntilEpochMs` | Int64 | When schedule suppression expires |
