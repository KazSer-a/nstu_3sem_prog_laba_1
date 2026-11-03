package main

import "fmt"

type QNode struct {
    value string
    next *QNode
}

type Queue struct {
    head *QNode
    tail *QNode
}

func (queue *Queue) push(value string) {
    node := &QNode{value: value}
    if queue.tail != nil {
        queue.tail.next = node
    } else {
        queue.head = node
    }
    queue.tail = node
}

func (queue *Queue) pop() (string, bool) {
    if queue.head == nil {
        return "", false
    }
    value := queue.head.value
    queue.head = queue.head.next
    if queue.head == nil {
        queue.tail = nil
    }
    return value, true
}

func (queue *Queue) items() []string {
    items := []string{}
    for current := queue.head; current != nil; current = current.next {
        items = append(items, current.value)
    }
    return items
}

func handleQueue(command string, db Database, name string, args []string) {
    if !checkType(db, name, "queue") {
        return
    }
    var queue Queue
    for _, value := range loadItems(db, name) {
        queue.push(value)
    }

    switch command {
    case "QPUSH":
        if need(args, 1) {
            queue.push(args[0])
            fmt.Println("->", args[0])
        }
    case "QPOP":
        if value, ok := queue.pop(); ok {
            fmt.Println("->", value)
        } else {
            fmt.Println("-> очередь пуста")
        }
    case "QPRINT":
        for current := queue.head; current != nil; current = current.next {
            fmt.Print(current.value, " -> ")
        }
        fmt.Println("nil")
    }
    saveItems(db, name, "queue", queue.items())
}
