%{ 
#include <stdio.h> 
#include <stdbool.h>
int symbolTable[26];
bool isSymbol[26];

%}

%union {
	char lvalue;
	int rvalue;
}

%token <lvalue> NAME
%token <rvalue> NUMBER

%type <rvalue> expression
%type <rvalue> var

%%
statements: /*empty*/
		| statements statement
     	;

statement: NAME '=' expression { symbolTable[$1] = $3; isSymbol[$1]=true; }
	 | NAME {
		if (!isSymbol[$1]) {
			fprintf(stderr, "Error: multi-character variables not allowed");
			yyerror();
		}
		printf("%d\n", symbolTable[$1]);}
	 | expression  { printf("%d\n", $1);}
     ;

expression: expression '+' var { $$ = $1 + $3;}
     | expression '-' var { $$ = $1 - $3; }
     | var {$$ = $1; }
     ;

var: NUMBER {$$ = $1;}
   | NAME {
		if (isSymbol[$1]) {
			$$ = symbolTable[$1];
		} else {
			fprintf(stderr, "Error: variable %c not previously defined", $1);
			yyerror();
		}
	}
   ;

%%



