%{
#include "exprdefs.h"
#include "expr-codegen.tab.h"
#include <stdlib.h>
#include <cstring>
#include <string>
#include <sstream>
#include <iostream>

int get_intconstant(const char *s) {
  if ((s[0] == '0') && (s[1] == 'x')) {
    int x;
    sscanf(s, "%x", &x);
    return x;
  } else {
    return atoi(s);
  }
}

%}
%%
\/                           { return T_DIV; }
==                           { return T_EQ; }
(0x[0-9a-fA-F]+)|([0-9]+)    { yylval.number = get_intconstant(yytext); return T_INTCONSTANT; }
\<<                          { return T_LEFTSHIFT; }
\<                           { return T_LT; }
-                            { return T_MINUS; }
\%                           { return T_MOD; }
\*                           { return T_MULT; }
\>>                          { return T_RIGHTSHIFT; }
\+                           { return T_PLUS; }
[ \t\n]  ;
.        return yytext[0];
%%
