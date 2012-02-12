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

enum js_opcode {
    JS_OP_UNDEFINED     = 0,
    JS_OP_RET           = 1,
    JS_OP_PUSHNUM       = 2,
    JS_OP_ADD           = 3,
    JS_OP_PUSHGLOBAL    = 4,
    JS_OP_PUSHSTR       = 5,
    JS_OP_METHCALL      = 6,
    JS_OP_SETVAR        = 7,
    JS_OP_PUSHVAR       = 8,
    JS_OP_TRUE          = 9,
    JS_OP_FALSE         = 10,
    JS_OP_NULL          = 11,
    JS_OP_JMP           = 12,
    JS_OP_JIT           = 13,
    JS_OP_JIF           = 14,
    JS_OP_SUB           = 15,
    JS_OP_MUL           = 16,
    JS_OP_DIV           = 17,
};

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