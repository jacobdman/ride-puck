#include "dashboard_state.h"

#include <string.h>

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

    // TODO: integrate cJSON or similar for production parsing.
    // Placeholder: accept only for scaffolding; real parser comes in milestone 1.
    (void)json;
    (void)len;
    *out = dashboard_state_default();
    return false;
}
