#include "array.h"
#include "dlist.h"
#include "flist.h"
#include "queue.h"
#include "stack.h"
#include "tree.h"

#include <iostream>
#include <sstream>
#include <string>

void handlePrint(Database& db, const std::string& name)
{
    auto it = db.find(name);
    if (it == db.end())
    {
        std::cout << "нет структуры " << name << "\n";
        return;
    }

    std::stringstream ss;
    if (it->second.type == "array") handleArray(Command::MPRINT, db, name, ss);
    else if (it->second.type == "flist") handleFlist(Command::FPRINT, db, name, ss);
    else if (it->second.type == "dlist") handleDlist(Command::LPRINT, db, name, ss);
    else if (it->second.type == "stack") handleStack(Command::SPRINT, db, name, ss);
    else if (it->second.type == "queue") handleQueue(Command::QPRINT, db, name, ss);
    else if (it->second.type == "tree") handleTree(Command::TPRINT, db, name, ss);
}

int main(int argc, char* argv[])
{
    if (argc != 5 || std::string(argv[1]) != "--file" || std::string(argv[3]) != "--query")
    {
        std::cout << "Использование: ./dbms --file <файл> --query '<команда>'\n";
        return 1;
    }

    std::string fileName = argv[2];
    std::stringstream ss(argv[4]);
    std::string commandText, name;
    if (!(ss >> commandText))
    {
        std::cout << "пустая команда\n";
        return 1;
    }

    Command command = toCommand(commandText);
    if (command == Command::UNKNOWN)
    {
        std::cout << "неизвестная команда\n";
        return 1;
    }

    if (!(ss >> name))
    {
        std::cout << "укажи имя структуры\n";
        return 1;
    }

    Database db;
    if (!loadDatabase(fileName, db)) return 1;

    switch (commandText[0])
    {
        case 'M': handleArray(command, db, name, ss); break;
        case 'F': handleFlist(command, db, name, ss); break;
        case 'L': handleDlist(command, db, name, ss); break;
        case 'S': handleStack(command, db, name, ss); break;
        case 'Q': handleQueue(command, db, name, ss); break;
        case 'T': handleTree(command, db, name, ss); break;
        case 'P': handlePrint(db, name); break;
        default:
            std::cout << "неизвестная команда\n";
            return 1;
    }

    return saveDatabase(fileName, db) ? 0 : 1;
}
