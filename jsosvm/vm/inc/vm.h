#ifndef JS_VM_H
#define JS_VM_H

#include <stdint.h>
#include "scope.h"
#include "image.h"
#include "value.h"

typedef struct {
    js_scope_t* global_scope;
} js_vm_t;

js_vm_t* js_vm_new();
VAL js_vm_exec(js_vm_t* vm, js_image_t* image, uint32_t section, js_scope_t* scope, VAL this, uint32_t argc, VAL* argv);

typedef struct {
    char* name;
    enum {
        OPERAND_NONE,
        OPERAND_NUMBER,
        OPERAND_UINT32,
        OPERAND_UINT32_UINT32,
        OPERAND_STRING,
    } operand;
} js_instruction_t;

js_instruction_t* js_instruction(uint32_t opcode);

#endif