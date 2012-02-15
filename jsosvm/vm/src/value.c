#include <stdlib.h>
#include <math.h>
#include "value.h"
#include "object.h"
#include "scope.h"
#include "vm.h"

/*
 *
 * bit twiddling stuff
 *
 */
 
js_value_t* js_value_get_pointer(VAL val)
{
    return (void*)(uint32_t)(val.i & 0xfffffffful);
}

double js_value_get_double(VAL val)
{
    return val.d;
}

VAL js_value_make_double(double num)
{
    VAL val;
    val.d = num;
    return val;
}

VAL js_value_make_pointer(js_value_t* ptr)
{
    VAL val;
    val.i = (uint64_t)(uint32_t)ptr;
    val.i |= 0xfffa000000000000ull;
    return val;
}

VAL js_value_make_boolean(bool boolean)
{
    if(boolean) {
        return js_value_make_pointer((js_value_t*)4);
    } else {
        return js_value_make_pointer((js_value_t*)3);
    }
}

VAL js_value_false()
{
    return js_value_make_boolean(false);
}
    
VAL js_value_true()
{
    return js_value_make_boolean(true);
}

VAL js_value_undefined()
{
    return js_value_make_pointer((js_value_t*)1);
}

VAL js_value_null()
{
    return js_value_make_pointer((js_value_t*)2);
}

js_type_t js_value_get_type(VAL val)
{
    js_value_t* ptr;
    if(val.i <= 0xfff8000000000000ull) return JS_T_NUMBER;
    
    ptr = js_value_get_pointer(val);
    uint32_t raw = (uint32_t)ptr;
    if(raw == 1) {
        return JS_T_UNDEFINED;
    }
    if(raw == 2) {
        return JS_T_NULL;
    }
    if(raw == 3 || raw == 4) {
        return JS_T_BOOLEAN;
    }
    
    return ptr->type;
}

/*
 *
 * END bit twiddling stuff
 *
 */

VAL js_value_make_object(VAL prototype, VAL class)
{
    js_value_t* obj = malloc(sizeof(js_value_t));
    obj->type = JS_T_OBJECT;
    obj->object.vtable = js_object_base_vtable();
    obj->object.prototype = prototype;
    obj->object.class = class;
    obj->object.properties = js_st_table_new();
    return js_value_make_pointer(obj);
}

VAL js_value_make_native_function(void* state, VAL(*call)(void*, VAL, uint32_t, VAL*), VAL(*construct)(void*, VAL, uint32_t, VAL*))
{
    js_function_t* fn = malloc(sizeof(js_function_t));
    fn->base.type = JS_T_FUNCTION;
    fn->base.object.vtable = js_object_base_vtable();
    fn->base.object.prototype = js_value_undefined(); // @TODO: set to Function.prototype
    fn->base.object.class = js_value_undefined(); // @TODO: set to Function
    fn->base.object.properties = js_st_table_new();
    fn->is_native = true;
    fn->native.state = state;
    fn->native.call = call;
    fn->native.construct = construct;
    return js_value_make_pointer((js_value_t*)fn);
}

VAL js_value_make_function(js_vm_t* vm, js_image_t* image, uint32_t section, js_scope_t* outer_scope)
{
    js_function_t* fn = malloc(sizeof(js_function_t));
    fn->base.type = JS_T_FUNCTION;
    fn->base.object.vtable = js_object_base_vtable();
    fn->base.object.prototype = js_value_undefined(); // @TODO: set to Function.prototype
    fn->base.object.class = js_value_undefined(); // @TODO: set to Function
    fn->base.object.properties = js_st_table_new();
    fn->is_native = false;
    fn->js.vm = vm;
    fn->js.image = image;
    fn->js.section = section;
    fn->js.outer_scope = outer_scope;
    return js_value_make_pointer((js_value_t*)fn);
}

bool js_value_is_truthy(VAL val)
{
    if(js_value_get_type(val) == JS_T_BOOLEAN) {
        return val.i == js_value_true().i;
    } else {
        return js_value_is_truthy(js_to_boolean(val));
    }
}

bool js_value_is_object(VAL val)
{
    return !js_value_is_primitive(val);
}

bool js_value_is_primitive(VAL val)
{
    switch(js_value_get_type(val)) {
        case JS_T_NULL:
        case JS_T_UNDEFINED:
        case JS_T_BOOLEAN:
        case JS_T_NUMBER:
        case JS_T_STRING:
            return true;
        default:
            return false;
    }
}

