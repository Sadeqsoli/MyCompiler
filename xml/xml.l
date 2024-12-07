%{

#include "xml.tab.h" // Include the Bison-generated h
#include <stdbool.h>

int yyerror();

int lines_number = 0;
%}

letter					[A-Za-z ]
digit					[0-9 ]
symbol                  [.,;:!?()@/]


%%
[ \t]+          {}
[0-9]*                         {return NUMBER;}
({letter}|{digit}|{symbol})*   {return TEXT;}
"<contact>"    { return MYTAG; }
"</contact>"   { return ENDMYTAG; }
"<name>"  { return AWESOME; }
"</name>" { return END_AWESOME; }
"<phone>"  { return PHONE; }
"</phone>" { return END_PHONE; }
"<email>"  { return EMAIL; }
"</email>" { return END_EMAIL; }
"<address>"  { return ADDRESS; }
"</address>" { return END_ADDRESS; }
"<street>"  { return STREET; }
"</street>" { return END_STREET; }
"<city>"  { return CITY; }
"</city>" { return END_CITY; }
"<state>"  { return STATE; }
"</state>" { return END_STATE; }
"<zip>"  { return ZIP; }
"</zip>" { return END_ZIP; }
"<socialMedia>"  { return SOCIALMEDIA; }
"</socialMedia>" { return END_SOCIALMEDIA; }
"<socialMediaAccount>"  { return SOCIALMEDIAACOUNT; }
"</socialMediaAccount>" { return END_SOCIALMEDIAACOUNT; }
"<platform>"  { return PLATFORM; }
"</platform>" { return END_PLATFORM; }
"<profileLink>"  { return PROFILELINK; }
"</profileLink>" { return END_PROFILELINK; }
"\n"         lines_number++;
.            {yyerror();}
%%

int yyerror()
{
    printf("# error on line %d!\n", ++lines_number);
    exit(1);
}

int yywrap() 
{
    printf("# correct!\n");
    exit(1);

}