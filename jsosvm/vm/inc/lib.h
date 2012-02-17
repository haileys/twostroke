#ifndef JS_LIB_H
#define JS_LIB_H

#include "value.h"

typedef struct {
    VAL Function;
    VAL Function_prototype;
    VAL Object;
    VAL Object_prototype;
    VAL Array;
    VAL Array_prototype;
    VAL Number;
    VAL Number_prototype;
} js_lib_t;

#include "vm.h"

void js_lib_initialize(struct js_vm* vm);

/* Function */
void js_lib_function_initialize(struct js_vm* vm);

/* Object */
void js_lib_object_initialize(struct js_vm* vm);
VAL js_make_object(struct js_vm*);

/* Array */
void js_lib_array_initialize(struct js_vm* vm);
VAL js_make_array(struct js_vm* vm, uint32_t count, VAL* items);

/* Number */
void js_lib_number_initialize(struct js_vm* vm);
double js_number_parse(js_string_t* str);

#endif