#include "commands.h"

#include <unordered_map>

Command toCommand(const std::string& text)
{
    static const std::unordered_map<std::string, Command> commands = {
        {"MPUSH", Command::MPUSH},
        {"MINSERT", Command::MINSERT},
        {"MGET", Command::MGET},
        {"MSET", Command::MSET},
        {"MDEL", Command::MDEL},
        {"MLEN", Command::MLEN},
        {"MPRINT", Command::MPRINT},

        {"FPUSHH", Command::FPUSHH},
        {"FPUSHT", Command::FPUSHT},
        {"FPUSHA", Command::FPUSHA},
        {"FPUSHB", Command::FPUSHB},
        {"FDELH", Command::FDELH},
        {"FDELT", Command::FDELT},
        {"FDELA", Command::FDELA},
        {"FDELB", Command::FDELB},
        {"FDEL", Command::FDEL},
        {"FFIND", Command::FFIND},
        {"FPRINT", Command::FPRINT},
        {"FPRINTR", Command::FPRINTR},

        {"LPUSHH", Command::LPUSHH},
        {"LPUSHT", Command::LPUSHT},
        {"LPUSHA", Command::LPUSHA},
        {"LPUSHB", Command::LPUSHB},
        {"LDELH", Command::LDELH},
        {"LDELT", Command::LDELT},
        {"LDELA", Command::LDELA},
        {"LDELB", Command::LDELB},
        {"LDEL", Command::LDEL},
        {"LFIND", Command::LFIND},
        {"LPRINT", Command::LPRINT},
        {"LPRINTR", Command::LPRINTR},

        {"SPUSH", Command::SPUSH},
        {"SPOP", Command::SPOP},
        {"SPRINT", Command::SPRINT},

        {"QPUSH", Command::QPUSH},
        {"QPOP", Command::QPOP},
        {"QPRINT", Command::QPRINT},

        {"TINSERT", Command::TINSERT},
        {"TFIND", Command::TFIND},
        {"TFULL", Command::TFULL},
        {"TPRINT", Command::TPRINT},

        {"PRINT", Command::PRINT}
    };

    auto it = commands.find(text);
    if (it == commands.end())
    {
        return Command::UNKNOWN;
    }

    return it->second;
}
