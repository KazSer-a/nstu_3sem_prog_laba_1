#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_FILE="$ROOT_DIR/data_demo.json"

printf '{}\n' > "$DB_FILE"

"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 8"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 4"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 12"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 2"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 6"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 10"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 14"

echo
echo "Проверка исходного дерева:"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TFULL demo_tree"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TPRINT demo_tree"

echo
echo "Поиск узла 6:"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TFIND demo_tree 6"

echo
echo "Добавление дубликата 10:"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TINSERT demo_tree 10"
"$ROOT_DIR/dbms" --file "$DB_FILE" --query "TFULL demo_tree"

echo
echo "Файл демонстрационных данных: $DB_FILE"
