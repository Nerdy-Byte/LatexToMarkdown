#include <iostream>
#include <string>
#include "gtest/gtest.h"
#include "converter.h"
#include "ast.h"

using namespace std;

class LatexToMdTest : public ::testing::Test {
protected:
    ASTManager astManager; 
    converter c; 

    LatexToMdTest() {
    }

    virtual ~LatexToMdTest() {
    }

    ASTNode* createSectionAST() {
        ASTNode* root = astManager.newNode(SECTION_H);
        root->data = "Introduction";
        return root;
    }

    ASTNode* createSubsectionAST() {
        ASTNode* root = astManager.newNode(SUBSECTION_H);
        root->data = "Subsection Example";
        return root;
    }

    ASTNode* createTextAST() {
        ASTNode* root = astManager.newNode(STRING_H);
        root->data = "This is a sample text.";
        return root;
    }

    ASTNode* createBoldAST() {
        ASTNode* root = astManager.newNode(TEXTBF_H);
        root->data = "bold";
        return root;
    }

    ASTNode* createItalicAST() {
        ASTNode* root = astManager.newNode(TEXTIT_H);
        root->data = "italic";
        return root;
    }

    ASTNode* createTabularAST() {
        ASTNode* root = astManager.newNode(TABULAR_H);
        
        ASTNode* row1 = astManager.newNode(ROW_H);
        ASTNode* cell1 = astManager.newNode(CELL_H);
        cell1->data = "Header1";
        row1->addChild(cell1);

        ASTNode* cell2 = astManager.newNode(CELL_H);
        cell2->data = "Header2";
        row1->addChild(cell2);
        root->addChild(row1);
        
        ASTNode* row2 = astManager.newNode(ROW_H);
        ASTNode* cell3 = astManager.newNode(CELL_H);
        cell3->data = "Row1Col1";
        row2->addChild(cell3);

        ASTNode* cell4 = astManager.newNode(CELL_H);
        cell4->data = "Row1Col2";
        row2->addChild(cell4);
        root->addChild(row2);

        return root;
    }

    ASTNode* createItemizeAST() {
        ASTNode* root = astManager.newNode(ITEMIZE_H);
        
        ASTNode* item1 = astManager.newNode(ITEM_H);
        ASTNode* str1 = astManager.newNode(STRING_H);
        str1->data = "First item";
        item1->addChild(str1);
        root->addChild(item1);

        ASTNode* item2 = astManager.newNode(ITEM_H);
        ASTNode* str2 = astManager.newNode(STRING_H);
        str2->data = "Second item";
        item2->addChild(str2);
        item1->addChild(item2);

        return root;
    }

    ASTNode* createVerbatimAST() {
        ASTNode* root = astManager.newNode(VERBATIM_H);
        root->data = "This is verbatim text.";
        return root;
    }

    ASTNode* createParAST() {
        ASTNode* root = astManager.newNode(STRING_H);
        ASTNode* par = astManager.newNode(PAR_H);
        root->data = "This is a paragraph.";
        ASTNode* child = astManager.newNode(STRING_H);
        child->data = "This is another paragraph.";
        par->addChild(child);
        root->addChild(par);
        return root;
    }

    ASTNode* createFigureAST() {
        ASTNode* root = astManager.newNode(FIGURE_H);
        root->data = "This is a figure caption.";
        return root;
    }

    ASTNode* createHrefAST() {
        ASTNode* root = astManager.newNode(HREF_H);
        // ASTNode* urlNode = astManager.newNode(STRING_H);
        root->data = "http://example.com#Example";
        // root->addChild(urlNode);
        return root;
    }

};

TEST_F(LatexToMdTest, ConvertsSectionToMarkdown) {
    ASTNode* root = createSectionAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "## 1 Introduction\n\n\n\n";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsSubsectionToMarkdown) {
    ASTNode* root = createSubsectionAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "### 1.1 Subsection Example\n\n\n\n";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsTextToMarkdown) {
    ASTNode* root = createTextAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "This is a sample text.";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsBoldToMarkdown) {
    ASTNode* root = createBoldAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "**bold** ";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsItalicToMarkdown) {
    ASTNode* root = createItalicAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "*italic* ";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsItemizeToMarkdown) {
    ASTNode* root = createItemizeAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "\n-First item\n-Second item\n\n";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsTabularToMarkdown) {
    ASTNode* root = createTabularAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = R"(
| Header1  | Header2  |
| -------- | -------- |
| Row1Col1 | Row1Col2 |
)";
}

TEST_F(LatexToMdTest, ConvertsVerbatimToMarkdown) {
    ASTNode* root = createVerbatimAST();
    std::string markdownOutput = c.traversal(root);
    std::string expectedMarkdown = "\n\n```\nThis is verbatim text.\n```\n\n";
    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsParToMarkdown) {
    ASTNode* root = createParAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "This is a paragraph. \n\n This is another paragraph.";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsFigureToMarkdown) {
    ASTNode* root = createFigureAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "![](This is a figure caption.)\n\n";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

TEST_F(LatexToMdTest, ConvertsHrefToMarkdown) {
    ASTNode* root = createHrefAST();
    std::string markdownOutput = c.traversal(root);

    std::string expectedMarkdown = "[Example](http://example.com) \n";

    EXPECT_EQ(markdownOutput, expectedMarkdown);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}