#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>
#include "ast.h"
#include "converter.h"
using namespace std;

extern int yyparse();
extern FILE *yyin;
extern void yyerror(const char *s);
extern ASTNode* root; 

ASTManager astManager;

void yyerror(const char *s) {
	cout << "Parse error!  Message: " << s << endl;
	exit(-1);
}

int main(int argc, char *argv[]) {
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

	converter C;
	astManager.print(root, 1);
	string s = C.traversal(root);
	C.printMarkdown(s, argv[2]);

	fclose(yyin);
	return 0;
}
