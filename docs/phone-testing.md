# Phone Testing (No Hardware)

Use these milestones to validate RidePuck on your phone before the ESP32 display arrives. Hardware desk tests can wait until the board is in hand.

## Prerequisites

- Mac with [Flutter stable](https://docs.flutter.dev/get-started/install) and Xcode 15+
- iPhone with USB cable (or wireless debugging enabled in Xcode)
- Apple Developer account (free tier works for personal device testing)
- [Mapbox account](https://account.mapbox.com/) (required for Test 2)

## Test 1 — App on your phone

Goal: install the app, grant permissions, and see live GPS speed without the display.

### 1. Bootstrap

```bash
cd mobile/ridepuck_app
flutter pub get
cp .env.example .env   # optional for Test 1 — placeholder token is fine
```

### 2. Verify toolchain

```bash
flutter doctor
```

Resolve any iOS toolchain issues before continuing.

### 3. iOS code signing

```bash
open ios/Runner.xcworkspace
```

In Xcode:

1. Select the **Runner** target
2. Open **Signing & Capabilities**
3. Choose your **Team**
4. Ensure **Automatically manage signing** is enabled

### 4. Run on device

Connect your iPhone, then:

```bash
flutter devices
flutter run -d <your-iphone-id>
```

### 5. On-device checks

- [ ] App launches to the home screen
- [ ] Grant **Location** when prompted — speed (MPH) updates when you move
- [ ] Config card shows Mapbox token status (placeholder is OK for Test 1)
- [ ] BLE shows disconnected with “requires display hardware” — expected
- [ ] “Connect to display” fails gracefully if you tap it without hardware

### Troubleshooting

| Issue | Fix |
|-------|-----|
| `flutter doctor` iOS errors | Install Xcode command-line tools; open Xcode once to accept license |
| Signing failed | Set Team in Xcode Signing & Capabilities |
| Location always 0 MPH | Walk or drive briefly; simulator GPS is unreliable for speed |
| App won’t install | Trust developer certificate on iPhone: Settings → General → VPN & Device Management |

---

## Test 2 — Mapbox directions on your phone

Goal: start turn-by-turn navigation and see maneuver, distance, street, and ETA in the on-phone display preview.

### 1. Mapbox tokens

You need two tokens from [Mapbox account](https://account.mapbox.com/access-tokens/):

| Token | Scope | Used for |
|-------|-------|----------|
| Public (`pk...`) | Default public scopes | Runtime maps and navigation |
| Secret (`sk...`) | `DOWNLOADS:READ` | Downloading native SDK binaries at build time |

**Never commit secret tokens.**

### 2. Configure the public token

**Flutter `.env`:**

```
MAPBOX_ACCESS_TOKEN=pk.your_real_token_here
```

**iOS** — copy the example secrets file and add your token:

```bash
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
# Edit Secrets.xcconfig and set MAPBOX_ACCESS_TOKEN=pk...
```

**Android** — edit `android/app/src/main/res/values/mapbox_access_token.xml`:

```xml
<string name="mapbox_access_token" translatable="false" tools:ignore="UnusedResources">pk.your_token_here</string>
```

### 3. Configure the downloads token (one-time)

**iOS** — add to `~/.netrc`:

```
machine api.mapbox.com
  login mapbox
  password sk.your_downloads_token_here
```

**Android** — add to `~/.gradle/gradle.properties`:

```
MAPBOX_DOWNLOADS_TOKEN=sk.your_downloads_token_here
```

### 4. Enable Swift Package Manager (iOS, one-time)

```bash
flutter config --enable-swift-package-manager
```

### 5. Run and navigate

```bash
cd mobile/ridepuck_app
flutter pub get
flutter run -d <your-iphone-id>
```

On the home screen:

1. Confirm **Mapbox** config card shows “Configured”
2. Tap **Start Navigation**
3. Pick a preset destination
4. Tap **Build Route**, then **Start Navigation**
5. Watch the **Display preview** card update with speed, maneuver, distance, and ETA

For desk testing with weak GPS, enable **Simulate route** on the navigation screen. Turn it off for a real walk or drive.

### Test 2 success criteria

- [ ] Map renders on the navigation screen
- [ ] Route builds to a chosen destination
- [ ] Turn-by-turn guidance starts (banner + voice)
- [ ] Display preview updates live
- [ ] Stop navigation returns cleanly to the map

---

## Android appendix

The app supports Android, but iPhone is the primary target.

1. Enable developer mode and USB debugging on your Android device
2. Set `mapbox_access_token.xml` and `MAPBOX_DOWNLOADS_TOKEN` as above
3. `MainActivity` extends `FlutterFragmentActivity` (required by Mapbox)
4. Run: `flutter run -d <android-device-id>`

---

## What’s deferred until hardware

- BLE streaming of live navigation to the ESP32 display
- Firmware flash and on-device LVGL verification
- Car / motorcycle testing with the round display
