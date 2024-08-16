#include "ast.h"

// Global root node pointer
ASTNode* root = nullptr;

// Default constructor for ASTNode
ASTNode::ASTNode() : node_type(STRING_H), data(""), attributes("") {
    // Initializes node with default values
}

// Parameterized constructor for ASTNode
ASTNode::ASTNode(NodeType type, const string &data, const string &attributes) 
    : node_type(type), data(data), attributes(attributes) {
    // Initializes node with specified type, data, and attributes
}

// Destructor for ASTNode
ASTNode::~ASTNode() {
    // Deletes all children nodes to avoid memory leaks
    for (auto child : children) {
        delete child;
    }
}

// Adds a child node to the current node
void ASTNode::addChild(ASTNode *child) {
    children.push_back(child);
}

// Recursively prints the AST, starting from this node
// `tabs` controls the indentation level for pretty-printing
void ASTNode::print(int tabs) const {
    // Print current node with appropriate indentation
    for (int i = 0; i < tabs; ++i) {
        cout << "\t";
    }
    // Print node type, data, and attributes
    cout << nodeTypeToString(node_type) << ": " << data << " (" << attributes << ")" << endl;
    
    // Recursively print all children with increased indentation
    for (const auto& child : children) {
        child->print(tabs + 1);
    }
}

// ASTManager constructor
ASTManager::ASTManager() {
    // Constructor can be used for initialization if needed
}

// ASTManager destructor
ASTManager::~ASTManager() {
    // Destructor for cleanup (no dynamic memory to handle directly here)
}

// Creates a new AST node of the specified type
ASTNode* ASTManager::newNode(NodeType type) {
    return new ASTNode(type);
}

// Recursively prints the AST from the given root node
// `tabs` controls the indentation level for pretty-printing
void ASTManager::print(ASTNode* root, int tabs) const {
    // Base case: if the node is null, return
    if (root == nullptr) {
        return;
    }
    
    // Print the current node with appropriate indentation
    for (int i = 0; i < tabs; ++i) {
        cout << "-*-";
    }
    cout << nodeTypeToString(root->node_type) << endl;
    
    // Recursively print all children with increased indentation
    for (const auto& child : root->children) {
        print(child, tabs + 1);
    }
}
