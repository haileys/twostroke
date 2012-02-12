#include <stdlib.h>
#include <string.h>
#include "image.h"

/* this function is insecure. todo: sprinkle some more bounds checks through */

js_image_t* js_image_parse(char* buff, uint32_t buff_size)
{
    uint32_t i, sz;
    /*char* buff_end = buff + buff_size;*/
    js_image_t* image;
    if(buff_size < 12) {
        return NULL;
    }
    image = malloc(sizeof(js_image_t));
    memcpy(image, buff, 8);
    if(image->signature != 0x0058534a /* "JSX\0" */) {
        free(image);
        return NULL;
    }
    buff += 8;
    image->sections = malloc(sizeof(js_section_t) * image->section_count);
    for(i = 0; i < image->section_count; i++) {
        sz = *(uint32_t*)buff;
        image->sections[i].instruction_count = sz / 4;
        buff += 4;
        image->sections[i].instructions = malloc(sz);
        memcpy(image->sections[i].instructions, buff, sz);
        buff += sz;
    }
    image->string_count = *(uint32_t*)buff;
    image->strings = malloc(sizeof(js_string_t) * image->string_count);
    buff += 4;
    for(i = 0; i < image->string_count; i++) {
        sz = *(uint32_t*)buff;
        buff += 4;
        image->strings[i].length = sz;
        image->strings[i].buff = malloc(sz + 1);
        memcpy(image->strings[i].buff, buff, sz + 1);
        buff += sz + 1;
    }
    return image;
}