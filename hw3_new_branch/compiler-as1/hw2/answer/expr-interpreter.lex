%{
using namespace std;
#include "usingcpp-defs.h"
#include "expr-interpreter.tab.h"
#include <stdlib.h>
%}

%%
[1-9][0-9]*\.[0-9][0-9]*	{ yylval.rvalue = atof(yytext); return T_DOUBLE; }
[0-9][0-9]*   			{ yylval.rvalue = atof(yytext); return T_NUMBER; }
exp				{ yylval.rvalue = 1; return T_EXP; }
sqrt				{ yylval.rvalue = 1; return T_SQRT; }
log				{ yylval.rvalue = 1; return T_LOG; }
[a-z]    			{ yylval.lvalue = yytext[0]; return T_NAME; }
[ \t\n]  /* ignore whitespace */
.        return yytext[0];
%%
