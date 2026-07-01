# BLE Protocol (V1)

## Transport

- **Protocol**: Bluetooth Low Energy (BLE 5)
- **Direction**: Phone (central) → Display (peripheral)
- **Payload format**: JSON (UTF-8)
- **Versioning**: `version` field in every message

Binary encoding may replace JSON in a future revision if bandwidth becomes a concern.

## GATT Service (planned)

| UUID | Role | Notes |
|------|------|-------|
| `0000FE00-0000-1000-8000-00805F9B34FB` | RidePuck Service | Placeholder — finalize before hardware bring-up |
| `0000FE01-0000-1000-8000-00805F9B34FB` | Dashboard State Characteristic | Notify / write from phone |

> UUIDs are placeholders for initial development. Assign official 128-bit UUIDs before production.

## Dashboard State Message

The phone sends a single versioned object on each update (or at a fixed interval, e.g. 2–5 Hz for speed).

### Example

```json
{
  "version": 1,
  "timestamp": 1782942340,
  "ride": {
    "speedMph": 47,
    "headingDeg": 82
  },
  "navigation": {
    "active": true,
    "maneuver": "right",
    "distanceMeters": 640,
    "instruction": "Turn right",
    "streetName": "Main St",
    "etaMinutes": 14
  },
  "device": {
    "phoneBattery": 82,
    "gpsSignal": "good"
  }
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | integer | yes | Protocol version (currently `1`) |
| `timestamp` | integer | yes | Unix epoch seconds |
| `ride.speedMph` | number | yes | Current speed in MPH |
| `ride.headingDeg` | number | no | Compass heading 0–359 |
| `navigation.active` | boolean | yes | Whether turn-by-turn guidance is active |
| `navigation.maneuver` | string | no | Maneuver type: `left`, `right`, `straight`, `u-turn`, `arrive`, etc. |
| `navigation.distanceMeters` | number | no | Distance to next maneuver |
| `navigation.instruction` | string | no | Human-readable instruction |
| `navigation.streetName` | string | no | Target street name |
| `navigation.etaMinutes` | integer | no | ETA to destination in minutes |
| `device.phoneBattery` | integer | no | Phone battery percentage |
| `device.gpsSignal` | string | no | `good`, `fair`, `poor`, `none` |

## Screen Mapping

| Condition | Display screen |
|-----------|----------------|
| BLE disconnected | Error — "Connection Lost" |
| Connected, no recent state | Waiting — "Waiting for phone..." |
| Connected, `navigation.active == false` | No Route |
| Connected, `navigation.active == true` | Primary Ride |

## Update Rate

| Data | Suggested rate |
|------|----------------|
| Speed / heading | 2–5 Hz while riding |
| Navigation maneuver | On change + periodic heartbeat (1 Hz) |
| Device metadata | 0.2 Hz |

## Schema

The canonical JSON Schema lives at `shared/dashboard-state.schema.json`.
