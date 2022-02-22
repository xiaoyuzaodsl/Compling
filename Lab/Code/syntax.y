%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	#include"tree.h"
	#include"lex.yy.c"
%}
%locations
%{
	void error_action(const char* msg){
		 fprintf(stderr,"error type[%c] at line %d:%s\n",'B',yylineno,msg);
	}
	void yyerror(const char* msg){
		error_num++;
		error_action(msg);
		}
%}

/*declare types*/
%define api.value.type {node_t *}
%define parse.error verbose

/*declare tokens*/
%start Program
%token INT
%token FLOAT
%token ID
%token STRUCT RETURN
%token IF ELSE WHILE
%token TYPE
%token SEMI COMMA
%token ASSIGNOP RELOP
%token PLUS MINUS STAR DIV AND OR DOT NOT
%token LP RP LB RB LC RC

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left LP RP LB RB DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
/*declare non-terminals*/

%%

/*high-leval definitions*/

Program:ExtDefList {
				//printf("fist step:\n");
				$$ = node_create(location,1,"Program");
				root = $$; 
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
				}
	   ;
ExtDefList:%empty {$$ = NULL;}
		  | ExtDef ExtDefList {
				$$ = node_create(location,2,"ExtDefList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
			}
		  ;
ExtDef:Specifier ExtDecList SEMI {
				$$ = node_create(location,3,"ExtDef");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;  
	}
	  | Specifier SEMI {
				$$ = node_create(location,2,"ExtDef");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
		}
	  | Specifier FunDec CompSt {
				$$ = node_create(location,3,"ExtDef");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
		}
	  | error {$$ = NULL;}
	  ;
ExtDecList:VarDec {
				$$ = node_create(location,1,"ExtDecList");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;	
			}
		  | VarDec COMMA ExtDecList {
				$$ = node_create(location,3,"ExtDecList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
			}
		  ;

/*specifiers*/
Specifier:TYPE {
				$$ = node_create(location,1,"Specifier");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
			}
		 | StructSpecifier {
				$$ = node_create(location,1,"StructSpecifier");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
			}
		 ;
StructSpecifier:STRUCT OptTag LC DefList RC {
				$$ = node_create(location,5,"StructSpecifier");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->my_loc = $1->my_loc;
				}
			   | STRUCT Tag {
				$$ = node_create(location,2,"StructSpecifier");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
				}
			   ;
OptTag:%empty {$$ = NULL;}
	  | ID {
				$$ = node_create(location,1,"OptTag");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
		}
	  ;
Tag:ID {
				$$ = node_create(location,1,"Tag");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
	}
   ;

/*declarations*/
VarDec:ID {
				$$ = node_create(location,1,"VarDec");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
		}
	  | VarDec LB INT RB {
				$$ = node_create(location,4,"VarDec");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->my_loc = $1->my_loc;
		}
	  ;
FunDec:ID LP VarList RP {
				$$ = node_create(location,4,"FunDec");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->my_loc = $1->my_loc;
			}
	  | ID LP RP {
				$$ = node_create(location,3,"FunDec");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
		}
	  ;
VarList:ParamDec COMMA VarList {
				$$ = node_create(location,3,"VarList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
		}
	   | ParamDec {
				$$ = node_create(location,1,"VarList");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
		}
	   ;
ParamDec:Specifier VarDec {
				$$ = node_create(location,2,"ParamDec");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
		}
		;

/*statements*/
CompSt:LC DefList StmtList RC {
				$$ = node_create(location,4,"Compst");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->my_loc = $1->my_loc;
		
		}
	  ;
StmtList:%empty{$$ = NULL;}
		| Stmt StmtList {
				$$ = node_create(location,2,"SmtList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
		}
		;
Stmt:Exp SEMI {
				$$ = node_create(location,2,"Stmt");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
		}
	| CompSt {
				$$ = node_create(location,1,"Stmt");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
	}
	| RETURN Exp SEMI {
				$$ = node_create(location,3,"Stmt");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
			}
	| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {
				$$ = node_create(location,5,"Stmt");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->my_loc = $1->my_loc;
			}
	| IF LP Exp RP Stmt ELSE Stmt{
				$$ = node_create(location,7,"Stmt");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->children[5] = $6;
				$$->children[6] = $7;
				$$->my_loc = $1->my_loc;
			}
	| WHILE LP Exp RP Stmt {
				$$ = node_create(location,5,"Stmt");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->children[4] = $5;
				$$->my_loc = $1->my_loc;
				}
	| error SEMI {$$ = NULL;}
	;

/*local definition*/
DefList:%empty {$$ = NULL;}
	   | Def DefList {
				$$ = node_create(location,2,"DefList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
				}
	   ;
Def:Specifier DecList SEMI {
 				$$ = node_create(location,3,"Def");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	| error SEMI;
   ;
DecList:Dec {
				$$ = node_create(location,1,"DecList");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
		}
	   | Dec COMMA DecList {
				$$ = node_create(location,3,"DecList");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	   ;
Dec:VarDec {
				$$ = node_create(location,1,"Dec");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
	}
   |VarDec ASSIGNOP Exp {
				$$ = node_create(location,3,"Dec");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	;

/*expression*/
Exp:Exp ASSIGNOP Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
    | Exp AND Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	| Exp OR Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	| Exp RELOP Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
	| Exp PLUS Exp  {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| Exp MINUS Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| Exp STAR Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| Exp DIV Exp {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| LP Exp RP {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| MINUS Exp {
				$$ = node_create(location,2,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
				}

	| NOT Exp {
				$$ = node_create(location,2,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->my_loc = $1->my_loc;
				}

	| ID LP Args RP {
				$$ = node_create(location,4,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->children[3] = $4;
				$$->my_loc = $1->my_loc;
				}

	| ID LP RP {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}
 
	| Exp DOT ID {
				$$ = node_create(location,3,"Exp");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| ID  {
				$$ = node_create(location,1,"Exp");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
				}

	| INT {
				$$ = node_create(location,1,"Exp");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
				}

	| FLOAT {
				$$ = node_create(location,1,"Exp");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
				}
	;
Args:Exp COMMA Args {
				$$ = node_create(location,3,"Args");
				$$->children[0] = $1;
				$$->children[1] = $2;
				$$->children[2] = $3;
				$$->my_loc = $1->my_loc;
				}

	| Exp {
				$$ = node_create(location,1,"Args");
				$$->children[0] = $1;
				$$->my_loc = $1->my_loc;
				}

	;

%%
/*void yyerror(char* msg){
	fprintf(stderr,"error:%s\n",msg);
}*/
