package main

import "fmt"

type SNode struct {
    value string
    next *SNode
}

type Stack struct {
    head *SNode
}

func (stack *Stack) push(value string) {
    stack.head = &SNode{value: value, next: stack.head}
}

func (stack *Stack) pop() (string, bool) {
    if stack.head == nil {
        return "", false
    }
    value := stack.head.value
    stack.head = stack.head.next
    return value, true
}

func (stack *Stack) items() []string {
    items := []string{}
    for current := stack.head; current != nil; current = current.next {
        items = append(items, current.value)
    }
    for i, j := 0, len(items)-1; i < j; i, j = i+1, j-1 {
        items[i], items[j] = items[j], items[i]
    }
    return items
}

func handleStack(command string, db Database, name string, args []string) {
    if !checkType(db, name, "stack") {
        return
    }
    var stack Stack
    for _, value := range loadItems(db, name) {
        stack.push(value)
    }

    switch command {
    case "SPUSH":
        if need(args, 1) {
            stack.push(args[0])
            fmt.Println("->", args[0])
        }
    case "SPOP":
        if value, ok := stack.pop(); ok {
            fmt.Println("->", value)
        } else {
            fmt.Println("-> стек пуст")
        }
    case "SPRINT":
        for current := stack.head; current != nil; current = current.next {
            fmt.Print(current.value, " -> ")
        }
        fmt.Println("nil")
    }
    saveItems(db, name, "stack", stack.items())
}
