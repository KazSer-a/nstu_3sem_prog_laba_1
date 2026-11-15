#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
printf '{}\n' > "$TMP"

cd "$ROOT"
make
(
    cd go
    go build -o dbms_go .
)

run_cpp() {
    ./dbms --file "$TMP" --query "$1"
}

run_go() {
    ./go/dbms_go --file "$TMP" --query "$1"
}

check() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    if [[ "$actual" != "$expected" ]]; then
        printf 'Ошибка: %s\nОжидалось: <%s>\nПолучено:  <%s>\n' \
            "$description" "$expected" "$actual"
        exit 1
    fi
}


check_cpp() {
    local query="$1"
    local expected="$2"
    local description="$3"
    local actual

    if ! actual=$(run_cpp "$query"); then
        echo "Ошибка запуска C++ команды: $query"
        exit 1
    fi
    check "$actual" "$expected" "$description"
}

check_go() {
    local query="$1"
    local expected="$2"
    local description="$3"
    local actual

    if ! actual=$(run_go "$query"); then
        echo "Ошибка запуска Go команды: $query"
        exit 1
    fi
    check "$actual" "$expected" "$description"
}

echo "Проверка динамического массива (C++)"
check_cpp 'MPUSH array_cpp a' '-> a' "добавление в массив"
run_cpp 'MPUSH array_cpp b' >/dev/null
run_cpp 'MINSERT array_cpp 1 middle' >/dev/null
check_cpp 'MGET array_cpp 1' '-> middle' "получение по индексу"
run_cpp 'MSET array_cpp 1 changed' >/dev/null
check_cpp 'MGET array_cpp 1' '-> changed' "изменение по индексу"
run_cpp 'MDEL array_cpp 1' >/dev/null
check_cpp 'MLEN array_cpp' '-> 2' "удаление по индексу"
check_cpp 'MGET array_cpp 99' 'нет такого индекса' "выход за границы массива"
check_cpp 'MPRINT array_cpp' 'a b (size=2, capacity=4)' "печать массива"
check_cpp 'PRINT array_cpp' 'a b (size=2, capacity=4)' "универсальная печать массива"
run_cpp 'MINSERT array_cpp 2 last' >/dev/null
check_cpp 'MGET array_cpp 2' '-> last' "вставка в конец массива"
check_cpp 'MINSERT array_cpp -1 invalid' 'неверный индекс' "проверка отрицательного индекса"
run_cpp 'MDEL array_cpp 2' >/dev/null
for value in a b c d e; do
    run_cpp "MPUSH array_cpp_capacity $value" >/dev/null
done
check_cpp 'MPRINT array_cpp_capacity' 'a b c d e (size=5, capacity=8)' "увеличение ёмкости массива C++"

echo "Проверка расширения массива (Go)"
for value in a b c d e; do
    run_go "MPUSH array_go $value" >/dev/null
done
check_go 'MLEN array_go' '-> 5' "размер массива после расширения"
check_go 'MPRINT array_go' 'a b c d e (size=5, capacity=8)' "увеличение ёмкости массива"
check_go 'PRINT array_go' 'a b c d e (size=5, capacity=8)' "универсальная печать массива Go"
run_go 'MPUSH array_go_ops a' >/dev/null
run_go 'MPUSH array_go_ops b' >/dev/null
run_go 'MINSERT array_go_ops 1 middle' >/dev/null
check_go 'MGET array_go_ops 1' '-> middle' "получение элемента массива Go"
run_go 'MSET array_go_ops 1 changed' >/dev/null
check_go 'MGET array_go_ops 1' '-> changed' "изменение элемента массива Go"
run_go 'MDEL array_go_ops 1' >/dev/null
check_go 'MLEN array_go_ops' '-> 2' "удаление элемента массива Go"

