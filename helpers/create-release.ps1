param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [string[]]$Devices = @("venu2", "venu2plus", "venu2s", "venu3", "venu3s", "venu441mm", "venu445mm"),

    [string]$MonkeybrainsJarPath,

    [Parameter(Mandatory = $true)]
    [string]$DeveloperKeyPath,

    [string]$OutputDir,

    [switch]$CreateTag,
    [switch]$SkipRelease,
    [switch]$DraftRelease,
    [switch]$PreRelease
)

$ErrorActionPreference = "Stop"

function Resolve-MonkeybrainsJar {
    param([string]$ProvidedPath)

    if ($ProvidedPath) {
        $resolved = Resolve-Path -Path $ProvidedPath -ErrorAction Stop
        return $resolved.Path
    }

    $sdkRoot = Join-Path $env:APPDATA "Garmin\ConnectIQ\Sdks"
    if (-not (Test-Path $sdkRoot)) {
        throw "Monkeybrains jar not provided and SDK folder not found at '$sdkRoot'."
    }

    $candidates = Get-ChildItem -Path $sdkRoot -Filter "monkeybrains.jar" -Recurse -File | Sort-Object LastWriteTimeUtc -Descending
    if (-not $candidates -or $candidates.Count -eq 0) {
        throw "No monkeybrains.jar found under '$sdkRoot'."
    }

    return $candidates[0].FullName
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not installed or not in PATH."
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path

if (-not $OutputDir) {
    $OutputDir = Join-Path $repoRoot "release\$Tag"
}

$allowedDevices = @("venu2", "venu2plus", "venu2s", "venu3", "venu3s", "venu441mm", "venu445mm")
$invalidDevices = $Devices | Where-Object { $_ -notin $allowedDevices }
if ($invalidDevices) {
    throw "Invalid device(s): $($invalidDevices -join ', '). Allowed: $($allowedDevices -join ', ')."
}

Require-Command -Name "java"
Require-Command -Name "git"
if (-not $SkipRelease) {
    Require-Command -Name "gh"
}

$jarPath = Resolve-MonkeybrainsJar -ProvidedPath $MonkeybrainsJarPath
$keyPath = (Resolve-Path -Path $DeveloperKeyPath -ErrorAction Stop).Path
$monkeyJunglePath = (Resolve-Path -Path (Join-Path $repoRoot "monkey.jungle") -ErrorAction Stop).Path

New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

Push-Location $repoRoot
try {
    $existingTag = git tag --list $Tag
    if (-not $existingTag) {
        if ($CreateTag) {
            git tag $Tag
            git push origin $Tag
        }
        else {
            throw "Tag '$Tag' does not exist locally. Re-run with -CreateTag or create and push it first."
        }
    }

    Write-Host "Using monkeybrains: $jarPath"
    Write-Host "Building for devices: $($Devices -join ', ')"

    $builtFiles = New-Object System.Collections.Generic.List[string]

    foreach ($device in $Devices) {
        foreach ($variant in @("debug", "release")) {
            $output = Join-Path $OutputDir "DungeonCrawler-$Tag-$device-$variant.prg"

            $javaArgs = @(
                "-Xms1g",
                "-Dfile.encoding=UTF-8",
                "-Dapple.awt.UIElement=true",
                "-jar", $jarPath,
                "-o", $output,
                "-f", $monkeyJunglePath,
                "-y", $keyPath,
                "-d", $device
            )

            if ($variant -eq "release") {
                $javaArgs += "-r"
            }

            Write-Host "Building $variant for $device..."
            & java @javaArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Build failed for $device ($variant)."
            }

            $builtFiles.Add($output)
        }
    }

    Write-Host "Built files:"
    $builtFiles | ForEach-Object { Write-Host " - $_" }

    if ($SkipRelease) {
        Write-Host "Skipping GitHub release creation/upload because -SkipRelease was specified."
        return
    }

    gh auth status | Out-Null

    $releaseExists = $false
    try {
        & gh release view $Tag --json id *> $null
        if ($LASTEXITCODE -eq 0) {
            $releaseExists = $true
        }
    }
    catch {
        $releaseExists = $false
    }

    if ($releaseExists) {
        Write-Host "Release $Tag already exists. Uploading/replacing assets..."
        $uploadArgs = @("release", "upload", $Tag) + $builtFiles + @("--clobber")
        & gh @uploadArgs
    }
    else {
        Write-Host "Creating release $Tag and uploading assets..."
        $createArgs = @("release", "create", $Tag) + $builtFiles + @("--title", $Tag, "--generate-notes")
        if ($DraftRelease) { $createArgs += "--draft" }
        if ($PreRelease) { $createArgs += "--prerelease" }
        & gh @createArgs
    }

    if ($LASTEXITCODE -ne 0) {
        throw "GitHub release command failed."
    }

    Write-Host "Release completed for tag $Tag."
}
finally {
    Pop-Location
}
