<p align="center">
  <img src="speedo/Assets.xcassets/AppIcon.appiconset/icon-1024.png" width="128" alt="Speedo app icon">
</p>

<h1 align="center">Speedo</h1>

<p align="center">A no-frills GPS speedometer for iPhone: one huge number, nothing else.</p>

## Screenshots

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/driving.png" width="260" alt="Speedo showing 65 mph"></td>
    <td align="center"><img src="docs/screenshots/no-fix.png" width="260" alt="Speedo waiting for a GPS fix"></td>
  </tr>
  <tr>
    <td align="center">Cruising at 65 mph</td>
    <td align="center">Waiting for a GPS fix</td>
  </tr>
</table>

## Features

- Shows your current GPS ground speed in whole miles per hour.
- Shows `--` until the first fix arrives, or when Core Location reports that speed is unavailable.
- Keeps the screen awake while the app is in the foreground, so you can mount it on the dash.
- White on black for readability at night. Works in portrait and landscape.

## Requirements

- Xcode with the iOS 26.5 SDK (the deployment target is iOS 26.5)
- An iPhone with location access granted ("While Using the App")

## Build & run

1. Open `speedo.xcodeproj` in Xcode.
2. Select the `speedo` scheme and a device or simulator that runs iOS 26.5 or later.
3. Run (⌘R). Allow location access when prompted.

## Testing in the Simulator

The Simulator has no real GPS, but `simctl` can simulate a drive. This command moves the device along a route at 29 m/s (about 65 mph):

```sh
xcrun simctl location booted start --speed=29 --interval=1 \
  37.3349,-122.0090 37.4000,-122.0800 37.4500,-122.1500 37.5000,-122.2200
```

To stop the simulated drive, run `xcrun simctl location booted clear`. To skip the permission prompt, grant location access in advance:

```sh
xcrun simctl privacy booted grant location villageparkrecords.com.speedo
```

Unit tests run with ⌘U in Xcode.

## Project layout

| Path | Purpose |
| --- | --- |
| `speedo/ContentView.swift` | The single full-screen speed readout |
| `speedo/LocationSpeedProvider.swift` | Thin Core Location wrapper that publishes the current speed |
| `speedo/SpeedFormatting.swift` | Pure m/s → mph string conversion (`--` for no or invalid speed) |
| `tools/make_icon.swift` | Renders the app icon variants to PNG |

To regenerate the app icon:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift tools/make_icon.swift
```

## License

[Mozilla Public License 2.0](LICENSE)
