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
ping -n 3 127.0.0.1 >nul
start "" "%SDK%\bin\simulator.exe" -d %DEVICE%
ping -n 11 127.0.0.1 >nul

echo Running tests...
"%SDK%\bin\monkeydo.bat" "bin\DungeonCrawler.prg" %DEVICE% /t %*
set TESTRESULT=%ERRORLEVEL%

echo Cleaning up...
taskkill /IM simulator.exe /F >nul 2>&1
ping -n 2 127.0.0.1 >nul
exit /b %TESTRESULT%
