#pragma once

#include <string>

enum class Command
{
    MPUSH,
    MINSERT,
    MGET,
    MSET,
    MDEL,
    MLEN,
    MPRINT,

    FPUSHH,
    FPUSHT,
    FPUSHA,
    FPUSHB,
    FDELH,
    FDELT,
    FDELA,
    FDELB,
    FDEL,
    FFIND,
    FPRINT,
    FPRINTR,

    LPUSHH,
    LPUSHT,
    LPUSHA,
    LPUSHB,
    LDELH,
    LDELT,
    LDELA,
    LDELB,
    LDEL,
    LFIND,
    LPRINT,
    LPRINTR,

    SPUSH,
    SPOP,
    SPRINT,

    QPUSH,
    QPOP,
    QPRINT,

    TINSERT,
    TFIND,
    TFULL,
    TPRINT,

    PRINT,
    UNKNOWN
};

Command toCommand(const std::string& text);
