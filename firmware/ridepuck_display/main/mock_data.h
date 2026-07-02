#pragma once

#include "dashboard_state.h"

#include "esp_err.h"

/// Start the on-device mock data task (no-op if disabled in Kconfig).
esp_err_t mock_data_start(void);

/// Stop the mock data task.
void mock_data_stop(void);

/// Build the default mock ride state used for desk testing.
dashboard_state_t mock_data_ride_state(void);
