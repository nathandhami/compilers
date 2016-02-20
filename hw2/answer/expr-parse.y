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

%type <value> factor

%%
expression: /*empty*/
		| expression PLUS term {}
     	| term
     	;

term: 
     | term TIMES factor  {;}
     | factor 
     ;

factor: L_PAREN expression R_PAREN {}
     | ID { }
     ;
%%

