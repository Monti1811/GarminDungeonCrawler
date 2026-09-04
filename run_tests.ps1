$SDK = "c:\Users\Timon\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa"
$DEVICE = "venu2s"
$MONKEYBRAINS = "$SDK\bin\monkeybrains.jar"
$MONKEYDO_CLASS = "com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux"
$SHELL = "$SDK\bin\shell.exe"
$PRG = "$PWD\bin\DungeonCrawler.prg"

Write-Host "Compiling with tests..."
& "java.exe" -Xms1g "-Dfile.encoding=UTF-8" "-Dapple.awt.UIElement=true" -jar $MONKEYBRAINS -o "bin\DungeonCrawler.prg" -f "monkey.jungle" -y "f:\Code\Garmin\developer_key" -d $DEVICE -w -t
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED"
    exit 1
}

Write-Host "Starting simulator..."
Get-Process -Name "simulator" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process -FilePath "$SDK\bin\simulator.exe" -ArgumentList "-d", $DEVICE -NoNewWindow
Start-Sleep -Seconds 10

# Parse comma-separated test names
$testNames = @()
if ($args.Count -gt 0) {
    $testNames = $args[0] -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
}

$totalExitCode = 0
$passed = 0
$failed = 0

if ($testNames.Count -gt 0) {
    Write-Host "Running $($testNames.Count) specific test(s): $($testNames -join ', ')"
    foreach ($test in $testNames) {
        Write-Host "--- Running test: $test ---"
        $testArgs = @("-classpath", $MONKEYBRAINS, $MONKEYDO_CLASS, "-f", $PRG, "-d", $DEVICE, "-s", $SHELL, "-t", $test)
        $testProc = Start-Process -FilePath "java.exe" -ArgumentList $testArgs -NoNewWindow -Wait -PassThru
        if ($testProc.ExitCode -eq 0) {
            $passed++
            Write-Host "PASS: $test"
        } else {
            $failed++
            $totalExitCode = 1
            Write-Host "FAIL: $test"
        }
    }
    Write-Host "---"
    Write-Host "Results: $passed passed, $failed failed"
} else {
    Write-Host "Running all tests..."
    $testArgs = @("-classpath", $MONKEYBRAINS, $MONKEYDO_CLASS, "-f", $PRG, "-d", $DEVICE, "-s", $SHELL, "-t")
    $testProc = Start-Process -FilePath "java.exe" -ArgumentList $testArgs -NoNewWindow -Wait -PassThru
    $totalExitCode = $testProc.ExitCode
}

Write-Host "Cleaning up..."
Get-Process -Name "simulator" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
exit $totalExitCode
