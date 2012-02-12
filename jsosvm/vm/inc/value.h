#ifndef JS_VALUE_H
#define JS_VALUE_H

#include <stdbool.h>
#include <stdint.h>
#include "st.h"

typedef enum {
    JS_T_NULL,
    JS_T_UNDEFINED,
    JS_T_BOOLEAN,
    JS_T_NUMBER,
    JS_T_OBJECT,
    JS_T_STRING,
    JS_T_FUNCTION,
    JS_T_ARRAY,
    JS_T_STRING_OBJECT,
    JS_T_NUMBER_OBJECT,
    JS_T_BOOLEAN_OBJECT,
} js_type_t;

typedef union {
    double d;
    uint64_t i;
} VAL;

typedef struct {
    uint32_t length;
    char* buff;
} js_string_t;

typedef struct {
    
} js_property_descriptor_t;

struct js_object_internal_methods;

typedef struct {
    struct js_object_internal_methods* vtable;
    VAL prototype;
    VAL class;
    st_table properties;
} js_object_t;

typedef struct {
    js_type_t type;
    union {
        js_string_t string;
        js_object_t object;
    };
} js_value_t;

typedef struct js_object_internal_methods {
    /* all objects should have these implemented: */
    VAL                         (*get)                  (js_value_t*, js_string_t*);
    js_property_descriptor_t*   (*get_own_property)     (js_value_t*, js_string_t*);
    js_property_descriptor_t*   (*get_property)         (js_value_t*, js_string_t*);
    void                        (*put)                  (js_value_t*, js_string_t*, VAL);
    bool                        (*can_put)              (js_value_t*, js_string_t*);
    bool                        (*has_property)         (js_value_t*, js_string_t*);
    bool                        (*delete)               (js_value_t*, js_string_t*);
    VAL                         (*default_value)        (js_value_t*);
    bool                        (*define_own_property)  (js_value_t*, js_property_descriptor_t*);
    
    /* these are optional, set to NULL if not implemented: */
    VAL                         (*call)                 (js_value_t*, VAL, js_arguments_t*);
    VAL                         (*construct)            (js_value_t*, js_arguments_t*);
} js_object_internal_methods_t;

VAL js_value_make_pointer(js_value_t* ptr);
VAL js_value_make_double(double num);
VAL js_value_undefined();
VAL js_value_null();
VAL js_value_false();
VAL js_value_true();
VAL js_value_make_boolean(bool boolean);

js_value_t* js_value_get_pointer(VAL val);
double js_value_get_double(VAL val);
bool js_value_is_truthy(VAL val);
js_type_t js_value_get_type(VAL val);

VAL js_to_object(VAL value);
VAL js_to_primitive(VAL value);
VAL js_to_boolean(VAL value);
VAL js_to_number(VAL value);

VAL js_object_get(VAL obj, js_string_t* prop);
void js_object_put(VAL obj, js_string_t* prop, VAL value);

#endif