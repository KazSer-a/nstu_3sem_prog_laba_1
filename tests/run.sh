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

echo "Проверка динамического массива (C++)"
check "$(run_cpp 'MPUSH array_cpp a')" '-> a' "добавление в массив"
run_cpp 'MPUSH array_cpp b' >/dev/null
run_cpp 'MINSERT array_cpp 1 middle' >/dev/null
check "$(run_cpp 'MGET array_cpp 1')" '-> middle' "получение по индексу"
run_cpp 'MSET array_cpp 1 changed' >/dev/null
check "$(run_cpp 'MGET array_cpp 1')" '-> changed' "изменение по индексу"
run_cpp 'MDEL array_cpp 1' >/dev/null
check "$(run_cpp 'MLEN array_cpp')" '-> 2' "удаление по индексу"
check "$(run_cpp 'MGET array_cpp 99')" 'нет такого индекса' "выход за границы массива"

echo "Проверка расширения массива (Go)"
for value in a b c d e; do
    run_go "MPUSH array_go $value" >/dev/null
done
check "$(run_go 'MLEN array_go')" '-> 5' "размер массива после расширения"

echo "Проверка односвязного списка (C++)"
run_cpp 'FPUSHH flist_cpp a' >/dev/null
run_cpp 'FPUSHT flist_cpp c' >/dev/null
run_cpp 'FPUSHA flist_cpp a b' >/dev/null
run_cpp 'FPUSHB flist_cpp c d' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'a -> b -> d -> c -> nullptr' "вставка в односвязный список"
check "$(run_cpp 'FFIND flist_cpp b')" '-> TRUE' "поиск существующего элемента"
check "$(run_cpp 'FFIND flist_cpp missing')" '-> FALSE' "поиск отсутствующего элемента"
run_cpp 'FDELA flist_cpp a' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'a -> d -> c -> nullptr' "удаление после элемента"
run_cpp 'FDELB flist_cpp c' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'a -> c -> nullptr' "удаление перед элементом"
run_cpp 'FDEL flist_cpp c' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'a -> nullptr' "удаление по значению"
check "$(run_cpp 'FDELA flist_cpp missing')" 'нет такого элемента' "удаление после отсутствующего элемента"
check "$(run_cpp 'FDELB flist_cpp a')" 'нет предыдущего элемента' "удаление перед головой"
check "$(run_cpp 'FDELA flist_cpp a')" 'нет следующего элемента' "удаление после хвоста"
run_cpp 'FPUSHT flist_cpp b' >/dev/null
run_cpp 'FDELT flist_cpp' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'a -> nullptr' "удаление хвоста"
run_cpp 'FDELH flist_cpp' >/dev/null
check "$(run_cpp 'FPRINT flist_cpp')" 'nullptr' "удаление головы"
check "$(run_cpp 'FDELH flist_cpp')" 'список пуст' "удаление из пустого списка"

echo "Проверка односвязного списка (Go)"
run_go 'FPUSHH flist_go a' >/dev/null
run_go 'FPUSHT flist_go c' >/dev/null
run_go 'FPUSHA flist_go a b' >/dev/null
run_go 'FPUSHB flist_go c d' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'a -> b -> d -> c -> nil' "вставка в односвязный список Go"
run_go 'FDELA flist_go a' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'a -> d -> c -> nil' "удаление после элемента Go"
run_go 'FDELB flist_go c' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'a -> c -> nil' "удаление перед элементом Go"
run_go 'FDEL flist_go c' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'a -> nil' "удаление по значению Go"
check "$(run_go 'FDELA flist_go missing')" 'нет такого элемента' "отсутствующий элемент Go"
check "$(run_go 'FDELB flist_go a')" 'нет предыдущего элемента' "удаление перед головой Go"
check "$(run_go 'FDELA flist_go a')" 'нет следующего элемента' "удаление после хвоста Go"
run_go 'FPUSHT flist_go b' >/dev/null
run_go 'FDELT flist_go' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'a -> nil' "удаление хвоста Go"
run_go 'FDELH flist_go' >/dev/null
check "$(run_go 'FPRINT flist_go')" 'nil' "удаление головы Go"
check "$(run_go 'FDELH flist_go')" 'список пуст' "удаление из пустого списка Go"

