package main

import "fmt"

type FNode struct {
    value string
    next *FNode
}

type FList struct {
    head *FNode
}

func (list *FList) pushFront(value string) {
    list.head = &FNode{value: value, next: list.head}
}

func (list *FList) pushBack(value string) {
    node := &FNode{value: value}
    if list.head == nil {
        list.head = node
        return
    }
    current := list.head
    for current.next != nil {
        current = current.next
    }
    current.next = node
}

func (list *FList) find(value string) *FNode {
    for current := list.head; current != nil; current = current.next {
        if current.value == value {
            return current
        }
    }
    return nil
}

func (list *FList) pushAfter(target *FNode, value string) {
    if target != nil {
        target.next = &FNode{value: value, next: target.next}
    }
}

func (list *FList) pushBefore(target *FNode, value string) {
    if target == nil {
        return
    }
    if target == list.head {
        list.pushFront(value)
        return
    }
    current := list.head
    for current != nil && current.next != target {
        current = current.next
    }
    if current != nil {
        list.pushAfter(current, value)
    }
}

func (list *FList) popFront() {
    if list.head != nil {
        list.head = list.head.next
    }
}

func (list *FList) popBack() {
    if list.head == nil {
        return
    }
    if list.head.next == nil {
        list.head = nil
        return
    }
    current := list.head
    for current.next.next != nil {
        current = current.next
    }
    current.next = nil
}

func (list *FList) popAfter(target *FNode) {
    if target != nil && target.next != nil {
        target.next = target.next.next
    }
}

func (list *FList) popBefore(target *FNode) {
    if target == nil || target == list.head {
        return
    }
    if list.head.next == target {
        list.popFront()
        return
    }
    current := list.head
    for current != nil && current.next != nil && current.next.next != target {
        current = current.next
    }
    if current != nil {
        list.popAfter(current)
    }
}

func (list *FList) deleteValue(value string) bool {
    if list.head == nil {
        return false
    }
    if list.head.value == value {
        list.popFront()
        return true
    }
    current := list.head
    for current.next != nil && current.next.value != value {
        current = current.next
    }
    if current.next == nil {
        return false
    }
    list.popAfter(current)
    return true
}

func (list *FList) items() []string {
    items := []string{}
    for current := list.head; current != nil; current = current.next {
        items = append(items, current.value)
    }
    return items
}

func handleFlist(command string, db Database, name string, args []string) {
    if !checkType(db, name, "flist") {
        return
    }
    var list FList
    for _, value := range loadItems(db, name) {
        list.pushBack(value)
    }

    switch command {
    case "FPUSHH":
        if need(args, 1) {
            list.pushFront(args[0])
        }
    case "FPUSHT":
        if need(args, 1) {
            list.pushBack(args[0])
        }
    case "FPUSHA":
        if need(args, 2) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else {
                list.pushAfter(node, args[1])
            }
        }
    case "FPUSHB":
        if need(args, 2) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else {
                list.pushBefore(node, args[1])
            }
        }
    case "FDELH":
        if list.head == nil {
            fmt.Println("список пуст")
        } else {
            list.popFront()
        }
    case "FDELT":
        if list.head == nil {
            fmt.Println("список пуст")
        } else {
            list.popBack()
        }
    case "FDELA":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil || node.next == nil {
                fmt.Println("нет следующего элемента")
            } else {
                list.popAfter(node)
            }
        }
    case "FDELB":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil || node == list.head {
                fmt.Println("нет предыдущего элемента")
            } else {
                list.popBefore(node)
            }
        }
    case "FDEL":
        if need(args, 1) && !list.deleteValue(args[0]) {
            fmt.Println("нет такого элемента")
        }
    case "FFIND":
        if need(args, 1) {
            if list.find(args[0]) != nil {
                fmt.Println("-> TRUE")
            } else {
                fmt.Println("-> FALSE")
            }
        }
    case "FPRINT":
        for _, value := range list.items() {
            fmt.Print(value, " -> ")
        }
        fmt.Println("nil")
    case "FPRINTR":
        items := list.items()
        for i := len(items) - 1; i >= 0; i-- {
            fmt.Print(items[i], " ")
        }
        fmt.Println()
    }
    saveItems(db, name, "flist", list.items())
}
