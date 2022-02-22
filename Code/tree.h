#ifndef __TREE_H__
#define __TREE_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "common.h"

typedef struct nodee {
    //buf分配一段内存 nr_child用于记录子结点的个数 loc记录当前行号以及列号
    char *buf;
    int nr_child;
    loc_t loc;
    struct nodee **child;
} node_t;

node_t *cst;
//node_ctor操作用于维护node结构
static inline node_t *node_ctor(loc_t loc, int nr_child, const char *fmt, ...) {
    va_list args1, args2;
    va_start(args1, fmt); va_copy(args2, args1);
    //为对象分配存储空间
    node_t *ret = malloc(sizeof(node_t));
    ret->loc = loc;
    ret->buf = malloc(1 + vsnprintf(NULL, 0, fmt, args1));
    vsprintf(ret->buf, fmt, args2);
    ret->nr_child = nr_child;
    ret->child = calloc(nr_child, sizeof(node_t *));
    va_end(args1); va_end(args2);
    return ret;
}
//node_print操作用于打印node所保存的语法树
static inline void node_print(node_t *cst, int indent) {
    if (cst == NULL) return;
    for (int i = 0; i < indent; i++) printf("  ");
    puts(cst->buf);
    for (int i = 0; i < cst->nr_child; i++)
        node_print(cst->child[i], indent + 1);
}
//node_dtor操作用于释放node存储部分的内存
static inline void node_dtor(node_t *cst) {
    if (cst == NULL) return;
    for (int i = 0; i < cst->nr_child; i++)
        node_dtor(cst->child[i]);
    free(cst->child);
    free(cst->buf);
    free(cst);
}

#endif

