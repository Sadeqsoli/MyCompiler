@echo off

REM Compile the Flex program
flex -o wnr.yy.c wnr.l
if %errorlevel% neq 0 (
    echo Error: Failed to compile Flex file.
    exit /b %errorlevel%
)

echo Flex file compiled successfully.

REM Compile the generated C file
gcc -o wnr wnr.yy.c 
if %errorlevel% neq 0 (
    echo Error: Failed to compile C file.
    exit /b %errorlevel%
)

echo C file compiled successfully.

REM Run the program
if "%1"=="" (
    echo Usage: %~nx0 ^<filename^>
    exit /b 1
)

wnr t.txt
if %errorlevel% neq 0 (
    echo Error: Execution failed.
    exit /b %errorlevel%
)

echo Execution completed successfully.
