@echo off

REM Compile Bison file
bison -d -o html_parser.tab.c html_parser.y
if %errorlevel% neq 0 (
    echo Error: Failed to compile Bison file.
    exit /b %errorlevel%
)

echo Bison file compiled successfully.

REM Compile Flex file
flex -o html_lexer.c html_lexer.l
if %errorlevel% neq 0 (
    echo Error: Failed to compile Flex file.
    exit /b %errorlevel%
)

echo Flex file compiled successfully.

REM Compile C files
gcc -o html_validator html_parser.tab.c html_lexer.c -lfl
if %errorlevel% neq 0 (
    echo Error: Failed to compile C files.
    exit /b %errorlevel%
)

echo HTML validator compiled successfully.

REM Run the HTML validator
if "%1"=="" (
    echo Usage: %~nx0 ^<filename^>
    exit /b 1
)

html_validator %1
if %errorlevel% neq 0 (
    echo Error: Validation failed.
    exit /b %errorlevel%
)

echo Validation completed successfully.