echo "Проверка односвязного списка (C++)"
run_cpp 'FPUSHH flist_cpp a' >/dev/null
run_cpp 'FPUSHT flist_cpp c' >/dev/null
run_cpp 'FPUSHA flist_cpp a b' >/dev/null
run_cpp 'FPUSHB flist_cpp c d' >/dev/null
check_cpp 'FPRINT flist_cpp' 'a -> b -> d -> c -> nullptr' "вставка в односвязный список"
check_cpp 'FPRINTR flist_cpp' 'c d b a ' "обратная печать односвязного списка"
check_cpp 'PRINT flist_cpp' 'a -> b -> d -> c -> nullptr' "универсальная печать односвязного списка"
check_cpp 'FFIND flist_cpp b' '-> TRUE' "поиск существующего элемента"
check_cpp 'FFIND flist_cpp missing' '-> FALSE' "поиск отсутствующего элемента"
run_cpp 'FDELA flist_cpp a' >/dev/null
check_cpp 'FPRINT flist_cpp' 'a -> d -> c -> nullptr' "удаление после элемента"
run_cpp 'FDELB flist_cpp c' >/dev/null
check_cpp 'FPRINT flist_cpp' 'a -> c -> nullptr' "удаление перед элементом"
run_cpp 'FDEL flist_cpp c' >/dev/null
check_cpp 'FPRINT flist_cpp' 'a -> nullptr' "удаление по значению"
check_cpp 'FDELA flist_cpp missing' 'нет такого элемента' "удаление после отсутствующего элемента"
check_cpp 'FDELB flist_cpp missing' 'нет такого элемента' "удаление перед отсутствующим элементом"
check_cpp 'FDEL flist_cpp missing' 'нет такого элемента' "удаление отсутствующего значения"
check_cpp 'FDELB flist_cpp a' 'нет предыдущего элемента' "удаление перед головой"
check_cpp 'FDELA flist_cpp a' 'нет следующего элемента' "удаление после хвоста"
run_cpp 'FPUSHT flist_cpp b' >/dev/null
run_cpp 'FDELT flist_cpp' >/dev/null
check_cpp 'FPRINT flist_cpp' 'a -> nullptr' "удаление хвоста"
run_cpp 'FDELH flist_cpp' >/dev/null
check_cpp 'FPRINT flist_cpp' 'nullptr' "удаление головы"
check_cpp 'FDELH flist_cpp' 'список пуст' "удаление из пустого списка"
check_cpp 'FDELT flist_cpp' 'список пуст' "удаление хвоста пустого списка"
run_cpp 'FPUSHH flist_edges_cpp a' >/dev/null
run_cpp 'FPUSHB flist_edges_cpp a before' >/dev/null
run_cpp 'FPUSHA flist_edges_cpp a after' >/dev/null
check_cpp 'FPRINT flist_edges_cpp' 'before -> a -> after -> nullptr' "вставка перед головой и после хвоста"
run_cpp 'FDELH flist_edges_cpp' >/dev/null
check_cpp 'FPRINT flist_edges_cpp' 'a -> after -> nullptr' "удаление головы после граничных вставок"
run_cpp 'FDELT flist_edges_cpp' >/dev/null
check_cpp 'FPRINT flist_edges_cpp' 'a -> nullptr' "удаление хвоста после граничных вставок"
run_cpp 'FDEL flist_edges_cpp a' >/dev/null
check_cpp 'FPRINT flist_edges_cpp' 'nullptr' "удаление последнего узла"

echo "Проверка односвязного списка (Go)"
run_go 'FPUSHH flist_go a' >/dev/null
run_go 'FPUSHT flist_go c' >/dev/null
run_go 'FPUSHA flist_go a b' >/dev/null
run_go 'FPUSHB flist_go c d' >/dev/null
check_go 'FPRINT flist_go' 'a -> b -> d -> c -> nil' "вставка в односвязный список Go"
check_go 'FPRINTR flist_go' 'c d b a ' "обратная печать односвязного списка Go"
check_go 'FFIND flist_go b' '-> TRUE' "поиск элемента односвязного списка Go"
check_go 'FFIND flist_go missing' '-> FALSE' "поиск отсутствующего элемента односвязного списка Go"
check_go 'PRINT flist_go' 'a -> b -> d -> c -> nil' "универсальная печать односвязного списка Go"
run_go 'FDELA flist_go a' >/dev/null
check_go 'FPRINT flist_go' 'a -> d -> c -> nil' "удаление после элемента Go"
run_go 'FDELB flist_go c' >/dev/null
check_go 'FPRINT flist_go' 'a -> c -> nil' "удаление перед элементом Go"
run_go 'FDEL flist_go c' >/dev/null
check_go 'FPRINT flist_go' 'a -> nil' "удаление по значению Go"
check_go 'FDELA flist_go missing' 'нет такого элемента' "удаление после отсутствующего элемента Go"
check_go 'FDELB flist_go missing' 'нет такого элемента' "удаление перед отсутствующим элементом Go"
check_go 'FDEL flist_go missing' 'нет такого элемента' "удаление отсутствующего значения Go"
check_go 'FDELB flist_go a' 'нет предыдущего элемента' "удаление перед головой Go"
check_go 'FDELA flist_go a' 'нет следующего элемента' "удаление после хвоста Go"
run_go 'FPUSHT flist_go b' >/dev/null
run_go 'FDELT flist_go' >/dev/null
check_go 'FPRINT flist_go' 'a -> nil' "удаление хвоста Go"
run_go 'FDELH flist_go' >/dev/null
check_go 'FPRINT flist_go' 'nil' "удаление головы Go"
check_go 'FDELH flist_go' 'список пуст' "удаление из пустого списка Go"
check_go 'FDELT flist_go' 'список пуст' "удаление хвоста пустого списка Go"
run_go 'FPUSHH flist_edges_go a' >/dev/null
run_go 'FPUSHB flist_edges_go a before' >/dev/null
run_go 'FPUSHA flist_edges_go a after' >/dev/null
check_go 'FPRINT flist_edges_go' 'before -> a -> after -> nil' "вставка перед головой и после хвоста Go"
run_go 'FDELH flist_edges_go' >/dev/null
check_go 'FPRINT flist_edges_go' 'a -> after -> nil' "удаление головы после граничных вставок Go"
run_go 'FDELT flist_edges_go' >/dev/null
check_go 'FPRINT flist_edges_go' 'a -> nil' "удаление хвоста после граничных вставок Go"
run_go 'FDEL flist_edges_go a' >/dev/null
check_go 'FPRINT flist_edges_go' 'nil' "удаление последнего узла Go"

