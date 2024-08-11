#include "ast.h"

ASTNode* root = nullptr;

ASTNode::ASTNode() : node_type(STRING_H), data(""), attributes("") {
    // Default constructor
}



ASTNode::ASTNode(NodeType type, const string &data, const string &attributes) 
    : node_type(type), data(data), attributes(attributes) {
    // Parameterized constructor
}

ASTNode::~ASTNode() {
    for (auto child : children) {
        delete child;
    }
}

void ASTNode::addChild(ASTNode *child) {
    children.push_back(child);
}

void ASTNode::print(int tabs) const {
    for (int i = 0; i < tabs; ++i) {
        cout << "\t";
    }
    cout << nodeTypeToString(node_type) << ": " << data << " (" << attributes << ")" << endl;
    for (const auto& child : children) {
        child->print(tabs + 1);
    }
}



ASTNode* ASTManager::newNode(NodeType type) {
    return new ASTNode(type);
}


ASTManager::ASTManager() {
    
}

ASTManager::~ASTManager() {
    
}

void ASTManager::print(ASTNode* root, int tabs) const {
    if (root == nullptr) {
        return;
    }
    for (int i = 0; i < tabs; ++i) {
        cout << "-*-";
    }
    cout << nodeTypeToString(root->node_type) << ": " << root->data << " (" << root->attributes << ")" << endl;
    
    for (const auto& child : root->children) {
        print(child, tabs + 1);
    }
}
