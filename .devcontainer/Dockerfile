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
