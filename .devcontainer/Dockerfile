FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PICO_SDK_VERSION=2.0.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        cmake \
        ninja-build \
        build-essential \
        gdb-multiarch \
        python3 \
        python3-pip \
        pkg-config \
        libusb-1.0-0-dev \
        gcc-arm-none-eabi \
        binutils-arm-none-eabi \
        libnewlib-arm-none-eabi \
        libstdc++-arm-none-eabi-newlib \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${PICO_SDK_VERSION} https://github.com/raspberrypi/pico-sdk.git /opt/pico-sdk \
    && git -C /opt/pico-sdk submodule update --init --recursive

RUN bash -c 'set -euo pipefail; \
        repo_url="https://github.com/TomWhitwell/Workshop_Computer.git"; \
        dest_dir="/opt/Workshop_Computer"; \
        echo "Cloning Workshop_Computer into ${dest_dir}"; \
        git clone --depth 1 "${repo_url}" "${dest_dir}"; \
        if [[ -f "${dest_dir}/.gitmodules" ]]; then \
            while IFS= read -r line; do \
                key="${line%% *}"; \
                url="${line#* }"; \
                new_url="${url}"; \
                if [[ "${url}" == git@github.com:* ]]; then \
                    new_url="https://github.com/${url#git@github.com:}"; \
                elif [[ "${url}" == ssh://git@github.com/* ]]; then \
                    new_url="https://github.com/${url#ssh://git@github.com/}"; \
                fi; \
                if [[ "${new_url}" != "${url}" ]]; then \
                    git -C "${dest_dir}" config -f .gitmodules "${key}" "${new_url}"; \
                fi; \
            done < <(git -C "${dest_dir}" config -f .gitmodules --get-regexp "^submodule\\..*\\.url$" || true); \
            git -C "${dest_dir}" submodule sync --recursive; \
            git -C "${dest_dir}" submodule update --init --recursive --depth 1; \
        fi'

# Make the SDK path available during the picotool build.
ENV PICO_SDK_PATH=/opt/pico-sdk

# Auto-include the dev-env Makefile helper so PicoSDK/CMake release folders
# without a local Makefile can still be built by running `make`.
ENV MAKEFILES=/workspaces/computercard-dev-env/scripts/pico_auto_make.mk

# Install picotool so the Pico SDK build doesn't need to fetch it.
# Match the SDK version by default.
RUN git clone --depth 1 --branch ${PICO_SDK_VERSION} https://github.com/raspberrypi/picotool.git /tmp/picotool \
    && cmake -S /tmp/picotool -B /tmp/picotool/build -G Ninja -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /tmp/picotool/build \
    && cmake --install /tmp/picotool/build \
    && rm -rf /tmp/picotool
