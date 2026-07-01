# Development Setup

Initial setup guide for the ScoutOS monorepo. This covers environment preparation only — not full build, flash, or device testing.

## 1. Clone and branch

```bash
git clone https://github.com/jacobdman/ride-puck.git
cd ride-puck
```

## 2. Mobile app (`mobile/scoutos_app`)

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- Xcode 15+ with iOS toolchain
- CocoaPods (`sudo gem install cocoapods`)
- Apple Developer account (for device testing)

### Bootstrap

```bash
cd mobile/scoutos_app
flutter pub get
cp .env.example .env
```

Edit `.env` and set your Mapbox token:

```
MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

### iOS project generation

If `ios/` is not yet generated:

```bash
flutter create . --org com.scoutos --project-name scoutos_app
flutter pub get
```

### Run (when ready)

```bash
flutter run -d <ios-device-id>
```

## 3. Firmware (`firmware/scoutos_display`)

### Prerequisites

- [ESP-IDF v5.2+](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/get-started/index.html)
- ESP32-S3 round display dev board
- USB data cable

### Bootstrap

```bash
cd firmware/scoutos_display
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

## 5. Recommended first milestone

Desk prototype sequence from the software plan:

1. Flash ESP32-S3 and render a static LVGL screen
2. Feed fake speed/navigation data on-device
3. Add BLE connection and receive mock dashboard state from the phone
4. Replace mock data with live phone GPS speed
5. Integrate Mapbox route state
6. Test in a car before motorcycle use

## 6. Environment variables

| Variable | Used by | Required |
|----------|---------|----------|
| `MAPBOX_ACCESS_TOKEN` | Mobile app | Yes (for navigation) |

## Troubleshooting

- **Flutter iOS build fails**: run `cd ios && pod install`
- **ESP-IDF not found**: source the ESP-IDF export script (`source $IDF_PATH/export.sh`)
- **BLE pairing issues**: ensure only one phone is connected; power-cycle the display
