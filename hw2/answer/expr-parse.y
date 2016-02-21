%{ 
#include "usingcpp-defs.h"
#include <stdio.h> 
#include <stdbool.h>
#include <iostream>
#include <ostream>
#include "expr-ast.cpp"

using namespace std;
%}

%union {
    class exprParseAST *ast;
    char *str;
    int value;
}

%token <value> PLUS 
%token <value> TIMES 
%token <str> L_PAREN 
%token <str> R_PAREN
%token <str> ID

%type <ast> factor term expression

%start expression

%%
expression: 
      expression PLUS term                {$$ = new BinaryExprAST(PLUS,$1,$3);}
    | term                                {$$ = $1;}
    ;

term: 
      term TIMES factor                   {$$ = new BinaryExprAST(TIMES, $1, $3);}
    | factor                              {$$ = $1;}
    ;

factor: 
      L_PAREN expression R_PAREN          {$$ = $2;}
    | ID                                  {$$ = new VariableExprAST($1); VariableExprAST *sa = new VariableExprAST($1); cout << getString(sa) << endl;}
    ;
%%