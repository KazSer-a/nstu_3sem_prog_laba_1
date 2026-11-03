package main

var commands = map[string]bool{
    "MPUSH": true, "MINSERT": true, "MGET": true, "MSET": true,
    "MDEL": true, "MLEN": true, "MPRINT": true,
    "FPUSHH": true, "FPUSHT": true, "FPUSHA": true, "FPUSHB": true,
    "FDELH": true, "FDELT": true, "FDELA": true, "FDELB": true,
    "FDEL": true, "FFIND": true, "FPRINT": true, "FPRINTR": true,
    "LPUSHH": true, "LPUSHT": true, "LPUSHA": true, "LPUSHB": true,
    "LDELH": true, "LDELT": true, "LDELA": true, "LDELB": true,
    "LDEL": true, "LFIND": true, "LPRINT": true, "LPRINTR": true,
    "SPUSH": true, "SPOP": true, "SPRINT": true,
    "QPUSH": true, "QPOP": true, "QPRINT": true,
    "TINSERT": true, "TFIND": true, "TFULL": true, "TPRINT": true,
    "PRINT": true,
}
