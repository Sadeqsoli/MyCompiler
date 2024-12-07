%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
%}

%union {
    char *str;
}

%token <str> TEXT
%token HTML END_HTML HEAD END_HEAD TITLE END_TITLE BODY END_BODY H1 END_H1 P END_P
%token DIV END_DIV SPAN END_SPAN UL END_UL LI END_LI

%%

document:
    HTML content END_HTML { printf("Valid HTML document\n"); }
    ;

content:
    HEAD head_content END_HEAD BODY body_content END_BODY
    ;

head_content:
    TITLE TEXT END_TITLE
    | /* empty */
    ;

body_content:
    element body_content
    | /* empty */
    ;

element:
    H1 TEXT END_H1
    | P TEXT END_P
    | DIV content END_DIV
    | SPAN TEXT END_SPAN
    | UL list_content END_UL
    ;

list_content:
    LI TEXT END_LI list_content
    | /* empty */
    ;

%%

int main(int argc, char **argv)
{
    if (argc != 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening file");
        return 1;
    }

    yyin = input;
    yyparse();
    fclose(input);
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "Error: %s\n", s);
}
