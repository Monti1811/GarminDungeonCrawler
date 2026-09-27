param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [string[]]$Devices,

    [string]$MonkeybrainsJarPath,

    [Parameter(Mandatory = $true)]
    [string]$DeveloperKeyPath,

    [string]$OutputDir,

    [switch]$CreateTag,
    [switch]$SkipRelease,
    [switch]$DraftRelease,
    [switch]$PreRelease,
    [switch]$BuildIq,
    [switch]$KeepDebugLogger
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not installed or not in PATH."
    }
}

function Get-ManifestDevices {
    param([string]$ManifestPath)

    if (-not (Test-Path $ManifestPath)) {
        throw "Manifest not found at '$ManifestPath'."
    }

    [xml]$manifest = Get-Content $ManifestPath -Raw
    $ns = New-Object System.Xml.XmlNamespaceManager($manifest.NameTable)
    $ns.AddNamespace("iq", "http://www.garmin.com/xml/connectiq")

    $productNodes = $manifest.SelectNodes("//iq:product/@id", $ns)
    $devices = @()
    foreach ($node in $productNodes) {
        $devices += $node.Value
    }

    if ($devices.Count -eq 0) {
        throw "No devices found in manifest.xml."
    }

    return $devices
}

function Prepare-ReleaseSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,

        [Parameter(Mandatory = $true)]
        [string]$TargetDir,

        [switch]$StripDebugLogger
    )

    if (Test-Path $TargetDir) {
        Remove-Item -Recurse -Force $TargetDir
    }
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null

    $copyNames = @("manifest.xml", "monkey.jungle", "source", "package.json", "package-lock.json")
    $copyNames += @(Get-ChildItem -Path $RepoRoot -Directory -Filter "resources*").Name

    foreach ($name in $copyNames) {
        $src = Join-Path $RepoRoot $name
        if (-not (Test-Path $src)) {
            throw "Required build input missing: $src"
        }
        Copy-Item -LiteralPath $src -Destination $TargetDir -Recurse -Force
    }

    $result = @{ Files = 0; Lines = 0 }
    if (-not $StripDebugLogger) {
        return $result
    }

    $moduleFile = Join-Path $TargetDir "source\Engine\Util\DebugLogger.mc"
    if (Test-Path $moduleFile) {
        Remove-Item -LiteralPath $moduleFile -Force
        $result.Files++
    }

    foreach ($file in (Get-ChildItem -Path (Join-Path $TargetDir "source") -Recurse -Filter *.mc)) {
        $lines = [System.IO.File]::ReadAllLines($file.FullName)
        $kept = New-Object System.Collections.Generic.List[string]
        $changed = $false

        foreach ($line in $lines) {
            if ($line -notmatch "DebugLogger") {
                $kept.Add($line)
                continue
            }
            if ($line -notmatch "^\s*DebugLogger\.") {
                throw "Unexpected DebugLogger reference in '$($file.FullName)': $line"
            }
            $result.Lines++
            $changed = $true
        }

        if ($changed) {
            [System.IO.File]::WriteAllLines($file.FullName, $kept)
            $result.Files++
        }
    }

    $leftover = Get-ChildItem -Path (Join-Path $TargetDir "source") -Recurse -Filter *.mc |
        Select-String -Pattern "DebugLogger"
    if ($leftover) {
        $refs = $leftover | Select-Object -First 3 | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
        throw "DebugLogger references remain after stripping: $($refs -join ', ')"
    }

    return $result
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path

if (-not $OutputDir) {
    $OutputDir = Join-Path $repoRoot "release\$Tag"
}

$manifestPath = Join-Path $repoRoot "manifest.xml"

if (-not $Devices -or $Devices.Count -eq 0) {
    $Devices = Get-ManifestDevices -ManifestPath $manifestPath
    Write-Host "Loaded $($Devices.Count) devices from manifest.xml"
}

Require-Command -Name "node"
Require-Command -Name "git"
if (-not $SkipRelease) {
    Require-Command -Name "gh"
}

$keyPath = (Resolve-Path -Path $DeveloperKeyPath -ErrorAction Stop).Path

# Ensure node_modules are installed
$nodeModulesPath = Join-Path $repoRoot "node_modules"
if (-not (Test-Path $nodeModulesPath)) {
    Write-Host "Installing dependencies..."
    Push-Location $repoRoot
    try {
        & npm install
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed."
        }
    }
    finally {
        Pop-Location
    }
}

New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

$releaseSrcDir = Join-Path $repoRoot "release-src"
Write-Host ""
Write-Host "Preparing release source copy in $releaseSrcDir ..."
$stripResult = Prepare-ReleaseSource -RepoRoot $repoRoot -TargetDir $releaseSrcDir -StripDebugLogger:(-not $KeepDebugLogger)
if ($KeepDebugLogger) {
    Write-Host "DebugLogger kept (-KeepDebugLogger specified)."
}
else {
    Write-Host "Stripped DebugLogger: $($stripResult.Lines) lines removed from $($stripResult.Files) files."
}
Write-Host ""

Push-Location $repoRoot
try {
    if (-not $SkipRelease) {
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
    }

    Write-Host "Building optimized release for $($Devices.Count) devices..."
    Write-Host "Devices: $($Devices -join ', ')"

    $builtFiles = New-Object System.Collections.Generic.List[string]

    foreach ($device in $Devices) {
        Write-Host "Building optimized $device..."
        & node "helpers/optimize-build.mjs" $device $OutputDir $keyPath $releaseSrcDir
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed for $device."
        }

        $prgFile = Join-Path $OutputDir "DungeonCrawler-$device.prg"
        if (Test-Path $prgFile) {
            $builtFiles.Add($prgFile)
        }
    }

    if ($BuildIq) {
        # Build universal .iq file (once, not per-device)
        # NOTE: This builds for 80 SDK devices and takes 40-60+ minutes
        Write-Host "Building universal .iq file (this may take 40-60 minutes)..."
        & node "helpers/optimize-build.mjs" iq $OutputDir $keyPath $releaseSrcDir
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed for .iq file."
        }

        $iqFile = Join-Path $OutputDir "DungeonCrawler.iq"
        if (Test-Path $iqFile) {
            $builtFiles.Add($iqFile)
        }
    }
    else {
        Write-Host "Skipping .iq build (use -BuildIq to include it)"
    }

    Write-Host ""
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
