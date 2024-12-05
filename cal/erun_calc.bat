win_bison -d -o calc.tab.c calc.y
win_flex -o lex.yy.c calc.l
gcc -o calc calc.tab.c lex.yy.c 
calc 
