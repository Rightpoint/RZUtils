# patch for apostrophe handling (including Unicode apostrophe)
s/\(RIGHTHYPHENMIN.*\)/\1\
COMPOUNDLEFTHYPHENMIN 2\
COMPOUNDRIGHTHYPHENMIN 3\
NOHYPHEN -,',’\
1-1\
1'1\
1’1\
NEXTLEVEL/
