# Networked integration test for the Plugins window's risset installation on
# Windows. It mirrors PluginsDialog: install uv with the official PowerShell
# installer into a temporary plugin directory, install risset with uv, then run
# "risset info --full".
#
# This is opt-in because it needs network access. It is started by the
# workflow_dispatch job in testbuild-qt6.yml.

$ErrorActionPreference = "Stop"

$tempRoot = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { [System.IO.Path]::GetTempPath() }
$root = Join-Path $tempRoot ("csoundqt-risset-test-" + [guid]::NewGuid().ToString("N"))
try {
    $bin = Join-Path $root "bin"
    $tools = Join-Path $root "tools"
    $python = Join-Path $root "python"
    $localAppData = Join-Path $root "localappdata"
    New-Item -ItemType Directory -Force -Path $bin, $tools, $python, $localAppData | Out-Null

    $env:UV_UNMANAGED_INSTALL = $bin
    $env:UV_NO_MODIFY_PATH = "1"
    $env:UV_DISABLE_UPDATE = "1"
    $env:UV_TOOL_BIN_DIR = $bin
    $env:UV_TOOL_DIR = $tools
    $env:UV_PYTHON_INSTALL_DIR = $python
    $env:UV_NO_PROGRESS = "1"
    $env:UV_COLOR = "never"
    $env:UV_LINK_MODE = "copy"
    $env:LOCALAPPDATA = $localAppData

    $installer = Join-Path $root "uv-install.ps1"
    Write-Host "Downloading the uv installer..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://astral.sh/uv/install.ps1" -OutFile $installer

    Write-Host "Installing uv into $bin..."
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
    if ($LASTEXITCODE -ne 0) {
        throw "uv installer failed with exit code $LASTEXITCODE"
    }

    $uv = Join-Path $bin "uv.exe"
    if (-not (Test-Path $uv)) {
        throw "uv.exe was not found at $uv"
    }

    Write-Host "Installing risset..."
    & $uv tool install --force risset
    if ($LASTEXITCODE -ne 0) {
        throw "uv tool install failed with exit code $LASTEXITCODE"
    }

    $risset = Join-Path $bin "risset.exe"
    if (-not (Test-Path $risset)) {
        throw "risset.exe was not found at $risset"
    }

    Write-Host "Checking risset..."
    $infoPath = Join-Path $root "info.json"
    & $risset info --full | Out-File -Encoding utf8 $infoPath
    if ($LASTEXITCODE -ne 0) {
        throw "risset info failed with exit code $LASTEXITCODE"
    }
    $info = Get-Content -Raw $infoPath | ConvertFrom-Json
    if (-not $info.version) {
        throw "risset info did not report a version"
    }
    Write-Host "risset installation test passed. version $($info.version)"
}
finally {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $root
}
