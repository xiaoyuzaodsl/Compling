#include <stdio.h>
#include "error.h"
#include "common.h"
#include "tree.h"

int main(int argc, char *argv[]) {
    if (argc > 1) {
        if (freopen(argv[1], "r", stdin) == NULL) {
            error_rec(ERROR_FILEINV, LOC_INITIALIZER, argv[1]);
            return 0;
        }
    }
    yyparse();
    if (error_type == 0) node_print(cst, 0);
    return 0;
}

