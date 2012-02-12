#include "object.h"
#include "st.h"

static int js_string_cmp(js_string_t* a, js_string_t* b)
{
    if(a->length < b->length) {
        return -1;
    }
    if(a->length > b->length) {
        return 1;
    }
    return memcmp(a->buff, b->buff, a->length);
}

static int js_string_hash(js_string_t* str)
{
    int val = 0;
    int i;
    for(i = 0; i < str->length; i++) {
        val += str->buff[i];
        val += (str->buff[i] << 10);
        val ^= (str->buff[i] >> 6);
    }
    val += (val << 3);
    val ^= (val >> 11);
    return val + (val << 15);
}

static struct st_hash_type js_string_hash = {
    js_string_cmp,
    js_string_hash
};

static VAL js_object_base_get(js_value_t* value, js_string_t* prop)
{
    
}

static js_object_internal_methods_t object_base_vtable = {
    
};

js_object_internal_methods_t* js_object_base_vtable()
{
    return &object_base_vtable;
}