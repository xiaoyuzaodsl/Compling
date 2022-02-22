%{
	#include"tree.h"
	#include"syntax.tab.h"	
	//int yycolumn = 1;
	#define YY_USER_ACTION\
		yylloc.first_line = yylloc.last_line = yylineno; \
		yylloc.first_column = yycolumn; \
		yylloc.last_column = yycolumn + yyleng - 1; \
		yycolumn += yyleng;
	//int my_yylineno = 1;
	node_t *yylval;
%}
%option yylineno
digit [0-9]
digit16 [0-9a-fA-F]
letter [a-zA-Z]
character [a-zA-Z0-9_]
empty_sp1 [ \t]
empty_sp2 [	]
number_ten  ([1-9]{digit}*)|0
number_eight 0[0-7]+
number_sixteen 0(x|X){digit16}+
float_normal {number_ten}\.{digit}+
float_ji ({number_ten}\.{digit}*)|(\.{number_ten})
float_science {float_ji}[eE][+-]?{digit}+
int {number_ten}|{number_eight}|{number_sixteen}
float {float_normal}|{float_science} 
struct struct
return return
if if
else else
while while
type ("int")|("float")
id [a-zA-Z_]{character}*
semi ";"
comma ","
assignop "=" 
relop ">"|"<"|">="|"<="|"=="|"!=" 
plus "+"
minus "-"
star "*"
div "/"
and "&&"
or "||"
dot "."
not "!"
lp "("
rp ")"
lb "["
rb "]"
lc "{"
rc "}"
empty_space ({empty_sp1}|{empty_sp2})+
%%
\n {yycolumn = 1;my_yylineno++;}
{int}  {
	//printf("int:%d(%s) ",atoi(yytext),yytext); 
	yylval = node_create(location,1,"INT:%d",atoi(yytext));
	return INT;
	}
{float} {
	//printf("float:%f ",atof(yytext)); 
	yylval = node_create(location,1,"FLOAT(%.6f)",atof(yytext));
	return FLOAT;
	} 
{struct} {
	//printf("struct:%s ",yytext); 
	yylval = node_create(location,1,"STRUCT");
	return STRUCT;
	}
{return} {
	//printf("return:%s ",yytext); 
	 yylval = node_create(location,1,"RETURN");
	return RETURN;
	}
{if} {
	//printf("if:%s ",yytext); 
	 yylval = node_create(location,1,"IF");
	return IF;
	}
{else} {
	//printf("else:%s ",yytext); 
	 yylval = node_create(location,1,"ELSE");
	return ELSE;
	}
{while} {
	//printf("while:%s ",yytext); 
	 yylval = node_create(location,1,"WHILE");
	return WHILE;
	}
{type} {
	//printf("type:%s ",yytext); 
	 yylval = node_create(location,1,"TYPE:%s",yytext);
	return TYPE;
	}
{id} {
	//printf("id:%s ",yytext); 
	 yylval = node_create(location,1,"ID：%s",yytext);
	return ID;
	}
{semi} {
	//printf("semi: ;\n"); 
	 yylval = node_create(location,1,"SEMI");
	return SEMI;
	}
{comma} {
	//printf("comma: : "); 
	 yylval = node_create(location,1,"COMMA");
	return COMMA;
	}
{assignop} {
	//printf("assignop:%s ",yytext); 
	 yylval = node_create(location,1,"ASSIGNOP");
	return ASSIGNOP;
	}
{relop} {
	//printf("relop:%s ",yytext); 
	 yylval = node_create(location,1,"RELOP:%s",yytext);
	return RELOP;
	}
{plus} {
	//printf("plus:%s ",yytext); 
	 yylval = node_create(location,1,"PLUS");
	return PLUS;
	}
{minus} {
	//printf("minus:%s ",yytext); 
	 yylval = node_create(location,1,"MINUS");
	return MINUS;
	}
{star} {
	//printf("star:%s ",yytext); 
	 yylval = node_create(location,1,"STAR");
	return STAR;
	}
{div} {
	//printf("div:%s ",yytext); 
	 yylval = node_create(location,1,"DIV");
	return DIV;
	}
{and} {
	//printf("and:%s ",yytext); 
	 yylval = node_create(location,1,"AND");
	return AND;
	}
{or} {
	//printf("or:%s ",yytext); 
	 yylval = node_create(location,1,"OR");
	return OR;
	}
{dot} {
	//printf("dot:%s ",yytext); 
	 yylval = node_create(location,1,"DOT");
	return DOT;
	}
{not} {
	//printf("not:%s ",yytext); 
	 yylval = node_create(location,1,"NOT");
	return NOT;
	}
{lp} {
	//printf("lp:%s ",yytext); 
	 yylval = node_create(location,1,"LP");
	return LP;
	}
{rp} {
	//printf("rp:%s ",yytext); 
	 yylval = node_create(location,1,"RP");
	return RP;
	}
{lb} {
	//printf("lb:%s ",yytext); 
	 yylval = node_create(location,1,"LB");
	return LB;
	}
{rb} {
	//printf("rb:%s ",yytext); 
	 yylval = node_create(location,1,"RB");
	return RB;
	}
{lc} {
	//printf("lc:%s ",yytext); 
	 yylval = node_create(location,1,"LC");
	return LC;
	}
{rc} {
	//printf("rc:%s ",yytext); 
	 yylval = node_create(location,1,"RC");
	return RC;
	}
{empty_space} 
. {
	printf("Error type[A] at Line %d: Mysterious characters \'%s\'\n",yylineno,yytext);
	}
%%
int yywrap(){return 1;}