VAL js_to_boolean(VAL value)
{
    switch(js_value_get_type(value)) {
        case JS_T_NULL:
        case JS_T_UNDEFINED:
            return js_value_false();
        case JS_T_BOOLEAN:
            return value;
        case JS_T_NUMBER:
            return js_value_make_boolean(
                js_value_get_double(value) != 0 /* non zero */
                && js_value_get_double(value) == js_value_get_double(value) /* non-nan */
            );
        case JS_T_STRING:
            /* @TODO return string != "" */
        default:
            return js_value_true();
    }
}

VAL js_to_object(VAL value)
{
    switch(js_value_get_type(value)) {
        case JS_T_NULL:
        case JS_T_UNDEFINED:
            printf("[PANIC] tried to convert undefined to object!\n");
            exit(-1);
            // @TODO throw exception
        case JS_T_BOOLEAN:
            // @TODO convert to Boolean object
        case JS_T_NUMBER:
            // @TODO convert to Number object
        case JS_T_STRING:
            // @TODO convert to String object
            
        case JS_T_OBJECT:
        case JS_T_FUNCTION:
        case JS_T_ARRAY:
        case JS_T_STRING_OBJECT:
        case JS_T_NUMBER_OBJECT:
        case JS_T_BOOLEAN_OBJECT:
            return value;
    }
    // @TODO throw?
    return js_value_null();
}

VAL js_to_primitive(VAL value)
{
    switch(js_value_get_type(value)) {
        case JS_T_NULL:
        case JS_T_UNDEFINED:
        case JS_T_BOOLEAN:
        case JS_T_NUMBER:
        case JS_T_STRING:
            return value;
            
        case JS_T_OBJECT:
            /* @TODO */
            break;
                
        case JS_T_FUNCTION:
            /* @TODO */
            break;
        
        case JS_T_ARRAY:
            /* @TODO */
            break;
            
        case JS_T_STRING_OBJECT:
            /* @TODO */
            break;
            
        case JS_T_NUMBER_OBJECT:
            /* @TODO */
            break;
            
        case JS_T_BOOLEAN_OBJECT:
            /* @TODO */
            break;
    }
    // @TODO throw?
    return js_value_null();
}

VAL js_to_number(VAL value)
{
    switch(js_value_get_type(value)) {
        case JS_T_UNDEFINED:
            return js_value_make_double(NAN);
        case JS_T_NULL:
            return js_value_make_double(0.0);
        case JS_T_BOOLEAN:
            return js_value_make_double(js_value_is_truthy(value));
        case JS_T_NUMBER:
            return value;
        case JS_T_STRING:
            /* @TODO parse string */
        default:
            /* @TODO js_to_number( js_to_primitive( value, "number" ) ) */
            break;
    }
    // @TODO throw?
    return js_value_null();
}

VAL js_object_get(VAL obj, js_string_t* prop)
{
    js_value_t* val;
    if(js_value_is_primitive(obj)) {
        return js_object_get(js_to_object(obj), prop);
    }
    val = js_value_get_pointer(obj);
    return val->object.vtable->get(val, prop);
}

void js_object_put(VAL obj, js_string_t* prop, VAL value)
{
    js_value_t* val;
    if(js_value_is_primitive(obj)) {
        js_object_put(js_to_object(obj), prop, value);
        return;
    }
    val = js_value_get_pointer(obj);
    val->object.vtable->put(val, prop, value);
}

VAL js_call(VAL fn, VAL this, uint32_t argc, VAL* argv)
{
    js_function_t* function;
    if(js_value_get_type(fn) != JS_T_FUNCTION) {
        // @TODO throw exception
        printf("[PANIC] called non callable");
        exit(-1);
    }
    function = (js_function_t*)js_value_get_pointer(fn);
    if(function->is_native) {
        return function->native.call(function->native.state, this, argc, argv);
    } else {
        return js_vm_exec(function->js.vm, function->js.image, function->js.section, js_scope_close(function->js.outer_scope, fn), this, argc, argv);
    }
}

VAL js_construct(VAL fn, uint32_t argc, VAL* argv)
{
    // @TODO
    (void)fn;
    (void)argc;
    (void)argv;
    return js_value_undefined();
}