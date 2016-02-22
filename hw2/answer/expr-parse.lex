%{
using namespace std;
#include "usingcpp-defs.h"
#include "expr-parse.tab.h"
#include <stdlib.h>
%}

%%
\+		 { yylval.value = atoi(yytext); return PLUS; }
\*		 { yylval.value = atoi(yytext); return TIMES; }
"("       { yylval.str = strdup(yytext); return L_PAREN;}
")" 		 { yylval.str = strdup(yytext); return R_PAREN;}
[a-z|A-Z|_]+[a-z|A-Z|_|0-9]*  { yylval.str = strdup(yytext); return ID; }
[ \t\n]	
.        return yytext[0];
%%
