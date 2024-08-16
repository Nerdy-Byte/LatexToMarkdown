#ifndef CONVERTER_H
#define CONVERTER_H

#include "ast.h"
#include <string>
#include <map>

class converter {
private:
    std::map<int, std::string> myMapping;
public:
    converter();
    std::string traversal(ASTNode* root);
    std::string traverseSection(ASTNode* root, int type);
    std::string traverseSubSection(ASTNode* root, int type);
    std::string traverseSubsubSection(ASTNode* root, int type);
    std::string traverseList(ASTNode* root, int type);
    std::string traverseVerbatim(ASTNode* root, int type);
    std::string traverseFont(ASTNode* root, int type);
    std::string traverseDate(ASTNode* root, int type);
    std::string traverseTitle(ASTNode* root, int type);
    std::string traverseChildren(ASTNode* root);
    std::string getMapping(int type);
    std::string traverseReference(ASTNode* root, int type);
    std::string traverseLabel(ASTNode* root, int type);
    std::string traverseFigure(ASTNode* root, int type);
    std::string traverseParagraph(ASTNode* root, int type);
    std::string traverseString(ASTNode* root, int type);
    std::string traverseHref(ASTNode* root, int type);
    std::string traverseTable(ASTNode* root, int type);
    void printMarkdown(const std::string& s, const std::string& filename);
};

#endif
