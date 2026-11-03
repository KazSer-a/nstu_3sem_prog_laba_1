#include "database.h"

#include <fstream>
#include <iostream>
#include <json-c/json.h>

bool loadDatabase(const std::string& fileName, Database& db)
{
    std::ifstream in(fileName);
    if (!in.is_open())
    {
        db.clear();
        return true;
    }
    if (in.peek() == EOF)
    {
        db.clear();
        return true;
    }
    in.close();

    json_object* root = json_object_from_file(fileName.c_str());
    if (root == nullptr || !json_object_is_type(root, json_type_object))
    {
        if (root != nullptr) json_object_put(root);
        std::cout << "не удалось прочитать JSON\n";
        return false;
    }

    db.clear();
    json_object_object_foreach(root, key, value)
    {
        if (!json_object_is_type(value, json_type_object))
        {
            json_object_put(root);
            std::cout << "неверный формат структуры: " << key << "\n";
            return false;
        }

        json_object* typeObject = nullptr;
        json_object* dataObject = nullptr;
        if (!json_object_object_get_ex(value, "type", &typeObject) ||
            !json_object_is_type(typeObject, json_type_string) ||
            !json_object_object_get_ex(value, "data", &dataObject) ||
            !json_object_is_type(dataObject, json_type_array))
        {
            json_object_put(root);
            std::cout << "неверный формат структуры: " << key << "\n";
            return false;
        }

        Entry entry;
        entry.type = json_object_get_string(typeObject);
        size_t count = json_object_array_length(dataObject);
        for (size_t i = 0; i < count; i++)
        {
            json_object* item = json_object_array_get_idx(dataObject, i);
            if (json_object_is_type(item, json_type_string))
                entry.data.emplace_back(json_object_get_string(item));
            else if (json_object_is_type(item, json_type_int))
                entry.data.emplace_back(std::to_string(json_object_get_int64(item)));
            else
            {
                json_object_put(root);
                std::cout << "неверный элемент в структуре: " << key << "\n";
                return false;
            }
        }
        db.emplace(key, std::move(entry));
    }

    json_object_put(root);
    return true;
}

bool saveDatabase(const std::string& fileName, const Database& db)
{
    json_object* root = json_object_new_object();
    for (const auto& pair : db)
    {
        json_object* entry = json_object_new_object();
        json_object_object_add(entry, "type", json_object_new_string(pair.second.type.c_str()));

        json_object* data = json_object_new_array();
        for (const std::string& value : pair.second.data)
            json_object_array_add(data, json_object_new_string(value.c_str()));

        json_object_object_add(entry, "data", data);
        json_object_object_add(root, pair.first.c_str(), entry);
    }

    int result = json_object_to_file_ext(fileName.c_str(), root, JSON_C_TO_STRING_PRETTY);
    json_object_put(root);
    if (result != 0)
    {
        std::cout << "не удалось сохранить файл\n";
        return false;
    }
    return true;
}

bool checkType(const Database& db, const std::string& name, const std::string& type)
{
    auto it = db.find(name);
    if (it != db.end() && it->second.type != type)
    {
        std::cout << name << " это не " << type << "\n";
        return false;
    }
    return true;
}

std::vector<std::string> getItems(const Database& db, const std::string& name)
{
    auto it = db.find(name);
    return it == db.end() ? std::vector<std::string>{} : it->second.data;
}

void saveItems(Database& db, const std::string& name, const std::string& type,
               const std::vector<std::string>& items)
{
    db[name] = Entry{type, items};
}
