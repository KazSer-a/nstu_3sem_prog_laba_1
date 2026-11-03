# Лабораторная работа №1

Абстрактные структуры данных. Вариант 4 — Full Binary Tree.

## Реализация

- C++: массив, односвязный список, двусвязный список, стек, очередь и бинарное дерево поиска с проверкой Full Binary Tree.
- Go: массив, односвязный список, двусвязный список, стек и очередь.
- Дерево реализовано только на C++.
- Данные хранятся в одном JSON-файле и сохраняются после каждой команды.

## Зависимости

Для C++ нужны g++ с поддержкой C++17, make, pkg-config и json-c.

Ubuntu:

```bash
sudo apt install g++ make pkg-config libjson-c-dev
```

Для Go нужен Go 1.20 или новее.

## Сборка C++

```bash
make
```

## Сборка Go

```bash
cd go
go build -o dbms_go .
```

## Запуск

C++:

```bash
./dbms --file data.json --query "MPUSH myarray 10"
```

Go:

```bash
cd go
./dbms_go --file ../data.json --query "SPUSH mystack item"
```

Команда содержит название операции, имя структуры и аргументы. Значения передаются одним словом без пробелов.

## Команды

Массив: `MPUSH`, `MINSERT`, `MGET`, `MSET`, `MDEL`, `MLEN`, `MPRINT`.

Односвязный список: `FPUSHH`, `FPUSHT`, `FPUSHA`, `FPUSHB`, `FDELH`, `FDELT`, `FDELA`, `FDELB`, `FDEL`, `FFIND`, `FPRINT`, `FPRINTR`.

Двусвязный список: те же операции с первой буквой `L`.

Стек: `SPUSH`, `SPOP`, `SPRINT`.

Очередь: `QPUSH`, `QPOP`, `QPRINT`.

Дерево: `TINSERT`, `TFIND`, `TFULL`, `TPRINT`.

Общая команда: `PRINT <имя_структуры>`.

В дереве используется правило BST: меньшие значения идут налево, большие и равные — направо. Дубликаты разрешены.

## Примеры

```bash
./dbms --file data.json --query "MPUSH numbers 10"
./dbms --file data.json --query "MINSERT numbers 0 5"
./dbms --file data.json --query "MPRINT numbers"
./dbms --file data.json --query "FPUSHT names Alex"
./dbms --file data.json --query "SPUSH mystack 1"
./dbms --file data.json --query "QPUSH myqueue 1"
./dbms --file data.json --query "TINSERT mytree 8"
./dbms --file data.json --query "TFULL mytree"
```

## Тесты

```bash
./tests/run.sh
```

## Очистка

```bash
make clean
```