echo "Проверка двусвязного списка (C++)"
run_cpp 'LPUSHH dlist_cpp a' >/dev/null
run_cpp 'LPUSHT dlist_cpp c' >/dev/null
run_cpp 'LPUSHA dlist_cpp a b' >/dev/null
run_cpp 'LPUSHB dlist_cpp c d' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'a <-> b <-> d <-> c <-> nullptr' "вставка в двусвязный список"
check_cpp 'PRINT dlist_cpp' 'a <-> b <-> d <-> c <-> nullptr' "универсальная печать двусвязного списка"
check_cpp 'LPRINTR dlist_cpp' 'c <-> d <-> b <-> a <-> nullptr' "обратный обход"
check_cpp 'LFIND dlist_cpp b' '-> TRUE' "поиск существующего элемента"
check_cpp 'LFIND dlist_cpp missing' '-> FALSE' "поиск отсутствующего элемента"
run_cpp 'LDELA dlist_cpp a' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'a <-> d <-> c <-> nullptr' "удаление следующего узла"
check_cpp 'LPRINTR dlist_cpp' 'c <-> d <-> a <-> nullptr' "обратные ссылки после удаления"
run_cpp 'LDELB dlist_cpp c' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'a <-> c <-> nullptr' "удаление предыдущего узла"
check_cpp 'LPRINTR dlist_cpp' 'c <-> a <-> nullptr' "обратные ссылки после второго удаления"
run_cpp 'LDEL dlist_cpp c' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'a <-> nullptr' "удаление по значению"
check_cpp 'LDELA dlist_cpp missing' 'нет такого элемента' "удаление после отсутствующего элемента"
check_cpp 'LDEL dlist_cpp missing' 'нет такого элемента' "удаление отсутствующего значения"
check_cpp 'LDELB dlist_cpp a' 'нет предыдущего элемента' "удаление перед головой"
check_cpp 'LDELA dlist_cpp a' 'нет следующего элемента' "удаление после хвоста"
run_cpp 'LPUSHT dlist_cpp b' >/dev/null
run_cpp 'LDELT dlist_cpp' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'a <-> nullptr' "удаление хвоста"
run_cpp 'LDELH dlist_cpp' >/dev/null
check_cpp 'LPRINT dlist_cpp' 'nullptr' "удаление головы"
check_cpp 'LDELH dlist_cpp' 'список пуст' "удаление из пустого списка"
check_cpp 'LDELT dlist_cpp' 'список пуст' "удаление хвоста пустого списка"
run_cpp 'LPUSHH dlist_edges_cpp a' >/dev/null
run_cpp 'LPUSHB dlist_edges_cpp a before' >/dev/null
run_cpp 'LPUSHA dlist_edges_cpp a after' >/dev/null
check_cpp 'LPRINT dlist_edges_cpp' 'before <-> a <-> after <-> nullptr' "вставка перед головой и после хвоста"
check_cpp 'LPRINTR dlist_edges_cpp' 'after <-> a <-> before <-> nullptr' "обратные ссылки после граничных вставок"

