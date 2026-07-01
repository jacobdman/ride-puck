#pragma once

#include <stdbool.h>
#include <stdint.h>

/// Maneuver types — keep in sync with shared/dashboard-state.schema.json
typedef enum {
    MANEUVER_NONE = 0,
    MANEUVER_LEFT,
    MANEUVER_RIGHT,
    MANEUVER_SLIGHT_LEFT,
    MANEUVER_SLIGHT_RIGHT,
    MANEUVER_STRAIGHT,
    MANEUVER_U_TURN,
    MANEUVER_ARRIVE,
    MANEUVER_DEPART,
    MANEUVER_MERGE,
    MANEUVER_ROUNDABOUT,
} maneuver_type_t;

typedef struct {
    float speed_mph;
    float heading_deg;
    bool has_heading;
} ride_state_t;

typedef struct {
    bool active;
    maneuver_type_t maneuver;
    float distance_meters;
    char instruction[64];
    char street_name[64];
    int eta_minutes;
} navigation_state_t;

typedef struct {
    int phone_battery;
    char gps_signal[8];
} device_state_t;

typedef struct {
    int version;
    uint64_t timestamp;
    ride_state_t ride;
    navigation_state_t navigation;
    device_state_t device;
    bool has_device;
} dashboard_state_t;

/// Parse JSON payload into dashboard_state_t. Returns true on success.
bool dashboard_state_parse(const char *json, size_t len, dashboard_state_t *out);

/// Return a zeroed default state for boot / waiting screen.
dashboard_state_t dashboard_state_default(void);
