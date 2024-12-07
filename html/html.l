%{
#include "html.tab.h" // Include the Bison-generated header
#include <stdbool.h>
#include <string.h>

int yyerror();

int lines_number = 0;
%}

letter                   [A-Za-z ]
digit                    [0-9 ]
symbol                   [.,;:!?()@/]

%%

[ \t]+                   {}
[0-9]+                   { return NUMBER; }
({letter}|{digit}|{symbol})+ { yylval.str = strdup(yytext); return TEXT; }
"<html>"                 { return HTML; }
"</html>"                { return END_HTML; }
"<head>"                 { return HEAD; }
"</head>"                { return END_HEAD; }
"<title>"                { return TITLE; }
"</title>"               { return END_TITLE; }
"<body>"                 { return BODY; }
"</body>"                { return END_BODY; }
"<h1>"                   { return H1; }
"</h1>"                  { return END_H1; }
"<p>"                    { return P; }
"</p>"                   { return END_P; }
"<div>"                  { return DIV; }
"</div>"                 { return END_DIV; }
"<span>"                 { return SPAN; }
"</span>"                { return END_SPAN; }
"<ul>"                   { return UL; }
"</ul>"                  { return END_UL; }
"<li>"                   { return LI; }
"</li>"                  { return END_LI; }
"\n"                     { lines_number++; }
.                        { yyerror(); }

%%

int yyerror()
{
    printf("Error on line %d\n", ++lines_number);
    return 1;
}

int yywrap() 
{
    return 1;
}
