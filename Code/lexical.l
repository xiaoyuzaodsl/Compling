%{

#include <stdint.h>
#include <stdlib.h>
#include "common.h"
#include "error.h"
#include "tree.h"
#include "syntax.tab.h"
//初始化行号列号
node_t *yylval;
loc_t yylloc = LOC_INITIALIZER;
static loc_t prev_loc = LOC_INITIALIZER;

static const char *const token_name[256] = {
    [(uint8_t)(';')] = "SEMI",
    [(uint8_t)(',')] = "COMMA",
    [(uint8_t)('=')] = "ASSIGNOP",
    [(uint8_t)('+')] = "PLUS",
    [(uint8_t)('-')] = "MINUS",
    [(uint8_t)('*')] = "STAR",
    [(uint8_t)('/')] = "DIV",
    [(uint8_t)('.')] = "DOT",
    [(uint8_t)('!')] = "NOT",
    [(uint8_t)('(')] = "LP",
    [(uint8_t)(')')] = "RP",
    [(uint8_t)('[')] = "LB",
    [(uint8_t)(']')] = "RB",
    [(uint8_t)('{')] = "LC",
    [(uint8_t)('}')] = "RC",
};
//维护当前位置
#define YY_USER_ACTION                                      \
    yylloc = prev_loc;                                      \
    for (int i = 0; yytext[i] != '\0'; i++) {               \
        if (yytext[i] == '\n') {                            \
            prev_loc.line++; prev_loc.col = 1;              \
        } else {                                            \
            prev_loc.col++;                                 \
        }                                                   \
    }

%}

%option nounput noinput
%x COMMENT_1
%x COMMENT_2

digit               [0-9]

num            \.?{digit}([.0-9a-zA-Z_]|(e+)|(e-)|(E+)|(E-))*
relop               >|<|>=|<=|==|!=
id          [a-zA-Z_][a-zA-Z0-9_]*

%%

[ \t\n]+            //清除空格换行制表符

"/*"                { BEGIN(COMMENT_1); }

<COMMENT_1>"*/"     { BEGIN(INITIAL); }

<COMMENT_1>(.|\n)   //清除注释

<COMMENT_1><<EOF>>  {
                        error_rec(ERROR_MYSCOMM, yylloc);
                        return 0; 
                    }

"//"                { BEGIN(COMMENT_2); }

<COMMENT_2>\n     { BEGIN(INITIAL); }

<COMMENT_2><<EOF>>    { BEGIN(INITIAL); return 0; }

<COMMENT_2>.      //清除注释

{num}          {        //对多进制数进行判断
                        char *end;
                        
                        errno = 0;                        
                        if (yytext[0] == '0' && yytext[1] == 'x') {
                            /* hexadecimal number literal */
                            long value = strtol(yytext, &end, 16);
                            if (*end != '\0') {
                                error_rec(ERROR_INVHEXNUM, yylloc, yytext);
                            } else if (errno == ERANGE) {
                                error_rec(ERROR_INTNUM_OF, yylloc, yytext);
                            }
                            yylval = node_ctor(yylloc, 1, "INT: %d", value);
                            return INT;

                        } if (strchr(yytext, '.') || strchr(yytext, 'e') ||
                            strchr(yytext, 'E')) {
                            /* floating-point number literal */
                            double value = strtod(yytext, &end);
                            if (*end != '\0') {
                                error_rec(ERROR_INVFPNUM, yylloc, yytext);
                            } else if (errno == ERANGE) {
                                error_rec(ERROR_FPNUM_OF, yylloc, yytext);
                            }
                            yylval = node_ctor(yylloc, 1, "FLOAT: %.6f", value);
                            return FLOAT;
                                
                        } else if (yytext[0] == '0') {
                            /* octal number literal */
                            long value = strtol(yytext, &end, 8);
                            if (*end != '\0') {
                                error_rec(ERROR_INVOCTNUM, yylloc, yytext);
                            } else if (errno == ERANGE) {
                                error_rec(ERROR_INTNUM_OF, yylloc, yytext);
                            }
                            yylval = node_ctor(yylloc, 1, "INT: %d", value);
                            return INT;

                        } else {
                            /* decimal number literal */
                            long value = strtol(yytext, &end, 10);
                            if (*end != '\0') {
                                error_rec(ERROR_INVDECNUM, yylloc, yytext);
                            } else if (errno == ERANGE) {
                                error_rec(ERROR_INTNUM_OF, yylloc, yytext);
                            }
                            yylval = node_ctor(yylloc, 1, "INT: %d", value);
                            return INT;

                        }
                    }

int|float           {
                        yylval = node_ctor(yylloc, 1, "TYPE: %s", yytext);
                        return TYPE;
                    }

struct              {
                        yylval = node_ctor(yylloc, 1, "STRUCT");
                        return STRUCT;
                    }

if                  {
                        yylval = node_ctor(yylloc, 1, "IF");
                        return IF;
                    }

else                {
                        yylval = node_ctor(yylloc, 1, "ELSE");
                        return ELSE;
                    }

while               {
                        yylval = node_ctor(yylloc, 1, "WHILE");
                        return WHILE;
                    }

return              {
                        yylval = node_ctor(yylloc, 1, "RETURN");
                        return RETURN;
                    }

{relop}             {
                        yylval = node_ctor(yylloc, 1, "RELOP");
                        return RELOP;
                    }

{id}        {
                        yylval = node_ctor(yylloc, 1, "ID: %s", yytext);
                        return ID;
                    }

&&                  {
                        yylval = node_ctor(yylloc, 1, "AND");
                        return AND;
                    }

\|\|                {
                        yylval = node_ctor(yylloc, 1, "OR");
                        return OR;
                    }

[(){};!=.,]         {
                        yylval = node_ctor(yylloc, 1,
                            token_name[(uint8_t)(yytext[0])]);
                        return yytext[0];
                    }

[-+/*]              {
                        yylval = node_ctor(yylloc, 1,
                            token_name[(uint8_t)(yytext[0])]);
                        return yytext[0];
                    }

\[|\]               {
                        yylval = node_ctor(yylloc, 1,
                            token_name[(uint8_t)(yytext[0])]);
                        return yytext[0];
                    }

.                   { 
                        error_rec(ERROR_MYSCHAR, yylloc, yytext);
                    }
                
%%

int yywrap() { return 1; }

