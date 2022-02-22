#include<stdio.h>
#include"tree.h"
extern int yyparse(void);
int main(int argc,char* argv[]){
	if(argc <= 1) return 1;
	/*FILE* f = fopen(argv[1],"r");
	if(!f){
		perror(argv[1]);
		return 1;
	}*/
	freopen(argv[1],"r",stdin);
	//printf("I'm going to yyparse\n");
	yyparse();
	//printf("yyparse end\n");
	if(error_num == 0) print_tree(root,0);
	return 0;
}
