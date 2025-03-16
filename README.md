# PicoRuby on ESP32

This is a component that can be used with ESP-IDF, allowing you to add [PicoRuby](https://github.com/picoruby/picoruby) to your project.

## Getting Started

### Preparation

Prepare your project by referring to [this page](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html#).

### Installation

Clone this repository into the `components` directory of your project using Git Submodule.

```sh
$ git submodule add https://github.com/picoruby/picoruby-esp32.git components/picoruby-esp32
```

### Setup

Open your `main/CMakeLists.txt` file in an editor. Add `picoruby-esp32` to the `REQUIRES` field.

```cmake
idf_component_register(
  SRCS "main.c"
  REQUIRES picoruby-esp32 # <-- add
  PRIV_REQUIRES spi_flash
  INCLUDE_DIRS ""
)
```

Call `picoruby_esp32()` from your C source code.

```c
#include "picoruby-esp32.h"

void app_main(void)
{
  picoruby_esp32();
}
```

### Build

Build the project using the `idf.py` command.

```sh
$ . $(YOUR_ESP_IDF_PATH)/export.sh
$ idf.py set-target $(YOUR_ESP_TARGET) # example: idf.py set-target esp32c3
$ idf.py build
```

### Flash and Monitor

Flash the firmware and monitor the output using the `idf.py` command. PicoRuby Shell will start.

```sh
$ idf.py flash
$ idf.py monitor
```

## Example

Refer to this project for examples.

## Supported Environment

Currently, this project is tested in the following environment only:

- **Build OS**:
  - Linux
  - macOS
- **Device**:
  - ESP32-DevKitC(esp32)
  - M5Stamp C3 Mate(esp32c3)

## License

[picoruby-esp32](https://github.com/picoruby/picoruby-esp32) is released under the [MIT License](https://github.com/picoruby/picoruby-esp32/blob/master/LICENSE).
