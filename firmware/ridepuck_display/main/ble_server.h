#pragma once

#include "esp_err.h"

/// Initialize BLE GATT server and start advertising as "RidePuck".
esp_err_t ble_server_init(void);

/// Register callback invoked when a new dashboard state JSON payload arrives.
typedef void (*ble_dashboard_state_cb_t)(const char *json, size_t len);
void ble_server_set_dashboard_callback(ble_dashboard_state_cb_t cb);
