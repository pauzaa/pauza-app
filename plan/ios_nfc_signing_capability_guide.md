# iOS NFC Capability and Signing Fix Guide

This guide explains how to fix iOS build/sign issues related to NFC capability (for `nfc_manager`) when building the Pauza app.

Use this when you see errors about:
- missing NFC entitlement
- provisioning profile does not include required capabilities
- code signing entitlement mismatch

---

## 1. Confirm project-side NFC configuration is present

Before changing Apple Developer settings, confirm these files already contain NFC setup:

1. `ios/Runner/Info.plist` contains:
   - `NFCReaderUsageDescription`
2. `ios/Runner/Runner.entitlements` contains:
   - `com.apple.developer.nfc.readersession.formats` with value `TAG`
3. `ios/Runner.xcodeproj/project.pbxproj` has:
   - `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` for Debug/Release/Profile

If these are missing, add/fix them first.

---

## 2. Enable NFC capability in Apple Developer portal

1. Open [Apple Developer](https://developer.apple.com/account/).
2. Go to **Certificates, Identifiers & Profiles**.
3. Open **Identifiers**.
4. Find your app ID (bundle id should match Xcode, e.g. `com.menace.pauza`).
5. Open the identifier details.
6. In **Capabilities**, enable **Near Field Communication Tag Reading**.
7. Save changes.

Notes:
- If the capability is already enabled, keep it as is.
- If you have multiple bundle IDs/environments (dev/stage/prod), repeat for each one.

---

## 3. Regenerate provisioning profile(s)

After changing capabilities on App ID, existing profiles may become stale.

### If you use manual signing

1. In Apple Developer portal, go to **Profiles**.
2. Locate the profile used by your app build (Development and/or Distribution).
3. Click **Edit**.
4. Keep same App ID and certificates, continue.
5. Click **Generate** to create updated profile.
6. Download the new `.mobileprovision`.
7. Install it (double-click or place in Xcode-managed profiles).

### If you use automatic signing

1. You usually do not need to manually download profiles.
2. Open Xcode and let it refresh signing assets (next section).

---

## 4. Refresh signing in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select **Runner** project (left sidebar), then **Runner** target.
3. Open **Signing & Capabilities**.
4. Verify:
   - Correct **Team**
   - Correct **Bundle Identifier**
   - **Automatically manage signing** is set according to your workflow
5. If automatic signing:
   - toggle **Automatically manage signing** off, then on again
   - this forces Xcode to refresh profile selection
6. If manual signing:
   - select the newly regenerated provisioning profile explicitly.

Optional cleanup if Xcode still uses old assets:
1. `Xcode > Settings > Accounts`
2. Select your Apple ID/team
3. Click **Download Manual Profiles** (or refresh profiles)

---

## 5. Clean and rebuild

From repo root:

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d <ios_device_id>
```

If CocoaPods is already healthy, `pod install` may report no changes.

---

## 6. Verify entitlements in built app

On successful build, verify runtime behavior:

1. Launch app on a physical iPhone (NFC does not work in iOS simulator).
2. Trigger NFC scan flow.
3. Confirm iOS NFC prompt/session appears and tag can be read.

If needed, inspect effective entitlements of built app in Xcode logs or with signing tools to verify `com.apple.developer.nfc.readersession.formats` is included.

---

## 7. Common errors and fixes

### Error: Provisioning profile doesn't include NFC capability
- Fix: enable NFC on App ID in Apple Developer portal and regenerate profile.

### Error: Entitlements file has key not allowed by profile
- Fix: profile is stale or wrong App ID/team selected; regenerate and reselect profile.

### Error: App installs but NFC scan never starts on iOS
- Check:
  1. real device (not simulator)
  2. `NFCReaderUsageDescription` exists
  3. entitlement key uses `TAG` value
  4. device supports NFC tag reading

### Error: Works in Debug but fails in Release
- Release profile is likely not regenerated or uses different App ID/team.
- Regenerate **distribution** profile separately.

---

## 8. Quick checklist

- [ ] App ID has **Near Field Communication Tag Reading** enabled
- [ ] Active provisioning profile regenerated after capability change
- [ ] Xcode uses correct team + bundle id + profile
- [ ] `Runner.entitlements` is linked in build settings
- [ ] `Info.plist` contains `NFCReaderUsageDescription`
- [ ] Tested on physical NFC-capable iPhone

