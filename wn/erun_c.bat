flex -o wnc.yy.c wnc.l
gcc -o wnc wnc.yy.c 
wnc t.txt