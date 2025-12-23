#include <inttypes.h>
#include <nvs_flash.h>
#include "picoruby.h"

#include <mrubyc.h>
#include "mrb/main_task.c"

#ifndef HEAP_SIZE
#if defined(CONFIG_IDF_TARGET_ESP32S3)
#define HEAP_SIZE (1024 * 180)
#elif defined(CONFIG_IDF_TARGET_ESP32C3)
#define HEAP_SIZE (1024 * 160)
#else
#define HEAP_SIZE (1024 * 120)
#endif
#endif

static uint8_t heap_pool[HEAP_SIZE];

void
initialize_nvs(void)
{
  esp_err_t ret = nvs_flash_init();
  if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    ESP_ERROR_CHECK(nvs_flash_erase());
    ret = nvs_flash_init();
  }
  ESP_ERROR_CHECK(ret);
}

void
picoruby_esp32(void)
{
  initialize_nvs();
  mrbc_init(heap_pool, HEAP_SIZE);

  mrbc_tcb *main_tcb = mrbc_create_task(main_task, 0);
  mrbc_set_task_name(main_tcb, "main_task");
  mrbc_vm *vm = &main_tcb->vm;

  picoruby_init_require(vm);
  mrbc_run();
}
