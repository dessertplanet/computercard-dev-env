SHELL := /usr/bin/env bash

.PHONY: help clean scrub clean-ComputerCard_Examples FORCE

# Directory to clean when running `make clean`.
DIR ?= ComputerCard_Examples

help:
	@echo "Usage: make <directory-with-CMakeLists.txt>"
	@echo "Example: make ."
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
