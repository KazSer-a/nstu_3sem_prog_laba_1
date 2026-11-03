#pragma once

#include "commands.h"

#include <string>

struct SNode
{
    std::string value;
    SNode* next;
};

struct Stack
{
    SNode* head = nullptr;
};

void push(Stack* stack, const std::string& value);
bool pop(Stack* stack, std::string& value);
void freeStack(Stack* stack);
void handleStack(Command command, Database& db, const std::string& name, std::stringstream& ss);
