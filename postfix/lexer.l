%{
#include <stdio.h>
#include "parser.tab.h"
%}

%%

[0-9]+      { yylval = atoi(yytext); return NUMBER; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
\n          { return EOL; }
[ \t]       ; /* Ignore whitespace */
.           { printf("Invalid character: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}
