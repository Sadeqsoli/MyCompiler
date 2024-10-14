/* Flex program - between words and numbers */
%{
int chars = 0;
int words = 0;
int lines = 0;
int numbers = 0;
FILE *yyin;
%}

%%

[0-9]+    { numbers++; chars += strlen(yytext); printf("numbers: %s\n", yytext); }
[a-zA-Z]+ { words++; chars += strlen(yytext); printf("words: %s\n", yytext); }
\n        { chars++; lines++; }
.         { chars++; }

%%

#include <stdio.h>
int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("bad parameters\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("unable to open file!\n");
        return 1;
    }
    yylex();
    printf("\nSummary:\nlines: %4d\nwords: %4d\nchars: %4d\nnumbers: %4d\n", lines, words, chars, numbers);
    fclose(yyin);
    return 0;
}
