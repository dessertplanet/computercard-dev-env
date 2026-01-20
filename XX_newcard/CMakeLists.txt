cmake_minimum_required(VERSION 3.13)

## -----------------------------------------------------------------------------
## User settings (edit these, or pass -D... to CMake)
## -----------------------------------------------------------------------------

# Name of the firmware/UF2 produced.
# This becomes the CMake target name and the resulting UF2 name: <CARD_NAME>.uf2
set(CARD_NAME "passthru" CACHE STRING "ComputerCard firmware name (also the UF2 filename stem)")

# USB serial stdio (usually OFF for audio-rate cards; set ON for debug).
set(CARD_STDIO_USB OFF CACHE BOOL "Enable USB stdio")

# Pico SDK import
# - Prefer a local copy of pico_sdk_import.cmake if present.
# - Otherwise require PICO_SDK_PATH (provided by this dev container).
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/pico_sdk_import.cmake")
	include(${CMAKE_CURRENT_LIST_DIR}/pico_sdk_import.cmake)
else()
	if (NOT DEFINED PICO_SDK_PATH)
		message(FATAL_ERROR "PICO_SDK_PATH not set and pico_sdk_import.cmake not found. Set PICO_SDK_PATH or add pico_sdk_import.cmake to this directory.")
	endif()
	include(${PICO_SDK_PATH}/external/pico_sdk_import.cmake)
endif()

project(${CARD_NAME} C CXX ASM)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(${CARD_NAME}
	${CMAKE_CURRENT_LIST_DIR}/main.cpp
)

target_compile_options(${CARD_NAME} PRIVATE -Wdouble-promotion -Wfloat-conversion -Wall -Wextra)
target_link_options(${CARD_NAME} PRIVATE -Wl,--print-memory-usage)

# Give oscillator more time to start - some boards won't run if this isn't included
target_compile_definitions(${CARD_NAME} PRIVATE PICO_XOSC_STARTUP_DELAY_MULTIPLIER=64)

target_include_directories(${CARD_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR})

target_link_libraries(${CARD_NAME}
	pico_stdlib
	hardware_adc
	hardware_clocks
	hardware_dma
	hardware_flash
	hardware_gpio
	hardware_i2c
	hardware_irq
	hardware_pwm
	hardware_spi
)

pico_add_extra_outputs(${CARD_NAME})

if (CARD_STDIO_USB)
	pico_enable_stdio_usb(${CARD_NAME} 1)
else()
	pico_enable_stdio_usb(${CARD_NAME} 0)
endif()

# Collect generated UF2 files in one place (in addition to the dev-env MAKEFILES helper).
set(COMPUTERCARD_UF2_DIR "${CMAKE_CURRENT_LIST_DIR}/UF2" CACHE PATH "Directory to copy generated .uf2 files into")
add_custom_command(
	TARGET ${CARD_NAME}
	POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E make_directory "${COMPUTERCARD_UF2_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy_if_different
		"$<TARGET_FILE_DIR:${CARD_NAME}>/${CARD_NAME}.uf2"
		"${COMPUTERCARD_UF2_DIR}/${CARD_NAME}.uf2"
)
