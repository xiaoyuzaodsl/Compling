#ifndef __COMMON_H__
#define __COMMON_H__

//维护当前位置
typedef struct loc {
    int line, col;
} loc_t;
//初始化行号列号
#define LOC_INITIALIZER ((loc_t) {1, 1})

extern loc_t yylloc;

int yylex(void);
int yyparse(void);

#endif