echo "Проверка двусвязного списка (Go)"
run_go 'LPUSHH dlist_go a' >/dev/null
run_go 'LPUSHT dlist_go c' >/dev/null
run_go 'LPUSHA dlist_go a b' >/dev/null
run_go 'LPUSHB dlist_go c d' >/dev/null
check_go 'LPRINT dlist_go' 'a <-> b <-> d <-> c <-> nil' "вставка в двусвязный список Go"
check_go 'LFIND dlist_go b' '-> TRUE' "поиск элемента двусвязного списка Go"
check_go 'LFIND dlist_go missing' '-> FALSE' "поиск отсутствующего элемента двусвязного списка Go"
check_go 'PRINT dlist_go' 'a <-> b <-> d <-> c <-> nil' "универсальная печать двусвязного списка Go"
check_go 'LPRINTR dlist_go' 'c <-> d <-> b <-> a <-> nil' "обратный обход Go"
run_go 'LDELA dlist_go a' >/dev/null
check_go 'LPRINT dlist_go' 'a <-> d <-> c <-> nil' "удаление следующего узла Go"
check_go 'LPRINTR dlist_go' 'c <-> d <-> a <-> nil' "обратные ссылки Go"
run_go 'LDELB dlist_go c' >/dev/null
check_go 'LPRINT dlist_go' 'a <-> c <-> nil' "удаление предыдущего узла Go"
run_go 'LDEL dlist_go c' >/dev/null
check_go 'LPRINT dlist_go' 'a <-> nil' "удаление по значению Go"
check_go 'LDELA dlist_go missing' 'нет такого элемента' "удаление после отсутствующего элемента Go"
check_go 'LDEL dlist_go missing' 'нет такого элемента' "удаление отсутствующего значения Go"
check_go 'LDELB dlist_go a' 'нет предыдущего элемента' "удаление перед головой Go"
check_go 'LDELA dlist_go a' 'нет следующего элемента' "удаление после хвоста Go"
run_go 'LPUSHT dlist_go b' >/dev/null
run_go 'LDELT dlist_go' >/dev/null
check_go 'LPRINT dlist_go' 'a <-> nil' "удаление хвоста Go"
run_go 'LDELH dlist_go' >/dev/null
check_go 'LPRINT dlist_go' 'nil' "удаление головы Go"
check_go 'LDELT dlist_go' 'список пуст' "удаление из пустого списка Go"
check_go 'LDELH dlist_go' 'список пуст' "удаление головы пустого списка Go"
run_go 'LPUSHH dlist_edges_go a' >/dev/null
run_go 'LPUSHB dlist_edges_go a before' >/dev/null
run_go 'LPUSHA dlist_edges_go a after' >/dev/null
check_go 'LPRINT dlist_edges_go' 'before <-> a <-> after <-> nil' "вставка перед головой и после хвоста Go"
check_go 'LPRINTR dlist_edges_go' 'after <-> a <-> before <-> nil' "обратные ссылки после граничных вставок Go"

echo "Проверка стека (C++)"
run_cpp 'SPUSH stack_cpp first' >/dev/null
run_cpp 'SPUSH stack_cpp second' >/dev/null
check_cpp 'SPRINT stack_cpp' 'second -> first -> nullptr' "порядок стека"
check_cpp 'PRINT stack_cpp' 'second -> first -> nullptr' "универсальная печать стека"
check_cpp 'SPOP stack_cpp' '-> second' "извлечение верхнего элемента"
check_cpp 'SPOP stack_cpp' '-> first' "извлечение следующего элемента"
check_cpp 'SPOP stack_cpp' '-> стек пуст' "извлечение из пустого стека"

echo "Проверка очереди (C++)"
run_cpp 'QPUSH queue_cpp first' >/dev/null
run_cpp 'QPUSH queue_cpp second' >/dev/null
check_cpp 'QPRINT queue_cpp' 'first -> second -> nullptr' "порядок очереди"
check_cpp 'PRINT queue_cpp' 'first -> second -> nullptr' "универсальная печать очереди"
check_cpp 'QPOP queue_cpp' '-> first' "извлечение первого элемента"
check_cpp 'QPOP queue_cpp' '-> second' "извлечение следующего элемента"
check_cpp 'QPOP queue_cpp' '-> очередь пуста' "извлечение из пустой очереди"
run_cpp 'QPUSH queue_cpp after_empty' >/dev/null
check_cpp 'QPOP queue_cpp' '-> after_empty' "повторное использование пустой очереди"

