%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

/* ---------- ε-NFA primitives ---------- */
typedef struct State State;   typedef struct Edge  Edge;
struct Edge  { char label; State *to; Edge *next; };
struct State { int  num;   Edge  *edge; int final; State *next; };

static State*all=NULL; static int id_gen=0;
static State*new_state(void){ State*s=calloc(1,sizeof(State)); s->num=id_gen++; s->next=all; all=s; return s; }
static void  add_edge(State*f,State*t,char lbl){ Edge*e=malloc(sizeof(Edge)); e->label=lbl; e->to=t; e->next=f->edge; f->edge=e; }

/* ---------- Thompson fragment ---------- */
typedef struct Frag { State *start,*fin; } Frag;
static Frag  frag_sym(char);
static Frag  frag_union(Frag,Frag);
static Frag  frag_cat (Frag,Frag);
static Frag  frag_star(Frag);

/* ---------- rule table ---------- */
typedef struct Alt  { char *txt; struct Alt *next; } Alt;
typedef struct Rule { char lhs; Alt *a,*z; struct Rule *next; } Rule;
static Rule *rules = NULL;

static Rule*get_rule(char lhs,int mk)
{
    for(Rule*r=rules;r;r=r->next) if(r->lhs==lhs) return r;
    if(!mk) return NULL;
    Rule*r=calloc(1,sizeof(Rule)); r->lhs=lhs; r->next=rules; rules=r; return r;
}
static void add_alt(char lhs,const char*rhs)
{
    Rule*r=get_rule(lhs,1);
    for(Alt*p=r->a;p;p=p->next) if(!strcmp(p->txt,rhs)) return;
    Alt*n=malloc(sizeof(Alt)); n->txt=strdup(rhs); n->next=NULL;
    if(r->z) r->z->next=n; else r->a=n; r->z=n;
}

/* ---------- NFA → grammar (one rule per DFA state) ---------- */
static int nt_cnt=0; static char fresh_nt(void){ return 'A'+nt_cnt++; }

typedef struct Map { State *st; char nt; struct Map *next; } Map;
static Map *mhead=NULL;
static char map_nt(State*s,int mk,State**Q,int*qsz)
{
    for(Map*m=mhead;m;m=m->next) if(m->st==s) return m->nt;
    if(!mk) return 0;
    char nt=(s->num==0?'S':fresh_nt());
    Map*m=malloc(sizeof(Map)); m->st=s; m->nt=nt; m->next=mhead; mhead=m;
    Q[(*qsz)++]=s; return nt;
}
static void nfa_to_grammar(State*start)
{
    State*Q[1024]; int qsz=0;
    map_nt(start,1,Q,&qsz);

    for(int qi=0; qi<qsz; ++qi){
        State*u=Q[qi];  char L = map_nt(u,0,NULL,NULL);
        if(u->final) add_alt(L,"lambda");

        for(Edge*e=u->edge;e;e=e->next){
            char R=map_nt(e->to,1,Q,&qsz);
            if(e->label){
                char rhs2[3]={e->label,R,'\0'}; add_alt(L,rhs2);
                if(e->to->final){ char rhs1[2]={e->label,'\0'}; add_alt(L,rhs1); }
            }else{
                char rhs[2]={R,'\0'}; add_alt(L,rhs);
            }
        }
    }
}

/* ---------- Post-pass 1: eliminate unit productions ---------- */
static void inline_units(void)
{
    bool changed=true;
    while(changed){
        changed=false;
        for(Rule*r=rules;r;r=r->next){
            Alt **pp=&r->a;
            while(*pp){
                Alt *alt=*pp;
                if(strlen(alt->txt)==1 && isupper(alt->txt[0])){ /* unit X->Y */
                    char Y=alt->txt[0];
                    Rule*Ry=get_rule(Y,0);
                    if(Ry){
                        for(Alt*p=Ry->a;p;p=p->next) add_alt(r->lhs,p->txt);
                    }
                    *pp=alt->next; free(alt->txt); free(alt); changed=true;
                    continue;
                }
                pp=&alt->next;
            }
        }
    }
}

