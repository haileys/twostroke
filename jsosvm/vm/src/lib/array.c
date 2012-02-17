#include <stdbool.h>
#include <string.h>
#include "lib.h"
#include "gc.h"
#include "object.h"

typedef struct {
    js_value_t base;
    uint32_t length;
    uint32_t items_length;
    uint32_t capacity;
    VAL* items;
} js_array_t;

static bool statically_initialized;
static js_object_internal_methods_t array_vtable;

VAL js_make_array(struct js_vm* vm, uint32_t count, VAL* items)
{
    js_array_t* ary = js_alloc(sizeof(js_array_t));
    ary->base.type = JS_T_OBJECT;
    ary->base.object.vtable = js_object_base_vtable();
    ary->base.object.prototype = vm->lib.Array_prototype;
    ary->base.object.class = vm->lib.Array;
    ary->base.object.properties = js_st_table_new();
    ary->length = count;
    ary->items_length = count;
    ary->capacity = count;
    if(count > 0) {
        ary->items = js_alloc(sizeof(VAL) * ary->capacity);
        memcpy(ary->items, items, sizeof(VAL) * ary->capacity);
    } else {
        ary->items = NULL;
    }
    return js_value_make_pointer((js_value_t*)ary);
}

static VAL Array_call(js_vm_t* vm, void* state, VAL this, uint32_t argc, VAL* argv)
{
    js_array_t* ary;
    uint32_t ary_length;
    if(argc == 1) {
        ary_length = js_to_uint32(argv[0]);
        ary = (js_array_t*)js_value_get_pointer(js_make_array(vm, ary_length, NULL));
        ary->length = ary_length;
        return js_value_make_pointer((js_value_t*)ary);
    } else {
        return js_make_array(vm, argc, argv);
    }
}

void js_lib_array_initialize(js_vm_t* vm)
{
    if(!statically_initialized) {
        statically_initialized = true;
        memcpy(&array_vtable, js_object_base_vtable(), sizeof(js_object_internal_methods_t));
    }
    
    vm->lib.Array = js_value_make_native_function(vm, NULL, Array_call, Array_call);
//    vm->lib.Array_prototype = js_make_object()
}