#include <stdlib.h>
#include "vm.h"

static js_instruction_t insns[] = {
    { "undefined",  OPERAND_NONE },
    { "ret",        OPERAND_NONE },
    { "pushnum",    OPERAND_NUMBER },
    { "add",        OPERAND_NONE },
    { "pushglobal", OPERAND_STRING },
    { "pushstr",    OPERAND_STRING },
    { "methcall",   OPERAND_UINT32 },
    { "setvar",     OPERAND_UINT32_UINT32 },
    { "pushvar",    OPERAND_UINT32_UINT32 },    
};

js_instruction_t* js_instruction(uint32_t opcode)
{
    if(opcode >= sizeof(insns) / sizeof(insns[0])) {
        return NULL;
    }
    return &insns[opcode];
}

js_vm_t* js_vm_new()
{
    js_vm_t* vm = malloc(sizeof(js_vm_t));
    vm->global_scope = js_scope_make_global(js_value_undefined() /* @TODO: change to object */);
    return vm;
}

/* @TODO: bounds checking here */
#define NEXT_UINT32() (INSNS[IP++])
#define NEXT_DOUBLE() (IP += 2, *(double*)&INSNS[IP - 2])
#define NEXT_STRING() (&image->strings[NEXT_UINT32()])

#define PUSH(v) ((SP >= SMAX ? (STACK = realloc(STACK, sizeof(VAL) * SMAX *= 2)) : STACK)[SP++] = (v))
#define POP()   (STACK[--SP])

VAL js_vm_exec(js_vm_t* vm, js_image_t* image, uint32_t section, js_scope_t* scope, VAL this, uint32_t argc, VAL* argv)
{
    uint32_t IP = 0;
    uint32_t IP_MAX = image->sections[section].instruction_count;
    uint32_t* INSNS = image->sections[section].instructions;
    uint32_t opcode;
    
    uint32_t SP = 0;
    uint32_t SMAX = 4;
    VAL* STACK = malloc(sizeof(VAL) * SMAX);
    
    VAL l, r;
    
    while(1) {
        opcode = NEXT_UINT32();
        switch(opcode) {
            
        case JS_OP_UNDEFINED:
            PUSH(js_value_undefined());
            break;
            
        case JS_OP_RET:
            return POP();
            break;
            
        case JS_OP_PUSHNUM:
            PUSH(js_value_make_double(NEXT_DOUBLE()));
            break;
            
        case JS_OP_ADD:
            r = js_to_primitive(POP());
            l = js_to_primitive(POP());
            if(js_value_get_type(l) == JS_T_STRING || js_value_get_type(r) == JS_T_STRING) {
                /* concatenate strings @TODO */
                PUSH(js_value_undefined());
            } else {
                PUSH(js_value_make_double(js_value_get_double(js_to_number(l)) + js_value_get_double(js_to_number(r))));
            }
            
        case JS_OP_PUSHGLOBAL:
        }
    }
}