/* ---------- Post-pass 2: remove unreachable rules ---------- */
static void drop_unreachable(void)
{
    bool reach[256]={0}; reach['S']=1; bool again=1;
    while(again){
        again=0;
        for(Rule*r=rules;r;r=r->next) if(reach[r->lhs])
            for(Alt*p=r->a;p;p=p->next)
                for(int i=0;i<strlen(p->txt);++i)
                    if(isupper(p->txt[i]) && !reach[(unsigned)p->txt[i]])
                        { reach[(unsigned)p->txt[i]]=1; again=1; }
    }
    Rule**pp=&rules;
    while(*pp){
        if(!reach[(*pp)->lhs]){ Rule*del=*pp; *pp=del->next; }
        else pp=&(*pp)->next;
    }
}

/* ---------- Post-pass 3: rename BFS S,A,B,… ---------- */
static void bfs_rename(void)
{
    char map[256]={0}; map['S']='S'; char next='A';
    char Q[256]; int qh=0,qt=0; Q[qt++]='S';

    while(qh<qt){
        char L=Q[qh++];
        Rule*r=get_rule(L,0); if(!r) continue;
        for(Alt*p=r->a;p;p=p->next)
            for(int i=0;i<strlen(p->txt);++i)
                if(isupper(p->txt[i]) && !map[(unsigned)p->txt[i]]){
                    map[(unsigned)p->txt[i]]=next++; Q[qt++]=p->txt[i];
                }
    }
    for(Rule*r=rules;r;r=r->next){
        r->lhs=map[(unsigned)r->lhs];
        for(Alt*p=r->a;p;p=p->next)
            for(int i=0;i<strlen(p->txt);++i)
                if(isupper(p->txt[i])) p->txt[i]=map[(unsigned)p->txt[i]];
    }
}

/* ---------- Pretty-print: S first, then A,B,… ---------- */
static void print_rules(void)
{
    Rule*r=get_rule('S',0);
    if(r){ printf("S -> %s",r->a->txt); for(Alt*p=r->a->next;p;p=p->next) printf(" | %s",p->txt); puts(""); }
    for(char nt='A';nt<='Z';++nt) if(nt!='S'){
        r=get_rule(nt,0); if(!r) continue;
        printf("%c -> %s",nt,r->a->txt);
        for(Alt*p=r->a->next;p;p=p->next) printf(" | %s",p->txt);
        puts("");
    }
}

/* ---------- Thompson helpers ---------- */
static Frag frag_sym(char c)
{ State*s=new_state(),*f=new_state(); f->final=1; add_edge(s,f,c); return (Frag){s,f}; }
static Frag frag_union(Frag a,Frag b)
{ State*s=new_state(),*f=new_state(); f->final=1;
  add_edge(s,a.start,0); add_edge(s,b.start,0);
  add_edge(a.fin,f,0);   add_edge(b.fin,f,0);
  a.fin->final=b.fin->final=0; return (Frag){s,f}; }
static Frag frag_cat(Frag a,Frag b)
{ add_edge(a.fin,b.start,0); a.fin->final=0; return (Frag){a.start,b.fin}; }
static Frag frag_star(Frag a)
{ State*s=new_state(),*f=new_state(); f->final=1;
  add_edge(s,a.start,0); add_edge(s,f,0);
  add_edge(a.fin,a.start,0); add_edge(a.fin,f,0);
  a.fin->final=0; return (Frag){s,f}; }

/* ---------- Bison glue ---------- */
void yyerror(const char*s){ fprintf(stderr,"error: %s\n",s); }
int yylex(void);
%}

%union { char sym; Frag frag; }

%token <sym> SYMBOL
%token OR STAR LPAREN RPAREN END
%type  <frag> regex term factor base

%%

input   : regex END
          {
              nfa_to_grammar($1.start);
              inline_units();
              drop_unreachable();
              bfs_rename();
              print_rules();
          }
        ;

regex   : regex OR term  { $$ = frag_union($1,$3); }
        | term           { $$ = $1; }
        ;

term    : term factor    { $$ = frag_cat($1,$2); }
        | factor         { $$ = $1; }
        ;

factor  : base STAR      { $$ = frag_star($1); }
        | base           { $$ = $1; }
        ;

base    : SYMBOL         { $$ = frag_sym($1); }
        | LPAREN regex RPAREN { $$ = $2; }
        ;
%%

/* ---------- Flex helper ---------- */
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(const char*);

int main(int argc,char*argv[])
{
    if(argc!=2){ puts("usage: regex \"<re>\""); return 1; }
    char *buf=malloc(strlen(argv[1])+2); sprintf(buf,"%s\n",argv[1]);
    yy_scan_string(buf); yyparse(); free(buf); return 0;
}
