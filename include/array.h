#pragma once

#include "commands.h"

#include <string>

struct Array
{
    std::string* data = nullptr;
    int size = 0;
    int capacity = 0;
};

void initArray(Array* arr);
void resizeArray(Array* arr);
void pushBack(Array* arr, const std::string& value);
bool insertAt(Array* arr, const std::string& value, int index);
bool getAt(const Array* arr, int index, std::string& value);
bool setAt(Array* arr, const std::string& value, int index);
bool removeAt(Array* arr, int index);
int lengthArray(const Array* arr);
void printArray(const Array* arr);
void freeArray(Array* arr);
void handleArray(Command command, Database& db, const std::string& name, std::stringstream& ss);
