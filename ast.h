#ifndef _AST_H
#define _AST_H

#include <iostream>
#include <string>
#include <vector>
#include <stack>
#include <map>
#include <algorithm>

using namespace std;

enum NodeType {
    AST_H,
    DOCUMENT_H,
    SECTION_H,
    SUBSECTION_H,
    SUBSUBSECTION_H,
    TEXTBF_H,
    TEXTIT_H,
    UNDERLINE_H,
    STRING_H,
    ENUMERATE_H,
    ITEMIZE_H,
    ITEM_H,
    PAR_H,
    TABULAR_H,
    ROW_H,
    CELL_H,
    FIGURE_H,
    CAPTION_H,
    INCLUDE_GRAPHICS_H,
    LABEL_H,
    REF_H,
    HLINE_H,
    SQRT_H,
    TITLE_H,
    DATE_H,
    VERBATIM_H,
    HRULE_H,
    HREF_H,
    TEXT_H
};

inline string nodeTypeToString(NodeType type) {
    switch (type) {
        case AST_H: return "AST_H";
        case SECTION_H: return "SECTION_H";
        case SUBSECTION_H: return "SUBSECTION_H";
        case ITEMIZE_H: return "ITEMIZE_H";
        case ENUMERATE_H: return "ENUMERATE_H";
        case ITEM_H: return "ITEM_H";
        case TEXTBF_H: return "TEXTBF_H";
        case TEXTIT_H: return "TEXTIT_H";
        case UNDERLINE_H: return "UNDERLINE_H";
        case PAR_H: return "PAR_H";
        case LABEL_H: return "LABEL_H";
        case REF_H: return "REF_H";
        case TABULAR_H: return "TABULAR_H";
        case FIGURE_H: return "FIGURE_H";
        case INCLUDE_GRAPHICS_H: return "INCLUDE_GRAPHICS_H";
        case CAPTION_H: return "CAPTION_H";
        case STRING_H: return "STRING_H";
        case DOCUMENT_H: return "DOCUMENT_H";
        case ROW_H: return "ROW_H";
        case CELL_H: return "CELL_H";
        case SQRT_H: return "SQRT_H";
        case HLINE_H: return "HLINE_H";
        case SUBSUBSECTION_H: return "SUBSUBSECTION_H";
        case TITLE_H: return "TITLE_H";
        case DATE_H: return "DATE_H";
        case VERBATIM_H: return "VERBATIM_H";
        case HRULE_H: return "HRULE_H";
        case HREF_H: return "HREF_H";
        case TEXT_H: return "TEXT_H";
        default: return "UNKNOWN_NODE_TYPE";
    }
}

class ASTNode
{
public:
    NodeType node_type;
    string data;
    string attributes;
    vector<ASTNode *> children;

    ASTNode();
    ASTNode(NodeType type, const string &data = "", const string &attributes = "");
    ~ASTNode();
    
    void addChild(ASTNode *child);
    void print(int tabs = 0) const;
};

class ASTManager {
public:
    ASTManager();
    ~ASTManager();

    // Node creation
    ASTNode* newNode(NodeType type);
    ASTNode* newNode();
    ASTNode* newNode(const string& data);
    
    void print(ASTNode* root, int tabs = 0) const;
};

extern ASTManager astManager; 

#endif // _AST_H
