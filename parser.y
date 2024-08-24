%{
//!Includes necessary headers and libraries.

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <cstdlib>
#include "ast.h"
#include "parser.tab.hpp"

using namespace std;

//!Declares external functions (yylex, yyerror) and the root ASTNode pointer, which will hold the final AST.

extern int yylex();
extern void yyerror(const char*);
extern FILE *yyin;
extern ASTNode* root;
%}

//!Defines a union to handle different types of values in the grammar. The parser can return either strings (svalue) or AST nodes (node).

%union {
    std::string* svalue;
    ASTNode* node;
}

/*##
Defines tokens for different LaTeX-like elements and maps them to the appropriate svalue or node type.
Specifies the types of non-terminal symbols in the grammar.
*/

%start start 

%token <svalue> STRING CODE FIGURE_PATH FIGURE_SPECS HEADING MATH_STRING FIG_ARGS TABLE_ARGS
%token TITLE DATE START_VERBATIM END_VERBATIM END_CURLY BEGIN_DOCUMENT END_DOCUMENT ITEM BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE SECTION SUBSECTION SUBSUBSECTION ENDL T_BF T_IT T_U BEGIN_TABULAR END_TABULAR
%token HLINE AMPERSAND DSLASH BEGIN_FIGURE BEGIN_SQUARE END_FIGURE END_SQUARE INCLUDE_GRAPHICS CAPTION COMMA
%token BEGIN_CURLY PAR LABEL_TAG REF_TAG HRULE HREF
%type <node> start title date begin_document content list ul ol items verbatim section subsection subsubsection bold 
%type <node> italic figure text hrule tabular row rows cell cells href code content_element

/*##Specifies the precedence of certain operators to resolve conflicts during parsing .*/

%left PAR
%left AMPERSAND DSLASH

%%

/*##This grammar allows parsing a LaTeX-like language into an AST, which can later be traversed or transformed into different formats like Markdown.*/


/*##The start rule combines the title, date, and document content into a DOCUMENT_H node.*/
start: title date begin_document {
    root = astManager.newNode(DOCUMENT_H);
    root->addChild($1);
    root->addChild($2);
    root->addChild($3);
};

/*##These rules create TITLE_H and DATE_H nodes, storing the corresponding string data.*/
title: TITLE STRING END_CURLY {
    $$ = astManager.newNode(TITLE_H);
    $$->data = *$2;
    delete $2;
}| {$$ = astManager.newNode(TITLE_H);};

date: DATE STRING END_CURLY {
    $$ = astManager.newNode(DATE_H);
    $$->data = *$2;
    delete $2;
}| {$$ = astManager.newNode(DATE_H);};

/*##Defines the structure of the document, where content is added as a child node of the DOCUMENT_H node.*/
begin_document: BEGIN_DOCUMENT content END_DOCUMENT {
    $$ = astManager.newNode(DOCUMENT_H);
    $$->addChild($2);
}
| content {
    $$ = astManager.newNode(DOCUMENT_H);
    $$->addChild($1);
};

/*##content can consist of various content_element types, including text, lists, figures, tables, etc.
Content elements are added as children to the document node.*/

content:
    content_element {
        $$ = astManager.newNode(DOCUMENT_H);
        $$->addChild($1);
    }
    | content content_element {
        $$ = $1;
        $$->addChild($2);
    }
    | /*## empty */ {
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
  | tabular;

/*##Handles unordered (ul) and ordered (ol) lists, where items are added as children to ITEMIZE_H or ENUMERATE_H nodes.*/

//! Top-level list rules
list: ul { $$ = $1; }
    | ol { $$ = $1; };

//! Unordered list
ul: BEGIN_ITEMIZE items END_ITEMIZE {
    $$ = astManager.newNode(ITEMIZE_H);
    $$->addChild($2);
};

//! Ordered list
ol: BEGIN_ENUMERATE items END_ENUMERATE {
    $$ = astManager.newNode(ENUMERATE_H);
    $$->addChild($2);
};

//! Items in lists
items: items ITEM text {
    $$ = $1;
    ASTNode* itemNode = astManager.newNode(ITEM_H);
    itemNode->addChild($3); //! Add the text as a child of the item node
    $$->addChild(itemNode);
}
    | ITEM text {
    $$ = astManager.newNode(ITEM_H);
    $$->addChild($2); //! Add the text as a child of the item node
}
    | items list { //! Handle nested lists
    $$ = $1;
    $$->addChild($2);
}
    | list { //! Handle case where the list starts directly with a nested list
    $$ = $1;
};

/*##Handles sections, subsections, and subsubsections by creating corresponding nodes and assigning the section title data.*/

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

/*##Handles verbatim environments by concatenating CODE tokens into a single VERBATIM_H node's data.*/

verbatim: START_VERBATIM code END_VERBATIM {
    $$ = astManager.newNode(VERBATIM_H);
    $$->data = $2->data;  //! Assign the concatenated code block to the VERBATIM_H node
    delete $2;  //! Clean up the concatenated string
};

code: code CODE {
    //! Append the new CODE token to the VERBATIM_H node's data
    (yyval.node) = (yyvsp[-1].node);  //! Use the existing VERBATIM_H node
    (yyval.node)->data += *(yyvsp[0].svalue);  //! Concatenate the new CODE data
    delete (yyvsp[0].svalue);  //! Clean up the CODE token
}
| CODE {
    //! Initialize the VERBATIM_H node with the first CODE token
    (yyval.node) = astManager.newNode(VERBATIM_H);
    (yyval.node)->data = *(yyvsp[0].svalue);  //! Assign the CODE token data
    delete (yyvsp[0].svalue);  //! Clean up the CODE token
};


/*##Handles bold (TEXTBF_H) and italic (TEXTIT_H) text formatting.*/

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

/*##Handles figures, where the image path is stored in the FIGURE_H node's data.*/

figure: INCLUDE_GRAPHICS BEGIN_SQUARE FIG_ARGS END_SQUARE BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(FIGURE_H);
    $$->data = *$6;
    delete $6;
};

/*##Handles text and paragraph (PAR_H) elements, where different text formatting (bold, italic) and plain text (STRING_H) are combined.*/

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
        parNode->addChild($3);  //! Add the following text as a child of PAR_H
        $$->addChild(parNode);
    }
    | text href{
        $$ = $1;
        $$->addChild($2);
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

/*##Handles tables (TABULAR_H) by defining rows (ROW_H) and cells (CELL_H) within the table.*/

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

cell: text {$$ = astManager.newNode(CELL_H); $$->addChild($1);};

/*##Handles hyperlinks, storing the link and label in the HREF_H node.*/

href: HREF BEGIN_CURLY STRING END_CURLY BEGIN_CURLY STRING END_CURLY {
    $$ = astManager.newNode(HREF_H);
    $$->data = *$3 + "#" + *$6;
    delete $3;
    delete $6;
};

/*##Handles horizontal rules by creating an HRULE_H node.*/

hrule: HRULE {
    $$ = astManager.newNode(HRULE_H);
};

%%
