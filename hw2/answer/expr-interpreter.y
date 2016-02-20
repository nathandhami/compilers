%{ 
#include "usingcpp-defs.h"
#include <stdio.h> 
#include <stdbool.h>
#include <math.h>

double symbolTable[26];
bool isSymbol[26];
%}


%union {
	char lvalue;
	double rvalue;
}

%token <rvalue> T_DOUBLE 
%token <rvalue> T_NUMBER 
%token <lvalue> T_NAME 
%token <rvalue> T_EXP 
%token <rvalue> T_SQRT 
%token <rvalue> T_LOG

%type <rvalue> expression
%type <rvalue> var

%%
statements: /*empty*/
		| statements statement
     	;

statement: T_NAME '=' expression {symbolTable[$1] = $3; isSymbol[$1]=true; }
	| T_NAME {printf("%f\n", symbolTable[$1]);}
	| T_EXP '(' expression ')' { printf("%f\n", log($3)); }
	| T_SQRT '(' expression ')' { printf("%f\n", log($3)); }
   	| T_LOG '(' expression ')' { printf("%f\n", log($3)); }
	| expression
   ;

expression: expression '+' var { $$ = $1 + $3;}
	| expression '-' var { $$ = $1 - $3;}
   	| var {$$ = $1;}
   	| T_EXP '(' expression ')' { $$ = exp($3); }
   	| T_SQRT '(' expression ')' { $$ = sqrt($3); }
   	| T_LOG '(' expression ')' { $$ = log($3); }
   ;

var: T_NUMBER {$$ = $1;}
	| T_DOUBLE {$$ = $1;}
   	| T_NAME {$$ = symbolTable[$1]; }
   ;

%%

