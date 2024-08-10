# Compiler and flags
CXX = g++
CXXFLAGS = -Wall
LEX = flex
YACC = bison

# Target executable
TARGET = parser

# Source files
YACC_SRC = parser.y
LEX_SRC = lex.l
YACC_OUT = parser.tab.c
YACC_HDR = parser.tab.h
LEX_OUT = lex.yy.c

# Main build rule
all: $(TARGET)

# Rule for compiling the parser
$(YACC_OUT): $(YACC_SRC)
	$(YACC) -d $<

# Rule for compiling the lexer
$(LEX_OUT): $(LEX_SRC)
	$(LEX) $<

# Rule for linking objects and generating executable
$(TARGET): $(YACC_OUT) $(LEX_OUT)
	$(CXX) $(CXXFLAGS) -o $@ $(YACC_OUT) $(LEX_OUT) -ly

# Clean rule
clean:
	rm -f $(TARGET) $(YACC_OUT) $(YACC_HDR) $(LEX_OUT)

# Phony target to avoid conflicts with files named 'all' or 'clean'
.PHONY: all clean
