%{
/* Make Frag visible before parser.tab.h is read */
typedef struct State State;
typedef struct Frag  { State *start; State *fin; } Frag;

#include "parser.tab.h"
%}

%%

"|"           return OR;
"*"           return STAR;
"("           return LPAREN;
")"           return RPAREN;
[a-zA-Z0-9]   { yylval.sym = yytext[0]; return SYMBOL; }
[ \t\r]+      /* skip whitespace */
\n            return END;
.             /* ignore everything else */

%%

int yywrap(void) { return 1; }
