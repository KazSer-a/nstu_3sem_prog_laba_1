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
    local output="$1"
    local expected="$2"
    if [[ "$output" != *"$expected"* ]]; then
        echo "Ошибка: ожидалось '$expected', получено '$output'"
        exit 1
    fi
}

check "$(run_cpp 'TFULL empty')" '-> TRUE'
run_cpp 'TINSERT single 5' >/dev/null
check "$(run_cpp 'TFULL single')" '-> TRUE'

run_cpp 'MPUSH arr 10' >/dev/null
run_cpp 'MINSERT arr 0 5' >/dev/null
check "$(run_cpp 'MGET arr 1')" '-> 10'
check "$(run_cpp 'MLEN arr')" '-> 2'

run_cpp 'FPUSHH flist a' >/dev/null
run_cpp 'FPUSHT flist c' >/dev/null
run_cpp 'FPUSHA flist a b' >/dev/null
check "$(run_cpp 'FPRINT flist')" 'a -> b -> c'

run_cpp 'LPUSHH dlist a' >/dev/null
run_cpp 'LPUSHT dlist c' >/dev/null
run_cpp 'LPUSHA dlist a b' >/dev/null
check "$(run_cpp 'LPRINTR dlist')" 'c <-> b <-> a'

run_cpp 'LPUSHT test_dlist_cpp c' >/dev/null
run_cpp 'LPUSHH test_dlist_cpp a' >/dev/null
run_cpp 'LPUSHA test_dlist_cpp a b' >/dev/null
run_cpp 'LPUSHB test_dlist_cpp c d' >/dev/null
run_cpp 'LDELA test_dlist_cpp a' >/dev/null
check "$(run_cpp 'LPRINT test_dlist_cpp')" 'a <-> d <-> c'
run_cpp 'LDELB test_dlist_cpp c' >/dev/null
check "$(run_cpp 'LPRINT test_dlist_cpp')" 'a <-> c'
run_cpp 'LDEL test_dlist_cpp c' >/dev/null
check "$(run_cpp 'LPRINT test_dlist_cpp')" 'a <-> nullptr'
check "$(run_cpp 'LDELA test_dlist_cpp missing')" 'нет такого элемента'
check "$(run_cpp 'LDELA test_dlist_cpp a')" 'нет следующего элемента'

run_cpp 'FPUSHH test_flist_cpp a' >/dev/null
check "$(run_cpp 'FDELB test_flist_cpp missing')" 'нет такого элемента'
check "$(run_cpp 'FDELH empty_flist_cpp')" 'список пуст'
check "$(run_cpp 'FDELT empty_flist_cpp')" 'список пуст'

run_go 'LPUSHH test_dlist_go a' >/dev/null
run_go 'LPUSHT test_dlist_go c' >/dev/null
run_go 'LPUSHA test_dlist_go a b' >/dev/null
run_go 'LPUSHB test_dlist_go c d' >/dev/null
run_go 'LDELA test_dlist_go a' >/dev/null
check "$(run_go 'LPRINT test_dlist_go')" 'a <-> d <-> c'
run_go 'LDELB test_dlist_go c' >/dev/null
check "$(run_go 'LPRINT test_dlist_go')" 'a <-> c'
check "$(run_go 'LDELA test_dlist_go missing')" 'нет такого элемента'
check "$(run_go 'LDELB test_dlist_go a')" 'нет предыдущего элемента'

run_go 'FPUSHH test_flist_go a' >/dev/null
check "$(run_go 'FDELA test_flist_go missing')" 'нет такого элемента'
check "$(run_go 'FDELB test_flist_go missing')" 'нет такого элемента'
check "$(run_go 'FDELH empty_flist_go')" 'список пуст'
check "$(run_go 'FDELT empty_flist_go')" 'список пуст'

run_cpp 'SPUSH stack first' >/dev/null
run_cpp 'SPUSH stack second' >/dev/null
check "$(run_cpp 'SPOP stack')" '-> second'

run_cpp 'QPUSH queue first' >/dev/null
run_cpp 'QPUSH queue second' >/dev/null
check "$(run_cpp 'QPOP queue')" '-> first'

for value in 8 4 12 2 6 10 14; do
    run_cpp "TINSERT tree $value" >/dev/null
done
check "$(run_cpp 'TFULL tree')" '-> TRUE'
run_cpp 'TINSERT tree 8' >/dev/null
check "$(run_cpp 'TFULL tree')" '-> FALSE'
check "$(run_cpp 'TFIND tree 8')" '-> TRUE'

run_go 'MPUSH arr 20' >/dev/null
check "$(run_cpp 'MGET arr 2')" '-> 20'
check "$(run_go 'QPUSH queue third')" '-> third'
check "$(run_cpp 'TFIND tree 14')" '-> TRUE'

printf 'Все проверки пройдены.\n'
