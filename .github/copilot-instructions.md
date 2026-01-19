# Copilot instructions (computercard-dev-env)

These instructions are for edits in this repo.

## Goals

- Make it easy to build Pico SDK firmware from inside the devcontainer.
- Preserve upstream repos (especially `Workshop_Computer/`) unchanged.
- Prefer simple, reliable workflows over clever automation.

## Intended workflow

- Users typically **fork/clone this dev environment repo**, build their own card starting in `XX_newcard/`, then **rename that directory** to their card name.
- The resulting card folder is intended to be submitted as a PR to the upstream Workshop_Computer repo (TomWhitwell), usually under `releases/`.
- This repo should remain a **build/debug-friendly sandbox**;

## Reference material (read these first)

- `ComputerCard_Examples/README.md` explains the intended patterns for using `ComputerCard.h`.
- Upstream full card examples live in the Workshop_Computer repo under `releases/`:
  - https://github.com/TomWhitwell/Workshop_Computer/tree/main/releases

## Key conventions

- **Do not add per-card Makefiles** to `Workshop_Computer/` releases. The dev environment provides Make behavior via `MAKEFILES` auto-include.
- The auto-Make logic lives in `scripts/pico_auto_make.mk`.
  - It provides `make`, `make .`, `make uf2`, and `make flash` in Pico SDK CMake project folders that have no local Makefile.
- **Flashing uses host-side OpenOCD**.
  - Inside container: `make flash` connects to `host.docker.internal:3333` by default.
  - Host wrappers: `scripts/start_openocd_host.sh` and `scripts/start_openocd_host.ps1` start OpenOCD on the host.
  - `flash` selects which ELF to load based on the newest `UF2/*.uf2` (OpenOCD/GDB loads ELF; UF2 is used for selection).

## Make commands (dev env)

There are two ways users invoke `make` in this repo:

- **From the repo root** (`/workspaces/computercard-dev-env`): the top-level `Makefile` is a convenience wrapper.
  - `make <dir>` or `make .` delegates to `scripts/build.sh` (CMake + Ninja build).
  - `make ComputerCard_Examples/<example>` builds a single example via the `ComputerCard_Examples/` make logic.

- **From inside a Pico SDK card directory** (a folder with `CMakeLists.txt` but no local Makefile): the devcontainer sets `MAKEFILES` to auto-include `scripts/pico_auto_make.mk`.
  - `make` / `make build`: configure + build into `./build/`.
  - `make uf2`: builds and stages any produced `*.uf2` into a local `./UF2/` folder.
  - `make flash`: builds, ensures `./UF2/` is up to date, then flashes via GDB/OpenOCD.
    - Selection rule: picks the newest `UF2/*.uf2` (or `FLASH_UF2=...`) and flashes the matching `build/<stem>.elf`.
    - OpenOCD must already be running on the host (default: `host.docker.internal:3333`).

Useful variables for `make flash`:

- `OPENOCD_HOST` / `OPENOCD_GDB_PORT` (defaults: `host.docker.internal` / `3333`)
- `FLASH_UF2` (explicit UF2 to select the target)
- `FLASH_ELF` (explicit ELF to flash)
- `GDB` (explicit GDB binary; default auto-detects `arm-none-eabi-gdb` then `gdb-multiarch`)

## Devcontainer expectations

- Pico SDK path in-container is `/opt/pico-sdk` (`PICO_SDK_PATH`).
- The container should include tools needed for build + debug:
  - `cmake`, `ninja`, `gcc-arm-none-eabi`, and a working GDB (`gdb-multiarch` is acceptable).
- Ensure host connectivity works on Linux hosts:
  - Prefer configuring the devcontainer to support `host.docker.internal` (e.g. `--add-host=host.docker.internal:host-gateway`).

## VS Code configs

- Use `.vscode/launch.json` + `.vscode/tasks.json` for F5 debugging.
  - Prefer a no-prompt config for `XX_newcard` and a prompted config for arbitrary project dirs.
- Extension recommendations live in `.vscode/extensions.json`.
  - Keep Makefile Tools / CMake Tools / container-related extensions in `unwantedRecommendations` if they interfere.

## Editing guidance

- Use tabs for Make recipes (Make requires TAB-indented command lines).
- When adding scripts intended for the host, document clearly that they are host-run.

## Validation

- For build-related changes, validate with:
  - `cd XX_newcard && make build`
  - `cd XX_newcard && make flash` (requires host OpenOCD running)
