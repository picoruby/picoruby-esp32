#include <inttypes.h>

#include "picoruby.h"

#include <mrubyc.h>
#include "mrb/main_task.c"

#ifndef HEAP_SIZE
#define HEAP_SIZE (1024 * 128)
#endif

static uint8_t heap_pool[HEAP_SIZE];

void picoruby_esp32(void)
{
  mrbc_init(heap_pool, HEAP_SIZE);

  mrbc_tcb *main_tcb = mrbc_create_task(main_task, 0);
  mrbc_set_task_name(main_tcb, "main_task");
  mrbc_vm *vm = &main_tcb->vm;

  picoruby_init_require(vm);
  mrbc_run();
}
