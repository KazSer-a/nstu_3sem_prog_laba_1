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

// Добавляет узел в начало списка.
func (list *DList) pushFront(value string) {
    node := &DNode{value: value, next: list.head}
    if list.head != nil {
        list.head.prev = node
    } else {
        list.tail = node
    }
    list.head = node
}

// Добавляет узел в конец списка.
func (list *DList) pushBack(value string) {
    node := &DNode{value: value, prev: list.tail}
    if list.tail != nil {
        list.tail.next = node
    } else {
        list.head = node
    }
    list.tail = node
}

// Находит узел по значению.
func (list *DList) find(value string) *DNode {
    for current := list.head; current != nil; current = current.next {
        if current.value == value {
            return current
        }
    }
    return nil
}

// Вставляет узел после указанного.
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

// Вставляет узел перед указанным.
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

// Удаляет узел и обновляет связи.
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

// Удаляет первый узел списка.
func (list *DList) popFront() { list.deleteNode(list.head) }
// Удаляет последний узел списка.
func (list *DList) popBack() { list.deleteNode(list.tail) }

// Удаляет узел после указанного.
func (list *DList) deleteAfter(target *DNode) bool {
    if target == nil || target.next == nil {
        return false
    }
    list.deleteNode(target.next)
    return true
}

// Удаляет узел перед указанным.
func (list *DList) deleteBefore(target *DNode) bool {
    if target == nil || target.prev == nil {
        return false
    }
    list.deleteNode(target.prev)
    return true
}

// Удаляет узел по значению.
func (list *DList) deleteValue(value string) bool {
    node := list.find(value)
    if node == nil {
        return false
    }
    list.deleteNode(node)
    return true
}

// Возвращает элементы списка по порядку.
func (list *DList) items() []string {
    items := []string{}
    for current := list.head; current != nil; current = current.next {
        items = append(items, current.value)
    }
    return items
}

// Выполняет команду двусвязного списка.
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
            if node == nil {
                fmt.Println("нет такого элемента")
            } else if !list.deleteAfter(node) {
                fmt.Println("нет следующего элемента")
            }
        }
    case "LDELB":
        if need(args, 1) {
            node := list.find(args[0])
            if node == nil {
                fmt.Println("нет такого элемента")
            } else if !list.deleteBefore(node) {
                fmt.Println("нет предыдущего элемента")
            }
        }
    case "LDEL":
        if need(args, 1) {
            if !list.deleteValue(args[0]) {
                fmt.Println("нет такого элемента")
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
