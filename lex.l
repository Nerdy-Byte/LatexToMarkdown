%option noyywrap

%{
    #include <iostream>
    #include <cstring>
    #include "parser.tab.h"

    using namespace std;

    vector<bool> state = {false, false, false};
%}

%s TABULAR
%s TABULAR_ARGUMENT
%s FIGURE
%s FIGURE_ARGUMENT
%s MATH

OPERATORS [+*\-\/\^=\(\)]
SPECIAL [\.,\^\-=+#!\(\)?\<\>\*:;@\']

%%

<*>[ \t] ; //ignoring all the spaces at the start of the program
<INITIAL, TABULAR, FIGURE>\n ;

"\\documentclass[sigconf]{acmart}\n"
"\\usepackage{balance}\n"
"\\usepackage{graphicx}\n"
"\\usepackage{url}\n"
"\\usepackage{amsmath}\n"
"\\usepackage{mathtools}\n"
"\\usepackage{tabularx}\n"
"\\usepackage{caption}\n"
"\\usepackage{subcaption}\n"
"\\usepackage{multirow}\n"
"\\usepackage{graphics}"    { return PREAMBLE; }

"\\begin{itemize}"           { return BEGIN_ITEMIZE; }
"\\end{itemize}"             { return END_ITEMIZE; }
"\\begin{enumerate}"         { return BEGIN_ENUMERATE; }
"\\end{enumerate}"           { return END_ENUMERATE; }
"\\begin{document}"          { return BEGIN_DOCUMENT; }
"\\end{document}"            { return END_DOCUMENT; }
"\\section"                  { return SECTION_H; }
"\\subsection"               { return SUBSECTION_H; }
"\\item"                     { return ITEM; }
"\\par"                      { return PAR; }
"\\label"                    { return LABEL_TAG; }
"\\ref"                      { return REF_TAG; }

<INITIAL,ENV_TABULAR>"\\textbf"      { return T_BF; }
<INITIAL,ENV_TABULAR>"\\textit"      { return T_IT; }
<INITIAL,ENV_TABULAR>"\\underline"   { return T_U; }
<INITIAL,ENV_TABULAR,MATHMODE>"{"    { return BEGIN_CURLY; }
<INITIAL,ENV_TABULAR,MATHMODE>"}"    { return END_CURLY; }

"\\begin{tabular}"          { BEGIN(TABULAR_ARGUMENT); return BEGIN_TABULAR; }
<TABULAR>"\\end{tabular}"   { BEGIN(INITIAL); state[0] = true; state[1] = false; state[2] = false; return END_TABULAR; }
<TABULAR_ARGUMENT>"{"       { return BEGIN_CURLY; }

<TABULAR_ARGUMENT>[ lcr|]+ 
    {
        string result="", str(yytext.begin(), yytext.end());
        for(auto x: str){
            if(x == 'l' || x == 'c' || x == 'r')
                result += x;
        }
        yylval.sval = result;
        return TABLE_ARGUMENT;
    }

<TABULAR_ARGUMENT>"}"
    {
        BEGIN(TABULAR);
        
        for(int i = 0; i<state.size(); i++){
            
            if(i==1) state[i] = true;
            else state[i] = false;
            
        }

        return END_CURLY;
    }


%%

