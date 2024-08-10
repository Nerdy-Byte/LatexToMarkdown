%{
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <cstdlib>
#include "parser.tab.h"
using namespace std;

extern int yylex();
extern void yyerror(const char*);
extern FILE *yyin;

%}

%union {
    std::string* svalue;
}

%start start 

%token <svalue> STRING CODE
%token TITLE DATE START_VERBATIM END_VERBATIM END_CURLY BEGIN_DOCUMENT END_DOCUMENT ITEM BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE

%%

start: preamble title date begin_document;

preamble: /* empty */;

title: TITLE STRING END_CURLY {
    cout << "*" << *$2 << "*" << endl;
    delete $2;
};

date: DATE STRING END_CURLY {
    cout << "***Date:*** " << *$2 << endl;
    delete $2;
};

begin_document: BEGIN_DOCUMENT content END_DOCUMENT;

content: 
    verbatim
  | list
  | content list
  | /* empty */;

list: ul
    | ol;

ul: BEGIN_ITEMIZE items END_ITEMIZE;

ol: BEGIN_ENUMERATE items END_ENUMERATE;

items: items ITEM STRING {
            cout << "* " << *$3 << endl;
            delete $3;
        }
    | ITEM STRING {
            cout << "* " << *$2 << endl;
            delete $2;
        };

verbatim: START_VERBATIM CODE END_VERBATIM {
    cout << "'''python\n" << *$2 << "\n''' " << endl;
    delete $2;
};

%%

void yyerror(const char* s) {
    cerr << "Error: " << s << endl;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        cout << "Error in entering arguments. Correct Format: ./compiler <input.tex>" << endl;
        return -1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        cout << "Error opening file: " << argv[1] << endl;
        return -1;
    }

    yyparse();

    fclose(yyin);
    return 0;
}
