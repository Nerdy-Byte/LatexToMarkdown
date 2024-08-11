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
SPECIAL [\.,\^\-=+#!\(\)?\<\>\*:;@\']

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

<INITIAL,ENV_TABULAR>"\\textbf"     { return T_BF; }

<INITIAL,ENV_TABULAR>"\\textit"     { return T_IT; }

<INITIAL,ENV_TABULAR>"\\underline"  { return T_U; }

<INITIAL,ENV_TABULAR,MATHMODE,ENV_FIGURE>"{"   { return BEGIN_CURLY; }

<INITIAL,ENV_TABULAR,MATHMODE,ENV_FIGURE>"}"   { return END_CURLY; }

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

<TABLE_ARGUMENTS>"}"               { BEGIN(ENV_TABULAR); prev_state[0] = 1; return END_CURLY; }

<ENV_TABULAR>"&"                   { return AMPERSAND; }

<INITIAL,ENV_TABULAR>\\\\         { return DSLASH; }

<ENV_TABULAR>"\\hline"             { return HLINE; }

<INITIAL>"\\begin{verbatim}"       { BEGIN(VERBATIUM_TEXT); return START_VERBATIM; }

<VERBATIUM_TEXT>"\\end{verbatim}"  { BEGIN(INITIAL); return END_VERBATIM; }

<VERBATIUM_TEXT>"def"[^{\n]*"{"([^{}]|\n)*"}" {
    yylval.svalue = new string(yytext);
    return CODE;
}

<INITIAL>"\\end{document}"         { return END_DOCUMENT; }

<INITIAL,DATE_CONTENT,TITLE_CONTENT,ENV_TABULAR,ENV_FIGURE>([a-zA-Z0-9 ]|{SPECIAL})* {
    yylval.svalue = new string(yytext);
    return STRING;
}

"\\begin{figure}"                  { BEGIN(ENV_FIGURE); prev_state[0] = 0; return BEGIN_FIGURE; }

<ENV_TABULAR>"\\begin{figure}"     { BEGIN(ENV_FIGURE); prev_state[0] = 1; return BEGIN_FIGURE; }

<ENV_FIGURE>"\\end{figure}"        {
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
    return END_FIGURE;
}

<INITIAL,ENV_FIGURE>"\\includegraphics"     { return INCLUDE_GRAPHICS; }

<INITIAL,ENV_FIGURE>"["                     { BEGIN(FIGURE_ARGUMENTS); return BEGIN_SQUARE; }

<ENV_FIGURE>"\\caption"                     { return CAPTION; }

<ENV_FIGURE>"\\label"                       { return LABEL_TAG; }

<FIGURE_ARGUMENTS>[a-z=. 0-9,]+ {
    std::string fin = "";
    int i = 0;
    while (yytext[i] != '\0') {
        switch (yytext[i]) {
            case 'c':
                if (yytext[i + 1] == 'm') {
                    i += 2;
                } else {
                    fin += yytext[i++];
                }
                break;
            case ',':
                i++;
                break;
            default:
                fin += yytext[i++];
                break;
        }
    }
    yylval.svalue = new string(fin);
    return FIG_ARGS;
}

<FIGURE_ARGUMENTS>"]"               { BEGIN(ENV_FIGURE); return END_SQUARE; }

<INITIAL,ENV_TABULAR,ENV_FIGURE>"$" { BEGIN(MATHMODE); return DOLLAR; }

<MATHMODE>"\\sum"                   { return SUMMATION; }

<MATHMODE>"\\int"                   { return INTEGRAL; }

<MATHMODE>"\\frac"                  { return FRACTION; }

<MATHMODE>"\\sqrt"                  { return SQUARE_ROOT; }

<MATHMODE>\^                        { return SUPERSCRIPT; }

<MATHMODE>\_                        { return SUBSCRIPT; }

<MATHMODE>([A-Za-z0-9]|{OPERATORS})* {
    std::string res = "";
    for (int i = 0; i < strlen(yytext); ++i) {
        res += yytext[i];
    }
    yylval.svalue = new string(res);
    return MATH_STRING;
}

<MATHMODE>"$" {
    if (prev_state[0] == 0) {
        BEGIN(INITIAL);
        prev_state[0] = 0;
    } else if (prev_state[0] == 1) {
        BEGIN(ENV_TABULAR);
        prev_state[0] = 1;
    } else if (prev_state[0] == 2) {
        BEGIN(ENV_FIGURE);
        prev_state[0] = 2;
    } else {
        cout << "Error" << endl;
        BEGIN(INITIAL);
    }

    return DOLLAR;
}

. { ; }

%%
