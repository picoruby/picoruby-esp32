idf_component_register(
  SRCS
    ${COMPONENT_DIR}/picoruby-esp32.c
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-machine/ports/esp32/machine.c
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-io-console/ports/esp32/io-console.c
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-filesystem-fat/ports/esp32/flash_disk.c
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-env/ports/esp32/env.c
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-gpio/ports/esp32/gpio.c
  INCLUDE_DIRS
    ${COMPONENT_DIR}
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-mrubyc/lib/mrubyc/src
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-machine/include
    ${COMPONENT_DIR}/picoruby/mrbgems/picoruby-filesystem-fat/ports/esp32
  REQUIRES esp_driver_uart spi_flash
  PRIV_REQUIRES esp_driver_gpio
)

add_definitions(
  -DMRBC_TICK_UNIT=10
  -DMRBC_TIMESLICE_TICK_COUNT=1
  -DMRBC_USE_FLOAT=2
  -DMRC_CUSTOM_ALLOC
  -DMRBC_CONVERT_CRLF=1
  -DUSE_FAT_FLASH_DISK
  -DNDEBUG
)

set(PICORUBY_DIR ${COMPONENT_DIR}/picoruby)
set(LIBMRUBY_FILE ${PICORUBY_DIR}/build/esp32/lib/libmruby.a)

# Build PicoRuby
add_custom_command(
  OUTPUT ${LIBMRUBY_FILE}
  COMMAND ${CMAKE_COMMAND} -E echo "MRUBY_CONFIG=${IDF_TARGET_ARCH}-esp rake"
  COMMAND ${CMAKE_COMMAND} -E env MRUBY_CONFIG=${IDF_TARGET_ARCH}-esp rake
  WORKING_DIRECTORY ${PICORUBY_DIR}
  COMMENT "PicoRuby build"
  VERBATIM
)

add_prebuilt_library(
  libmruby ${LIBMRUBY_FILE}
  REQUIRES ${COMPONENT_NAME}
)
target_link_libraries(${COMPONENT_LIB} PRIVATE libmruby)

add_custom_target(
  picoruby DEPENDS ${LIBMRUBY_FILE}
  DEPENDS ${LIBMRUBY_FILE}
)
add_dependencies(${COMPONENT_LIB} picoruby)

# Compile Ruby files
add_custom_target(
  mrbdir ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${COMPONENT_DIR}/mrb
)
add_dependencies(mrbdir picoruby)

set(RUBY_FILES main_task)
set(PICORBC ${COMPONENT_DIR}/picoruby/bin/picorbc)

foreach(rb ${RUBY_FILES})
add_custom_target(${rb}
  COMMAND ${PICORBC} -B${rb} -o${COMPONENT_DIR}/mrb/${rb}.c ${COMPONENT_DIR}/mrblib/${rb}.rb
  DEPENDS mrbdir
)
add_dependencies(${rb} picoruby)
endforeach(rb)

add_custom_target(generate_files ALL DEPENDS mrbdir ${RUBY_FILES})
add_dependencies(generate_files picoruby)