echo "Проверка двусвязного списка (C++)"
run_cpp 'LPUSHH dlist_cpp a' >/dev/null
run_cpp 'LPUSHT dlist_cpp c' >/dev/null
run_cpp 'LPUSHA dlist_cpp a b' >/dev/null
run_cpp 'LPUSHB dlist_cpp c d' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'a <-> b <-> d <-> c <-> nullptr' "вставка в двусвязный список"
check "$(run_cpp 'LPRINTR dlist_cpp')" 'c <-> d <-> b <-> a <-> nullptr' "обратный обход"
check "$(run_cpp 'LFIND dlist_cpp b')" '-> TRUE' "поиск существующего элемента"
check "$(run_cpp 'LFIND dlist_cpp missing')" '-> FALSE' "поиск отсутствующего элемента"
run_cpp 'LDELA dlist_cpp a' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'a <-> d <-> c <-> nullptr' "удаление следующего узла"
check "$(run_cpp 'LPRINTR dlist_cpp')" 'c <-> d <-> a <-> nullptr' "обратные ссылки после удаления"
run_cpp 'LDELB dlist_cpp c' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'a <-> c <-> nullptr' "удаление предыдущего узла"
check "$(run_cpp 'LPRINTR dlist_cpp')" 'c <-> a <-> nullptr' "обратные ссылки после второго удаления"
run_cpp 'LDEL dlist_cpp c' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'a <-> nullptr' "удаление по значению"
check "$(run_cpp 'LDELA dlist_cpp missing')" 'нет такого элемента' "удаление после отсутствующего элемента"
check "$(run_cpp 'LDELB dlist_cpp a')" 'нет предыдущего элемента' "удаление перед головой"
check "$(run_cpp 'LDELA dlist_cpp a')" 'нет следующего элемента' "удаление после хвоста"
run_cpp 'LPUSHT dlist_cpp b' >/dev/null
run_cpp 'LDELT dlist_cpp' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'a <-> nullptr' "удаление хвоста"
run_cpp 'LDELH dlist_cpp' >/dev/null
check "$(run_cpp 'LPRINT dlist_cpp')" 'nullptr' "удаление головы"
check "$(run_cpp 'LDELH dlist_cpp')" 'список пуст' "удаление из пустого списка"

echo "Проверка двусвязного списка (Go)"
run_go 'LPUSHH dlist_go a' >/dev/null
run_go 'LPUSHT dlist_go c' >/dev/null
run_go 'LPUSHA dlist_go a b' >/dev/null
run_go 'LPUSHB dlist_go c d' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'a <-> b <-> d <-> c <-> nil' "вставка в двусвязный список Go"
check "$(run_go 'LPRINTR dlist_go')" 'c <-> d <-> b <-> a <-> nil' "обратный обход Go"
run_go 'LDELA dlist_go a' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'a <-> d <-> c <-> nil' "удаление следующего узла Go"
check "$(run_go 'LPRINTR dlist_go')" 'c <-> d <-> a <-> nil' "обратные ссылки Go"
run_go 'LDELB dlist_go c' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'a <-> c <-> nil' "удаление предыдущего узла Go"
run_go 'LDEL dlist_go c' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'a <-> nil' "удаление по значению Go"
check "$(run_go 'LDELA dlist_go missing')" 'нет такого элемента' "удаление после отсутствующего элемента Go"
check "$(run_go 'LDELB dlist_go a')" 'нет предыдущего элемента' "удаление перед головой Go"
check "$(run_go 'LDELA dlist_go a')" 'нет следующего элемента' "удаление после хвоста Go"
run_go 'LPUSHT dlist_go b' >/dev/null
run_go 'LDELT dlist_go' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'a <-> nil' "удаление хвоста Go"
run_go 'LDELH dlist_go' >/dev/null
check "$(run_go 'LPRINT dlist_go')" 'nil' "удаление головы Go"
check "$(run_go 'LDELT dlist_go')" 'список пуст' "удаление из пустого списка Go"

