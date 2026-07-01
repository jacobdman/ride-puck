#include "dashboard_state.h"

#include "cJSON.h"

#include <stdlib.h>
#include <string.h>

static maneuver_type_t parse_maneuver(const char *value)
{
    if (value == NULL) {
        return MANEUVER_NONE;
    }
    if (strcmp(value, "left") == 0) {
        return MANEUVER_LEFT;
    }
    if (strcmp(value, "right") == 0) {
        return MANEUVER_RIGHT;
    }
    if (strcmp(value, "slight-left") == 0) {
        return MANEUVER_SLIGHT_LEFT;
    }
    if (strcmp(value, "slight-right") == 0) {
        return MANEUVER_SLIGHT_RIGHT;
    }
    if (strcmp(value, "straight") == 0) {
        return MANEUVER_STRAIGHT;
    }
    if (strcmp(value, "u-turn") == 0) {
        return MANEUVER_U_TURN;
    }
    if (strcmp(value, "arrive") == 0) {
        return MANEUVER_ARRIVE;
    }
    if (strcmp(value, "depart") == 0) {
        return MANEUVER_DEPART;
    }
    if (strcmp(value, "merge") == 0) {
        return MANEUVER_MERGE;
    }
    if (strcmp(value, "roundabout") == 0) {
        return MANEUVER_ROUNDABOUT;
    }
    return MANEUVER_NONE;
}

static bool copy_string_field(char *dest, size_t dest_len, const cJSON *obj, const char *key)
{
    const cJSON *item = cJSON_GetObjectItemCaseSensitive(obj, key);
    if (!cJSON_IsString(item) || item->valuestring == NULL) {
        dest[0] = '\0';
        return false;
    }
    strncpy(dest, item->valuestring, dest_len - 1);
    dest[dest_len - 1] = '\0';
    return true;
}

dashboard_state_t dashboard_state_default(void)
{
    dashboard_state_t state = {0};
    state.version = 1;
    return state;
}

bool dashboard_state_parse(const char *json, size_t len, dashboard_state_t *out)
{
    if (json == NULL || out == NULL || len == 0) {
        return false;
    }

    char *json_copy = malloc(len + 1);
    if (json_copy == NULL) {
        return false;
    }
    memcpy(json_copy, json, len);
    json_copy[len] = '\0';

    cJSON *root = cJSON_Parse(json_copy);
    free(json_copy);

    if (root == NULL) {
        return false;
    }

    dashboard_state_t state = dashboard_state_default();

    const cJSON *version = cJSON_GetObjectItemCaseSensitive(root, "version");
    const cJSON *timestamp = cJSON_GetObjectItemCaseSensitive(root, "timestamp");
    const cJSON *ride = cJSON_GetObjectItemCaseSensitive(root, "ride");
    const cJSON *navigation = cJSON_GetObjectItemCaseSensitive(root, "navigation");
    const cJSON *device = cJSON_GetObjectItemCaseSensitive(root, "device");

    if (!cJSON_IsNumber(version) || version->valueint != 1) {
        cJSON_Delete(root);
        return false;
    }
    if (!cJSON_IsNumber(timestamp)) {
        cJSON_Delete(root);
        return false;
    }
    if (!cJSON_IsObject(ride) || !cJSON_IsObject(navigation)) {
        cJSON_Delete(root);
        return false;
    }

    state.version = version->valueint;
    state.timestamp = (uint64_t)timestamp->valuedouble;

    const cJSON *speed_mph = cJSON_GetObjectItemCaseSensitive(ride, "speedMph");
    if (!cJSON_IsNumber(speed_mph) || speed_mph->valuedouble < 0) {
        cJSON_Delete(root);
        return false;
    }
    state.ride.speed_mph = (float)speed_mph->valuedouble;

    const cJSON *heading_deg = cJSON_GetObjectItemCaseSensitive(ride, "headingDeg");
    if (cJSON_IsNumber(heading_deg)) {
        state.ride.heading_deg = (float)heading_deg->valuedouble;
        state.ride.has_heading = true;
    }

    const cJSON *active = cJSON_GetObjectItemCaseSensitive(navigation, "active");
    if (!cJSON_IsBool(active)) {
        cJSON_Delete(root);
        return false;
    }
    state.navigation.active = cJSON_IsTrue(active);

    const cJSON *maneuver = cJSON_GetObjectItemCaseSensitive(navigation, "maneuver");
    if (cJSON_IsString(maneuver)) {
        state.navigation.maneuver = parse_maneuver(maneuver->valuestring);
    }

    const cJSON *distance_meters = cJSON_GetObjectItemCaseSensitive(navigation, "distanceMeters");
    if (cJSON_IsNumber(distance_meters)) {
        state.navigation.distance_meters = (float)distance_meters->valuedouble;
    }

    copy_string_field(state.navigation.instruction, sizeof(state.navigation.instruction),
                      navigation, "instruction");
    copy_string_field(state.navigation.street_name, sizeof(state.navigation.street_name),
                      navigation, "streetName");

    const cJSON *eta_minutes = cJSON_GetObjectItemCaseSensitive(navigation, "etaMinutes");
    if (cJSON_IsNumber(eta_minutes)) {
        state.navigation.eta_minutes = eta_minutes->valueint;
    }

    if (cJSON_IsObject(device)) {
        state.has_device = true;
        const cJSON *phone_battery = cJSON_GetObjectItemCaseSensitive(device, "phoneBattery");
        if (cJSON_IsNumber(phone_battery)) {
            state.device.phone_battery = phone_battery->valueint;
        }
        copy_string_field(state.device.gps_signal, sizeof(state.device.gps_signal), device,
                            "gpsSignal");
    }

    cJSON_Delete(root);
    *out = state;
    return true;
}
