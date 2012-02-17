#include "lib.h"
#include "gc.h"

static VAL Object_call(js_vm_t* vm, void* state, VAL this, uint32_t argc, VAL* argv)
{
    if(argc == 0) {
        return js_make_object(vm);
    } else {
        return js_to_object(argv[0]);
    }
}

VAL js_make_object(struct js_vm* vm)
{    
    return js_value_make_object(vm->lib.Object_prototype, vm->lib.Object);
}

void js_lib_object_initialize(struct js_vm* vm)
{
    vm->lib.Object = js_value_make_native_function(vm, NULL, Object_call, Object_call);
    vm->lib.Object_prototype = js_value_make_object(js_value_null(), vm->lib.Object);
    js_object_put(vm->lib.Object, js_cstring("prototype"), vm->lib.Object_prototype);
    js_object_put(vm->global_scope->global_object, js_cstring("Object"), vm->lib.Object);
}