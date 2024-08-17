#include "converter.h"
#include <sstream>
#include <fstream>

int section_no = 0;          // Counter for sections
int subsection_no = 0;      // Counter for subsections
int subsubsection_no = 0;   // Counter for subsubsections
int nested = 0;             // Counter for nested lists
// Converts an integer to a string
std::string myString(int n) {
    std::stringstream ss;
    ss << n;
    return ss.str();
}

// Constructor initializes the mapping of node types to their Markdown representations
converter::converter() {
    myMapping[SECTION_H] = "##";              // Section (Markdown heading level 2)
    myMapping[SUBSECTION_H] = "###";          // Subsection (Markdown heading level 3)
    myMapping[SUBSUBSECTION_H] = "####";      // Subsubsection (Markdown heading level 4)
    myMapping[ITEMIZE_H] = "";                // Unordered list (Markdown list item)
    myMapping[ENUMERATE_H] = "";              // Ordered list (Markdown list item with number)
    myMapping[ITEM_H] = "- ";                 // List item (Markdown list item) - for ordered lists
    myMapping[TEXTBF_H] = "**";               // Bold text (Markdown bold)
    myMapping[TEXTIT_H] = "*";                // Italic text (Markdown italic)
    myMapping[UNDERLINE_H] = "<u>";           // Underline text (HTML underline tag)
    myMapping[PAR_H] = "";                    // Paragraph (not directly used in Markdown)
    myMapping[LABEL_H] = "";                  // Anchor label (not used in Markdown)
    myMapping[REF_H] = "";                    // Anchor reference (not used in Markdown)
    myMapping[TABULAR_H] = "";                // Table (not used directly in Markdown)
    myMapping[FIGURE_H] = "![]";              // Image placeholder (Markdown image)
    myMapping[INCLUDE_GRAPHICS_H] = "![]";    // Image (Markdown image)
    myMapping[CAPTION_H] = "";                // Figure caption (Markdown caption for images)
    myMapping[STRING_H] = "";                 // Generic string content
    myMapping[DATE_H] = "Date: ";             // Date (Markdown date representation)
    myMapping[TITLE_H] = "#";                 // Title (Markdown heading level 1)
    myMapping[VERBATIM_H] = "```";            // Verbatim text (Markdown code block)
    myMapping[HRULE_H] = "---";               // Horizontal rule (Markdown horizontal rule)
    myMapping[HREF_H] = "";                   // Hyperlink (Markdown link placeholder)
}

// Converts the entire AST starting from the root node
std::string converter::traversal(ASTNode* root) {
    if (!root) return "";  // Return empty string if root is null
    int type = root->node_type;
    switch (type) {
        case ITEM_H: return traversal(root->children[0]);  // Directly return item data
        case STRING_H: 
            {
                string str = root->data; 
                if (!root->children.empty()) 
                    return str +" "+traversal(root->children[0]); 
                return str;
            }
        case SECTION_H: return traverseSection(root, type);  // Handle section nodes
        case SUBSECTION_H: return traverseSubSection(root, type);  // Handle subsection nodes
        case SUBSUBSECTION_H: return traverseSubsubSection(root, type); // Handle subsubsection nodes
        case ITEMIZE_H:
        case ENUMERATE_H: return traverseList(root, type);  // Handle list nodes
        case VERBATIM_H: return traverseVerbatim(root, type);  // Handle verbatim nodes
        case TEXTBF_H:
        case TEXTIT_H:return traverseFont(root, type);  // Handle font formatting nodes
        case TITLE_H: return traverseTitle(root, type);  // Handle title nodes
        case DATE_H: return traverseDate(root, type);  // Handle date nodes
        case FIGURE_H: return traverseFigure(root, type);  // Handle figure nodes
        case REF_H: return traverseReference(root, type);  // Handle reference nodes
        case HRULE_H: return "\n\n---\n\n";  // Handle horizontal rules
        case PAR_H: return traverseParagraph(root, type);  // Handle paragraph nodes
        case HREF_H: return traverseHref(root, type);  // Handle hyperlink nodes
        case TABULAR_H: return traverseTable(root, type);  // Handle table nodes
        default: return traverseChildren(root);  // Handle unknown or other node types
    }
}

