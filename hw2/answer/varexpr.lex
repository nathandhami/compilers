%{
#include "varexpr.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+   { yylval.rvalue = atoi(yytext); return NUMBER; }
[a-z]    { yylval.lvalue = yytext[0]; return NAME; }
[ \t\n]  /* ignore whitespace */
.        return yytext[0];
%%
