#include "queue.h"

#include <iostream>
#include <vector>

// Добавляет элемент в конец очереди.
void enqueue(Queue* queue, const std::string& value)
{
    QNode* node = new QNode{value, nullptr};
    if (queue->tail != nullptr) queue->tail->next = node;
    else queue->head = node;
    queue->tail = node;
}

// Извлекает элемент из начала очереди.
bool dequeue(Queue* queue, std::string& value)
{
    if (queue->head == nullptr) return false;
    QNode* node = queue->head;
    value = node->value;
    queue->head = node->next;
    if (queue->head == nullptr) queue->tail = nullptr;
    delete node;
    return true;
}

// Освобождает все элементы очереди.
void freeQueue(Queue* queue)
{
    std::string value;
    while (dequeue(queue, value)) {}
}

// Выполняет команду очереди и сохраняет её состояние.
void handleQueue(Command command, Database& db, const std::string& name, std::stringstream& ss)
{
    if (!checkType(db, name, "queue")) return;
    Queue queue;
    for (const std::string& value : getItems(db, name)) enqueue(&queue, value);

    std::string value;
    switch (command)
    {
        case Command::QPUSH:
            if (!(ss >> value)) std::cout << "не хватает аргументов\n";
            else { enqueue(&queue, value); std::cout << "-> " << value << "\n"; }
            break;
        case Command::QPOP:
            if (dequeue(&queue, value)) std::cout << "-> " << value << "\n";
            else std::cout << "-> очередь пуста\n";
            break;
        case Command::QPRINT:
            for (QNode* current = queue.head; current != nullptr; current = current->next)
                std::cout << current->value << " -> ";
            std::cout << "nullptr\n";
            break;
        default:
            break;
    }

    std::vector<std::string> data;
    for (QNode* current = queue.head; current != nullptr; current = current->next)
        data.push_back(current->value);
    saveItems(db, name, "queue", data);
    freeQueue(&queue);
}
