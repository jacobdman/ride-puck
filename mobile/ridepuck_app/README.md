# RidePuck Mobile App

Flutter iOS companion app for RidePuck. Handles GPS, Mapbox turn-by-turn navigation, and BLE dashboard state transmission to the round display.

## Status

Phase 1 desk prototype — BLE GATT client, mock dashboard streaming, and connection UI for desk testing with the ESP32 display.

## Setup

```bash
# From this directory
flutter pub get
cp .env.example .env   # optional — app falls back to .env.example
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

1. Add Mapbox Navigation SDK via native iOS bridge
2. Wire live GPS speed from `geolocator`
3. Replace mock stream with Mapbox active guidance state
