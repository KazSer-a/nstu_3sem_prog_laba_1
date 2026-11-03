package main

import (
    "encoding/json"
    "fmt"
    "os"
    "strconv"
)

type Item string

func (item *Item) UnmarshalJSON(data []byte) error {
    var value string
    if err := json.Unmarshal(data, &value); err == nil {
        *item = Item(value)
        return nil
    }
    number, err := strconv.ParseInt(string(data), 10, 64)
    if err != nil {
        return fmt.Errorf("неверный элемент JSON")
    }
    *item = Item(strconv.FormatInt(number, 10))
    return nil
}

type Entry struct {
    Type string `json:"type"`
    Data []Item `json:"data"`
}

type Database map[string]Entry

func loadDatabase(fileName string) (Database, error) {
    db := Database{}
    data, err := os.ReadFile(fileName)
    if err != nil {
        if os.IsNotExist(err) {
            return db, nil
        }
        return nil, err
    }
    if len(data) == 0 {
        return db, nil
    }
    if err := json.Unmarshal(data, &db); err != nil {
        return nil, err
    }
    if db == nil {
        db = Database{}
    }
    return db, nil
}

func saveDatabase(fileName string, db Database) error {
    data, err := json.MarshalIndent(db, "", "    ")
    if err != nil {
        return err
    }
    data = append(data, '\n')
    return os.WriteFile(fileName, data, 0644)
}

func checkType(db Database, name, structType string) bool {
    entry, ok := db[name]
    if ok && entry.Type != structType {
        fmt.Println(name, "это не", structType)
        return false
    }
    return true
}

func loadItems(db Database, name string) []string {
    entry, ok := db[name]
    if !ok {
        return []string{}
    }
    items := make([]string, 0, len(entry.Data))
    for _, item := range entry.Data {
        items = append(items, string(item))
    }
    return items
}

func saveItems(db Database, name, structType string, items []string) {
    data := make([]Item, 0, len(items))
    for _, item := range items {
        data = append(data, Item(item))
    }
    db[name] = Entry{Type: structType, Data: data}
}

func need(args []string, count int) bool {
    if len(args) < count {
        fmt.Println("не хватает аргументов")
        return false
    }
    return true
}

func parseIndex(value string) (int, error) {
    return strconv.Atoi(value)
}
