# Build & Release

Build instructions and release process.

## Prerequisites

- Java in `PATH`
- Git in `PATH`
- GitHub CLI (`gh`) authenticated (`gh auth login`)
- Garmin developer key file
- Connect IQ SDK installed (auto-detected in `%APPDATA%\Garmin\ConnectIQ\Sdks`)

## Build for Development

### Single Device

```powershell
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-jar" "c:\Users\Timon\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa\bin\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "f:\Code\Garmin\DungeonCrawler\monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s" "-w"
```

### Test Build

Add `-t` flag for test mode:

```powershell
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-jar" "...\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s" "-w" "-t"
```

## Target Devices

| Device ID | Name |
|-----------|------|
| `venu2` | Venu 2 |
| `venu2s` | Venu 2S |
| `venu2plus` | Venu 2 Plus |
| `venu3` | Venu 3 |
| `venu3s` | Venu 3S |
| `venu441mm` | Venu 4 41mm |
| `venu445mm` | Venu 4 45mm |

## Release Build

### Using the Release Script

```powershell
.\helpers\create-release.ps1 -Tag v1.2.0 -DeveloperKeyPath "F:\Code\Garmin\developer_key"
```

This will:
1. Auto-detect SDK path
2. Build `.prg` files for all 7 target devices
3. Create git tag (if `-CreateTag` specified)
4. Create GitHub release with artifacts

### Optional Parameters

| Parameter | Description |
|-----------|-------------|
| `-Devices venu2s,venu3` | Build selected devices only |
| `-CreateTag` | Create and push git tag |
| `-MonkeybrainsJarPath` | Override SDK path |

### Manual Release

1. Build for each device (replace `-d` flag)
2. Collect `.prg` files from `bin/`
3. Create git tag: `git tag v1.2.0`
4. Push tag: `git push origin v1.2.0`
5. Create GitHub release with `.prg` files attached

## Project Configuration

### monkey.jungle

Main build configuration file. Defines:
- Source files
- Resource files
- Device targets
- Build options

### manifest.xml

App manifest with:
- App ID and type (`watch-app`)
- Target devices
- Permissions (`UserProfile`)
- Entry point (`DungeonCrawlerApp`)

## Build Output

- `bin/DungeonCrawler.prg` -- compiled app for simulator
- `bin/<device>/` -- device-specific builds (in release mode)
