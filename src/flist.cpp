#include "flist.h"

#include <iostream>
#include <vector>

FNode* pushFront(FNode* head, const std::string& value)
{
    return new FNode{value, head};
}

FNode* pushBack(FNode* head, const std::string& value)
{
    FNode* node = new FNode{value, nullptr};
    if (head == nullptr) return node;
    FNode* current = head;
    while (current->next != nullptr) current = current->next;
    current->next = node;
    return head;
}

FNode* findValue(FNode* head, const std::string& value)
{
    for (FNode* current = head; current != nullptr; current = current->next)
        if (current->value == value) return current;
    return nullptr;
}

FNode* insertAfter(FNode* head, FNode* target, const std::string& value)
{
    if (target != nullptr) target->next = new FNode{value, target->next};
    return head;
}

FNode* insertBefore(FNode* head, FNode* target, const std::string& value)
{
    if (target == nullptr) return head;
    if (target == head) return pushFront(head, value);
    FNode* current = head;
    while (current != nullptr && current->next != target) current = current->next;
    if (current != nullptr) insertAfter(head, current, value);
    return head;
}

FNode* popFront(FNode* head)
{
    if (head == nullptr) return nullptr;
    FNode* next = head->next;
    delete head;
    return next;
}

FNode* popBack(FNode* head)
{
    if (head == nullptr) return nullptr;
    if (head->next == nullptr)
    {
        delete head;
        return nullptr;
    }
    FNode* current = head;
    while (current->next->next != nullptr) current = current->next;
    delete current->next;
    current->next = nullptr;
    return head;
}

FNode* deleteAfter(FNode* head, FNode* target)
{
    if (target == nullptr || target->next == nullptr) return head;
    FNode* removed = target->next;
    target->next = removed->next;
    delete removed;
    return head;
}

FNode* deleteBefore(FNode* head, FNode* target)
{
    if (head == nullptr || target == nullptr || target == head) return head;
    if (head->next == target) return popFront(head);
    FNode* current = head;
    while (current->next != nullptr && current->next->next != target)
        current = current->next;
    if (current->next != nullptr) deleteAfter(head, current);
    return head;
}

FNode* deleteValue(FNode* head, const std::string& value)
{
    if (head == nullptr) return nullptr;
    if (head->value == value) return popFront(head);
    FNode* current = head;
    while (current->next != nullptr && current->next->value != value)
        current = current->next;
    if (current->next != nullptr) deleteAfter(head, current);
    return head;
}

void freeList(FNode* head)
{
    while (head != nullptr) head = popFront(head);
}

void handleFlist(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "flist")) return;
    FNode* head = nullptr;
    for (const std::string& value : getItems(db, name)) head = pushBack(head, value);

    std::string target, value;
    FNode* node = nullptr;
    switch (command)
    {
        case Command::FPUSHH:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else head = pushFront(head, value);
            break;
        case Command::FPUSHT:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else head = pushBack(head, value);
            break;
        case Command::FPUSHA:
            if (!(ss >> target >> value)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(head, target);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else insertAfter(head, node, value);
            }
            break;
        case Command::FPUSHB:
            if (!(ss >> target >> value)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(head, target);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else head = insertBefore(head, node, value);
            }
            break;
        case Command::FDELH:
            head = popFront(head);
            break;
        case Command::FDELT:
            head = popBack(head);
            break;
        case Command::FDELA:
            if (!(ss >> target)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(head, target);
                if (node == nullptr) std::cout << "нет такого элемента\n";
                else if (node->next == nullptr) std::cout << "нет следующего элемента\n";
                else deleteAfter(head, node);
            }
            break;
        case Command::FDELB:
            if (!(ss >> target)) std::cout << "не хватает аргументов\n";
            else
            {
                node = findValue(head, target);
                if (node == nullptr || node == head) std::cout << "нет предыдущего элемента\n";
                else head = deleteBefore(head, node);
            }
            break;
        case Command::FDEL:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else if (findValue(head, value) == nullptr) std::cout << "нет такого элемента\n";
            else head = deleteValue(head, value);
            break;
        case Command::FFIND:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else std::cout << (findValue(head, value) != nullptr ? "-> TRUE\n" : "-> FALSE\n");
            break;
        case Command::FPRINT:
            for (FNode* current = head; current != nullptr; current = current->next)
                std::cout << current->value << " -> ";
            std::cout << "nullptr\n";
            break;
        case Command::FPRINTR:
        {
            std::vector<std::string> values;
            for (FNode* current = head; current != nullptr; current = current->next)
                values.push_back(current->value);
            for (auto it = values.rbegin(); it != values.rend(); ++it) std::cout << *it << " ";
            std::cout << "\n";
            break;
        }
        default:
            break;
    }

    std::vector<std::string> data;
    for (FNode* current = head; current != nullptr; current = current->next)
        data.push_back(current->value);
    saveItems(db, name, "flist", data);
    freeList(head);
}