echo "Проверка стека и очереди (Go)"
run_go 'SPUSH stack_go first' >/dev/null
run_go 'SPUSH stack_go second' >/dev/null
check_go 'SPRINT stack_go' 'second -> first -> nil' "порядок стека Go"
check_go 'PRINT stack_go' 'second -> first -> nil' "универсальная печать стека Go"
check_go 'SPOP stack_go' '-> second' "извлечение верхнего элемента Go"
check_go 'SPOP stack_go' '-> first' "извлечение следующего элемента Go"
check_go 'SPOP stack_go' '-> стек пуст' "извлечение из пустого стека Go"
run_go 'QPUSH queue_go first' >/dev/null
run_go 'QPUSH queue_go second' >/dev/null
check_go 'QPRINT queue_go' 'first -> second -> nil' "порядок очереди Go"
check_go 'PRINT queue_go' 'first -> second -> nil' "универсальная печать очереди Go"
check_go 'QPOP queue_go' '-> first' "извлечение первого элемента очереди Go"
check_go 'QPOP queue_go' '-> second' "извлечение следующего элемента очереди Go"
check_go 'QPOP queue_go' '-> очередь пуста' "извлечение из пустой очереди Go"
run_go 'QPUSH queue_go after_empty' >/dev/null
check_go 'QPOP queue_go' '-> after_empty' "повторное использование пустой очереди Go"

echo "Проверка бинарного дерева поиска и Full Binary Tree"
check_cpp 'TFULL empty_tree' '-> TRUE' "пустое дерево"
run_cpp 'TINSERT tree 8' >/dev/null
run_cpp 'TINSERT tree 4' >/dev/null
run_cpp 'TINSERT tree 12' >/dev/null
run_cpp 'TINSERT tree 2' >/dev/null
run_cpp 'TINSERT tree 6' >/dev/null
run_cpp 'TINSERT tree 10' >/dev/null
run_cpp 'TINSERT tree 14' >/dev/null
check_cpp 'TFULL tree' '-> TRUE' "полное бинарное дерево"
check_cpp 'TFIND tree 10' '-> TRUE' "поиск в дереве"
check_cpp 'TFIND tree 99' '-> FALSE' "поиск отсутствующего ключа"
check_cpp 'TPRINT tree' 
run_cpp 'TINSERT tree 8' >/dev/null
check_cpp 'TFULL tree' '-> FALSE' "дерево с узлом, имеющим одного потомка"

echo "Проверка обмена данными между C++ и Go"
run_go 'MPUSH array_cpp from_go' >/dev/null
check_cpp 'MGET array_cpp 2' '-> from_go' "чтение Go-данных из C++"
run_cpp 'MPUSH array_cpp from_cpp' >/dev/null
check_go 'MGET array_cpp 3' '-> from_cpp' "чтение C++-данных из Go"
run_cpp 'QPUSH shared_queue cpp_value' >/dev/null
check_go 'QPOP shared_queue' '-> cpp_value' "чтение очереди C++-версией из Go"

printf 'Все проверки пройдены.\n'
прямой:       8 4 2 6 12 10 14 \nсимметричный: 2 4 6 8 10 12 14 \nобратный:     2 6 4 10 14 12 8 \nв ширину:     8 4 12 2 6 10 14 ' "обходы дерева"
check_cpp 'PRINT tree' 
run_cpp 'TINSERT tree 8' >/dev/null
check_cpp 'TFULL tree' '-> FALSE' "дерево с узлом, имеющим одного потомка"

echo "Проверка обмена данными между C++ и Go"
run_go 'MPUSH array_cpp from_go' >/dev/null
check_cpp 'MGET array_cpp 2' '-> from_go' "чтение Go-данных из C++"
run_cpp 'MPUSH array_cpp from_cpp' >/dev/null
check_go 'MGET array_cpp 3' '-> from_cpp' "чтение C++-данных из Go"
run_cpp 'QPUSH shared_queue cpp_value' >/dev/null
check_go 'QPOP shared_queue' '-> cpp_value' "чтение очереди C++-версией из Go"

printf 'Все проверки пройдены.\n'
прямой:       8 4 2 6 12 10 14 \nсимметричный: 2 4 6 8 10 12 14 \nобратный:     2 6 4 10 14 12 8 \nв ширину:     8 4 12 2 6 10 14 ' "универсальная печать дерева"
run_cpp 'TINSERT tree 8' >/dev/null
check_cpp 'TFULL tree' '-> FALSE' "дерево с узлом, имеющим одного потомка"

echo "Проверка обмена данными между C++ и Go"
run_go 'MPUSH array_cpp from_go' >/dev/null
check_cpp 'MGET array_cpp 2' '-> from_go' "чтение Go-данных из C++"
run_cpp 'MPUSH array_cpp from_cpp' >/dev/null
check_go 'MGET array_cpp 3' '-> from_cpp' "чтение C++-данных из Go"
run_cpp 'QPUSH shared_queue cpp_value' >/dev/null
check_go 'QPOP shared_queue' '-> cpp_value' "чтение очереди C++-версией из Go"

printf 'Все проверки пройдены.\n'
