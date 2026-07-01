# RidePuck Display Firmware

ESP-IDF firmware for the ESP32-S3 round display. Receives dashboard state over BLE and renders the riding UI with LVGL.

## Status

Phase 1 desk prototype — LVGL UI, on-device mock data, BLE GATT server, and JSON dashboard parser.

## Target Hardware

Default pinout targets the **Waveshare ESP32-S3-Touch-LCD-1.28** (240×240 round, GC9A01). Edit [`main/board_config.h`](main/board_config.h) for other boards.

## Prerequisites

- ESP-IDF v5.2+
- ESP32-S3 round display dev board
- USB serial connection

## Setup

```bash
source $IDF_PATH/export.sh
cd firmware/ridepuck_display
idf.py set-target esp32s3
idf.py build
idf.py -p /dev/ttyUSB0 flash monitor
```

## Configuration

| Kconfig option | Default | Purpose |
|----------------|---------|---------|
| `CONFIG_RIDEPUCK_MOCK_DATA` | enabled | Feed mock ride state on-device without a phone |
| `CONFIG_RIDEPUCK_MOCK_CYCLE_SCREENS` | disabled | Alternate ride / no-route screens every 10s |

Disable mock data when testing phone → display BLE:

```bash
idf.py menuconfig  # RidePuck Configuration → disable mock data
```

## Structure

```
main/
├── main.c                  # Entry point, BLE + UI orchestration
├── board_config.h          # Display pinout (edit for your board)
├── display_driver.c/h      # GC9A01 + LVGL port
├── dashboard_state.c/h     # JSON parser (cJSON)
├── ble_server.c/h          # BLE GATT server
├── mock_data.c/h           # On-device mock dashboard task
└── ui/
    ├── ui_manager.c/h      # Screen routing
    └── screens/            # LVGL screen implementations
```

## BLE Protocol

See [`docs/ble-protocol.md`](../../docs/ble-protocol.md). Device advertises as **RidePuck**.
