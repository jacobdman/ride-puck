# RidePuck Display Firmware

ESP-IDF firmware for the ESP32-S3 round display. Receives dashboard state over BLE and renders the riding UI with LVGL.

## Status

Initial scaffold — requires ESP-IDF and display board configuration before build.

## Prerequisites

- ESP-IDF v5.2+
- ESP32-S3 round display dev board
- USB serial connection

## Setup

```bash
# Source ESP-IDF environment first
source $IDF_PATH/export.sh

cd firmware/ridepuck_display
idf.py set-target esp32s3
idf.py build
idf.py -p /dev/ttyUSB0 flash monitor
```

## Structure

```
main/
├── main.c                  # Entry point, BLE + UI orchestration
├── dashboard_state.h       # Parsed state types (mirrors shared schema)
├── ble_server.c/h          # BLE GATT server (TODO)
└── ui/
    ├── ui_manager.c/h      # Screen routing (ride, waiting, error)
    └── screens/              # LVGL screen implementations (TODO)
```

## Configuration

Edit `sdkconfig.defaults` for your display pinout and BLE device name.

## Next Steps

1. Add LVGL component and display driver for your round board
2. Implement BLE GATT server with dashboard state characteristic
3. Parse incoming JSON into `dashboard_state_t`
4. Render static ride screen with mock data
5. Wire BLE updates to LVGL screen transitions
