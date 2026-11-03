#pragma once

#include <string>
#include <unordered_map>
#include <vector>

struct Entry
{
    std::string type;
    std::vector<std::string> data;
};

using Database = std::unordered_map<std::string, Entry>;

bool loadDatabase(const std::string& fileName, Database& db);
bool saveDatabase(const std::string& fileName, const Database& db);
bool checkType(const Database& db, const std::string& name, const std::string& type);
std::vector<std::string> getItems(const Database& db, const std::string& name);
void saveItems(Database& db, const std::string& name, const std::string& type,
               const std::vector<std::string>& items);
