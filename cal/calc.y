%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int yylex();
int yyerror(const char *s);
%}

/* Declare the semantic value type */
%union {
    double dval;
}

/* Specify token and type declarations */
%token <dval> NUMBER
%token SIN COS TAN ABS POW
%type <dval> expr

%left '+' '-'
%left '*' '/'
%left UMINUS
%right '^'

%%

program:
    program expr '\n'   { printf("Result: %f\n", $2); }
  | expr '\n'           { printf("Result: %f\n", $1); }
  | /* empty */
  ;

expr:
    NUMBER                 { $$ = $1; }
  | expr '+' expr         { $$ = $1 + $3; }
  | expr '-' expr         { $$ = $1 - $3; }
  | expr '*' expr         { $$ = $1 * $3; }
  | expr '/' expr         { if ($3 == 0) { yyerror("division by zero"); $$ = 0; } else { $$ = $1 / $3; } }
  | expr '^' expr         { $$ = pow($1, $3); }
  | '-' expr %prec UMINUS { $$ = -$2; }
  | '(' expr ')'          { $$ = $2; }
  | SIN '(' expr ')'      { $$ = sin($3); }
  | COS '(' expr ')'      { $$ = cos($3); }
  | TAN '(' expr ')'      { $$ = tan($3); }
  | ABS '(' expr ')'      { $$ = fabs($3); }
  | POW '(' expr ',' expr ')' { $$ = pow($3, $5); }
  ;

%%
int main() {
    printf("Enter expressions (Ctrl+C to exit):\n");
    yyparse();
    return 0;
}
int yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}
