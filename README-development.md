# Development notes (how this repo works)

This file is for contributors and curious users.

If you’re just trying to get set up and build/flash/debug a card, start with [README.md](README.md).

## High-level goals

- Make it easy to build Pico SDK firmware inside the devcontainer.
- Build example and release card projects without modifying upstream repos.
- Keep per-card folders compatible with upstream submission workflows.

## Repo layout

- `XX_newcard/`: minimal Pico SDK project template to start from.
- `ComputerCard_Examples/`: examples + documentation for `ComputerCard.h` usage patterns.
- `scripts/pico_auto_make.mk`: auto-injected Make support for Pico SDK CMake projects that don’t have a local Makefile.
- `.vscode/`: build tasks and Cortex-Debug launch configs.

## Workshop_Computer bootstrap

The devcontainer image clones the upstream repo into `/opt/Workshop_Computer` during build. On devcontainer creation, `scripts/bootstrap_workshop_computer.sh` copies it into `Workshop_Computer/` if it isn’t already present (with a network clone as a fallback).

Intent:

- Provide reference cards/examples in the workspace.
- Keep upstream content unchanged (treat the clone as read-only reference).

## Build workflows

There are two common ways users build in this repo.

### 1) Run `make` inside a card directory (auto-make)

This devcontainer sets the `MAKEFILES` environment variable to include `scripts/pico_auto_make.mk` globally.

Effect:

- In directories with a Pico SDK `CMakeLists.txt` but no local `Makefile`, commands like `make build` work.
- The build output goes into `./build/` by default.
- UF2 outputs are staged into `./UF2/` for convenience.

Auto-make targets:

- `make` / `make build`: configure + build
- `make uf2`: ensure build ran and list uf2 outputs
- `make clean`: remove build directory
- `make flash`: flash via GDB against a running OpenOCD instance

Implementation: see `scripts/pico_auto_make.mk`.

### 2) Run `make <dir>` from the repo root (wrapper)

The root `Makefile` delegates most targets to `scripts/build.sh`.

Examples:

- `make XX_newcard`
- `make .`

`ComputerCard_Examples/<example>` targets are delegated to the `ComputerCard_Examples/` make logic.

## Pico SDK resolution

Auto-make tries to find the Pico SDK in this order:

1. `PICO_SDK_PATH` if already set
2. `/opt/pico-sdk` (the devcontainer default)
3. `ComputerCard_Examples/build/pico-sdk` (if present)
4. Otherwise, allow Pico SDK FetchContent-based fetching (see variables below)

Related variables:

- `PICO_SDK_PATH`
- `PICO_SDK_FETCH_FROM_GIT` (default `ON`)
- `PICO_SDK_FETCH_FROM_GIT_PATH` (default `$HOME/.pico-sdk`)
- `PICO_SDK_FETCH_FROM_GIT_TAG` (default `master`)

## Flashing and debugging model

This repo’s default workflow expects:

- OpenOCD runs on the host (not in the container)
- The devcontainer connects to OpenOCD’s GDB server at `host.docker.internal:3333`

Why host-side OpenOCD?

- It keeps USB device access and permissions simpler across platforms.
- It avoids needing to pass-through USB debug devices into the container.

### Starting OpenOCD on the host

Use the host wrapper scripts at the repo root:

- macOS/Linux: `./start_openocd_host.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File .\start_openocd_host.ps1`

Those wrappers default to CMSIS-DAP + RP2040 target configs:

- `interface/cmsis-dap.cfg`
- `target/rp2040.cfg`

You can also run OpenOCD manually (example):

- `openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"`

Debug probe reference:

- Adafruit Pico Debug Probe info: https://learn.adafruit.com/raspberry-pi-pico-debug-probe

### How `make flash` chooses what to flash

OpenOCD/GDB flashes an ELF.

For convenience, `make flash` selects the target by looking for the newest `UF2/*.uf2` (or a UF2 you specify), then flashes the matching `build/<stem>.elf`.

Key variables:

- `OPENOCD_HOST` (default `host.docker.internal`)
- `OPENOCD_GDB_PORT` (default `3333`)
- `FLASH_UF2` (explicit UF2 to select the target)
- `FLASH_ELF` (explicit ELF to flash)
- `GDB` (explicit gdb binary; otherwise auto-detect)

### VS Code debugging (Cortex-Debug)

The `.vscode/` launch configurations attach to OpenOCD’s GDB server.

Requirements:

- OpenOCD must already be running on the host.
- The container must be able to resolve `host.docker.internal` (the devcontainer adds a host-gateway mapping).

## Devcontainer specifics

The devcontainer sets:

- `PICO_SDK_PATH=/opt/pico-sdk`
- `MAKEFILES=/workspaces/computercard-dev-env/scripts/pico_auto_make.mk`

See `.devcontainer/devcontainer.json`.
