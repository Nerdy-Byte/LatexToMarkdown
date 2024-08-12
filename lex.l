%option noyywrap

%{
#include <iostream>
#include <string>
#include "ast.h"
#include "parser.tab.h"

using namespace std;

int prev_state[1] = {0};
%}

%x PYTHON_CODE
%x ENV_TABULAR
%x TITLE_CONTENT
%x DATE_CONTENT
%x TABLE_ARGUMENTS
%x ENV_FIGURE
%x FIGURE_ARGUMENTS
%x MATHMODE
%x VERBATIUM_TEXT

OPERATORS [+*\-\/\^=\(\)]
SPECIAL [\.,\^\-=+#!\(\)?\<\>\*:;@\'/]

%%

<*>[ \t]+ ; /* skip whitespace */

<INITIAL>\n                         ; 

<INITIAL>"\\documentclass{article}" { cout << " DOCUMENT CLASS\n"; }

<INITIAL>"\\usepackage{graphicx}"   { cout << " USE PACKAGE GRAPHICX\n"; }

<INITIAL>"\\usepackage{hyperref}"   { cout << " USE PACKAGE HYPERREF\n"; }

<INITIAL>"\\title{"                 { BEGIN(TITLE_CONTENT); return TITLE; }

<TITLE_CONTENT>"}"                  { BEGIN(INITIAL); return END_CURLY; }

<INITIAL>"\\date{"                  { BEGIN(DATE_CONTENT); return DATE; }

<DATE_CONTENT>"}"                   { BEGIN(INITIAL); return END_CURLY; }

<INITIAL>"\\begin{document}"        { return BEGIN_DOCUMENT; }

"\\begin{itemize}"                  { return BEGIN_ITEMIZE; }

"\\end{itemize}"                    { return END_ITEMIZE; }

"\\begin{enumerate}"                { return BEGIN_ENUMERATE; }

"\\end{enumerate}"                  { return END_ENUMERATE; }

"\\item"                            { return ITEM; }

"\\section"                         { return SECTION; }

"\\subsection"                      { return SUBSECTION; }

"\\subsubsection"                   { return SUBSUBSECTION; }

"\\par"                             { return PAR; }

<INITIAL,ENV_TABULAR>"\\textbf"     { return T_BF; }

<INITIAL,ENV_TABULAR>"\\textit"     { return T_IT; }

<INITIAL,ENV_TABULAR>"\\underline"  { return T_U; }

<INITIAL,ENV_TABULAR,MATHMODE,ENV_FIGURE>"{"   {  return BEGIN_CURLY; }

<INITIAL,ENV_TABULAR,MATHMODE>"}"   {  BEGIN(INITIAL);return END_CURLY; }

"\\begin{tabular}"                  { BEGIN(TABLE_ARGUMENTS); return BEGIN_TABULAR; }

<ENV_TABULAR>"\\end{tabular}"       { BEGIN(INITIAL); prev_state[0] = 0; return END_TABULAR; }

<TABLE_ARGUMENTS>\{                 { return BEGIN_CURLY;}

<TABLE_ARGUMENTS>[lcr|]*            {
    std::string res = "";
    for (int i = 0; i < strlen(yytext); i++) {
        if (yytext[i] == 'l' || yytext[i] == 'c' || yytext[i] == 'r') {
            res += yytext[i];
        }
    }
    yylval.svalue = new string(res);
    return TABLE_ARGS;
}
<INITIAL>"\\hrule"                 { return HRULE; }
<TABLE_ARGUMENTS>"}"               { BEGIN(ENV_TABULAR); prev_state[0] = 1; return END_CURLY; }

<ENV_TABULAR>"&"                   { return AMPERSAND; }

<INITIAL,ENV_TABULAR>\\\\          { return DSLASH; }

<ENV_TABULAR>"\\hline"             { return HLINE; }

<INITIAL>"\\begin{verbatim}"       { BEGIN(VERBATIUM_TEXT); return START_VERBATIM; }

<VERBATIUM_TEXT>"\\end{verbatim}"  { BEGIN(INITIAL); return END_VERBATIM; }

<VERBATIUM_TEXT>"def"[^{\n]*"{"([^{}]|\n)*"}" {
    yylval.svalue = new string(yytext);
    return CODE;
}

<INITIAL>"\\end{document}"         {  return END_DOCUMENT; }

<INITIAL,DATE_CONTENT,TITLE_CONTENT,ENV_TABULAR,ENV_FIGURE>([a-zA-Z0-9 ]|{SPECIAL})* {
    yylval.svalue = new string(yytext);
    return STRING;
}

"\\begin{figure}"                  { BEGIN(ENV_FIGURE); prev_state[0] = 0; return BEGIN_FIGURE; }

<ENV_TABULAR>"\\begin{figure}"     { BEGIN(ENV_FIGURE); prev_state[0] = 1; return BEGIN_FIGURE; }

<ENV_FIGURE>"}"        {
    if (prev_state[0] == 0) {
        BEGIN(INITIAL);
        prev_state[0] = 2;
    } else if (prev_state[0] == 1) {
        BEGIN(ENV_TABULAR);
        prev_state[0] = 2;
    } else if (prev_state[0] == 2) {
        BEGIN(ENV_FIGURE);
        prev_state[0] = 2;
    } else {
        BEGIN(INITIAL);
    }
    return END_CURLY;
}

<INITIAL,ENV_FIGURE>"\\includegraphics"     { return INCLUDE_GRAPHICS; }

<ENV_FIGURE,INITIAL>"["                     { BEGIN(FIGURE_ARGUMENTS); return BEGIN_SQUARE; }

<ENV_FIGURE>"\\caption"                     { return CAPTION; }

<ENV_FIGURE>"\\label"                       { return LABEL_TAG; }

<FIGURE_ARGUMENTS>[a-zA-Z0-9=.,\s\-\\]+ {
    std::string fin(yytext);
    
    yylval.svalue = new string(fin);
    return FIG_ARGS;
}

<FIGURE_ARGUMENTS>"]"               {  BEGIN(ENV_FIGURE); return END_SQUARE; }

. { ; }

%%
