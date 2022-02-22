/*位置信息*/
#ifndef __TREE_H__
#define __TREE_H__

#include<stdio.h>
#include<stdlib.h>
#include<stdarg.h>
typedef struct myyy_location{
		int line;
		int column;
}loc_t;
static loc_t location = {1,1};	
typedef struct my_node{
		char* name;
		int n_children;
		loc_t my_loc;
		struct my_node **children;
}node_t;

node_t *root;
static int my_yylineno = 1;
static int yycolumn = 1;
static int error_num = 0;
static inline void update_location(){
	location.line = my_yylineno;
	location.column = yycolumn;
}
static inline node_t *node_create(loc_t my_loc,int n_children,const char *fmt, ...){
		va_list args1,args2;
		va_start(args1, fmt); va_copy(args2, args1);
		node_t *me = malloc(sizeof(node_t));
		update_location();
		me->my_loc = my_loc;
		me->name = malloc(1+vsnprintf(NULL,0,fmt,args1)); 
		//printf("name = %s\n",me->name);
		vsprintf(me->name,fmt,args2);
		//printf("name = %s\n",me->name);
		me->n_children = n_children;
		me->children = calloc(n_children,sizeof(node_t*));
		va_end(args1);
		va_end(args2);
		//printf("create a new node:{%s\t,%d\t,%d %d\t,}\n",me->name,me->n_children,me->my_loc.line,me->my_loc.column);
		return me;
}	
static inline void print_tree(node_t* me,int depth){
		if(me==NULL) return;
		for(int i = 0;i < depth;i++) printf(" ");
		printf("%s",me->name);
		printf("(%d)\n",me->my_loc.line);
		for(int i = 0;i < me->n_children;i++){
			print_tree(me->children[i],depth+1);
		}	
}
#endif
