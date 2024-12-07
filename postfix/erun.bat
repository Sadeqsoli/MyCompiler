win_bison -d -o parser.tab.c parser.y
win_flex -o lex.yy.c lexer.l
gcc parser.tab.c lex.yy.c -o postfixParser 
postfixParser
