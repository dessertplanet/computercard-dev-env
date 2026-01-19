# ComputerCard Pico Dev Environment

This repo helps you build, flash, and debug Raspberry Pi Pico / RP2040 “ComputerCard” firmware using the Pico SDK, with a VS Code Dev Container.

If you want the deeper “how it works” details (auto-make, OpenOCD wiring, environment variables), see [README-development.md](README-development.md).

## What you’ll need

### Software (host machine / your laptop)

- [Visual Studio Code](https://code.visualstudio.com)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 
- [VS Code “Dev Containers” extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Hardware (for flashing/debugging)

- A target Workshop Computer
- A USB cable for the target
- Optional but recommended: a debug probe (CMSIS-DAP)
  - Adafruit Pico Debug Probe info: https://learn.adafruit.com/raspberry-pi-pico-debug-probe

Note: you can usually build without any hardware connected.

## Quick start

1) Clone (or fork and then clone) this repo.

2) Open it in VS Code.

3) Reopen in the devcontainer:

- Command Palette → “Dev Containers: Reopen in Container”

During the first container creation (before VS Code finishes attaching), the devcontainer bootstraps by cloning the upstream Workshop_Computer repo into `Workshop_Computer/`.

4) Build the starter card:

- In VS Code terminal (inside the container):
  - `cd XX_newcard`
  - `make build`

5) (Optional) Flash using a debug probe + OpenOCD:

- Start OpenOCD on your host (this will need to be from a separate Terminal or Powershell window):
  - macOS/Linux: `./start_openocd_host.sh`
  - Windows: `powershell -ExecutionPolicy Bypass -File .\start_openocd_host.ps1`
- Then in the container (in your card directory):
  - `make flash`

6) (Optional) Debug (F5):

- Start OpenOCD on the host first (Step 5)
- In VS Code (attached to the devcontainer), press `F5`.

## Platform prerequisites

### macOS

- Install Docker Desktop.
- Install OpenOCD on the host (for `make flash` / debugging), e.g. via Homebrew:
  - `brew install openocd`

### Windows

- Install Docker Desktop (WSL2 backend recommended).
- Install OpenOCD on the host (for `make flash` / debugging).
- If the debug probe shows up but OpenOCD can’t access it, you may need a WinUSB driver for the CMSIS-DAP interface.

### Linux

- Install Docker Engine + Docker Compose.
- Install OpenOCD on the host (for `make flash` / debugging).
- If OpenOCD can’t access the probe, you may need udev rules/permissions for the CMSIS-DAP device.

## Building cards from Workshop_Computer

When the container is provisioned, you should have a `Workshop_Computer/` folder at the repo root.

### How to tell which cards use the Pico SDK

Pico SDK cards are typically CMake-based. A Pico SDK card usually contains a `CMakeLists.txt` (sometimes under `src/`).

Some examples:
- 11_Goldfish
- 22_Sheep
- 21_Resonator
- 05_chord_blimey

### How to build a Pico SDK release card

From the card’s directory (example path):

- `cd Workshop_Computer/releases/<card_name>`
- `make`
- (optionally) `make flash` to use debug probe to flash to a connected WS Computer (requires host OpenOCD + debug probe)

## Making your own card

1. Start your project in `XX_newcard/`.
2. When ready, rename `XX_newcard/` to your card name.
3. Submit that folder as a PR to the upstream Workshop_Computer repo (TomWhitwell), usually under `releases/`:
   - https://github.com/TomWhitwell/Workshop_Computer/tree/main/releases

Reference on how to use `ComputerCard.h`:

- [ComputerCard_Examples/README.md](ComputerCard_Examples/README.md)

## Common commands (inside the container)

From a card directory (example: `XX_newcard/`):

- `make` / `make build` — configure + build into `./build/`
- `make clean` — remove `./build/`
- `make flash` — flash via host OpenOCD (requires a debug probe)

From the repo root:

- `make XX_newcard` — build that directory
- `make .` — build the current directory
- `make ComputerCard_Examples/<example>` — build one example

## Troubleshooting

- Container won’t connect to OpenOCD: ensure OpenOCD is running on the host and listening on port `3333`.
- Flash/debug still failing: see [README-development.md](README-development.md) for variables like `OPENOCD_HOST`, `OPENOCD_GDB_PORT`, and `GDB`.
