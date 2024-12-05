%{
#include <stdio.h>
#include <stdlib.h>
#include "calc.tab.h"
%}

%%

[0-9]+\.?[0-9]*    { yylval.dval = atof(yytext); return NUMBER; }
[ \t]+              ; /* Ignore whitespace */
\n                  { return '\n'; }
\+                  { return '+'; }
\-                  { return '-'; }
\*                  { return '*'; }
\/                  { return '/'; }
\^                  { return '^'; }
\(                  { return '('; }
\)                  { return ')'; }
sin                 { return SIN; }
cos                 { return COS; }
tan                 { return TAN; }
abs                 { return ABS; }
pow                 { return POW; }
.                    { return yytext[0]; }

%%

/* Prevent multiple definitions of yywrap by using `#ifndef` */
#ifndef YYWRAP
int yywrap() {
    return 1;
}
#endif
