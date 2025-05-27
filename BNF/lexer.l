/* regex2bnf.l – Flex scanner                                         */
/* Build: win_flex -o regex2bnf_lex.c regex2bnf.l                     */

%{
#include "parser.tab.h"
#include <string.h>

/* strdup portability */
#ifdef _WIN32
  #ifdef _MSC_VER
    #define strdup _strdup
  #endif
#endif
%}

%%

[a-zA-Z0-9]    { yylval.str = strdup(yytext); return CHARACTER; }

"|"            { return OR;       }
"*"            { return STAR;     }
"+"            { return PLUS;     }
"?"            { return QUESTION; }
"."            { return DOT;      }
"("            { return LPAREN;   }
")"            { return RPAREN;   }
"\n"           { return NEWLINE;  }

[ \t\r]+       { /* skip whitespace & CR */ }
.              { /* ignore everything else */ }

%%

int yywrap(void) { return 1; }
