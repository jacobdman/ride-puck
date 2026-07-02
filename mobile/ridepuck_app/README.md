# RidePuck Mobile App

Flutter iOS companion app for RidePuck. Handles GPS, Mapbox turn-by-turn navigation, and BLE dashboard state transmission to the round display.

## Status

Phone-first testing — live GPS on the home screen, Mapbox turn-by-turn navigation, and an on-phone display preview. BLE streaming to the ESP32 display waits on hardware.

## Setup

```bash
# From this directory
flutter pub get
cp .env.example .env
# Edit .env with your Mapbox public token (pk...)
```

See [docs/phone-testing.md](../../docs/phone-testing.md) for iPhone device setup, Mapbox tokens, and test checklists.

## Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   └── mapbox_config.dart
├── models/
│   ├── dashboard_state.dart
│   └── navigation_progress.dart
├── services/
│   ├── ble_service.dart
│   ├── gps_service.dart
│   ├── navigation_service.dart
│   └── dashboard_state_builder.dart
├── screens/
│   ├── home_screen.dart
│   └── navigation_screen.dart
└── widgets/
    └── dashboard_preview_card.dart
```

## Next Steps

1. Verify on iPhone using [docs/phone-testing.md](../../docs/phone-testing.md)
2. When hardware arrives: stream live navigation over BLE to the display
