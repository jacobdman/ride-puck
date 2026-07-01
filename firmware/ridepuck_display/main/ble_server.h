#pragma once

#include "esp_err.h"

#include <stddef.h>
#include <stdbool.h>

/// Initialize BLE GATT server and start advertising as "RidePuck".
esp_err_t ble_server_init(void);

/// Register callback invoked when a new dashboard state JSON payload arrives.
typedef void (*ble_dashboard_state_cb_t)(const char *json, size_t len);
void ble_server_set_dashboard_callback(ble_dashboard_state_cb_t cb);

/// Register callback invoked on BLE connect/disconnect.
typedef void (*ble_connection_cb_t)(bool connected);
void ble_server_set_connection_callback(ble_connection_cb_t cb);

/// Returns true when a central is connected.
bool ble_server_is_connected(void);
