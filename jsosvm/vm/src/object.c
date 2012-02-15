#include <stdlib.h>
#include <string.h>
#include "object.h"
#include "st.h"

int js_string_cmp(js_string_t* a, js_string_t* b)
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
    uint32_t i;
    for(i = 0; i < str->length; i++) {
        val += str->buff[i];
        val += (str->buff[i] << 10);
        val ^= (str->buff[i] >> 6);
    }
    val += (val << 3);
    val ^= (val >> 11);
    return val + (val << 15);
}

static struct st_hash_type js_string_st_type = {
    js_string_cmp,
    js_string_hash
};

st_table* js_st_table_new()
{
    return st_init_table(&js_string_st_type);
}

static VAL js_object_base_get(js_value_t* obj, js_string_t* prop)
{
    js_property_descriptor_t* descr = NULL;
    if(!st_lookup(obj->object.properties, (st_data_t)prop, (st_data_t*)&descr)) {
        /* if not in object, look in prototype */
        if(js_value_get_type(obj->object.prototype) == JS_T_UNDEFINED || js_value_get_type(obj->object.prototype) == JS_T_NULL) {
            /* do not attempt if prototype is null or undefined */
            return js_value_undefined();
        }
        return js_object_get(obj->object.prototype, prop);
    }
    // @TODO: access property descriptor properly
    return descr->value;
}

static void js_object_base_put(js_value_t* obj, js_string_t* prop, VAL value)
{
    js_property_descriptor_t* descr = NULL;
    if(st_lookup(obj->object.properties, (st_data_t)prop, (st_data_t*)&descr)) {
        descr->value = value;
        return;
    }
    descr = malloc(sizeof(js_property_descriptor_t));
    descr->value = value;
    st_insert(obj->object.properties, (st_data_t)prop, (st_data_t)descr);
}

static js_object_internal_methods_t object_base_vtable = {
    /* get */                   js_object_base_get,
    /* get_own_property */      NULL,
    /* get_property */          NULL,
    /* put */                   js_object_base_put,
    /* can_put */               NULL,
    /* has_property */          NULL,
    /* delete */                NULL,
    /* default_value */         NULL,
    /* define_own_property */   NULL,
    // @TODO: ^^ all those
};

js_object_internal_methods_t* js_object_base_vtable()
{
    return &object_base_vtable;
}