win_bison -d -o parser.tab.c parser.y
win_flex -o lex.yy.c lexer.l
gcc -o regular_ex parser.tab.c lex.yy.c
regular_ex "(a|b)*cc*"
