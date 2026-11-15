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

void enqueue(Queue* queue, const std::string& value);
bool dequeue(Queue* queue, std::string& value);
void freeQueue(Queue* queue);
void handleQueue(Command command, Database& db, const std::string& name, std::stringstream& ss);
