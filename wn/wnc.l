/* just like Unix wc */
%{
int chars = 0;
int words = 0;
int lines = 0;
int numbers = 0;
FILE *yyin;
%}

%%

[0-9]+    {words++; chars += strlen(yytext); numbers++;}
[a-zA-Z]+ {words++; chars += strlen(yytext);}
\n        {chars++; lines++;}
.         {chars++;}

%%

#include <stdio.h>
int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("bad parameters");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("unable to open file!");
        return 1;
    }
    yylex();
    printf("lines:%4d words:%4d chars:%4d numbers:%4d\n", lines, words, chars, numbers);
    fclose(yyin);
    return 0;
}