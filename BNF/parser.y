/* regex2bnf.y – Bison grammar
 * Build (MSVC) :  win_bison -d regex2bnf.y
 *                win_flex  -o regex2bnf_lex.c regex2bnf.l
 *                cl /EHsc regex2bnf.tab.c regex2bnf_lex.c /link user32.lib
 *
 * Build (MinGW):  win_bison -d regex2bnf.y
 *                win_flex  -o regex2bnf_lex.c regex2bnf.l
 *                gcc -std=c11 -Wall -Wextra regex2bnf.tab.c regex2bnf_lex.c -o regex2bnf.exe
 */

%defines
%{

/* ── standard headers ─────────────────────────────────────────────── */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ── cross-platform helpers ───────────────────────────────────────── */
#ifdef _WIN32                              /* Windows */
  #include <windows.h>

  /* usleep → Sleep(ms) */
  #define usleep(us) Sleep((DWORD)((us)/1000))

  /* strdup → _strdup on MSVC; MinGW already has strdup                */
  #ifdef _MSC_VER
    #define strdup _strdup
  #endif

  /* enable ANSI colours (not mandatory for grammar printing)          */
  static void enable_ansicolour(void)
  {
      HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
      if (h == INVALID_HANDLE_VALUE) return;
      DWORD m = 0;
      if (!GetConsoleMode(h, &m)) return;
      m |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
      SetConsoleMode(h, m);
      SetConsoleOutputCP(CP_UTF8);
  }
#else                                      /* POSIX / Linux / macOS */
  #include <unistd.h>
  static void enable_ansicolour(void) { /* already works */ }
#endif

/* ── forward decls ────────────────────────────────────────────────── */
int  yylex(void);
void yyerror(const char *s);

/* ── small helpers ────────────────────────────────────────────────── */
static int   rule_id = 0;     /* <X0>, <X1>, … */
static FILE *out   = NULL;    /* grammar.bnf   */

/* Print one grammar rule in the desired style:  A -> B | C | lambda  */
static void add_rule(const char *lhs, const char *rhs)
{
    printf("%s -> %s\n", lhs, rhs);
    if (out) fprintf(out, "%s -> %s\n", lhs, rhs);
}

/* fresh non-terminal name */
static char *new_nt(void)
{
    char *buf = (char *)malloc(16);
    sprintf(buf, "<X%d>", rule_id++);
    return buf;
}
%}

/* ── Bison declarations ───────────────────────────────────────────── */
%union { char *str; }

%token  <str> CHARACTER
%token  OR STAR PLUS QUESTION LPAREN RPAREN DOT NEWLINE

%type   <str> input expr term factor base
%start  input
%%

/* ── grammar ──────────────────────────────────────────────────────── */
input:
      expr NEWLINE
      {
          char *final_nt = new_nt();          /* wrap whole expr     */
          add_rule(final_nt, $1);
          add_rule("<S>",   final_nt);        /* start symbol        */
          exit(EXIT_SUCCESS);
      }
;

expr:
      expr OR term
      {
          char *nt  = new_nt();
          size_t sz = strlen($1) + strlen($3) + 4;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "%s | %s", $1, $3);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | term
;

term:
      term factor
      {
          char *nt  = new_nt();
          size_t sz = strlen($1) + strlen($2) + 2;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "%s %s", $1, $2);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | factor
;

factor:
      base STAR
      {
          char *nt  = new_nt();
          size_t sz = strlen($1)*2 + 16;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "%s %s | lambda", $1, nt);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | base PLUS
      {
          char *nt  = new_nt();
          size_t sz = strlen($1)*2 + 16;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "%s %s | %s", $1, nt, $1);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | base QUESTION
      {
          char *nt  = new_nt();
          size_t sz = strlen($1) + 16;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "%s | lambda", $1);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | base
;

base:
      CHARACTER
      {
          char *nt  = new_nt();
          size_t sz = strlen($1) + 8;
          char *rhs = (char *)malloc(sz);
          sprintf(rhs, "\"%s\"", $1);
          add_rule(nt, rhs);
          $$ = nt;
      }
    | DOT
      {
          char *nt = new_nt();
          add_rule(nt, "\"a\" | \"b\" | \"c\" | …");
          $$ = nt;
      }
    | LPAREN expr RPAREN   { $$ = $2; }
;

%%  /* ── user code ─────────────────────────────────────────────────── */

void yyerror(const char *s) { fprintf(stderr, "parser error: %s\n", s); }

static void type_effect(const char *t)
{
    while (*t) { putchar(*t++); fflush(stdout); usleep(50000); }
    putchar('\n');
}

int main(void)
{
    enable_ansicolour();
    out = fopen("grammar.bnf", "w");
    if (!out) { perror("grammar.bnf"); return EXIT_FAILURE; }

    printf("Enter the regular expression and press Enter:\n");
    yyparse();

    fclose(out);
    return 0;
}
