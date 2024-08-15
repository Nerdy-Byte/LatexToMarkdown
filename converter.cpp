#include "converter.h"
#include <sstream>
#include <fstream>

int section_no = 0;
int subsection_no = 0;
int subsubsection_no = 0;

std::string myString(int n) {
    std::stringstream ss;
    ss << n;
    return ss.str();
}

converter::converter() {
    myMapping[SECTION_H] = "##";              // Section
    myMapping[SUBSECTION_H] = "###";          // Subsection
    myMapping[SUBSUBSECTION_H] = "####";      // Subsubsection
    myMapping[ITEMIZE_H] = "-";               // Unordered list (ul)
    myMapping[ENUMERATE_H] = "1.";            // Ordered list (ol)
    myMapping[ITEM_H] = "- ";                 // List item (li) (note that `ITEMIZE_H` already uses "-")
    myMapping[TEXTBF_H] = "**";               // Bold text (strong)
    myMapping[TEXTIT_H] = "*";                // Italic text (em)
    myMapping[UNDERLINE_H] = "<u>";           // Underline text (u)
    myMapping[PAR_H] = "";                    // Paragraph (br)
    myMapping[LABEL_H] = "";                  // Anchor label (not used in output, just for linking)
    myMapping[REF_H] = "";                    // Anchor reference (not used in output, just for linking)
    myMapping[TABULAR_H] = "";                // Table (not used in output, just for table structure)
    myMapping[FIGURE_H] = "![]";              // Image (img) (for image link)
    myMapping[INCLUDE_GRAPHICS_H] = "![]";    // Image (img) (for image link)
    myMapping[CAPTION_H] = "";                // Figure caption (used with image)
    myMapping[STRING_H] = "";                 // Generic string content
    myMapping[DATE_H] = "Date: ";             // Date
    myMapping[TITLE_H] = "#";                 // Title (header level 1)
    myMapping[VERBATIM_H] = "```";            // Verbatim text
    myMapping[CAPTION_H] = "![IIT Delhi]";      // Caption for figures
    myMapping[HRULE_H] = "---";               // Horizontal rule
    myMapping[HREF_H] = "";                   // Hyperlink
}

std::string converter::traversal(ASTNode* root) {
    if (!root) return "";
    int type = root->node_type;
    switch (type) {
        case ITEM_H: return root->data + "\n";
        case STRING_H: return root->data + "\n";
        case SECTION_H:
            return traverseSection(root, type);
        case SUBSECTION_H:
            return traverseSubSection(root, type);
        case SUBSUBSECTION_H:
            return traverseSubsubSection(root, type);
        case ITEMIZE_H:
        case ENUMERATE_H:
            return traverseList(root, type);
        case VERBATIM_H:
            return traverseVerbatim(root, type);
        case TEXTBF_H:
        case TEXTIT_H:
        case UNDERLINE_H:
            return traverseFont(root, type);
        case TITLE_H:
            return traverseTitle(root, type);
        case DATE_H:
            return traverseDate(root, type);
        case FIGURE_H:
            return traverseFigure(root, type);
        case LABEL_H:
            return traverseLabel(root, type);
        case REF_H:
            return traverseReference(root, type);
        case HRULE_H:  return "\n\n---\n\n";
        case PAR_H: return traverseParagraph(root, type);
        case HREF_H: return traverseHref(root, type);

        default:
            return traverseChildren(root);
    }
}

std::string converter::traverseSection(ASTNode* root, int type) {
    section_no++;
    subsection_no = 0;
    subsubsection_no = 0;
    return getMapping(type) + " " + myString(section_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

std::string converter::traverseSubSection(ASTNode* root, int type) {
    subsection_no++;
    subsubsection_no = 0;
    return getMapping(type) + " " + myString(section_no) + "." + myString(subsection_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

std::string converter::traverseSubsubSection(ASTNode* root, int type) {
    subsubsection_no++;
    return getMapping(type) + " " + myString(section_no) + "." + myString(subsection_no) + "." + myString(subsubsection_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

std::string converter::traverseList(ASTNode* root, int type) {
    std::string result;
    ASTNode *temp = root->children[0];
    if(type == ITEMIZE_H){
        for (auto& child : root->children) {
            result += getMapping(type) + " " + traversal(child) + "\n";
        }
        for (auto& child : temp->children) {
            result += getMapping(type) + " " + traversal(child) + "\n";
        }
    }
    else{
        int count = 1;
        for (auto& child : root->children) {
            result += std::to_string(count) + " " + traversal(child) + "\n";
            count++;
        }
        for (auto& child : temp->children) {
            result += std::to_string(count) + " " + traversal(child) + "\n";
            count++;
        }

    }
    return result + "\n";
}

std::string converter::traverseVerbatim(ASTNode* root, int type) {
    return getMapping(type) + "\n" + root->data + "\n" + getMapping(type) + "\n\n";
}

std::string converter::traverseFont(ASTNode* root, int type) {
    return getMapping(type) + root->data + getMapping(type)+"\n";
}

std::string converter::traverseDate(ASTNode* root, int type) {
    return getMapping(type) + root->data + "\n\n";
}

std::string converter::traverseTitle(ASTNode* root, int type) {
    return getMapping(type) + " " + root->data + "\n\n";
}

std::string converter::traverseFigure(ASTNode* root, int type) {
    std::string result = getMapping(FIGURE_H) + "(" + root->data + ")";
    for (auto& child : root->children) {
        if (child->node_type == CAPTION_H) {
            result += " " + getMapping(CAPTION_H) + " \"" + child->data + "\"";
        }
    }
    return result + "\n\n";
}

std::string converter::traverseLabel(ASTNode* root, int type) {
    return getMapping(LABEL_H) + root->data + "\n\n";
}

std::string converter::traverseHref(ASTNode* root, int type) {
    std::string data = root->data, link="", label="";
    bool flag = true;
    for(auto x: data){
        if(x == '#'){ flag = false; continue;}
        if(flag) link += x;
        else label += x;
    }
    return getMapping(HREF_H) + "[" + link + "]"+ "(" + label + ")" + "\n\n";
}

std::string converter::traverseReference(ASTNode* root, int type) {
    return getMapping(REF_H) + root->data + "\n\n";
}

std::string converter::traverseChildren(ASTNode* root) {
    std::string result;
    for (auto& child : root->children) {
        result += traversal(child);
    }
    return result;
}

std::string converter::getMapping(int type) {
    return myMapping[type];
}

std::string converter::traverseParagraph(ASTNode* root, int type) {
    std::string result;
    ASTNode* temp = root->children[0];
    for (auto& child : temp->children) {
        result += traverseFont(child, child->node_type); 
    }
    for (auto& child : root->children) {
        result += traverseFont(child, child->node_type); 
    }
    
    return result + "\n\n";
}

void converter::printMarkdown(const std::string& s, const std::string& filename) {
    std::ofstream file(filename);
    if (file.is_open()) {
        file << s;
        file.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}
