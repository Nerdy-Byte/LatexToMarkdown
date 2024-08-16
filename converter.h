#ifndef CONVERTER_H
#define CONVERTER_H

#include "ast.h"
#include <string>
#include <map>

// Converter class for traversing AST nodes and converting them to a Markdown-like format
class converter {
private:
    std::map<int, std::string> myMapping;  // Mapping of node types to their string representations

public:
    // Constructor
    converter();

    // Traversal method for converting the entire AST starting from the root node
    std::string traversal(ASTNode* root);

    // Traversal methods for different node types, based on their type
    std::string traverseSection(ASTNode* root, int type);        // Handles SECTION nodes
    std::string traverseSubSection(ASTNode* root, int type);     // Handles SUBSECTION nodes
    std::string traverseSubsubSection(ASTNode* root, int type);  // Handles SUBSUBSECTION nodes
    std::string traverseList(ASTNode* root, int type);           // Handles LIST nodes (e.g., itemize, enumerate)
    std::string traverseVerbatim(ASTNode* root, int type);       // Handles VERBATIM nodes (e.g., code blocks)
    std::string traverseFont(ASTNode* root, int type);           // Handles font formatting nodes (e.g., bold, italic)
    std::string traverseDate(ASTNode* root, int type);           // Handles DATE nodes
    std::string traverseTitle(ASTNode* root, int type);          // Handles TITLE nodes
    std::string traverseChildren(ASTNode* root);                 // Handles traversal of child nodes

    // Retrieves the string representation for a given node type from the mapping
    std::string getMapping(int type);

    // Traversal methods for additional node types
    std::string traverseReference(ASTNode* root, int type);     // Handles REFERENCE nodes
    std::string traverseLabel(ASTNode* root, int type);         // Handles LABEL nodes
    std::string traverseFigure(ASTNode* root, int type);        // Handles FIGURE nodes
    std::string traverseParagraph(ASTNode* root, int type);     // Handles PARAGRAPH nodes
    std::string traverseString(ASTNode* root, int type);        // Handles STRING nodes
    std::string traverseHref(ASTNode* root, int type);          // Handles HREF (hyperlink) nodes
    std::string traverseTable(ASTNode* root, int type);         // Handles TABLE nodes (e.g., tabular environments)

    // Outputs the converted Markdown content to a specified file
    void printMarkdown(const std::string& s, const std::string& filename);
};

#endif // CONVERTER_H
