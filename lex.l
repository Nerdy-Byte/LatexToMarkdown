%option noyywrap

%{
#include <iostream>
#include <string>
#include "parser.tab.h"
using namespace std;
%}

%x ENV_TABULAR
%x TITLE_CONTENT
%x DATE_CONTENT
%x TABLE_ARGUMENTS
%x ENV_FIGURE
%x FIGURE_ARGUMENTS
%x MATHMODE
%x VERBATIUM_TEXT

OPERATORS [+*\-\/\^=\(\)]
SPECIAL [\.,\^\-=+#!\(\)?\<\>\*:;@\']

%%

<*>[ \t]+ ; /* skip whitespace */

<INITIAL>\n     ; 
<INITIAL>"\\documentclass{article}"         { cout << " DOCUMENT CLASS\n"; }
<INITIAL>"\\usepackage{graphicx}"           { cout << " USE PACKAGE GRAPHICX\n"; }
<INITIAL>"\\usepackage{hyperref}"           { cout << " USE PACKAGE HYPERREF\n"; }
<INITIAL>"\\title{"                         { BEGIN(TITLE_CONTENT); return TITLE; }
<TITLE_CONTENT>"}"                          { BEGIN(INITIAL); return END_CURLY; }
<INITIAL>"\\date{"                          { BEGIN(DATE_CONTENT); return DATE; }
<DATE_CONTENT>"}"                           { BEGIN(INITIAL); return END_CURLY; }

<INITIAL>"\\begin{document}"                { return BEGIN_DOCUMENT; }

"\\begin{itemize}"                          { return BEGIN_ITEMIZE; }

"\\end{itemize}"                            { return END_ITEMIZE; }

"\\begin{enumerate}"                        { return BEGIN_ENUMERATE; }

"\\end{enumerate}"                          { return END_ENUMERATE; }

"\\item"                                    { return ITEM; }

<INITIAL>"\\begin{verbatim}"                { BEGIN(VERBATIUM_TEXT); return START_VERBATIM; }
<VERBATIUM_TEXT>"\\end{verbatim}"           { BEGIN(INITIAL); return END_VERBATIM; }
<VERBATIM_TEXT>"def"[^{\n]*"{"([^{}]|\n)*"}" { yylval.svalue = new string(yytext);  return CODE;  }
<INITIAL>"\\end{document}"                  { return END_DOCUMENT; }

<INITIAL,DATE_CONTENT,TITLE_CONTENT>([a-zA-Z0-9 ]|{SPECIAL})*     { yylval.svalue = new string(yytext); return STRING; }


. { ; }

%%
