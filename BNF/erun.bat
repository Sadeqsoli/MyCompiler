win_bison -d -o parser.tab.c parser.y
win_flex -o lex.yy.c lexer.l
gcc -o reg_ex parser.tab.c lex.yy.c 
reg_ex 
