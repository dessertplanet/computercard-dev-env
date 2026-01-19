<#!
Start host-side OpenOCD for RP2040 (CMSIS-DAP), for use with the devcontainer.

Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\start_openocd_host.ps1
  powershell -ExecutionPolicy Bypass -File .\scripts\start_openocd_host.ps1 -AdapterSpeed 2000

Then from inside the container:
  make flash
#>

[CmdletBinding()]
param(
  [string]$InterfaceCfg = $env:OPENOCD_INTERFACE_CFG,
  [string]$TargetCfg = $env:OPENOCD_TARGET_CFG,
  [int]$AdapterSpeed = $(if ($env:OPENOCD_ADAPTER_SPEED) { [int]$env:OPENOCD_ADAPTER_SPEED } else { 5000 }),
  [int]$GdbPort = $(if ($env:OPENOCD_GDB_PORT) { [int]$env:OPENOCD_GDB_PORT } else { 3333 }),
  [int]$TelnetPort = $(if ($env:OPENOCD_TELNET_PORT) { [int]$env:OPENOCD_TELNET_PORT } else { 4444 }),
  [int]$TclPort = $(if ($env:OPENOCD_TCL_PORT) { [int]$env:OPENOCD_TCL_PORT } else { 6666 }),
  [string[]]$ExtraArgs = @()
)

if ([string]::IsNullOrWhiteSpace($InterfaceCfg)) { $InterfaceCfg = "interface/cmsis-dap.cfg" }
if ([string]::IsNullOrWhiteSpace($TargetCfg)) { $TargetCfg = "target/rp2040.cfg" }

$openocd = Get-Command openocd -ErrorAction SilentlyContinue
if (-not $openocd) {
  Write-Error "openocd not found on PATH. Install OpenOCD on the host."
  exit 127
}

Write-Host "Starting OpenOCD (host)..."
Write-Host "  interface:   $InterfaceCfg"
Write-Host "  target:      $TargetCfg"
Write-Host "  speed (kHz): $AdapterSpeed"
Write-Host "  gdb_port:    $GdbPort"
Write-Host "  telnet_port: $TelnetPort"
Write-Host "  tcl_port:    $TclPort"

$openocdArgs = @(
  '-f', $InterfaceCfg,
  '-f', $TargetCfg,
  '-c', "adapter speed $AdapterSpeed",
  '-c', "gdb_port $GdbPort",
  '-c', "telnet_port $TelnetPort",
  '-c', "tcl_port $TclPort"
) + $ExtraArgs

& $openocd.Source @openocdArgs
exit $LASTEXITCODE
