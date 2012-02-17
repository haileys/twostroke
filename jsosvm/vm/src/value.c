#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include "value.h"
#include "object.h"
#include "scope.h"
#include "vm.h"
#include "gc.h"
#include "lib.h"

/*
 *
 * bit twiddling stuff
 *
 */
 
js_value_t* js_value_get_pointer(VAL val)
{
    #if __WORDSIZE == 32
        return (void*)(uint32_t)(val.i & 0xfffffffful);
    #else
        #if __WORDSIZE == 64
            return (void*)(uint64_t)(val.i & 0x7ffffffffffful);
        #else
            #error address size is not supported
        #endif
    #endif
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
    val.i = (uint64_t)(intptr_t)ptr;
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
    intptr_t raw = (intptr_t)ptr;
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
    js_value_t* obj = js_alloc(sizeof(js_value_t));
    obj->type = JS_T_OBJECT;
    obj->object.vtable = js_object_base_vtable();
    obj->object.prototype = prototype;
    obj->object.class = class;
    obj->object.properties = js_st_table_new();
    return js_value_make_pointer(obj);
}

VAL js_value_make_native_function(js_vm_t* vm, void* state, VAL(*call)(js_vm_t*, void*, VAL, uint32_t, VAL*), VAL(*construct)(js_vm_t*, void*, VAL, uint32_t, VAL*))
{
    js_function_t* fn = js_alloc(sizeof(js_function_t));
    fn->base.type = JS_T_FUNCTION;
    fn->base.object.vtable = js_object_base_vtable();
    fn->base.object.prototype = vm->lib.Function_prototype;
    fn->base.object.class = vm->lib.Function;
    fn->base.object.properties = js_st_table_new();
    fn->is_native = true;
    fn->vm = vm;
    fn->native.state = state;
    fn->native.call = call;
    fn->native.construct = construct;
    return js_value_make_pointer((js_value_t*)fn);
}

VAL js_value_make_function(js_vm_t* vm, js_image_t* image, uint32_t section, js_scope_t* outer_scope)
{
    js_function_t* fn = js_alloc(sizeof(js_function_t));
    fn->base.type = JS_T_FUNCTION;uint32_t js_to_uint32(VAL value);
    int32_t js_to_int32(VAL value);
    fn->base.object.vtable = js_object_base_vtable();
    fn->base.object.prototype = vm->lib.Function_prototype;
    fn->base.object.class = vm->lib.Function;
    fn->base.object.properties = js_st_table_new();
    fn->vm = vm;
    fn->is_native = false;
    fn->js.image = image;
    fn->js.section = section;
    fn->js.outer_scope = outer_scope;
    return js_value_make_pointer((js_value_t*)fn);
}

VAL js_value_make_cstring(char* str)
{
    return js_value_make_string(str, strlen(str));
}

VAL js_value_make_string(char* buff, uint32_t len)
{
    js_value_t* val = js_alloc(sizeof(js_value_t));
    val->type = JS_T_STRING;
    val->string.buff = js_alloc(len + 1);
    memcpy(val->string.buff, buff, len);
    val->string.buff[len] = 0; /* null terminate to ensure things don't break with old c stuff */
    val->string.length = len;
    return js_value_make_pointer(val);
}

js_string_t* js_cstring(char* cstr)
{
    js_string_t* str = js_alloc(sizeof(js_string_t));
    uint32_t len = strlen(cstr);
    str->buff = js_alloc(len + 1);
    memcpy(str->buff, cstr, len);
    str->buff[len] = 0;
    str->length = len;
    return str;
}

VAL js_value_wrap_string(js_string_t* string)
{
    js_value_t* val = js_alloc(sizeof(js_value_t));
    val->type = JS_T_STRING;
    memcpy(&val->string, string, sizeof(js_string_t));
    return js_value_make_pointer(val);
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
            return js_value_make_boolean(js_value_get_pointer(value)->string.length > 0);
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
            return js_value_make_double(js_number_parse(&js_value_get_pointer(value)->string));
        default:
            /* @TODO js_to_number( js_to_primitive( value, "number" ) ) */
            break;
    }
    // @TODO throw?
    return js_value_null();
}

uint32_t js_to_uint32(VAL value)
{
    double d = js_value_get_double(js_to_number(value));
    if(!isfinite(d) || d != d) {
        return 0;
    } else {
        return (uint32_t)d;
    }
}

int32_t js_to_int32(VAL value)
{
    double d = js_value_get_double(js_to_number(value));
    if(!isfinite(d) || d != d) {
        return 0;
    } else {
        return (int32_t)d;
    }
}

VAL js_to_string(VAL value)
{
    switch(js_value_get_type(value)) {
        case JS_T_UNDEFINED:
            return js_value_make_cstring("undefined");
        case JS_T_NULL:
            return js_value_make_cstring("null");
        case JS_T_BOOLEAN:
            return js_value_make_cstring(js_value_is_truthy(value) ? "true" : "false");
        case JS_T_NUMBER: {
            char buff[32];
            snprintf(buff, 32, "%lf", js_value_get_double(value));
            return js_value_make_cstring(buff);
        }
        case JS_T_STRING:
            return value;
        default:
            /* @TODO js_to_string( js_to_primitive( value, "string" ) ) */
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

bool js_object_has_property(VAL obj, js_string_t* prop)
{
    js_value_t* val;
    if(js_value_is_primitive(obj)) {
        return js_object_has_property(js_to_object(obj), prop);
    }
    val = js_value_get_pointer(obj);
    return val->object.vtable->has_property(val, prop);
}

VAL js_call(VAL fn, VAL this, uint32_t argc, VAL* argv)
{
    js_function_t* function;
    if(js_value_get_type(fn) != JS_T_FUNCTION) {
        // @TODO throw exception
        printf("[PANIC] called non callable\n");
        exit(-1);
    }
    function = (js_function_t*)js_value_get_pointer(fn);
    if(function->is_native) {
        return function->native.call(function->vm, function->native.state, this, argc, argv);
    } else {
        return js_vm_exec(function->vm, function->js.image, function->js.section, js_scope_close(function->js.outer_scope, fn), this, argc, argv);
    }
}

VAL js_construct(VAL fn, uint32_t argc, VAL* argv)
{
    // @TODO
    VAL this = js_value_make_object(js_object_get(fn, js_cstring("prototype")), fn);
    js_function_t* function;
    if(js_value_get_type(fn) != JS_T_FUNCTION) {
        // @TODO throw exception
        printf("[PANIC] constructed non callable\n");
        exit(-1);
    }
    function = (js_function_t*)js_value_get_pointer(fn);
    if(function->is_native) {
        if(function->native.construct) {
            return function->native.construct(function->vm, function->native.state, this, argc, argv);
        } else {
            // @TODO throw exception
            printf("[PANIC] function is not a constructor\n");
            exit(-1);
        }
    } else {
        return js_vm_exec(function->vm, function->js.image, function->js.section, js_scope_close(function->js.outer_scope, fn), this, argc, argv);
    }
}