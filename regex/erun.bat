win_bison -d -o parser.tab.c parser.y
win_flex -o lex.yy.c lexer.l
gcc -o regex parser.tab.c lex.yy.c
regex "(a|b)*c"
regex "(a|b)*cc*"
