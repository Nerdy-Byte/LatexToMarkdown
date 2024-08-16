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

%token <svalue> STRING CODE FIGURE_PATH FIGURE_SPECS HEADING MATH_STRING FIG_ARGS TABLE_ARGS
%token TITLE DATE START_VERBATIM END_VERBATIM END_CURLY BEGIN_DOCUMENT END_DOCUMENT ITEM BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE SECTION SUBSECTION SUBSUBSECTION ENDL T_BF T_IT T_U BEGIN_TABULAR END_TABULAR
%token HLINE AMPERSAND DSLASH BEGIN_FIGURE BEGIN_SQUARE END_FIGURE END_SQUARE INCLUDE_GRAPHICS CAPTION COMMA
%token BEGIN_CURLY PAR LABEL_TAG REF_TAG HRULE HREF
%type <node> start title date begin_document content list ul ol items verbatim section subsection subsubsection bold 
%type <node> italic figure par text hrule tabular row rows cell cells href code content_element

%left PAR  /* Adjust precedence if necessary */
%left AMPERSAND DSLASH

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
    content_element {
        $$ = astManager.newNode(DOCUMENT_H);
        $$->addChild($1);
    }
    | content content_element {
        $$ = $1;
        $$->addChild($2);
    }
    | /* empty */ {
        $$ = astManager.newNode(DOCUMENT_H);
    };

content_element:
    verbatim
  | list
  | section
  | subsection
  | subsubsection
  | text
  | figure
  | hrule
  | tabular
  | href;


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

verbatim: START_VERBATIM code END_VERBATIM {
    $$ = astManager.newNode(VERBATIM_H);
    $$->data = $2->data;  // Assign the concatenated code block to the VERBATIM_H node
    delete $2;  // Clean up the concatenated string
};

code: code CODE {
    // Append the new CODE token to the VERBATIM_H node's data
    (yyval.node) = (yyvsp[-1].node);  // Use the existing VERBATIM_H node
    (yyval.node)->data += *(yyvsp[0].svalue);  // Concatenate the new CODE data
    delete (yyvsp[0].svalue);  // Clean up the CODE token
}
| CODE {
    // Initialize the VERBATIM_H node with the first CODE token
    (yyval.node) = astManager.newNode(VERBATIM_H);
    (yyval.node)->data = *(yyvsp[0].svalue);  // Assign the CODE token data
    delete (yyvsp[0].svalue);  // Clean up the CODE token
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

text:
    text STRING {
        $$ = $1;
        ASTNode* stringNode = astManager.newNode(STRING_H);
        stringNode->data = *$2;
        delete $2;
        $$->addChild(stringNode);
    }
    | text bold {
        $$ = $1;
        $$->addChild($2);
    }
    | text italic {
        $$ = $1;
        $$->addChild($2);
    }
    | text PAR text {
        $$ = $1;
        ASTNode* parNode = astManager.newNode(PAR_H);
        parNode->addChild($3);  // Add the following text as a child of PAR_H
        $$->addChild(parNode);
    }
    | text PAR {
        $$ = $1;
        ASTNode* parNode = astManager.newNode(PAR_H);
        $$->addChild(parNode);
    }
    | PAR text {
        $$ = astManager.newNode(PAR_H);
        $$->addChild($2);
    }
    | PAR {
        $$ = astManager.newNode(PAR_H);
    }
    | bold {
        $$ = astManager.newNode(TEXT_H);
        $$->addChild($1);
    }
    | italic {
        $$ = astManager.newNode(TEXT_H);
        $$->addChild($1);
    }
    | STRING {
        $$ = astManager.newNode(STRING_H);
        $$->data = *$1;
        delete $1;
    };

tabular: BEGIN_TABULAR BEGIN_CURLY TABLE_ARGS END_CURLY HLINE rows END_TABULAR {
    $$ = astManager.newNode(TABULAR_H);
    $$->data = *$3;
    delete $3;
    $$->addChild($6);
};

rows: rows row {
    $$ = $1;
    $$->addChild($2);
}
    | row {
    $$ = $1;
};

row: cells DSLASH HLINE {
    $$ = astManager.newNode(ROW_H);
    $$->addChild($1);
}
    | cells DSLASH {
    $$ = astManager.newNode(ROW_H);
    $$->addChild($1);
};

cells: cells AMPERSAND cell {
    $$ = $1;
    $$->addChild($3);
}
    | cell {
    $$ = astManager.newNode(CELL_H);
    $$->addChild($1);
};

cell: STRING {
    $$ = astManager.newNode(CELL_H);
    $$->data = *$1;
    delete $1;
};

href: HREF BEGIN_CURLY STRING END_CURLY BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(HREF_H);
    $$->data = *$3 + "#" + *$6;
    delete $3;
    delete $6;
};

hrule: HRULE {
    $$ = astManager.newNode(HRULE_H);
};

%%
