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
