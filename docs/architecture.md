# Architecture

## Overview

RidePuck is a two-part system: a phone companion app and an ESP32-S3 round display. The phone owns all complex logic; the display is a thin BLE client that renders glanceable ride information.

## Components

### Mobile App (`mobile/ridepuck_app`)

| Concern | Technology |
|---------|------------|
| UI | Flutter |
| Turn-by-turn navigation | Mapbox Navigation SDK |
| Device communication | Bluetooth Low Energy |
| Platform bridge | Native iOS (if needed for Mapbox SDK) |

Responsibilities:
- GPS speed and heading
- Route calculation and active guidance
- ETA and maneuver extraction
- BLE connection management and auto-reconnect
- Settings and future OTA coordination

### Firmware (`firmware/ridepuck_display`)

| Concern | Technology |
|---------|------------|
| RTOS / framework | ESP-IDF |
| UI rendering | LVGL |
| Connectivity | BLE GATT server |
| Future updates | Wi-Fi OTA (V2) |

Responsibilities:
- Fast boot and automatic BLE reconnect
- Parse incoming dashboard state
- Render ride, waiting, no-route, and error screens
- Minimal on-device state

## Data Flow

```
┌─────────────────┐     BLE GATT      ┌──────────────────┐
│   iPhone App    │ ────────────────> │  ESP32 Display   │
│                 │  DashboardState   │                  │
│  GPS + Mapbox   │     (JSON v1)     │  LVGL UI render  │
└─────────────────┘                   └──────────────────┘
```

## Display Screens (V1)

| Screen | Trigger | Content |
|--------|---------|---------|
| Primary Ride | Active route + moving | Speed, maneuver arrow, distance, street name |
| No Route | Connected, no active navigation | Speed, "No Route", connection status |
| Waiting | Boot / no phone | "RidePuck", "Waiting for phone..." |
| Error | BLE disconnect | "Connection Lost", "Reconnecting" |

## Long-Term Normalized State

The display should remain motorcycle-agnostic. Internally it only consumes a normalized dashboard state:

```
DashboardState
├── ride: RideState          (speed, heading)
├── navigation: NavigationState (maneuver, distance, ETA, ...)
├── media?: MediaState       (V2)
└── vehicle?: VehicleState   (V2 — Scout telemetry adapter)
```

Future motorcycle-specific adapters (CAN bus, Scout telemetry) feed into `vehicle` without changing the display UI contract.

## V1 Non-Goals

- ECU / CAN bus reads
- Fuel, RPM, warning lights
- Touch-heavy interactions
- Full map rendering on the display
- Replacing the stock gauge
