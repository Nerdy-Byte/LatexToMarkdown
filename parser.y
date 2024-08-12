%{
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <cstdlib>
#include "ast.h" 
#include "parser.tab.h"

using namespace std;

extern int yylex();
extern void yyerror(const char*);
extern FILE *yyin;
extern ASTNode* root;
%}

%union {
    std::string* svalue;
    ASTNode* node;
}

%start start 

%token <svalue> STRING CODE FIGURE_PATH FIGURE_SPECS HEADING MATH_STRING FIG_ARGS
%token TITLE DATE START_VERBATIM END_VERBATIM END_CURLY BEGIN_DOCUMENT END_DOCUMENT ITEM BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE SECTION SUBSECTION SUBSUBSECTION ENDL T_BF T_IT T_U BEGIN_TABULAR END_TABULAR
%token TABLE_ARGS HLINE AMPERSAND DSLASH BEGIN_FIGURE BEGIN_SQUARE END_FIGURE END_SQUARE INCLUDE_GRAPHICS CAPTION COMMA
%token BEGIN_CURLY PAR LABEL_TAG REF_TAG HRULE

%type <node> start title date begin_document content list ul ol items verbatim section subsection subsubsection bold 
%type <node> italic figure par text hrule

%%

start: title date begin_document {
    root = astManager.newNode(DOCUMENT_H);
    root->addChild($1);
    root->addChild($2);
    root->addChild($3);
};

title: TITLE STRING END_CURLY {
    $$ = astManager.newNode(TITLE_H);
    $$->data = *$2;
    delete $2;
};

date: DATE STRING END_CURLY {
    $$ = astManager.newNode(DATE_H);
    $$->data = *$2;
    delete $2;
};

begin_document: BEGIN_DOCUMENT content END_DOCUMENT {
    $$ = astManager.newNode(DOCUMENT_H);
    $$->addChild($2);
};

content:
    verbatim
  | list
  | section
  | subsection
  | subsubsection
  | bold
  | italic
  | par
  | figure
  | hrule
  | content list {
    $$ = $1;
    $$->addChild($2);
  }
  | content section {
    $$ = $1;
    $$->addChild($2);
  }
  | content subsection {
    $$ = $1;
    $$->addChild($2);
  }
  | content subsubsection {
    $$ = $1;
    $$->addChild($2);
  }
  | content bold {
    $$ = $1;
    $$->addChild($2);
  }
  | content italic {
    $$ = $1;
    $$->addChild($2);
  }
  | content figure {
    $$ = $1;
    $$->addChild($2);
  }
  | content par {
    $$ = $1;
    $$->addChild($2);
  }
  | content hrule {
    $$ = $1;
    $$->addChild($2);
  }
  | /* empty */ {
    $$ = astManager.newNode(DOCUMENT_H);
  };

list: ul { $$ = $1; }
    | ol { $$ = $1; };

ul: BEGIN_ITEMIZE items END_ITEMIZE {
    $$ = astManager.newNode(ITEMIZE_H);
    $$->addChild($2);
};

ol: BEGIN_ENUMERATE items END_ENUMERATE {
    $$ = astManager.newNode(ENUMERATE_H);
    $$->addChild($2);
};

items: items ITEM STRING {
            $$ = $1;
            ASTNode* itemNode = astManager.newNode(ITEM_H);
            itemNode->data = *$3;
            $$->addChild(itemNode);
            delete $3;
        }
    | ITEM STRING {
            $$ = astManager.newNode(ITEM_H);
            $$->data = *$2;
            delete $2;
        };

section: SECTION BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(SECTION_H);
    $$->data = *$3;
    delete $3;
};

hrule: HRULE {
    $$ = astManager.newNode(HRULE_H);
};

subsection: SUBSECTION BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(SUBSECTION_H);
    $$->data = *$3;
    delete $3;
};

subsubsection: SUBSUBSECTION BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(SUBSUBSECTION_H);
    $$->data = *$3;
    delete $3;
};

verbatim: START_VERBATIM CODE END_VERBATIM {
    $$ = astManager.newNode(VERBATIM_H);
    $$->data = *$2;
    delete $2;
};

bold: T_BF BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(TEXTBF_H);
    $$->data = *$3;
    delete $3;
};

italic: T_IT BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(TEXTIT_H);
    $$->data = *$3;
    delete $3;
};

figure: INCLUDE_GRAPHICS BEGIN_SQUARE FIG_ARGS END_SQUARE BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(FIGURE_H);
    $$->data = *$6;
    delete $6;
};

par: text PAR text {
    $$ = astManager.newNode(PAR_H);
    $$->data = $1->data + "\n\n" + $3->data;
    delete $1;
    delete $3;
};


text: text STRING {
    $$ = $1;
    $$->data += " " + *$2;
    delete $2;
}
| STRING {
    $$ = astManager.newNode(STRING_H);
    $$->data = *$1;
    delete $1;
};


%%

