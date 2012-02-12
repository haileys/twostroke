#include <stdlib.h>
#include <stdio.h>
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
    { "true",       OPERAND_NONE },
    { "false",      OPERAND_NONE },
    { "null",       OPERAND_NONE },
    { "jmp",        OPERAND_UINT32 },
    { "jit",        OPERAND_UINT32 },
    { "jif",        OPERAND_UINT32 },
    { "sub",        OPERAND_NONE },
    { "mul",        OPERAND_NONE },
    { "div",        OPERAND_NONE },
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

#define PUSH(v) do { \
                    if(SP >= SMAX) { \
                        STACK = realloc(STACK, sizeof(VAL) * (SMAX *= 2)); \
                    } \
                    STACK[SP++] = (v); \
                } while(false)
#define POP()   (STACK[--SP])
#define PEEK()  (STACK[SP - 1])

VAL js_vm_exec(js_vm_t* vm, js_image_t* image, uint32_t section, js_scope_t* scope, VAL this, uint32_t argc, VAL* argv)
{
    uint32_t IP = 0;
    uint32_t* INSNS = image->sections[section].instructions;
    uint32_t opcode;
    
    uint32_t SP = 0;
    uint32_t SMAX = 4;
    VAL* STACK = malloc(sizeof(VAL) * SMAX);
    
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
            
            case JS_OP_ADD: {
                VAL r = js_to_primitive(POP());
                VAL l = js_to_primitive(POP());
                if(js_value_get_type(l) == JS_T_STRING || js_value_get_type(r) == JS_T_STRING) {
                    /* concatenate strings @TODO */
                    PUSH(js_value_undefined());
                } else {
                    PUSH(js_value_make_double(js_value_get_double(js_to_number(l)) + js_value_get_double(js_to_number(r))));
                }
                break;
            }
            
            case JS_OP_PUSHGLOBAL: {
                js_string_t* var = NEXT_STRING();
                PUSH(js_scope_get_global_var(scope, var));
                break;
            }
        
            case JS_OP_PUSHSTR:
                /* @TODO */
                break;
        
            case JS_OP_METHCALL:
                /* @TODO */
                break;
        
            case JS_OP_SETVAR: {
                uint32_t idx = NEXT_UINT32();
                uint32_t sc = NEXT_UINT32();
                js_scope_set_var(scope, idx, sc, PEEK());
                break;
            }
        
            case JS_OP_PUSHVAR: {
                uint32_t idx = NEXT_UINT32();
                uint32_t sc = NEXT_UINT32();
                PUSH(js_scope_get_var(scope, idx, sc));
                break;
            }
            
            case JS_OP_TRUE:
                PUSH(js_value_true());
                break;
                
            case JS_OP_FALSE:
                PUSH(js_value_false());
                break;

            case JS_OP_NULL:
                PUSH(js_value_null());
                break;
                
            case JS_OP_JMP: {
                uint32_t next = NEXT_UINT32();
                IP = next;
                break;
            }
                
            case JS_OP_JIT: {
                uint32_t next = NEXT_UINT32();
                if(js_value_is_truthy(POP())) {
                    IP = next;
                }
                break;
            }
            
            case JS_OP_JIF: {
                uint32_t next = NEXT_UINT32();
                if(!js_value_is_truthy(POP())) {
                    IP = next;
                }
                break;
            }
            
            case JS_OP_SUB: {
                VAL r = js_to_primitive(POP());
                VAL l = js_to_primitive(POP());
                PUSH(js_value_make_double(js_value_get_double(js_to_number(l)) - js_value_get_double(js_to_number(r))));
                break;
            }
            
            case JS_OP_MUL: {
                VAL r = js_to_primitive(POP());
                VAL l = js_to_primitive(POP());
                PUSH(js_value_make_double(js_value_get_double(js_to_number(l)) * js_value_get_double(js_to_number(r))));
                break;
            }
            
            case JS_OP_DIV: {
                VAL r = js_to_primitive(POP());
                VAL l = js_to_primitive(POP());
                PUSH(js_value_make_double(js_value_get_double(js_to_number(l)) / js_value_get_double(js_to_number(r))));
                break;
            }
            
            default:
                /* @TODO proper-ify this */
                fprintf(stderr, "[PANIC] unknown opcode %u\n", opcode);
                exit(-1);
        }
    }
}