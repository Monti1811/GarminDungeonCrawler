# Agents

## Build

```bash
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-Dapple.awt.UIElement=true" "-jar" "c:\Users\Timon\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa\bin\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "f:\Code\Garmin\DungeonCrawler\monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s_sim" "-w"
```

Working directory: `F:/Code/Garmin/DungeonCrawler`

## Unit Tests

Tests ausführen mit `run_tests.ps1` (kein offenes CMD-Fenster):

```bash
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1"                              # alle Tests
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1" "debugPrintRoomMap"          # einzelner Test
```

Das Script:
1. Kompiliert mit `-t` (Test-Modus)
2. Startet Simulator mit `venu2s` (NICHT `venu2s_sim`)
3. Führt `monkeydo` (Java direkt) mit `/t` aus
4. Beendet Simulator

Wichtig: Simulator-Device muss `venu2s` sein, `venu2s_sim` funktioniert nicht mit `monkeydo`.

Manuell (ohne Script):
```bash
# Kompilieren
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-Dapple.awt.UIElement=true" "-jar" "...\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s" "-w" "-t"

# Simulator starten
Start-Process "...\simulator.exe" -ArgumentList "-d", "venu2s"

# Tests ausführen (einzelner Test mit Funktionsname)
& "...\monkeydo.bat" "bin\DungeonCrawler.prg" "venu2s" "/t" "testFunctionName"
```
