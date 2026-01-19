# Global Makefile include for this dev environment.
#
# This file is injected via the MAKEFILES environment variable (see
# .devcontainer/devcontainer.json). It enables a convenient workflow:
#
#   cd Workshop_Computer/releases/<card>
#   make
#
# even when that directory contains no local Makefile, as long as it looks like
# a Pico SDK (CMake) project.

SHELL := /bin/bash

# Only activate when there is NO local makefile in the current directory.
LOCAL_MAKEFILE := $(firstword $(wildcard GNUmakefile Makefile makefile))
ifeq ($(strip $(LOCAL_MAKEFILE)),)

# Detect where the CMake project is rooted.
# Preference order:
#  1) ./CMakeLists.txt
#  2) ./src/CMakeLists.txt
#  3) first CMakeLists.txt within depth 2 (excluding build-like dirs)
PICO_PROJECT_DIR := $(strip \
  $(if $(wildcard CMakeLists.txt),.,\
    $(if $(wildcard src/CMakeLists.txt),src,\
      $(shell find . -maxdepth 2 -mindepth 2 -name CMakeLists.txt \
        -not -path './build/*' -not -path './*/build/*' \
        -not -path './_build/*' -not -path './*/_build/*' \
        -not -path './cmake-build-*/*' -not -path './*/cmake-build-*/*' \
        -print -quit 2>/dev/null | sed 's#^\\./##' | xargs -r dirname))))

PICO_PROJECT_CMAKELISTS := $(if $(PICO_PROJECT_DIR),$(PICO_PROJECT_DIR)/CMakeLists.txt,)

# Only treat as Pico SDK project if it either has a pico_sdk_import.cmake alongside
# the CMakeLists.txt or references pico_sdk_import from the CMakeLists.
PICO_IS_PICO_SDK := $(strip \
  $(if $(PICO_PROJECT_DIR),\
    $(shell \
      if [[ -f "$(PICO_PROJECT_DIR)/pico_sdk_import.cmake" ]]; then echo yes; \
      elif [[ -f "$(PICO_PROJECT_CMAKELISTS)" ]] && grep -q "pico_sdk_import" "$(PICO_PROJECT_CMAKELISTS)"; then echo yes; \
      else echo no; fi \
    ),\
    no))

ifeq ($(PICO_IS_PICO_SDK),yes)

.DEFAULT_GOAL := all

CMAKE ?= cmake
BUILD_DIR ?= build

# Pico SDK resolution:
# - Respect PICO_SDK_PATH if already set.
# - Otherwise prefer the SDK in this dev container.
# - Otherwise fall back to the SDK built under ComputerCard_Examples (if present).
# - Otherwise allow FetchContent via Pico SDK's standard variables.
PICO_SDK_PATH ?= $(if $(wildcard /opt/pico-sdk/pico_sdk_init.cmake),/opt/pico-sdk,)
WORKSPACE_PICO_SDK ?= /workspaces/computercard-dev-env/ComputerCard_Examples/build/pico-sdk
ifneq ($(strip $(PICO_SDK_PATH)),)
  CMAKE_PICO_SDK_ARGS := -DPICO_SDK_PATH=$(PICO_SDK_PATH)
else ifneq ($(wildcard $(WORKSPACE_PICO_SDK)/pico_sdk_init.cmake),)
  CMAKE_PICO_SDK_ARGS := -DPICO_SDK_PATH=$(WORKSPACE_PICO_SDK)
else
  PICO_SDK_FETCH_FROM_GIT ?= ON
  PICO_SDK_FETCH_FROM_GIT_PATH ?= $(HOME)/.pico-sdk
  PICO_SDK_FETCH_FROM_GIT_TAG ?= master
  CMAKE_PICO_SDK_ARGS := \
    -DPICO_SDK_FETCH_FROM_GIT=$(PICO_SDK_FETCH_FROM_GIT) \
    -DPICO_SDK_FETCH_FROM_GIT_PATH=$(PICO_SDK_FETCH_FROM_GIT_PATH) \
    -DPICO_SDK_FETCH_FROM_GIT_TAG=$(PICO_SDK_FETCH_FROM_GIT_TAG)
endif

CMAKE_ARGS ?=
CMAKE_ARGS += -DCMAKE_EXPORT_COMPILE_COMMANDS=ON $(CMAKE_PICO_SDK_ARGS)

NINJA := $(shell command -v ninja 2>/dev/null)
ifneq ($(strip $(NINJA)),)
  CMAKE_GEN_ARGS := -G "Ninja"
else
  CMAKE_GEN_ARGS :=
endif

.PHONY: all configure build clean distclean uf2 help .

# Support the (somewhat common) "make ." habit.
.: all

all: build

configure:
	$(CMAKE) -S "$(PICO_PROJECT_DIR)" -B "$(BUILD_DIR)" $(CMAKE_GEN_ARGS) $(CMAKE_ARGS)

build: configure
	$(CMAKE) --build "$(BUILD_DIR)"
	@# Stage UF2 outputs into ./UF2 for convenience.
	@mkdir -p "UF2"
	@set -e; \
	  shopt -s nullglob; \
	  found=0; \
	  while IFS= read -r -d '' f; do \
	    found=1; \
	    cp -f "$$f" "UF2/"; \
	  done < <(find "$(BUILD_DIR)" -maxdepth 4 -type f -name '*.uf2' -print0 2>/dev/null); \
	  if [[ $$found -eq 0 ]]; then \
	    true; \
	  fi

clean:
	rm -rf "$(BUILD_DIR)"

distclean: clean

uf2: build
	@find "$(BUILD_DIR)" -maxdepth 3 -type f -name '*.uf2' -print 2>/dev/null || true
	@find . -maxdepth 3 -type f -name '*.uf2' -print 2>/dev/null || true

help:
	@echo "PicoSDK helper (auto-enabled when no Makefile exists)"
	@echo "Targets: build (default), clean, uf2"
	@echo "Vars: BUILD_DIR=build CMAKE=cmake PICO_SDK_PATH=/path/to/pico-sdk"
	@echo "      PICO_SDK_FETCH_FROM_GIT=ON PICO_SDK_FETCH_FROM_GIT_PATH=\$$HOME/.pico-sdk"

endif # PICO_IS_PICO_SDK
endif # no local makefile
