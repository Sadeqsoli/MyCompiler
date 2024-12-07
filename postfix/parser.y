%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

#define MAX_STACK 100
double stack[MAX_STACK];
int top = -1;

void push(double value) {
    if (top == MAX_STACK - 1) {
        printf("Stack overflow!\n");
        exit(1);
    }
    stack[++top] = value;
}

double pop() {
    if (top < 0) {
        printf("Stack underflow!\n");
        exit(1);
    }
    return stack[top--];
}

#define MAX_EXPR 100
char postfix[MAX_EXPR][20];
int postfix_index = 0;

void add_to_postfix(const char *token) {
    strcpy(postfix[postfix_index++], token);
}

double evaluate_postfix() {
    top = -1;
    for (int i = 0; i < postfix_index; i++) {
        if (strcmp(postfix[i], "+") == 0) {
            double b = pop();
            double a = pop();
            push(a + b);
        } else if (strcmp(postfix[i], "-") == 0) {
            double b = pop();
            double a = pop();
            push(a - b);
        } else if (strcmp(postfix[i], "*") == 0) {
            double b = pop();
            double a = pop();
            push(a * b);
        } else if (strcmp(postfix[i], "/") == 0) {
            double b = pop();
            double a = pop();
            if (b == 0) {
                printf("Error: Division by zero!\n");
                exit(1);
            }
            push(a / b);
        } else if (strcmp(postfix[i], "neg") == 0) {
            double a = pop();
            push(-a);
        } else {
            push(atof(postfix[i]));
        }
    }
    return pop();
}
%}

%token NUMBER
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN EOL
%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS

%%

input
    : /* empty */
    | input line
    ;

line
    : EOL
    | expr EOL {
        printf("\nPF expression: ");
        for (int i = 0; i < postfix_index; i++) {
            printf("%s ", postfix[i]);
        }
        printf("\nResult = %.2f\n", evaluate_postfix());
        postfix_index = 0; 
        printf("\nEnter an expression (or Ctrl+C to exit):\n");
    }
    ;

expr
    : term
    | expr PLUS term { add_to_postfix("+"); }
    | expr MINUS term { add_to_postfix("-"); }
    | MINUS term %prec UMINUS { add_to_postfix("neg"); }
    ;

term
    : factor
    | term TIMES factor { add_to_postfix("*"); }
    | term DIVIDE factor { add_to_postfix("/"); }
    ;

factor
    : NUMBER {
        char num_str[20];
        sprintf(num_str, "%d", $1);
        add_to_postfix(num_str);
    }
    | LPAREN expr RPAREN
    | MINUS NUMBER %prec UMINUS {
        char num_str[20];
        sprintf(num_str, "%d", -$2);
        add_to_postfix(num_str);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(void) {
    printf("Enter an expression (example: (6-9))*(12/5)):\n");
    yyparse();
    return 0;
}
