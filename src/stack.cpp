#include "stack.h"

#include <algorithm>
#include <iostream>
#include <vector>

void push(Stack* stack, const std::string& value)
{
    stack->head = new SNode{value, stack->head};
}

bool pop(Stack* stack, std::string& value)
{
    if (stack->head == nullptr) return false;
    SNode* node = stack->head;
    value = node->value;
    stack->head = node->next;
    delete node;
    return true;
}

void freeStack(Stack* stack)
{
    std::string value;
    while (pop(stack, value)) {}
}

void handleStack(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "stack")) return;
    Stack stack;
    for (const std::string& value : getItems(db, name)) push(&stack, value);

    std::string value;
    switch (command)
    {
        case Command::SPUSH:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else { push(&stack, value); std::cout << "-> " << value << "\n"; }
            break;
        case Command::SPOP:
            if (pop(&stack, value)) std::cout << "-> " << value << "\n";
            else std::cout << "-> стек пуст\n";
            break;
        case Command::SPRINT:
            for (SNode* current = stack.head; current != nullptr; current = current->next)
                std::cout << current->value << " -> ";
            std::cout << "nullptr\n";
            break;
        default:
            break;
    }

    std::vector<std::string> data;
    for (SNode* current = stack.head; current != nullptr; current = current->next)
        data.push_back(current->value);
    std::reverse(data.begin(), data.end());
    saveItems(db, name, "stack", data);
    freeStack(&stack);
}
