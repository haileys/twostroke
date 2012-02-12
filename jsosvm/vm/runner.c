#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include "image.h"
#include "vm.h"
#include "value.h"

char* read_until_eof(FILE* f, uint32_t* len)
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
    *len = idx;
    return buff;
}

int main()
{
    uint32_t len;
    char* buff = read_until_eof(stdin, &len);
    js_image_t* image = js_image_parse(buff, len);
    js_vm_t* vm = js_vm_new();
    
    VAL retn = js_vm_exec(vm, image, 0, js_scope_close(vm->global_scope), js_value_null(), 0, NULL);
    if(js_value_get_type(retn) != JS_T_NUMBER) {
        printf("retn was not a number!\n");
    } else {
        printf("retn = %lf\n", js_value_get_double(retn));
    }
    
    return 0;
}