# ScoutOS Mobile App

Flutter iOS companion app for ScoutOS. Handles GPS, Mapbox turn-by-turn navigation, and BLE dashboard state transmission to the round display.

## Status

Initial scaffold — not yet runnable until Flutter project files are generated.

## Setup

```bash
# From this directory
flutter create . --org com.scoutos --project-name scoutos_app
flutter pub get
cp .env.example .env
# Edit .env with your Mapbox token
```

## Structure

```
lib/
├── main.dart
├── app.dart
├── models/
│   └── dashboard_state.dart    # BLE payload types
├── services/
│   ├── ble_service.dart        # BLE connection + transmission
│   └── dashboard_state_builder.dart
└── screens/
    └── home_screen.dart        # Connection status + mock controls
```

## Next Steps

1. Run `flutter create` to generate `ios/` and platform files
2. Add Mapbox Navigation SDK via native iOS bridge
3. Implement BLE GATT client (service UUID in `docs/ble-protocol.md`)
4. Wire live GPS speed from `geolocator`
5. Replace mock stream with Mapbox active guidance state
