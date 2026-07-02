# Development Setup

Initial setup guide for the RidePuck monorepo. This covers environment preparation only — not full build, flash, or device testing.

## 1. Clone and branch

```bash
git clone https://github.com/jacobdman/ride-puck.git
cd ride-puck
```

## 2. Mobile app (`mobile/ridepuck_app`)

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- Xcode 15+ with iOS toolchain
- CocoaPods (`sudo gem install cocoapods`)
- Apple Developer account (for device testing)

### Bootstrap

```bash
cd mobile/ridepuck_app
flutter pub get
cp .env.example .env   # optional — app falls back to .env.example
```

Edit `.env` and set your Mapbox token:

```
MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

Platform files (`ios/`, `android/`, etc.) are already generated. To regenerate:

```bash
flutter create . --org com.ridepuck --project-name ridepuck_app
flutter pub get
```

### Run (when ready)

```bash
flutter run -d <ios-device-id>
```

## 3. Firmware (`firmware/ridepuck_display`)

### Prerequisites

- [ESP-IDF v5.2+](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/get-started/index.html)
- ESP32-S3 round display dev board
- USB data cable

### Bootstrap

```bash
cd firmware/ridepuck_display
idf.py set-target esp32s3
idf.py menuconfig   # optional: configure display pins / BLE name
```

### Build and flash (when ready)

```bash
idf.py build
idf.py -p /dev/ttyUSB0 flash monitor
```

## 4. Shared protocol

The BLE payload format is defined in:

- `shared/dashboard-state.schema.json`
- `docs/ble-protocol.md`

Keep mobile serialization and firmware parsing aligned with this schema.

## 5. Recommended milestones

**No hardware yet?** Start with phone testing:

1. [Phone testing guide](phone-testing.md) — Test 1: app on your iPhone with live GPS
2. [Phone testing guide](phone-testing.md) — Test 2: Mapbox turn-by-turn + display preview

**When the ESP32 display arrives**, continue with the desk prototype sequence:

1. Flash ESP32-S3 and render a static LVGL screen
2. Feed fake speed/navigation data on-device
3. Add BLE connection and receive mock dashboard state from the phone
4. Stream live phone GPS + Mapbox navigation over BLE
5. Test in a car before motorcycle use

## 6. Environment variables

| Variable | Used by | Required |
|----------|---------|----------|
| `MAPBOX_ACCESS_TOKEN` | Mobile app | Yes (for navigation) |

## Troubleshooting

- **Flutter iOS build fails**: run `cd ios && pod install`
- **ESP-IDF not found**: source the ESP-IDF export script (`source $IDF_PATH/export.sh`)
- **BLE pairing issues**: ensure only one phone is connected; power-cycle the display
