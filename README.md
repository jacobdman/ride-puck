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
- [Phone Testing (no hardware)](docs/phone-testing.md)
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

## Phone testing (no hardware)

If you do not have the ESP32 display yet, validate on your iPhone first:

| Test | Goal | Guide |
|------|------|-------|
| **Test 1** | App installs, live GPS speed on home screen | [docs/phone-testing.md](docs/phone-testing.md) |
| **Test 2** | Mapbox turn-by-turn + on-phone display preview | [docs/phone-testing.md](docs/phone-testing.md) |

Phase 1 firmware/BLE code is in the repo; hardware verification waits until the board arrives.

## Roadmap

### Phase 0 — Foundation

- [x] Monorepo scaffold (mobile, firmware, shared protocol, docs)
- [x] Flutter project generated (`com.ridepuck.ridepuck_app`)
- [x] BLE dashboard state schema and protocol docs
- [x] ESP-IDF firmware skeleton with UI screen routing stubs

### Phase 1 — Desk prototype

Goal: prove the display and phone can talk before adding real navigation.

- [x] Flash ESP32-S3 round display and bring up LVGL (code complete — verify on hardware)
- [x] Render static ride UI (speed, maneuver arrow, distance, street name)
- [x] Feed fake speed/navigation data on-device
- [x] Implement BLE GATT server on display
- [x] Implement BLE client in phone app
- [x] Send mock `DashboardState` from phone → display
- [x] Verify all four screens: waiting, no-route, ride, error/reconnecting

### Phase 2 — V1 MVP (ride-ready, in progress)

Goal: a working navigation companion you can test in a car, then on the bike.

- [x] Wire live GPS speed from phone (home screen + navigation preview)
- [x] Integrate Mapbox Navigation SDK (turn-by-turn on phone)
- [ ] Stream real maneuver, distance, street name, and ETA over BLE
- [ ] Automatic BLE reconnect after power loss
- [ ] Smooth UI updates at riding speeds
- [ ] Car testing on real routes
- [ ] Motorcycle field testing on the Scout Bobber

**V1 success criteria:** display boots reliably, phone auto-connects, live speed and next instruction render clearly, and lost-phone / no-route / reconnect states all work.

### Phase 3 — V2 enhancements

Goal: richer riding experience without changing the core display philosophy.

- [ ] Music metadata (now playing)
- [ ] Incoming call indicator
- [ ] Weather / temperature
- [ ] Favorite destinations
- [ ] Offline route caching
- [ ] OTA firmware updates (Wi-Fi)
- [ ] Custom ride modes
- [ ] Trip stats

### Phase 4 — Vehicle telemetry (future)

Goal: motorcycle-specific data via adapters, keeping the display UI bike-agnostic.

- [ ] Scout telemetry adapter
- [ ] Fuel level, RPM, neutral, high beam, turn signals
- [ ] CAN bus / ECU integration (optional path)
- [ ] Normalized `vehicle` state in dashboard protocol

### Explicitly out of scope for V1

Motorcycle CAN bus integration, fuel/RPM/warning lights, touch-heavy UI, music controls, weather, full map display, and stock gauge replacement.

## License

TBD
