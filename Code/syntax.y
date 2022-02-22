%{
#include "lex.yy.c"
#include <stdio.h>
#include "common.h"
#include "error.h"
#include "tree.h"

void yyerror(const char*);

#define YYLTYPE loc_t;

//维护当前位置
#define YYLLOC_DEFAULT(Cur, Rhs, N) {       \
    do {                                    \
        if (N) {                            \
            (Cur) = YYRHSLOC(Rhs, 1);       \
        } else {                            \
            (Cur) = YYRHSLOC(Rhs, 0);       \
        }                                   \
    while (0)
%}

%define api.value.type {node_t *}
%define parse.error verbose
%destructor { node_dtor($$); } <>
%start  Program
%token  INT FLOAT ID TYPE
%token  IF WHILE RETURN STRUCT 

%right      '='
%left       AND OR
%left       RELOP
%left       '+' '-'
%left       '*' '/'
%right      '!' UMINUS
%left       '.' '[' ']' '(' ')'

%nonassoc   LOWER_THAN_ELSE
%nonassoc   ELSE

%%

//遵照实验要求进行定义
Program : 
      ExtDefList                        { cst = $1; $$ = NULL;}
    ;


ExtDefList : 
      ExtDef ExtDefList                 {
                                          $$ = node_ctor(yylloc, 2, "ExtDefList (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | %empty                            { $$=NULL; }
    ;

ExtDef : 
      Specifier ExtDecList ';'          {
                                          $$ = node_ctor(yylloc, 3, "ExtDef (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Specifier ';'                     {
                                          $$ = node_ctor(yylloc, 2, "ExtDef (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | Specifier FunDec CompSt           {
                                          $$ = node_ctor(yylloc, 3, "ExtDef (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | error                             { $$=NULL; }
    ;

ExtDecList : 
      VarDec                            {
                                          $$ = node_ctor(yylloc, 1, "ExtDecList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | VarDec ',' ExtDecList             {
                                          $$ = node_ctor(yylloc, 3, "ExtDecList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    ;


Specifier : 
      TYPE                              {
                                          $$ = node_ctor(yylloc, 1, "Specifier (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | StructSpecifier                   {
                                          $$ = node_ctor(yylloc, 1, "Specifier (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    ;

StructSpecifier : 
      STRUCT OptTag '{' DefList '}'     {
                                          $$ = node_ctor(yylloc, 5, "StructSpecifier (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                          $$->child[4] = $5;
                                        }
    | STRUCT Tag                        {
                                          $$ = node_ctor(yylloc, 2, "StructSpecifier (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    ;

OptTag : 
      ID                                {
                                          $$ = node_ctor(yylloc, 1, "OptTag (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | %empty                            { $$=NULL; }
    ;

Tag :                                   
      ID                                {
                                          $$ = node_ctor(yylloc, 1, "Tag (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    ;


VarDec : 
      ID                                {
                                          $$ = node_ctor(yylloc, 1, "VarDec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | VarDec '[' INT ']'                {
                                          $$ = node_ctor(yylloc, 4, "VarDec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                        }
    ;

FunDec : 
      ID '(' VarList ')'                {
                                          $$ = node_ctor(yylloc, 4, "FunDec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                        }
    | ID '(' ')'                        {
                                          $$ = node_ctor(yylloc, 3, "FunDec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    ;

VarList : 
      ParamDec ',' VarList              {
                                          $$ = node_ctor(yylloc, 3, "VarList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | ParamDec                          {
                                          $$ = node_ctor(yylloc, 1, "VarList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    ;

ParamDec : 
      Specifier VarDec                  {
                                          $$ = node_ctor(yylloc, 2, "ParamDec (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    ;


CompSt : 
      '{' DefList StmtList '}'          {
                                          $$ = node_ctor(yylloc, 4, "CompSt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                        }
    ;

StmtList :                              
      Stmt StmtList                     {
                                          $$ = node_ctor(yylloc, 2, "StmtList (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | %empty                            { $$=NULL; }
    ;

Stmt : 
      Exp ';'                           {
                                          $$ = node_ctor(yylloc, 2, "Stmt (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | error ';'                         {
                                          $$ = node_ctor(yylloc, 1, "Stmt (Error) (%d)", yylloc.line);
                                          $$->child[0] = $2;
                                        }
    | CompSt                            {
                                          $$ = node_ctor(yylloc, 1, "Stmt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | RETURN Exp ';'                    {
                                          $$ = node_ctor(yylloc, 3, "Stmt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | IF '(' Exp ')' Stmt %prec LOWER_THAN_ELSE
                                        {
                                          $$ = node_ctor(yylloc, 5, "Stmt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                          $$->child[4] = $5;
                                        }
    | IF '(' Exp ')' Stmt ELSE Stmt     {
                                          $$ = node_ctor(yylloc, 7, "Stmt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                          $$->child[4] = $5;
                                          $$->child[5] = $6;
                                          $$->child[6] = $7;
                                        }
    | WHILE '(' Exp ')' Stmt            {
                                          $$ = node_ctor(yylloc, 5, "Stmt (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                          $$->child[4] = $5;
                                        }
    ;


DefList : 
      Def DefList                       {
                                          $$ = node_ctor(yylloc, 2, "DefList (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | %empty                            { $$=NULL; }
    ;

Def : 
      Specifier DecList ';'             {
                                          $$ = node_ctor(yylloc, 3, "Def (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    ;

DecList : 
      Dec                               {
                                          $$ = node_ctor(yylloc, 1, "DecList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | Dec ',' DecList                   {
                                          $$ = node_ctor(yylloc, 3, "DecList (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    ;

Dec : 
      VarDec                            {
                                          $$ = node_ctor(yylloc, 1, "Dec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | VarDec '=' Exp                    {
                                          $$ = node_ctor(yylloc, 3, "Dec (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    ;

// 表达式

Exp :
      Exp '=' Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp AND Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp OR Exp                        {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp RELOP Exp                     {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp '+' Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp '-' Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp '*' Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp '/' Exp                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | '(' Exp ')'                       {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | '-' Exp   %prec UMINUS            {
                                          $$ = node_ctor(yylloc, 2, "Exp (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | '!' Exp   %prec UMINUS            {
                                          $$ = node_ctor(yylloc, 2, "Exp (%d)",  yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                        }
    | ID '(' Args ')'                   {
                                          $$ = node_ctor(yylloc, 4, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                        }
    | ID '(' ')'                        {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp '[' Exp ']'                   {
                                          $$ = node_ctor(yylloc, 4, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                          $$->child[3] = $4;
                                        }
    | Exp '.' ID                        {
                                          $$ = node_ctor(yylloc, 3, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | ID                                {
                                          $$ = node_ctor(yylloc, 1, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | INT                               {
                                          $$ = node_ctor(yylloc, 1, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    | FLOAT                             {
                                          $$ = node_ctor(yylloc, 1, "Exp (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    ;

Args : 
      Exp ',' Args                      {
                                          $$ = node_ctor(yylloc, 3, "Args (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                          $$->child[1] = $2;
                                          $$->child[2] = $3;
                                        }
    | Exp                               {
                                          $$ = node_ctor(yylloc, 1, "Args (%d)", yylloc.line);
                                          $$->child[0] = $1;
                                        }
    ;

%%

void yyerror(char const *msg) {
    error_rec(ERROR_SYNTAX, yylloc, msg);
}

