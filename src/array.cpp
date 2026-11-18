#include "array.h"

#include <iostream>
#include <vector>

// Создаёт массив с начальной вместимостью.
void initArray(Array* arr)
{
    arr->capacity = 4;
    arr->size = 0;
    arr->data = new std::string[arr->capacity];
}

// Увеличивает вместимость массива в два раза.
void resizeArray(Array* arr)
{
    int newCapacity = arr->capacity == 0 ? 4 : arr->capacity * 2;
    std::string* newData = new std::string[newCapacity];
    for (int i = 0; i < arr->size; i++) newData[i] = arr->data[i];
    delete[] arr->data;
    arr->data = newData;
    arr->capacity = newCapacity;
}

// Добавляет элемент в конец массива.
void pushBack(Array* arr, const std::string& value)
{
    if (arr->size == arr->capacity) resizeArray(arr);
    arr->data[arr->size++] = value;
}

// Вставляет элемент по заданному индексу.
bool insertAt(Array* arr, int index, const std::string& value)
{
    if (index < 0 || index > arr->size) return false;
    if (arr->size == arr->capacity) resizeArray(arr);
    for (int i = arr->size; i > index; i--) arr->data[i] = arr->data[i - 1];
    arr->data[index] = value;
    arr->size++;
    return true;
}

// Получает элемент по индексу.
bool getAt(const Array* arr, int index, std::string& value)
{
    if (index < 0 || index >= arr->size) return false;
    value = arr->data[index];
    return true;
}

// Изменяет элемент по индексу.
bool setAt(Array* arr, int index, const std::string& value)
{
    if (index < 0 || index >= arr->size) return false;
    arr->data[index] = value;
    return true;
}

// Удаляет элемент и сдвигает оставшиеся значения.
bool removeAt(Array* arr, int index)
{
    if (index < 0 || index >= arr->size) return false;
    for (int i = index; i < arr->size - 1; i++) arr->data[i] = arr->data[i + 1];
    arr->data[--arr->size].clear();
    return true;
}

// Возвращает количество элементов массива.
int lengthArray(const Array* arr)
{
    return arr->size;
}

// Выводит элементы, размер и вместимость массива.
void printArray(const Array* arr)
{
    for (int i = 0; i < arr->size; i++) std::cout << arr->data[i] << " ";
    std::cout << "(size=" << arr->size << ", capacity=" << arr->capacity << ")\n";
}

// Освобождает память массива и сбрасывает его поля.
void freeArray(Array* arr)
{
    delete[] arr->data;
    arr->data = nullptr;
    arr->size = 0;
    arr->capacity = 0;
}

// Выполняет команду массива и сохраняет его состояние.
void handleArray(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "array")) return;
    Array arr;
    initArray(&arr);
    for (const std::string& value : getItems(db, name)) pushBack(&arr, value);

    int index;
    std::string value;
    switch (command)
    {
        case Command::MPUSH:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else { pushBack(&arr, value); std::cout << "-> " << value << "\n"; }
            break;
        case Command::MINSERT:
            if (!(ss >> index >> value)) std::cout << "не хватает аргументов\n";
            else if (!insertAt(&arr, index, value)) std::cout << "неверный индекс\n";
            break;
        case Command::MGET:
            if (!(ss >> index)) std::cout << "не хватает аргументов\n";
            else if (getAt(&arr, index, value)) std::cout << "-> " << value << "\n";
            else std::cout << "нет такого индекса\n";
            break;
        case Command::MSET:
            if (!(ss >> index >> value)) std::cout << "не хватает аргументов\n";
            else if (!setAt(&arr, index, value)) std::cout << "нет такого индекса\n";
            break;
        case Command::MDEL:
            if (!(ss >> index)) std::cout << "не хватает аргументов\n";
            else if (!removeAt(&arr, index)) std::cout << "нет такого индекса\n";
            break;
        case Command::MLEN:
            std::cout << "-> " << lengthArray(&arr) << "\n";
            break;
        case Command::MPRINT:
            printArray(&arr);
            break;
        default:
            break;
    }

    std::vector<std::string> data;
    for (int i = 0; i < arr.size; i++) data.push_back(arr.data[i]);
    saveItems(db, name, "array", data);
    freeArray(&arr);
}
