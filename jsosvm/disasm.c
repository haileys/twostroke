#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

typedef struct {
    uint32_t length;
    char* buff;
} string_t;

typedef struct {
    uint32_t instruction_count;
    uint32_t* instructions;
} section_t;

typedef struct {
    uint32_t signature;
    uint32_t section_count;
    section_t* sections;
    uint32_t string_count;
    string_t* strings;
} image_t;

typedef struct {
    char* name;
    enum {
        OPERAND_NONE,
        OPERAND_NUMBER,
        OPERAND_UINT32,
        OPERAND_UINT32_UINT32,
        OPERAND_STRING
    } operand;
} instruction_t;

instruction_t insns[] = {
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

image_t* parse_image(char* data)
{
    uint32_t i, sz;
    image_t* image = malloc(sizeof(image_t));
    memcpy(image, data, 8);
    if(image->signature != 0x0058534a /* "JSX\0" */) {
        free(image);
        return NULL;
    }
    data += 8;
    image->sections = malloc(sizeof(section_t) * image->section_count);
    for(i = 0; i < image->section_count; i++) {
        sz = *(uint32_t*)data;
        image->sections[i].instruction_count = sz / 4;
        data += 4;
        image->sections[i].instructions = malloc(sz);
        memcpy(image->sections[i].instructions, data, sz);
        data += sz;
    }
    image->string_count = *(uint32_t*)data;
    image->strings = malloc(sizeof(string_t) * image->string_count);
    data += 4;
    for(i = 0; i < image->string_count; i++) {
        sz = *(uint32_t*)data;
        data += 4;
        image->strings[i].length = sz;
        image->strings[i].buff = malloc(sz + 1);
        memcpy(image->strings[i].buff, data, sz + 1);
        data += sz + 1;
    }
    return image;
}

char* read_until_eof(FILE* f)
{
    size_t cap = 4096;
    size_t idx = 0;
    char* buff = malloc(cap);
    while(!feof(stdin)) {
        idx += fread(buff + idx, 1, 4096, f);
        if(idx >= cap) {
            cap *= 2;
            buff = realloc(buff, cap);
        }
    }
    return buff;
}

int main()
{    
    char* buff = read_until_eof(stdin);
    image_t* image = parse_image(buff);
    uint32_t i, j, op;
    double number;
    printf("read %d sections\n", image->section_count);
    for(i = 0; i < image->section_count; i++) {
        printf("\nsection %d:\n", i);
        for(j = 0; j < image->sections[i].instruction_count; j++) {
            op = image->sections[i].instructions[j];
            printf("    %04d  %-12s", j, insns[op].name);
            switch(insns[op].operand) {
                case OPERAND_NONE:
                    printf("\n");
                    break;
                case OPERAND_NUMBER:
                    number = *(double*)&image->sections[i].instructions[++j];
                    printf("%lf\n", number);
                    j++;
                    break;
                case OPERAND_UINT32:
                    op = image->sections[i].instructions[++j];
                    printf("%u\n", op);
                    break;
                case OPERAND_UINT32_UINT32:
                    op = image->sections[i].instructions[++j];
                    printf("%u, ", op);
                    op = image->sections[i].instructions[++j];
                    printf("%u\n", op);
                    break;
                case OPERAND_STRING:
                    op = image->sections[i].instructions[++j];
                    printf("\"%s\" (%d)\n", image->strings[op].buff, op);
                    break;
            }
        }
    }
    printf("\nstrings:\n");
    for(i = 0; i < image->string_count; i++) {
        printf("    %04d  \"%s\"\n", i, image->strings[i].buff);
    }
}