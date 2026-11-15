#!/usr/bin/env bash
# Демонстрационный запуск команд. Проверки ожидаемых результатов находятся в run.sh.
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

cpp() {
    echo
    echo "\$ ./dbms --file $TMP --query \"$1\""
    ./dbms --file "$TMP" --query "$1"
}

golang() {
    echo
    echo "\$ ./go/dbms_go --file $TMP --query \"$1\""
    ./go/dbms_go --file "$TMP" --query "$1"
}

echo "========== C++: ARRAY =========="
cpp 'MPRINT arr'
cpp 'MPUSH arr alpha'
cpp 'MPUSH arr beta'
cpp 'MINSERT arr 1 middle'
cpp 'MGET arr 1'
cpp 'MSET arr 1 changed'
cpp 'MLEN arr'
cpp 'MDEL arr 1'
cpp 'PRINT arr'

echo
echo "========== C++: SINGLY LINKED LIST =========="
cpp 'FPRINT flist'
cpp 'FPUSHH flist a'
cpp 'FPUSHT flist c'
cpp 'FPUSHA flist a b'
cpp 'FPUSHB flist c d'
cpp 'FFIND flist b'
cpp 'FPRINTR flist'
cpp 'FDELA flist a'
cpp 'FDELB flist c'
cpp 'FDEL flist c'
cpp 'FDELH flist'
cpp 'FDELT flist'
cpp 'FPRINT flist'

echo
echo "========== C++: DOUBLY LINKED LIST =========="
cpp 'LPRINT dlist'
cpp 'LPUSHH dlist a'
cpp 'LPUSHT dlist c'
cpp 'LPUSHA dlist a b'
cpp 'LPUSHB dlist c d'
cpp 'LFIND dlist b'
cpp 'LPRINTR dlist'
cpp 'LDELA dlist a'
cpp 'LDELB dlist c'
cpp 'LDEL dlist c'
cpp 'LDELH dlist'
cpp 'LDELT dlist'
cpp 'LPRINT dlist'

echo
echo "========== C++: STACK =========="
cpp 'SPRINT stack'
cpp 'SPUSH stack first'
cpp 'SPUSH stack second'
cpp 'PRINT stack'
cpp 'SPOP stack'
cpp 'SPOP stack'
cpp 'SPOP stack'
cpp 'SPRINT stack'

echo
echo "========== C++: QUEUE =========="
cpp 'QPRINT queue'
cpp 'QPUSH queue first'
cpp 'QPUSH queue second'
cpp 'PRINT queue'
cpp 'QPOP queue'
cpp 'QPOP queue'
cpp 'QPOP queue'
cpp 'QPRINT queue'

echo
echo "========== C++: FULL BINARY TREE =========="
cpp 'TFULL empty_tree'
cpp 'TINSERT tree 8'
cpp 'TINSERT tree 4'
cpp 'TINSERT tree 12'
cpp 'TINSERT tree 2'
cpp 'TINSERT tree 6'
cpp 'TINSERT tree 10'
cpp 'TINSERT tree 14'
cpp 'TFIND tree 10'
cpp 'TFIND tree 99'
cpp 'TPRINT tree'
cpp 'TFULL tree'
cpp 'TINSERT tree 8'
cpp 'TFULL tree'
cpp 'TINSERT duplicates 7'
cpp 'TINSERT duplicates 7'
cpp 'TFIND duplicates 7'
cpp 'TPRINT duplicates'

echo
echo "========== GO: ARRAY =========="
golang 'MPRINT go_arr'
golang 'MPUSH go_arr alpha'
golang 'MPUSH go_arr beta'
golang 'MINSERT go_arr 1 middle'
golang 'MGET go_arr 1'
golang 'MSET go_arr 1 changed'
golang 'MLEN go_arr'
golang 'MDEL go_arr 1'
golang 'PRINT go_arr'

echo
echo "========== GO: SINGLY LINKED LIST =========="
golang 'FPRINT go_flist'
golang 'FPUSHH go_flist a'
golang 'FPUSHT go_flist c'
golang 'FPUSHA go_flist a b'
golang 'FPUSHB go_flist c d'
golang 'FFIND go_flist b'
golang 'FPRINTR go_flist'
golang 'FDELA go_flist a'
golang 'FDELB go_flist c'
golang 'FDEL go_flist c'
golang 'FDELH go_flist'
golang 'FDELT go_flist'
golang 'FPRINT go_flist'

echo
echo "========== GO: DOUBLY LINKED LIST =========="
golang 'LPRINT go_dlist'
golang 'LPUSHH go_dlist a'
golang 'LPUSHT go_dlist c'
golang 'LPUSHA go_dlist a b'
golang 'LPUSHB go_dlist c d'
golang 'LFIND go_dlist b'
golang 'LPRINTR go_dlist'
golang 'LDELA go_dlist a'
golang 'LDELB go_dlist c'
golang 'LDEL go_dlist c'
golang 'LDELH go_dlist'
golang 'LDELT go_dlist'
golang 'LPRINT go_dlist'

echo
echo "========== GO: STACK =========="
golang 'SPRINT go_stack'
golang 'SPUSH go_stack first'
golang 'SPUSH go_stack second'
golang 'PRINT go_stack'
golang 'SPOP go_stack'
golang 'SPOP go_stack'
golang 'SPOP go_stack'
golang 'SPRINT go_stack'

echo
echo "========== GO: QUEUE =========="
golang 'QPRINT go_queue'
golang 'QPUSH go_queue first'
golang 'QPUSH go_queue second'
golang 'PRINT go_queue'
golang 'QPOP go_queue'
golang 'QPOP go_queue'
golang 'QPOP go_queue'
golang 'QPRINT go_queue'

echo
echo "========== SHARED JSON =========="
golang 'MPUSH arr from_go'
cpp 'MPRINT arr'
cpp 'MPUSH go_arr from_cpp'
golang 'MPRINT go_arr'

echo
echo "Все команды вызваны. Проверь вывод выше: поиск должен выдавать TRUE/FALSE,"
echo "стек — извлекать последний добавленный элемент, очередь — первый."
