#include <stdlib.h>
#include "lib.h"

VAL Number_call(js_vm_t* vm, void* state, VAL this, uint32_t argc, VAL* argv)
{
    if(argc == 0) {
        return js_value_make_double(0);
    } else {
        return js_to_number(argv[0]);
    }
}

void js_lib_number_initialize(js_vm_t* vm)
{
    vm->lib.Number = js_value_make_native_function(vm, NULL, Number_call, NULL);
    vm->lib.Number_prototype = js_value_make_object(vm->lib.Object_prototype, vm->lib.Number);
    js_object_put(vm->lib.Number, js_cstring("prototype"), vm->lib.Number_prototype);
    js_object_put(vm->global_scope->global_object, js_cstring("Number"), vm->lib.Number);
}