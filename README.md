# Mobile-Client

A Flutter mobile application that acts as the end-user client for **MHub**, a middleware for collecting, processing, and delivering real-time air-quality alerts from BLE-connected sensors to citizens' smartphones.

## Description

Mobile-Client is the mobile-facing piece of a larger air-quality-monitoring system built as an undergraduate thesis (TCC) project. The app connects to a Mobile Hub instance (provided by the [`MHub-package`](https://github.com/EnQyMo/MHub-package) plugin) over a local IP/port, scans for nearby Bluetooth Low Energy (BLE) sensor devices, and listens for structured pollutant/alert messages pushed from the hub. Alerts are displayed to the user grouped by sensor, showing the pollutant detected, its risk level (`low` / `moderate` / `high`), and the possible health effects associated with it.

The app is built with Flutter and targets Android, iOS, Linux, macOS, Windows, and Web from a single codebase, following an MVVM-style architecture (`view_models` + `widgets`, backed by `ChangeNotifier` and the `provider` package).

## Dataset Information

This repository does not ship a static dataset. Instead, it consumes a **live stream of alert messages** at runtime, produced by the MHub middleware from real or simulated sensor readings. Each alert message received by the app is a JSON object with roughly the following shape:

```json
{
  "alert_id": "string",
  "timestamp": "ISO-8601 datetime string",
  "analisys": {
    "alert_id": "string",
    "timestamp": "ISO-8601 datetime string",
    "sensores": [
      {
        "sensor_id": "string",
        "poluentes": [
          {
            "poluente": "string (pollutant name)",
            "risk_level": "low | moderate | high",
            "affected_diseases": {
              "disease": ["string", "..."]
            }
          }
        ]
      }
    ]
  }
}
```

Nearby BLE devices discovered during a scan are represented as:

```json
{
  "uuid": "string",
  "name": "string",
  "rssi": "number"
}
```

No sample data files are stored in this repo; to see live data you must run the app against a reachable Mobile Hub instance (see [Usage Instructions](#usage-instructions)).

## Code Information

```
lib/
├── main.dart                      # App entry point, sets up the HomePageView
├── core/
│   ├── message_service.dart       # Singleton that listens to alert messages from the plugin
│   └── ble_devices_service.dart   # Singleton that manages BLE scanning and device discovery
└── ui/
    ├── home/                      # Main screen: lists incoming air-quality alerts
    ├── settings/                  # Screen to configure the Hub's IP/port and start/stop it
    └── ble_devices/               # Screen listing nearby BLE devices and signal strength
```

- **`core/message_service.dart`** — subscribes to `Plugin().onMessageReceived`, decodes incoming JSON, and exposes the alert history as a stream/list to the UI layer.
- **`core/ble_devices_service.dart`** — starts/stops BLE listening via the plugin, deduplicates devices by UUID, and periodically pushes the list of nearby device UUIDs back to the hub as context.
- **`ui/settings`** — validates the hub's IPv4 address and port, requests location/notification permissions, and starts or stops the Mobile Hub connection.
- **`ui/home`** — renders the list of alerts, grouped per sensor, with a color-coded risk badge (green/yellow/red) and the associated health effects.
- **`ui/ble_devices`** — renders a live list of discovered BLE devices with name, UUID, and RSSI.

All hub/BLE/plugin communication is delegated to the external `plugin` package (from `MHub-package`), which this app depends on as a local path dependency.

## Usage Instructions

1. Clone this repository and the companion plugin package:
   ```bash
   git clone https://github.com/EnQyMo/Mobile-Client.git
   git clone https://github.com/EnQyMo/MHub-package.git
   ```
2. Point `pubspec.yaml`'s `plugin` dependency at your local copy of `MHub-package`:
   ```yaml
   dependencies:
     plugin:
       path: ../MHub-package   # adjust to wherever you cloned it
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```
5. In the app, open the menu (top-left) → **Configurações** (Settings), enter the IP address and port of a running Mobile Hub instance, and tap **Iniciar Mobile Hub**. Grant the requested location/notification permissions when prompted.
6. Once connected, incoming alerts appear on the home screen; nearby BLE devices can be viewed from the menu → **Dispositivos BLE**.
7. To disconnect, return to Settings and tap **Parar Mobile Hub**.

## Requirements

- Flutter SDK compatible with Dart `^3.8.1`
- A running instance of the [MHub-package](https://github.com/EnQyMo/MHub-package) plugin/middleware, reachable over the local network
- Android: minimum SDK supporting `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `ACCESS_FINE_LOCATION`, `FOREGROUND_SERVICE_LOCATION`, and `POST_NOTIFICATIONS` permissions
- Key Dart packages (see `pubspec.yaml` for exact versions):
  - `flutter`, `provider`, `intl`, `permission_handler`, `cupertino_icons`, `flutter_lorem`
  - Dev/test: `flutter_test`, `integration_test`, `flutter_lints`, `mocktail`

## Methodology

The app follows this runtime data flow:

1. **Configuration** — the user supplies the Mobile Hub's IP address and port in the Settings screen; the app validates the IPv4 format and port range before proceeding.
2. **Permission handling** — location and notification permissions are requested, since BLE scanning on Android requires location access.
3. **Hub connection** — `SettingsViewModel.startMobileHub()` calls into the native plugin to start the Mobile Hub session.
4. **BLE discovery** — `BleDevicesService` starts listening to the plugin's BLE stream, deduplicating devices by UUID and periodically reporting the discovered device list back to the hub as "context" (every 3 seconds).
5. **Alert ingestion** — `MessageService` listens for JSON-encoded alert messages pushed by the hub, decodes them, and prepends them to an in-memory history exposed as a stream.
6. **Presentation** — `HomePageViewModel` consumes that stream and notifies the UI, which renders each alert as a card grouped by sensor, pollutant, computed risk level, and associated health effects.
7. **Teardown** — stopping the Mobile Hub cancels the BLE and message subscriptions and clears in-memory state.

Automated tests under `test/` cover each view model and widget (using `mocktail` for mocking the plugin, message service, and BLE service), plus a Flutter integration test in `integration_test/app_test.dart`.

## Citations

This app is part of an undergraduate thesis (TCC) project pairing a mobile client with the MHub middleware for air-quality monitoring. If you use or reference this work academically, please cite the companion middleware repository and any associated thesis/paper once published:

- MHub-package (middleware plugin): https://github.com/EnQyMo/MHub-package

No third-party dataset or prior published dataset is bundled with or required by this repository.

## License & Contribution Guidelines

No license file is currently included in this repository; the code is not licensed for reuse or redistribution until a license is added. Contact the repository owner (EnQyMo) before reusing this code.

Contributions: this repository does not currently define a formal contribution process. If you'd like to contribute, please open an issue first to discuss the proposed change before submitting a pull request.

## Reproduction Script

This repository does not simulate or generate a dataset itself — alert data is produced live by the external MHub middleware from sensor input. There is therefore no standalone "reproduce the dataset" script within this codebase.

To reproduce the *app's* behavior end-to-end for testing/demo purposes:

1. Run an instance of `MHub-package` configured to emit simulated sensor/pollutant readings (see that repository's own documentation for its simulation/reproduction script, if provided).
2. Run this app (`flutter run`) and connect it to that hub instance via the Settings screen, as described in [Usage Instructions](#usage-instructions).
3. Optionally, run the bundled tests to exercise the message-parsing and BLE-handling logic against mocked plugin data:
   ```bash
   flutter test
   flutter test integration_test/app_test.dart
   ```
