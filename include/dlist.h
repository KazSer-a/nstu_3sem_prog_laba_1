#pragma once

#include "commands.h"

#include <string>

struct DNode
{
    std::string value;
    DNode* next;
    DNode* prev;
};

struct DList
{
    DNode* head = nullptr;
    DNode* tail = nullptr;
};

void pushFront(DList* list, const std::string& value);
void pushBack(DList* list, const std::string& value);
DNode* findValue(DList* list, const std::string& value);
void insertAfter(DList* list, DNode* target, const std::string& value);
void insertBefore(DList* list, DNode* target, const std::string& value);
void popFront(DList* list);
void popBack(DList* list);
void deleteNode(DList* list, DNode* node);
void freeList(DList* list);
void handleDlist(Command command, Database& db, const std::string& name, std::stringstream& ss);
