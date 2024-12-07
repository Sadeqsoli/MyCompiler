bison -d -o html.tab.c html.y
flex -o html.yy.c html.l
gcc -o html_validator html.tab.c html.yy.c -lfl
./xml_run i.xml
