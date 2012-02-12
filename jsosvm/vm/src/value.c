#include <math.h>
#include "value.h"

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

bool js_value_is_truthy(VAL val)
{
    if(js_value_get_type(val) == JS_T_BOOLEAN) {
        return val.i == js_value_true().i;
    } else {
        return js_value_is_truthy(js_to_boolean(val));
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
    /* @TODO */
    obj = obj;
    prop = prop;
    return js_value_undefined();
}

void js_object_put(VAL obj, js_string_t* prop, VAL value)
{
    /* @TODO */
    obj = obj;
    prop = prop;
    value = value;
}
