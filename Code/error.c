#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "common.h"
#include "error.h"

int error_type = 0;

static const char *error_out[2048] = {
    [ERROR_FILEINV]   = "file '%s' invalid",

    [ERROR_MYSCOMM]  = "mysterious comment",
    [ERROR_MYSCHAR]     = "mysterious character '%s'",
    [ERROR_INVFPNUM]    = "invalid floating-point number '%s'",
    [ERROR_INVHEXNUM]   = "invalid hexadecimal number '%s'",
    [ERROR_INVOCTNUM]   = "invalid octal number '%s'",
    [ERROR_INVDECNUM]   = "invalid decimal number '%s'",
    [ERROR_FPNUM_OF]    = "floating-point number '%s' overflow",
    [ERROR_INTNUM_OF]   = "integer number '%s' overflow",

    [ERROR_SYNTAX]      = "%s",
};

static const char *error_mes[16] = {
    [0]                     = "system error: ",
    [1]                     = "error type A at line %d, col %d: ",
    [2]                     = "error type B at line %d, col %d: ",
};

void error_rec(int cmm_errno, loc_t loc, ...) {
    va_list ap;
    error_type++;
    fprintf(stderr, error_mes[cmm_errno / 1000], loc.line, loc.col);
    va_start(ap, loc);
    vfprintf(stderr, error_out[cmm_errno], ap);
    va_end(ap);
    fprintf(stderr, "\n");
}
