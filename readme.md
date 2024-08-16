# LaTeX to Markdown Converter

## Overview

This project is a C++ application that converts LaTeX documents into Markdown format. It uses Flex and Bison for lexical analysis and parsing. The parser processes various LaTeX constructs, such as sections, lists, tables, and more, and converts them into equivalent Markdown representations.

## Features

- Convert LaTeX sections and subsections to Markdown headers.
- Handle ordered and unordered lists.
- Support for tables, figures, and verbatim text.
- Conversion of LaTeX formatting (bold, italic) to Markdown.
- Output Markdown to a file.

## Project Structure

- `main.cpp`: The main entry point of the application.
- `ast.h` / `ast.cpp`: Defines and implements the Abstract Syntax Tree (AST) for LaTeX documents.
- `converter.h` / `converter.cpp`: Contains the logic for converting AST nodes into Markdown format.
- `parser.y` / `lexer.l`: Defines the Flex and Bison rules for lexical analysis and parsing LaTeX.
- `README.md`: This file, providing an overview and documentation of the project.

## Dependencies

- Flex (Fast Lexical Analyzer Generator)
- Bison (GNU Parser Generator)
- C++11 or later (for certain features)

## Installation

1. **Install Flex and Bison:**
   - On Debian-based systems: `sudo apt-get install flex bison`
   - On Red Hat-based systems: `sudo yum install flex bison`

2. **Clone the repository:**

```bash
   git clone <repository_url>
   cd <repository_directory>
```
## Make

```bash
    make
```

## Usage

```bash
    ./compiler input.tex output.md
```

## Example Latex Code

```latex

    \section{Introduction}
    This is a sample document.

    \begin{itemize}
        \item Item 1
        \item Item 2
    \end{itemize}

    \begin{tabular}{|c|c|}
    \hline
    Header 1 & Header 2 \\
    \hline
    Data 1 & Data 2 \\
    \hline
    \end{tabular}

```
