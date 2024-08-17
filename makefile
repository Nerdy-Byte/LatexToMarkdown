compiler: main.cpp lex.yy.c parser.tab.c converter.cpp
	@g++ -std=c++11 main.cpp lex.yy.c parser.tab.c ast.cpp converter.cpp -o compiler
parser.tab.c parser.tab.h: ast.cpp parser.y
	@bison -dv parser.y
lex.yy.c: lex.l parser.tab.h
	@flex lex.l
clean:
	@rm -f compiler parser.tab.c parser.tab.h lex.yy.c out.md *.o ast.txt