package main

import "fmt"

type Array struct {
    data []string
    size int
    capacity int
}

func initArray(arr *Array) {
    arr.capacity = 4
    arr.data = make([]string, arr.capacity)
    arr.size = 0
}

func resizeArray(arr *Array) {
    capacity := arr.capacity * 2
    data := make([]string, capacity)
    copy(data, arr.data[:arr.size])
    arr.data = data
    arr.capacity = capacity
}

func arrayPushBack(arr *Array, value string) {
    if arr.size == arr.capacity {
        resizeArray(arr)
    }
    arr.data[arr.size] = value
    arr.size++
}

func arrayInsertAt(arr *Array, index int, value string) bool {
    if index < 0 || index > arr.size {
        return false
    }
    if arr.size == arr.capacity {
        resizeArray(arr)
    }
    for i := arr.size; i > index; i-- {
        arr.data[i] = arr.data[i-1]
    }
    arr.data[index] = value
    arr.size++
    return true
}

func arrayGetAt(arr *Array, index int) (string, bool) {
    if index < 0 || index >= arr.size {
        return "", false
    }
    return arr.data[index], true
}

func arraySetAt(arr *Array, index int, value string) bool {
    if index < 0 || index >= arr.size {
        return false
    }
    arr.data[index] = value
    return true
}

func arrayRemoveAt(arr *Array, index int) bool {
    if index < 0 || index >= arr.size {
        return false
    }
    for i := index; i < arr.size-1; i++ {
        arr.data[i] = arr.data[i+1]
    }
    arr.size--
    arr.data[arr.size] = ""
    return true
}

func arrayPrint(arr *Array) {
    for i := 0; i < arr.size; i++ {
        fmt.Print(arr.data[i], " ")
    }
    fmt.Printf("(size=%d, capacity=%d)\n", arr.size, arr.capacity)
}

func handleArray(command string, db Database, name string, args []string) {
    if !checkType(db, name, "array") {
        return
    }

    var arr Array
    initArray(&arr)
    for _, value := range loadItems(db, name) {
        arrayPushBack(&arr, value)
    }

    switch command {
    case "MPUSH":
        if need(args, 1) {
            arrayPushBack(&arr, args[0])
            fmt.Println("->", args[0])
        }
    case "MINSERT":
        if need(args, 2) {
            index, err := parseIndex(args[0])
            if err != nil || !arrayInsertAt(&arr, index, args[1]) {
                fmt.Println("неверный индекс")
            }
        }
    case "MGET":
        if need(args, 1) {
            index, err := parseIndex(args[0])
            if err != nil {
                fmt.Println("неверный индекс")
            } else if value, ok := arrayGetAt(&arr, index); ok {
                fmt.Println("->", value)
            } else {
                fmt.Println("нет такого индекса")
            }
        }
    case "MSET":
        if need(args, 2) {
            index, err := parseIndex(args[0])
            if err != nil || !arraySetAt(&arr, index, args[1]) {
                fmt.Println("нет такого индекса")
            }
        }
    case "MDEL":
        if need(args, 1) {
            index, err := parseIndex(args[0])
            if err != nil || !arrayRemoveAt(&arr, index) {
                fmt.Println("нет такого индекса")
            }
        }
    case "MLEN":
        fmt.Println("->", arr.size)
    case "MPRINT":
        arrayPrint(&arr)
    }

    items := append([]string{}, arr.data[:arr.size]...)
    saveItems(db, name, "array", items)
}
