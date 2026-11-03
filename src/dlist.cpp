#include "dlist.h"

#include <iostream>
#include <vector>

void pushFront(DList* list, const std::string& value)
{
    DNode* node = new DNode{value, list->head, nullptr};
    if (list->head != nullptr) list->head->prev = node;
    else list->tail = node;
    list->head = node;
}

void pushBack(DList* list, const std::string& value)
{
    DNode* node = new DNode{value, nullptr, list->tail};
    if (list->tail != nullptr) list->tail->next = node;
    else list->head = node;
    list->tail = node;
}

DNode* findValue(DList* list, const std::string& value)
{
    for (DNode* current = list->head; current != nullptr; current = current->next)
        if (current->value == value) return current;
    return nullptr;
}

void insertAfter(DList* list, DNode* target, const std::string& value)
{
    if (target == nullptr) return;
    if (target == list->tail) { pushBack(list, value); return; }
    DNode* node = new DNode{value, target->next, target};
    target->next->prev = node;
    target->next = node;
}

void insertBefore(DList* list, DNode* target, const std::string& value)
{
    if (target == nullptr) return;
    if (target == list->head) { pushFront(list, value); return; }
    DNode* node = new DNode{value, target, target->prev};
    target->prev->next = node;
    target->prev = node;
}

void deleteNode(DList* list, DNode* node)
{
    if (node == nullptr) return;
    if (node->prev != nullptr) node->prev->next = node->next;
    else list->head = node->next;
    if (node->next != nullptr) node->next->prev = node->prev;
    else list->tail = node->prev;
    delete node;
}

void popFront(DList* list) { deleteNode(list, list->head); }
void popBack(DList* list) { deleteNode(list, list->tail); }

void freeList(DList* list)
{
    while (list->head != nullptr) popFront(list);
}

void handleDlist(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "dlist")) return;
    DList list;
    for (const std::string& value : getItems(db, name)) pushBack(&list, value);

    std::string target, value;
    DNode* node = nullptr;
    switch (command)
    {
        case Command::LPUSHH:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else pushFront(&list, value);
            break;
        case Command::LPUSHT:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else pushBack(&list, value);
            break;
        case Command::LPUSHA:
            if (!(ss >> target >> value)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(&list, target);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else insertAfter(&list, node, value);
            }
            break;
        case Command::LPUSHB:
            if (!(ss >> target >> value)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(&list, target);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else insertBefore(&list, node, value);
            }
            break;
        case Command::LDELH:
            if (list.head == nullptr) std::cout << "список пуст\n";
            else popFront(&list);
            break;
        case Command::LDELT:
            if (list.tail == nullptr) std::cout << "список пуст\n";
            else popBack(&list);
            break;
        case Command::LDELA:
            if (!(ss >> target)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(&list, target);
                if (node == nullptr || node->next == nullptr) std::cout << "нет следующего элемента\n";
                else deleteNode(&list, node->next);
            }
            break;
        case Command::LDELB:
            if (!(ss >> target)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(&list, target);
                if (node == nullptr || node->prev == nullptr) std::cout << "нет предыдущего элемента\n";
                else deleteNode(&list, node->prev);
            }
            break;
        case Command::LDEL:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(&list, value);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else deleteNode(&list, node);
            }
            break;
        case Command::LFIND:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else std::cout << (findValue(&list, value) != nullptr ? "-> TRUE\n" : "-> FALSE\n");
            break;
        case Command::LPRINT:
            for (DNode* current = list.head; current != nullptr; current = current->next)
                std::cout << current->value << " <-> ";
            std::cout << "nullptr\n";
            break;
        case Command::LPRINTR:
            for (DNode* current = list.tail; current != nullptr; current = current->prev)
                std::cout << current->value << " <-> ";
            std::cout << "nullptr\n";
            break;
        default:
            break;
    }

    std::vector<std::string> data;
    for (DNode* current = list.head; current != nullptr; current = current->next)
        data.push_back(current->value);
    saveItems(db, name, "dlist", data);
    freeList(&list);
}
