@echo off
set SDK=c:\Users\Timon\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa
set DEVICE=venu2s

echo Compiling with tests...
java.exe -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar "%SDK%\bin\monkeybrains.jar" -o "bin\DungeonCrawler.prg" -f "monkey.jungle" -y "f:\Code\Garmin\developer_key" -d "%DEVICE%" -w -t
if %ERRORLEVEL% neq 0 (
    echo BUILD FAILED
    exit /b 1
)

echo Starting simulator...
taskkill /IM simulator.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul
start "" "%SDK%\bin\simulator.exe" -d %DEVICE%
timeout /t 10 /nobreak >nul

echo Running tests...
"%SDK%\bin\monkeydo.bat" "bin\DungeonCrawler.prg" %DEVICE% /t %*
taskkill /IM simulator.exe /F >nul 2>&1
