# Лабораторная работа № 1

Абстрактные структуры данных. Индивидуальный вариант № 4 — Full Binary Tree.

## Состав проекта

- C++: динамический массив, односвязный и двусвязный списки, стек, очередь и бинарное дерево поиска с проверкой Full Binary Tree.
- Go: массив, односвязный и двусвязный списки, стек и очередь.
- Дерево реализовано на C++.
- Состояние структур хранится в JSON-файле.

## Зависимости

Для C++ нужны g++ с поддержкой C++17, make, pkg-config и json-c.

В Ubuntu зависимости устанавливаются командой:

```bash
sudo apt install g++ make pkg-config libjson-c-dev
```

Для сборки Go нужен Go 1.20 или новее.

## Сборка

C++:

```bash
make
```

Go:

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

В запросе указываются команда, имя структуры и её аргументы. Значения передаются одним словом без пробелов.

## Команды

Массив: `MPUSH`, `MINSERT`, `MGET`, `MSET`, `MDEL`, `MLEN`, `MPRINT`.

Односвязный список: `FPUSHH`, `FPUSHT`, `FPUSHA`, `FPUSHB`, `FDELH`, `FDELT`, `FDELA`, `FDELB`, `FDEL`, `FFIND`, `FPRINT`, `FPRINTR`.

Двусвязный список: те же операции с первой буквой `L`.

Стек: `SPUSH`, `SPOP`, `SPRINT`.

Очередь: `QPUSH`, `QPOP`, `QPRINT`.

Дерево: `TINSERT`, `TFIND`, `TFULL`, `TPRINT`.

Общая команда: `PRINT <имя_структуры>`.

В дереве меньшие ключи размещаются слева, большие и равные — справа. Повторяющиеся значения разрешены.

## Примеры команд

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

## Очистка

```bash
make clean
```
