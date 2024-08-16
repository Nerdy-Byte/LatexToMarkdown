#ifndef _AST_H
#define _AST_H

#include <iostream>
#include <string>
#include <vector>
#include <stack>
#include <map>
#include <algorithm>

using namespace std;

// Enumeration for the different types of nodes in the AST
enum NodeType {
    AST_H,                // Abstract Syntax Tree root
    DOCUMENT_H,           // Document node
    SECTION_H,            // Section node
    SUBSECTION_H,         // Subsection node
    SUBSUBSECTION_H,      // Subsubsection node
    TEXTBF_H,             // Bold text node
    TEXTIT_H,             // Italic text node
    UNDERLINE_H,          // Underlined text node
    STRING_H,             // String (plain text) node
    ENUMERATE_H,          // Enumerate environment node
    ITEMIZE_H,            // Itemize environment node
    ITEM_H,               // Item node
    PAR_H,                // Paragraph node
    TABULAR_H,            // Tabular environment node
    ROW_H,                // Table row node
    CELL_H,               // Table cell node
    FIGURE_H,             // Figure environment node
    CAPTION_H,            // Figure caption node
    INCLUDE_GRAPHICS_H,   // Include graphics node
    LABEL_H,              // Label node
    REF_H,                // Reference node
    HLINE_H,              // Horizontal line node in tables
    SQRT_H,               // Square root node
    TITLE_H,              // Title node
    DATE_H,               // Date node
    VERBATIM_H,           // Verbatim environment node
    HRULE_H,              // Horizontal rule node
    HREF_H,               // Hyperlink node
    TEXT_H,               // Text node with formatting (e.g., bold, italic)
    CODE_H                // Code node (e.g., for verbatim content)
};

// Converts a NodeType enum value to a string for printing purposes
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
        case CODE_H: return "CODE_H";
        default: return "UNKNOWN_NODE_TYPE";
    }
}

// ASTNode class represents a node in the AST
class ASTNode {
public:
    NodeType node_type;             // Type of the node (e.g., SECTION_H, ITEM_H)
    string data;                    // Data associated with the node (e.g., text content)
    string attributes;              // Additional attributes (e.g., label, reference)
    vector<ASTNode *> children;     // Child nodes

    // Constructors
    ASTNode();  // Default constructor
    ASTNode(NodeType type, const string &data = "", const string &attributes = "");  // Parameterized constructor

    // Destructor
    ~ASTNode();  // Destructor to clean up children nodes

    // Adds a child node to the current node
    void addChild(ASTNode *child);

    // Prints the node and its children with indentation based on the depth in the tree
    void print(int tabs = 0) const;
};

// ASTManager class manages the AST, including creating and printing nodes
class ASTManager {
public:
    // Constructors and Destructor
    ASTManager();   // Default constructor
    ~ASTManager();  // Destructor

    // Node creation methods
    ASTNode* newNode(NodeType type);  // Create a new node with a specified type
    ASTNode* newNode();               // Create a default node
    ASTNode* newNode(const string& data);  // Create a new node with data

    // Prints the AST starting from the root node
    void print(ASTNode* root, int tabs = 0) const;
};

// Global ASTManager instance to be used across the program
extern ASTManager astManager; 

#endif // _AST_H
