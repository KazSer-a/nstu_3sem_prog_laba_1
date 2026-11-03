package main

import "fmt"

type DNode struct {
    value string
    next *DNode
    prev *DNode
}

type DList struct {
    head *DNode
    tail *DNode
}

func (list *DList) pushFront(value string) {
    node := &DNode{value: value, next: list.head}
    if list.head != nil {
        list.head.prev = node
    } else {
        list.tail = node
    }
    list.head = node
}

func (list *DList) pushBack(value string) {
    node := &DNode{value: value, prev: list.tail}
    if list.tail != nil {
        list.tail.next = node
    } else {
        list.head = node
    }
    list.tail = node
}

func (list *DList) find(value string) *DNode {
    for current := list.head; current != nil; current = current.next {
        if current.value == value {
            return current
        }
    }
    return nil
}

func (list *DList) pushAfter(target *DNode, value string) {
    if target == nil {
        return
    }
    node := &DNode{value: value, next: target.next, prev: target}
    if target.next != nil {
        target.next.prev = node
    } else {
        list.tail = node
    }
    target.next = node
}

func (list *DList) pushBefore(target *DNode, value string) {
    if target == nil {
        return
    }
    if target.prev == nil {
        list.pushFront(value)
        return
    }
    list.pushAfter(target.prev, value)
}

func (list *DList) deleteNode(node *DNode) {
    if node == nil {
        return
    }
    if node.prev != nil {
        node.prev.next = node.next
    } else {
        list.head = node.next
    }
    if node.next != nil {
        node.next.prev = node.prev
    } else {
        list.tail = node.prev
    }
}

func (list *DList) popFront() { list.deleteNode(list.head) }
func (list *DList) popBack() { list.deleteNode(list.tail) }

func (list *DList) items() []string {
    items := []string{}
    for current := list.head; current != nil; current = current.next {
        items = append(items, current.value)
    }
    return items
}

func handleDlist(command string, db Database, name string, args []string) {
    if !checkType(db, name, "dlist") {
        return
    }
    var list DList
    for _, value := range loadItems(db, name) {
        list.pushBack(value)
    }

    switch command {
    case "LPUSHH":
        if need(args, 1) {
            list.pushFront(args[0])
        }
    case "LPUSHT":
        if need(args, 1) {
            list.pushBack(args[0])
        }
    case "LPUSHA":
        if need(args, 2) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else {
                list.pushAfter(node, args[1])
            }
        }
    case "LPUSHB":
        if need(args, 2) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else {
                list.pushBefore(node, args[1])
            }
        }
    case "LDELH":
        if list.head == nil {
            fmt.Println("список пуст")
        } else {
            list.popFront()
        }
    case "LDELT":
        if list.tail == nil {
            fmt.Println("список пуст")
        } else {
            list.popBack()
        }
    case "LDELA":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil || node.next == nil {
                fmt.Println("нет следующего элемента")
            } else {
                list.deleteNode(node.next)
            }
        }
    case "LDELB":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil || node.prev == nil {
                fmt.Println("нет предыдущего элемента")
            } else {
                list.deleteNode(node.prev)
            }
        }
    case "LDEL":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else {
                list.deleteNode(node)
            }
        }
    case "LFIND":
        if need(args, 1) {
            if list.find(args[0]) != nil {
                fmt.Println("-> TRUE")
            } else {
                fmt.Println("-> FALSE")
            }
        }
    case "LPRINT":
        for current := list.head; current != nil; current = current.next {
            fmt.Print(current.value, " <-> ")
        }
        fmt.Println("nil")
    case "LPRINTR":
        for current := list.tail; current != nil; current = current.prev {
            fmt.Print(current.value, " <-> ")
        }
        fmt.Println("nil")
    }
    saveItems(db, name, "dlist", list.items())
}
