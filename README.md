# ComputerCard Pico Dev Environment

This repo is a **build/debug-friendly sandbox** for developing Raspberry Pi Pico / RP2040 “ComputerCard” firmware using the **Pico SDK**, with a VS Code Dev Container.

The goals are:

- Make it easy to build Pico SDK firmware **inside the devcontainer**.
- Support building example and release card projects **without modifying upstream repos**.
- Provide a straightforward workflow for **making your own card** and submitting it upstream.

Huge thank you to Chris Johnson for creating the ComputerCard framework!

## Intended workflow (make your own card)

1. Fork/clone this dev environment repo.
2. Start your card in `XX_newcard/`.
3. Rename `XX_newcard/` to your card name when you’re ready.
4. Submit that card folder as a PR to the upstream Workshop_Computer repo (TomWhitwell), typically under `releases/`:
   - https://github.com/TomWhitwell/Workshop_Computer/tree/main/releases

Reference on how to use `ComputerCard.h`:
- See [ComputerCard_Examples/README.md](ComputerCard_Examples/README.md)

## What’s in here

- `XX_newcard/`: a minimal Pico SDK project template that builds a passthrough-style example.
- `ComputerCard_Examples/`: upstream-ish examples + documentation for `ComputerCard.h` usage patterns.
- `scripts/pico_auto_make.mk`: auto-injected Make support for Pico SDK CMake projects that *don’t* have a local Makefile.
- `.vscode/`: tasks and launch configs for build + debugging.

## Building

There are two common ways to build.

### 1) Build from inside a card directory (recommended)

For Pico SDK CMake projects that don’t ship a Makefile, this devcontainer sets the `MAKEFILES` environment variable so running `make` “just works”.

From a card directory (example: `XX_newcard/`):

- `make` / `make build` — configure + build into `./build/`
- `make uf2` — build and stage any produced `*.uf2` into `./UF2/`
- `make clean` — remove `./build/`

### 2) Build from the repo root (wrapper)

The root `Makefile` is a convenience wrapper:

- `make XX_newcard` — builds that directory via `scripts/build.sh`
- `make .` — builds the current directory
- `make ComputerCard_Examples/<example>` — builds a single example via the `ComputerCard_Examples/` make logic

## Flashing (OpenOCD + Debug Probe)

This repo’s default `make flash` workflow assumes:

- **OpenOCD runs on the host** (not in the container)
- The container connects to OpenOCD’s GDB server at `host.docker.internal:3333`

### Start OpenOCD on the host

We provide host wrappers:

- macOS/Linux: `scripts/start_openocd_host.sh`
- Windows: `scripts/start_openocd_host.ps1`

Example (macOS/Linux):

- `./scripts/start_openocd_host.sh`

Then from inside the container (in your card directory):

- `make flash`

Notes:

- `make flash` uses the newest `UF2/*.uf2` to **select** which target to flash, but OpenOCD/GDB actually flashes the corresponding `build/<stem>.elf`.
- Useful overrides:
  - `make flash OPENOCD_HOST=host.docker.internal OPENOCD_GDB_PORT=3333`
  - `make flash FLASH_UF2=UF2/my_card.uf2`
  - `make flash FLASH_ELF=build/my_card.elf`
  - `make flash GDB=gdb-multiarch`

## Debugging (F5 in VS Code)

This repo includes Cortex-Debug launch configs:

- “RP2040 (XX_newcard, attach to host OpenOCD)” — no prompts, targets `XX_newcard`.
- “RP2040 (attach to host OpenOCD)” — prompted config for arbitrary project folders.

Requirements:

- Start OpenOCD on the host first (see above).
- In VS Code (attached to the devcontainer), press `F5`.

## Troubleshooting

- If `make flash` says it can’t connect to OpenOCD:
  - Ensure OpenOCD is running on the host and listening on port `3333`.
  - On Linux hosts, ensure `host.docker.internal` is available (the devcontainer is configured to add it).
- If your probe isn’t detected on Windows:
  - You may need WinUSB drivers for the CMSIS-DAP interface.

---

If you want to contribute improvements to this dev environment repo, keep changes minimal and avoid modifying `Workshop_Computer/` content (that repo is treated as upstream reference material).
