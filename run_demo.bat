@echo off
setlocal

set "DB_FILE=%~dp0data_demo.json"
> "%DB_FILE%" echo {}

"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 8" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 4" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 12" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 2" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 6" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 10" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 14" || exit /b 1

echo.
echo Проверка исходного дерева:
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TFULL demo_tree" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TPRINT demo_tree" || exit /b 1

echo.
echo Поиск узла 6:
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TFIND demo_tree 6" || exit /b 1

echo.
echo Добавление дубликата 10:
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TINSERT demo_tree 10" || exit /b 1
"%~dp0dbms.exe" --file "%DB_FILE%" --query "TFULL demo_tree" || exit /b 1

echo.
echo Файл демонстрационных данных: %DB_FILE%
endlocal
