%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern FILE *yyin;

#include "xml.tab.h"
extern int yylex(void);
extern void yyterminate();
void yyerror(const char *s);
%}


%token TEXT NUMBER
%token MYTAG AWESOME ENDMYTAG END_AWESOME PHONE END_PHONE EMAIL END_EMAIL ADDRESS END_ADDRESS SOCIALMEDIA END_SOCIALMEDIA
%token STREET END_STREET CITY END_CITY STATE END_STATE ZIP END_ZIP 
%token SOCIALMEDIAACOUNT END_SOCIALMEDIAACOUNT PLATFORM END_PLATFORM PROFILELINK END_PROFILELINK

%%

statement:

    entry statement
    |   ;


entry:
    MYTAG assTag ENDMYTAG;

assTag:
    AWESOME TEXT END_AWESOME 
    PHONE NUMBER END_PHONE
    EMAIL TEXT END_EMAIL
    ADDRESS addTag END_ADDRESS
    SOCIALMEDIA solTag END_SOCIALMEDIA;

addTag:
    STREET TEXT END_STREET
    CITY TEXT END_CITY
    STATE TEXT END_STATE
    ZIP NUMBER END_ZIP ;

solTag: 
      solTag SOCIALMEDIAACOUNT acoTag END_SOCIALMEDIAACOUNT
    |  ;


acoTag:
    PLATFORM TEXT END_PLATFORM
    PROFILELINK TEXT END_PROFILELINK
%%
int main(int argc, char *argv[])
{
	printf("\n# check file %s\n", argv[1]);
	yyin = fopen(argv[1], "r");
	yyparse();
}