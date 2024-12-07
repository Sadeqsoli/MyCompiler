win_bison -d -o xml.tab.c xml.y
win_flex -o xml.yy.c xml.l
gcc -o xml_validator xml.tab.c xml.yy.c
xml_validator i.xml