// Converts a SECTION node to Markdown format
std::string converter::traverseSection(ASTNode* root, int type) {
    section_no++;
    subsection_no = 0;
    subsubsection_no = 0;
    return getMapping(type) + " " + myString(section_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

// Converts a SUBSECTION node to Markdown format
std::string converter::traverseSubSection(ASTNode* root, int type) {
    subsection_no++;
    subsubsection_no = 0;
    return getMapping(type) + " " + myString(section_no) + "." + myString(subsection_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

// Converts a SUBSUBSECTION node to Markdown format
std::string converter::traverseSubsubSection(ASTNode* root, int type) {
    subsubsection_no++;
    return getMapping(type) + " " + myString(section_no) + "." + myString(subsection_no) + "." + myString(subsubsection_no) + " " + root->data + "\n\n" + traverseChildren(root);
}

// Converts LIST nodes (either ITEMIZE or ENUMERATE) to Markdown format
std::string converter::traverseList(ASTNode* root, int type) {
    std::string result = "\n";
    std::string indent(nested, '\t');  // Create indentation based on nesting level

    if (type == ITEMIZE_H) {
        // Handle unordered list
        for (const auto& child : root->children) {
            if (child->node_type == ITEM_H) {
                std::string itemText = traversal(child->children[0]);
                if (!itemText.empty() && itemText != "\n" && itemText != " ") {
                    result += indent + "- " + itemText + "\n";
                }

                // Handle nested lists
                if (child->children.size() > 1) {
                    nested++;
                    result += traverseList(child->children[1], type);  // Recursively handle nested lists
                    nested--;
                }
            }
        }

        for (const auto& child : root->children[0]->children) {
            if (child->node_type == ITEM_H) {
                std::string itemText = traversal(child->children[0]);
                if (!itemText.empty() && itemText != "\n" && itemText != " ") {
                    result += indent + "- " + itemText + "\n";
                }

                // Handle nested lists
                // if (child->children.size() > 1) {
                //     nested++;
                //     result += traverseList(child->children[1], type);  // Recursively handle nested lists
                //     nested--;
                // }
            }
        }

    } else {
        // Handle ordered list
        int count = 1;
        int idx = 1;
        ASTNode* temp;
        for (const auto& child : root->children) {
            if (child->node_type == ITEM_H) {
                std::string itemText = traversal(child->children[0]);
                if (!itemText.empty() && itemText != "\n" && itemText != " ") {
                    result += indent + std::to_string(count) + ". " + itemText + "\n";
                    count++;
                }

                // Handle nested lists
                if (child->children.size() > 1) {
                    nested++;
                    temp = child;
                    result += traverseList(child->children[idx], type);  // Recursively handle nested lists
                    idx++;
                    nested--;
                }
            }
        }
        
        for (const auto& child : root->children[0]->children) {
            if (child->node_type == ITEM_H) {
                std::string itemText = traversal(child->children[0]);
                if (!itemText.empty() && itemText != "\n" && itemText != " ") {
                    result += indent + std::to_string(count) + ". " + itemText + "\n";
                    count++;
                }

                // Handle nested lists
                if (child->children.size() > 1) {
                    nested++;
                    result += traverseList(temp->children[idx], type);  // Recursively handle nested lists  
                    idx++;                  
                    nested--;
                }
            }
        }

    }

    return result+"\n";
}


// Converts VERBATIM nodes (code blocks) to Markdown format
std::string converter::traverseVerbatim(ASTNode* root, int type) {
    return "\n\n" + getMapping(type) + "\n" + root->data + "\n" + getMapping(type) + "\n\n";
}

// Converts font formatting nodes (e.g., bold, italic) to Markdown format
std::string converter::traverseFont(ASTNode* root, int type) {
    return getMapping(type) + root->data + getMapping(type) + "\n";
}

// Converts DATE nodes to Markdown format
std::string converter::traverseDate(ASTNode* root, int type) {
    if(root->data.empty()) return "";
    return getMapping(type) + root->data + "\n\n";
}

// Converts TITLE nodes to Markdown format
std::string converter::traverseTitle(ASTNode* root, int type) {
    if(root->data.empty()) return "";
    return getMapping(type) + " " + root->data + "\n\n";
}

// Converts FIGURE nodes to Markdown format
std::string converter::traverseFigure(ASTNode* root, int type) {
    std::string result = getMapping(FIGURE_H) + "(" + root->data + ")";
    for (auto& child : root->children) {
        if (child->node_type == CAPTION_H) {
            result += " " + getMapping(CAPTION_H) + " \"" + child->data + "\"";
        }
    }
    return result + "\n\n";
}


// Converts HREF nodes (hyperlinks) to Markdown format
std::string converter::traverseHref(ASTNode* root, int type) {
    std::string data = root->data, link="", label="";
    bool flag = true;
    for(auto x: data){
        if(x == '#'){ flag = false; continue;}
        if(flag) link += x;
        else label += x;
    }
    return getMapping(HREF_H) + "[" + link + "]" + "(" + label + ")" + "\n\n";
}

// Converts REFERENCE nodes to Markdown format
std::string converter::traverseReference(ASTNode* root, int type) {
    return getMapping(REF_H) + root->data + "\n\n";
}

// Traverses and processes all child nodes
std::string converter::traverseChildren(ASTNode* root) {
    std::string result;
    for (auto& child : root->children) {
        result += traversal(child);
    }
    return result;
}

// Retrieves the string representation for a given node type from the mapping
std::string converter::getMapping(int type) {
    return myMapping[type];
}

// Converts TABLE nodes to Markdown format
std::string converter::traverseTable(ASTNode* root, int type) {
    std::string result;
    int count = 0;
    // Iterate through all rows in the table
    for (auto row : root->children) {
        if (row->node_type == ROW_H) {
            std::string rowResult;
            // Iterate through all cells in the row
            for (auto cell : row->children) {
                if (cell->node_type == CELL_H) {
                    // Extract cell data and add it to the row string
                    std::string cellData = " | ";
                    for (auto innerCell : cell->children) {
                        if (innerCell->node_type == CELL_H) {
                            cellData += traversal(innerCell) + " | ";
                        }
                        count++;
                    }

                    // Add cell data to the row with formatting
                    rowResult += cellData + " | ";
                }
            }
            // Trim the last pipe character and add a newline after the row
            if (!rowResult.empty()) {
                rowResult = rowResult.substr(0, rowResult.length() - 3); // Remove trailing " | "
            }
            rowResult += "\n";
            result += rowResult;
        }
    }

    for (auto row : root->children[0]->children) {
        if (row->node_type == ROW_H) {
            std::string rowResult;

            // Iterate through all cells in the row
            for (auto cell : row->children) {
                if (cell->node_type == CELL_H) {
                    // Extract cell data and add it to the row string
                    std::string cellData = " | ";
                    for (auto innerCell : cell->children) {
                        if (innerCell->node_type == CELL_H) {
                            cellData += traversal(innerCell)+" | ";
                        }
                    }

                    // Add cell data to the row with formatting
                    rowResult += cellData + " | ";
                }
            }
            // Trim the last pipe character and add a newline after the row
            if (!rowResult.empty()) {
                rowResult = rowResult.substr(0, rowResult.length() - 3); 
            }
            rowResult += "\n";
            result += rowResult;
        }
    }

    // Adding formatting (e.g., column separators)
    if (!result.empty()) {
        // Add a separator line after the header (first row)
        size_t pos = result.find('\n');
        if (pos != std::string::npos) {
            std::string separator(pos, '-'); // Create a separator line of dashes
            int len = separator.length();
            int p = len/count;
            count--;
            while(p<len && count--){
                separator[p] = '|';
                p*=2;
            }
            result.insert(pos + 1, separator + "\n"); // Insert after the first row
        }
    }
    return result;
}

// Converts PARAGRAPH nodes to Markdown format
std::string converter::traverseParagraph(ASTNode* root, int type) {
    std::string result;
    ASTNode* temp = root->children[0];
    for (auto& child : temp->children) {
        result += traverseFont(child, child->node_type); 
    }
    for (auto& child : root->children) {
        result += "\n\n"+traverseFont(child, child->node_type); 
    }
    
    return result + "\n\n";
}

// Writes the converted Markdown content to a specified file
void converter::printMarkdown(const std::string& s, const std::string& filename) {
    std::ofstream file(filename);
    if (file.is_open()) {
        file << s;
        file.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}
