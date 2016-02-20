%{ 
#include "usingcpp-defs.h"
#include <stdio.h> 
#include <stdbool.h>
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
%}

%union {
    char *str;
    int value;
}

%token <value> PLUS 
%token <value> TIMES 
%token <str> L_PAREN 
%token <str> R_PAREN
%token <str> ID

%type <str> factor
%type <str> term
%type <str> expression

%%
expression: expression PLUS term {printf("%s + %s\n", $1,$3);}
     	| term {$$ = $1;}
     	;

term: term TIMES factor  {printf("%s * %s\n", $1,$3);}
     | factor { $$ = $1;}
     ;

factor: 
     | L_PAREN expression R_PAREN {printf("( %s ) ", $2);}
     | ID {printf("ID: %s\n", $1);}
     ;
%%

