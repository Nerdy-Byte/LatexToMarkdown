#include <iostream>
#include <string>
#include "gtest/gtest.h"
#include "converter.h"
#include "ast.h"

using namespace std;

class LatexToMd : public ::testing::Test {
protected:
    ASTManager astManager; // ASTManager for managing AST nodes
    converter c; // Converter object

    LatexToMd() {
        // Initialization
    }

    virtual ~LatexToMd() {
        // Cleanup
    }

    virtual void SetUp() {
        // Code to set up the test environment
    }

    virtual void TearDown() {
        // Code to clean up after each test
    }

    // Helper function to create an AST for testing
    ASTNode* createSampleAST() {
        // Manually create an AST that corresponds to the sample LaTeX content
        ASTNode* root = astManager.newNode(SECTION_H);
        root->data = "Introduction";

        ASTNode* paragraph = astManager.newNode(TEXT_H);
        paragraph->data = "This is a simple LaTeX document.";
        root->addChild(paragraph);

        ASTNode* subsection = astManager.newNode(SUBSECTION_H);
        subsection->data = "Subsection Example";
        root->addChild(subsection);

        ASTNode* text = astManager.newNode(TEXT_H);
        text->data = "Here is some more text with ";
        subsection->addChild(text);

        ASTNode* bold = astManager.newNode(TEXTBF_H);
        bold->data = "bold";
        subsection->addChild(bold);

        ASTNode* text2 = astManager.newNode(TEXT_H);
        text2->data = " and ";
        subsection->addChild(text2);

        ASTNode* italic = astManager.newNode(TEXTIT_H);
        italic->data = "italic";
        subsection->addChild(italic);

        ASTNode* text3 = astManager.newNode(TEXT_H);
        text3->data = " formatting.";
        subsection->addChild(text3);

        ASTNode* itemize = astManager.newNode(ITEMIZE_H);
        root->addChild(itemize);

        ASTNode* item1 = astManager.newNode(ITEM_H);
        item1->data = "First item";
        itemize->addChild(item1);

        ASTNode* item2 = astManager.newNode(ITEM_H);
        item2->data = "Second item";
        itemize->addChild(item2);

        return root;
    }
};

// Test that the converter correctly converts LaTeX AST to Markdown
TEST_F(LatexToMd, ConvertsLatexToMarkdown) {
    ASTNode* root = createSampleAST();
    std::string markdownOutput = c.traversal(root);
    
    std::string expectedMarkdown = R"(
# Introduction

This is a simple LaTeX document.

## Subsection Example

Here is some more text with **bold** and *italic* formatting.

- First item
- Second item
)";
    
    EXPECT_EQ(markdownOutput, markdownOutput);
}

// Additional tests can be added here

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
