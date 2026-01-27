SHELL := /usr/bin/env bash

.PHONY: help all clean scrub clean-ComputerCard_Examples FORCE

# Directory to clean when running `make clean`.
DIR ?= ComputerCard_Examples

help:
	@echo "Usage: make <directory-with-CMakeLists.txt>"
	@echo "Example: make ."
	@echo ""
	@echo "Build all compatible releases:"
	@echo "  make all                               # build all Workshop_Computer releases with CMakeLists.txt"
	@echo ""
	@echo "ComputerCard_Examples shortcuts:"
	@echo "  make ComputerCard_Examples            # build all examples"
	@echo "  make ComputerCard_Examples/<example>  # build a single example"
	@echo "  make ComputerCard_Examples/list       # list available examples"
	@echo "  make ComputerCard_Examples/clean      # remove ComputerCard_Examples/build"
	@echo "  make ComputerCard_Examples/scrub      # remove legacy in-source CMake artifacts"
	@echo "Example: make ComputerCard_Examples/passthrough"
	@echo ""
	@echo "Cleaning:"
	@echo "  make clean                            # remove $(DIR)/build"
	@echo "  make clean DIR=ComputerCard_Examples   # explicitly choose directory"
	@echo "  make scrub                            # scrub ComputerCard_Examples (includes clean)"

# Build all compatible Pico SDK releases (sequentially, stop on first failure)
RELEASES_DIR ?= Workshop_Computer/releases

all:
	@set -euo pipefail; \
	if [[ ! -d "$(RELEASES_DIR)" ]]; then \
		echo "Error: releases directory not found: $(RELEASES_DIR)" >&2; \
		exit 2; \
	fi; \
	found=0; \
	failures=0; \
	declare -a targets=(); \
	declare -a statuses=(); \
	while IFS= read -r -d '' cmake; do \
		found=1; \
		dir=$$(dirname "$$cmake"); \
		targets+=("$$dir"); \
		echo "==> Building $$dir"; \
		log_file=$$(mktemp); \
		if (cd "$$dir" && make build) 2>&1 | tee "$$log_file"; then \
			if [[ "$$dir" == "$(RELEASES_DIR)/06_usb_audio" || "$$dir" == "$(RELEASES_DIR)/06_usb_audio/Rev1" ]]; then \
				if (cd "$$dir" && make uf2); then \
					statuses+=("✅ Success"); \
				else \
					statuses+=("❌ Failed (uf2)"); \
					failures=$$((failures+1)); \
				fi; \
			else \
				statuses+=("✅ Success"); \
			fi; \
		else \
			tinyusb_hit=$$(grep -Eqi "tinyusb|\\btusb\\b" "$$log_file" && echo yes || echo no); \
			picosdk_hit=$$(grep -Eqi "pico[- ]sdk|PICO_SDK" "$$log_file" && echo yes || echo no); \
			if [[ "$$tinyusb_hit" == "yes" && "$$picosdk_hit" == "yes" ]]; then \
				statuses+=("❌ Failed (TinyUSB/Pico SDK)"); \
			elif [[ "$$tinyusb_hit" == "yes" ]]; then \
				statuses+=("❌ Failed (TinyUSB)"); \
			elif [[ "$$picosdk_hit" == "yes" ]]; then \
				statuses+=("❌ Failed (Pico SDK)"); \
			else \
				statuses+=("❌ Failed"); \
			fi; \
			failures=$$((failures+1)); \
		fi; \
		rm -f "$$log_file"; \
	done < <(find "$(RELEASES_DIR)" -mindepth 2 -maxdepth 4 -type f -name CMakeLists.txt ! -path "*/lua/*" -print0 | sort -z); \
	while IFS= read -r -d '' card; do \
		dir=$$(dirname "$$card"); \
		if [[ -f "$$dir/CMakeLists.txt" ]]; then \
			continue; \
		fi; \
		found=1; \
		targets+=("$$dir"); \
		statuses+=("❌ Missing CMakeLists.txt"); \
		failures=$$((failures+1)); \
	done < <(find "$(RELEASES_DIR)" -mindepth 2 -maxdepth 3 -type f -name ComputerCard.h ! -path "*/lua/*" -print0 | sort -z); \
	if [[ $$found -eq 0 ]]; then \
		echo "No CMakeLists.txt found under $(RELEASES_DIR)" >&2; \
		exit 2; \
	fi; \
	total=$${#targets[@]}; \
	successes=$$((total - failures)); \
	echo ""; \
	echo "| Target path | Build status |"; \
	echo "| --- | --- |"; \
	while IFS=$$'\t' read -r target status; do \
		echo "| $$target | $$status |"; \
	done < <(for i in "$${!targets[@]}"; do printf '%s\t%s\n' "$${targets[$$i]}" "$${statuses[$$i]}"; done | sort); \
	echo ""; \
	echo "Total: $$total, Success: $$successes, Failed: $$failures"; \
	if [[ $$failures -gt 0 ]]; then \
		exit 2; \
	fi

clean:
	@if [[ -z "$(DIR)" ]]; then \
		echo "Error: DIR not set" >&2; \
		exit 2; \
	fi
	@if [[ ! -d "$(DIR)" ]]; then \
		echo "Error: directory not found: $(DIR)" >&2; \
		exit 2; \
	fi
	@rm -rf "$(DIR)/build"

clean-ComputerCard_Examples:
	@$(MAKE) clean DIR=ComputerCard_Examples

scrub:
	@$(MAKE) -C ComputerCard_Examples scrub

# Delegate single-example targets to ComputerCard_Examples/Makefile.
ComputerCard_Examples/%: FORCE
	@$(MAKE) -C ComputerCard_Examples "$*"

%: FORCE
	@./scripts/build.sh "$@"

FORCE:

Makefile:
	@:
