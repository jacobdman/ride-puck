# RidePuck

A minimalist motorcycle dashboard companion for the 2023 Indian Scout Bobber. RidePuck pairs an iPhone app with a circular ESP32-S3 display over Bluetooth Low Energy to show speed, turn-by-turn navigation, distance to the next maneuver, and ETA — without replacing the stock gauge or reading motorcycle ECU data in V1.

## Architecture

```
iPhone App (Flutter + Mapbox)
        |
        | Bluetooth Low Energy (JSON dashboard state)
        v
ESP32-S3 Round Display (ESP-IDF + LVGL)
```

The phone handles GPS, routing, ETA, settings, and updates. The display receives a versioned dashboard state object and renders a purpose-built riding UI.

## Repository Layout

| Path | Description |
|------|-------------|
| `mobile/ridepuck_app/` | Flutter iOS companion app |
| `firmware/ridepuck_display/` | ESP-IDF firmware for the round display |
| `shared/` | BLE protocol schema and shared types |
| `docs/` | Architecture, protocol, and setup guides |

## Getting Started

This repo is scaffolded for development. See the setup guides before building or flashing:

- [Development Setup](docs/setup.md)
- [Architecture Overview](docs/architecture.md)
- [BLE Protocol](docs/ble-protocol.md)

### Quick prerequisites

**Mobile app**
- Flutter SDK (stable channel)
- Xcode (for iOS builds)
- Mapbox access token

**Firmware**
- ESP-IDF v5.x
- ESP32-S3 round display board
- USB serial connection for flashing

## MVP Goals

- ESP32 display boots reliably and renders the ride UI
- Phone connects automatically over BLE
- App sends live GPS speed and next navigation instruction
- Display handles no-route, lost-phone, and reconnecting states

## Non-Goals (V1)

Motorcycle CAN bus integration, fuel/RPM/warning lights, touch-heavy UI, music controls, weather, full map display, and stock gauge replacement.

## License

TBD
