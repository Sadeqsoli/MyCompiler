flex -o wnr.yy.c wnr.l
gcc -o wnr wnr.yy.c 
wnr t.txt