%{ 
#include <stdio.h> 
#include <stdbool.h>
%}

%token NAME NUMBER

%%
statements: /*empty*/
		| statements statement
     	;

statement: NAME '=' expression { printf("%c = %d\n", $1, $3);}
     | expression  { printf("%d\n", $1); }
     ;

expression: expression '+' NUMBER { $$ = $1 + $3; }
     | expression '-' NUMBER { $$ = $1 - $3; }
     | NUMBER { $$ = $1; }
     ;
%%

