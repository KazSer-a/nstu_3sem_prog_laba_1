package main

import (
    "fmt"
    "os"
    "strings"
)

func main() {
    if len(os.Args) != 5 || os.Args[1] != "--file" || os.Args[3] != "--query" {
        fmt.Println("Использование: ./dbms_go --file <файл> --query '<команда>'")
        os.Exit(1)
    }

    fileName := os.Args[2]
    words := strings.Fields(os.Args[4])
    if len(words) == 0 {
        fmt.Println("пустая команда")
        os.Exit(1)
    }

    command := words[0]
    if !commands[command] {
        fmt.Println("неизвестная команда")
        os.Exit(1)
    }
    if len(words) < 2 {
        fmt.Println("укажи имя структуры")
        os.Exit(1)
    }

    db, err := loadDatabase(fileName)
    if err != nil {
        fmt.Println("не удалось прочитать файл:", err)
        os.Exit(1)
    }

    name := words[1]
    args := words[2:]
    switch command[0] {
    case 'M':
        handleArray(command, db, name, args)
    case 'F':
        handleFlist(command, db, name, args)
    case 'L':
        handleDlist(command, db, name, args)
    case 'S':
        handleStack(command, db, name, args)
    case 'Q':
        handleQueue(command, db, name, args)
    case 'T':
        fmt.Println("дерево реализовано только в C++ версии")
    case 'P':
        handlePrint(db, name)
    }

    if err := saveDatabase(fileName, db); err != nil {
        fmt.Println("не удалось сохранить файл:", err)
        os.Exit(1)
    }
}

func handlePrint(db Database, name string) {
    entry, ok := db[name]
    if !ok {
        fmt.Println("нет структуры", name)
        return
    }

    switch entry.Type {
    case "array":
        handleArray("MPRINT", db, name, nil)
    case "flist":
        handleFlist("FPRINT", db, name, nil)
    case "dlist":
        handleDlist("LPRINT", db, name, nil)
    case "stack":
        handleStack("SPRINT", db, name, nil)
    case "queue":
        handleQueue("QPRINT", db, name, nil)
    case "tree":
        fmt.Println("дерево реализовано только в C++ версии")
    }
}