echo "Проверка стека (C++)"
run_cpp 'SPUSH stack_cpp first' >/dev/null
run_cpp 'SPUSH stack_cpp second' >/dev/null
check "$(run_cpp 'SPRINT stack_cpp')" 'second -> first -> nullptr' "порядок стека"
check "$(run_cpp 'SPOP stack_cpp')" '-> second' "извлечение верхнего элемента"
check "$(run_cpp 'SPOP stack_cpp')" '-> first' "извлечение следующего элемента"
check "$(run_cpp 'SPOP stack_cpp')" '-> стек пуст' "извлечение из пустого стека"

echo "Проверка очереди (C++)"
run_cpp 'QPUSH queue_cpp first' >/dev/null
run_cpp 'QPUSH queue_cpp second' >/dev/null
check "$(run_cpp 'QPRINT queue_cpp')" 'first -> second -> nullptr' "порядок очереди"
check "$(run_cpp 'QPOP queue_cpp')" '-> first' "извлечение первого элемента"
check "$(run_cpp 'QPOP queue_cpp')" '-> second' "извлечение следующего элемента"
check "$(run_cpp 'QPOP queue_cpp')" '-> очередь пуста' "извлечение из пустой очереди"

echo "Проверка стека и очереди (Go)"
run_go 'SPUSH stack_go first' >/dev/null
run_go 'SPUSH stack_go second' >/dev/null
check "$(run_go 'SPRINT stack_go')" 'second -> first -> nil' "порядок стека Go"
check "$(run_go 'SPOP stack_go')" '-> second' "извлечение из стека Go"
run_go 'QPUSH queue_go first' >/dev/null
run_go 'QPUSH queue_go second' >/dev/null
check "$(run_go 'QPRINT queue_go')" 'first -> second -> nil' "порядок очереди Go"
check "$(run_go 'QPOP queue_go')" '-> first' "извлечение из очереди Go"

echo "Проверка бинарного дерева поиска и Full Binary Tree"
check "$(run_cpp 'TFULL empty_tree')" '-> TRUE' "пустое дерево"
run_cpp 'TINSERT tree 8' >/dev/null
run_cpp 'TINSERT tree 4' >/dev/null
run_cpp 'TINSERT tree 12' >/dev/null
run_cpp 'TINSERT tree 2' >/dev/null
run_cpp 'TINSERT tree 6' >/dev/null
run_cpp 'TINSERT tree 10' >/dev/null
run_cpp 'TINSERT tree 14' >/dev/null
check "$(run_cpp 'TFULL tree')" '-> TRUE' "полное бинарное дерево"
check "$(run_cpp 'TFIND tree 10')" '-> TRUE' "поиск в дереве"
check "$(run_cpp 'TFIND tree 99')" '-> FALSE' "поиск отсутствующего ключа"
check "$(run_cpp 'TPRINT tree')" $'прямой:       8 4 2 6 12 10 14 \nсимметричный: 2 4 6 8 10 12 14 \nобратный:     2 6 4 10 14 12 8 \nв ширину:     8 4 12 2 6 10 14 ' "обходы дерева"
run_cpp 'TINSERT tree 8' >/dev/null
check "$(run_cpp 'TFULL tree')" '-> FALSE' "дерево с узлом, имеющим одного потомка"

echo "Проверка обмена данными между C++ и Go"
run_go 'MPUSH array_cpp from_go' >/dev/null
check "$(run_cpp 'MGET array_cpp 2')" '-> from_go' "чтение Go-данных из C++"
run_cpp 'MPUSH array_cpp from_cpp' >/dev/null
check "$(run_go 'MGET array_cpp 3')" '-> from_cpp' "чтение C++-данных из Go"
run_cpp 'QPUSH shared_queue cpp_value' >/dev/null
check "$(run_go 'QPOP shared_queue')" '-> cpp_value' "чтение очереди C++-версией из Go"

printf 'Все проверки пройдены.\n'
