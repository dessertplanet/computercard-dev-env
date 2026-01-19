SHELL := /usr/bin/env bash

# Wrapper makefile to build ComputerCard_Examples via an out-of-tree CMake build.
#
# This file is intentionally named GNUmakefile so it takes precedence over any
# CMake-generated top-level "Makefile" (e.g. from an in-source "Unix Makefiles" build).
#
# Usage:
#   make list
#   make all
#   make <example-name>
#   make example EXAMPLE=<example-name>

BUILD_DIR ?= build
GENERATOR ?= Ninja

# Where to store shared CMake FetchContent dependencies (e.g. picotool sources)
# so they are downloaded once and reused across subsequent builds.
DEPS_DIR ?= $(HOME)/.cache/computercard

# Keep this list in sync with CMakeLists.txt (add_example(...)).
EXAMPLES := \
	calibrated_cv_out \
	midi_device \
	midi_device_host \
	midi_host \
	normalisation_probe \
	passthrough \
	sample_and_hold \
	sample_upload \
	second_core \
	sine_wave_lookup \
	sine_wave_float \
	usb_detect \
	usb_serial

.PHONY: help list configure all clean scrub distclean example $(EXAMPLES)

help:
	@echo "Targets: list, all, clean, example, <example-name>"
	@echo ""
	@echo "Examples:";
	@printf "  %s\n" $(EXAMPLES)
	@echo ""
	@echo "Build a single example:";
	@echo "  make passthrough"
	@echo "  make example EXAMPLE=passthrough"

list:
	@printf "%s\n" $(EXAMPLES)

configure:
	@COMPUTERCARD_BUILD_DIR="$(BUILD_DIR)" \
	 COMPUTERCARD_DEPS_DIR="$(DEPS_DIR)" \
	 COMPUTERCARD_GENERATOR="$(GENERATOR)" \
	 ../scripts/build.sh . --configure-only

all:
	@COMPUTERCARD_BUILD_DIR="$(BUILD_DIR)" \
	 COMPUTERCARD_DEPS_DIR="$(DEPS_DIR)" \
	 COMPUTERCARD_GENERATOR="$(GENERATOR)" \
	 ../scripts/build.sh .

example:
	@if [[ -z "$(EXAMPLE)" ]]; then \
		echo "Error: EXAMPLE not set. Try: make passthrough" >&2; \
		exit 2; \
	fi
	@COMPUTERCARD_BUILD_DIR="$(BUILD_DIR)" \
	 COMPUTERCARD_DEPS_DIR="$(DEPS_DIR)" \
	 COMPUTERCARD_GENERATOR="$(GENERATOR)" \
	 ../scripts/build.sh . --target "$(EXAMPLE)"

$(EXAMPLES):
	@$(MAKE) example EXAMPLE="$@"

clean:
	@COMPUTERCARD_BUILD_DIR="$(BUILD_DIR)" \
	 COMPUTERCARD_DEPS_DIR="$(DEPS_DIR)" \
	 COMPUTERCARD_GENERATOR="$(GENERATOR)" \
	 ../scripts/build.sh . --clean

# Remove legacy in-source CMake build artifacts (from running CMake in this
# directory) so that only $(BUILD_DIR)/ contains disposable build output.
scrub: clean
	@rm -rf CMakeCache.txt CMakeFiles cmake_install.cmake _deps pico-sdk generated Makefile

distclean: scrub
