#ifndef JS_IMAGE_H
#define JS_IMAGE_H

#include <stdint.h>
#include "value.h"

enum js_opcode {
    JS_OP_UNDEFINED     = 0,
    JS_OP_RET           = 1,
    JS_OP_PUSHNUM       = 2,
    JS_OP_ADD           = 3,
    JS_OP_PUSHGLOBAL    = 4,
    JS_OP_PUSHSTR       = 5,
    JS_OP_METHCALL      = 6,
    JS_OP_SETVAR        = 7,
    JS_OP_PUSHVAR       = 8
};

typedef struct {
    uint32_t instruction_count;
    uint32_t* instructions;
} js_section_t;

typedef struct {
    uint32_t signature;
    uint32_t section_count;
    js_section_t* sections;
    uint32_t string_count;
    js_string_t* strings;
} js_image_t;

js_image_t* js_image_parse(char* buff, uint32_t buff_size);

#endif