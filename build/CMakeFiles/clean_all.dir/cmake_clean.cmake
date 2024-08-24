file(REMOVE_RECURSE
  "CMakeFiles/clean_all"
  "ast.txt"
  "lex.yy.cpp"
  "parser.tab.cpp"
  "parser.tab.h"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/clean_all.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
