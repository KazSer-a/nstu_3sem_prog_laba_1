#pragma once

#include "commands.h"

#include <string>

struct FNode
{
    std::string value;
    FNode* next;
};

FNode* pushFront(FNode* head, const std::string& value);
FNode* pushBack(FNode* head, const std::string& value);
FNode* findValue(FNode* head, const std::string& value);
FNode* insertAfter(FNode* head, FNode* target, const std::string& value);
FNode* insertBefore(FNode* head, FNode* target, const std::string& value);
FNode* popFront(FNode* head);
FNode* popBack(FNode* head);
FNode* deleteAfter(FNode* head, FNode* target);
FNode* deleteBefore(FNode* head, FNode* target);
FNode* deleteValue(FNode* head, const std::string& value);
void freeList(FNode* head);
void handleFlist(Command command, Database& db, const std::string& name, std::stringstream& ss);
