#include <iostream>
#include <string>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

extern int yyparse();
extern FILE *yyin;
extern void yyerror(const char *s);

void yyerror(const char *s) {
    cout << s << endl;
    exit(1);
}

int main(int argc, char** argv) {
    if (argc < 2) {
		cout << "Error in entering arguments. Correct Format: /compiler <input.tex> <output.md>" << endl;
		return -1;
	}

	yyin = fopen(argv[1], "r");
	if (!yyin) {
		cout << "Error opening file: " << argv[1] << endl;
		return -1;
	}

    do {
		yyparse();
	} while (!feof(yyin));

    fclose(yyin);
    return 0;

}