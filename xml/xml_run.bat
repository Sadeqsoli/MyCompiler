@echo off

REM Compile Bison file
win_bison -d -o xml.tab.c xml.y
if %errorlevel% neq 0 (
    echo Error: Failed to compile Bison file.
    exit /b %errorlevel%
)

echo Bison file compiled successfully.

REM Compile Flex file
win_flex -o xml.yy.c xml.l
if %errorlevel% neq 0 (
    echo Error: Failed to compile Flex file.
    exit /b %errorlevel%
)

echo Flex file compiled successfully.

REM Compile C files
gcc -o xml_validator xml.tab.c xml.yy.c
if %errorlevel% neq 0 (
    echo Error: Failed to compile C files.
    exit /b %errorlevel%
)

echo XML validator compiled successfully.

REM Run the XML validator
if "%1"=="" (
    echo Usage: %~nx0 ^<filename^>
    exit /b 1
)

xml_validator i.xml
if %errorlevel% neq 0 (
    echo Error: Validation failed.
    exit /b %errorlevel%
)


echo Validation completed successfully.
xml_validator i.xml