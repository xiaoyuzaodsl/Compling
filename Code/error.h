#ifndef __ERROR_H__
#define __ERROR_H__

#include "common.h"

extern int error_type;

enum CMM_ERROR_NO {
    ERROR_FILEINV         =   1,

    ERROR_MYSCOMM        = 1001,
    ERROR_MYSCHAR           = 1002,
    ERROR_INVFPNUM          = 1003,
    ERROR_INVHEXNUM         = 1004,
    ERROR_INVOCTNUM         = 1005,
    ERROR_INVDECNUM         = 1006,
    ERROR_FPNUM_OF          = 1007,
    ERROR_INTNUM_OF         = 1008,

    ERROR_SYNTAX            = 2001,
};

void error_rec(int cmm_errno, loc_t loc, ...);

#endif

