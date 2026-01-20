# ComputerCard Development Environment

This repo helps you build, flash, and debug RP2040 “ComputerCard” firmware for the Music Thing Workshop System using the Pico SDK, with a VS Code Dev Container.

If you want the deeper “how it works” details (auto-make, OpenOCD wiring, environment variables), see [README-development.md](README-development.md).

## What you’ll need

### Software (host machine / your laptop)

- [Visual Studio Code](https://code.visualstudio.com)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)  (Note you need to launch this once to ensure it gets set up, you may be prompted for admin permissions on MacOS. On Windows 11 it should automatically launch the Windows Subsystem for Linux which is fine and helpful. No real need to launch Docker Desktop ever again!)
- [VS Code “Dev Containers” extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- OpenOCD (host-side, required for flashing/debugging via a debug probe)

### Hardware (for flashing/debugging)

- A target Workshop Computer
- A USB cable for the target
- Optional but recommended: [a debug probe (CMSIS-DAP)](https://www.adafruit.com/product/5699?srsltid=AfmBOorkEWewNy0JeAIm2ezrGlUNuRmwIGylu4z_UqYe02S_rFjOrdcW)

Note: you can usually build without any hardware connected.

## Quick start

0) Ensure you have the prerequites described above installed (and git!)

1) Clone (or fork and then clone) this repo.

2) Open it in VS Code.

3) Reopen in the devcontainer:

   - Command Palette (command/ctrl-shift-P) → “Dev Containers: Reopen in Container” (or use the prompt that appears when you open VS Code)
   - **The first time you launch the container it will take up to 10 minutes to provision.** Subsequent rebuilds and reloads will be much faster.

4) Build the starter card:

   - In VS Code terminal (inside the container):
     - `cd XX_newcard`
     - `make`

5) (Optional) Flash using a debug probe + OpenOCD:

      - OpenOCD is required for this dev env to communicate with the debug probe hardware (see installation notes below)
      - Connect the debug probe to your Workshop System target first.
      - Start OpenOCD on your host (this will need to be from a separate Terminal or Powershell window):
       - macOS/Linux: `./start_openocd_host.sh`
       - Windows: `powershell -ExecutionPolicy Bypass -File .\start_openocd_host.ps1`
      - After starting OpenOCD, you should see a line like:
       - `Info : Listening on port 3333 for gdb connections`
   - Then in the container (in your card directory):
     - `make flash`

6) (Optional) Debug (F5):

   - Start OpenOCD on the host first (Step 5)
   - In VS Code (attached to the devcontainer), press `F5`.

## Platform prerequisites

### macOS

- Install Docker Desktop.
- Install OpenOCD on the host (for `make flash` / debugging), e.g. via Homebrew:
   - Install Homebrew: https://brew.sh/
  - `brew install openocd`

### Windows

- Install Docker Desktop (WSL2 backend recommended).
- Install OpenOCD on the host (for `make flash` / debugging).
   - Install Chocolatey: https://chocolatey.org/
   - Example: `choco install openocd`
- If the debug probe shows up but OpenOCD can’t access it, you may need a WinUSB driver for the CMSIS-DAP interface.

### Linux

- Install Docker Engine + Docker Compose.
- Install OpenOCD on the host (for `make flash` / debugging).
- If OpenOCD can’t access the probe, you may need udev rules/permissions for the CMSIS-DAP device.

## Building cards from Workshop_Computer

`Workshop_Computer/` is not cloned automatically. If you want the upstream cards/examples locally, clone it into the repo root:

- `git clone https://github.com/TomWhitwell/Workshop_Computer.git Workshop_Computer`

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

- `make` or `make build` — configure + build into `./build/`
   - This command will create a `./UF2` directory in the card directory (if one does not exist) and copy a read-to-flash compiled UF2 there. If there is already a UF2 directory and file there, the existing one may be overwritten. 
- `make clean` — remove `./build/`
- `make flash` — flash via host OpenOCD (requires a debug probe)

## VS Code tasks and keyboard shortcuts (optional)

- VS Code tasks are set up to build and flash the card corresponding to the currently open file in VS Code.
- This repo includes an example of keyboard shortcut configurations you can copy/paste into your user keybindings in order to enable shortcut-based build and flash: [.vscode/keybindings.example.json](.vscode/keybindings.example.json)

Shortcut setup steps:

1. Open Command Palette (command/ctrl-shift-P) → “Preferences: Open Keyboard Shortcuts (JSON)”.
2. Copy the entries from [.vscode/keybindings.example.json](.vscode/keybindings.example.json) into your user `keybindings.json`.
3. Adjust the key combos if they conflict with your existing shortcuts.

Note: keybindings are user-level in your local VS Code install (host machine), not inside the devcontainer.

VS Code docs: https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization

Note: these tasks pick the build/flash directory based on the file you currently have open. If a shortcut seems to do nothing, click a source file inside your card folder (one that lives under a directory containing `CMakeLists.txt`) and try again.

Once installed, you can run the same actions via Command Palette (command/ctrl-shift-P) → “Tasks: Run Task”, and/or bind them to keys.

## Troubleshooting

- Container won’t connect to OpenOCD: ensure OpenOCD is running on the host and you see `Info : Listening on port 3333 for gdb connections` in the OpenOCD output.
- Flash/debug still failing: see [README-development.md](README-development.md) for variables like `OPENOCD_HOST`, `OPENOCD_GDB_PORT`, and `GDB`.
