#pragma once

#include "commands.h"

#include <string>

struct QNode
{
    std::string value;
    QNode* next;
};

struct Queue
{
    QNode* head = nullptr;
    QNode* tail = nullptr;
};

void push(Queue* queue, const std::string& value);
bool pop(Queue* queue, std::string& value);
void freeQueue(Queue* queue);
void handleQueue(Command command, Database& db, const std::string& name, std::stringstream& ss);
