%{ 
#include "usingcpp-defs.h"
#include <stdio.h> 
#include <stdbool.h>
#include <iostream>
#include <ostream>
#include "expr-ast.cpp"

bool printAST = true;
string output = "";

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
%type <ast> statement_list



%%

start: program

program:  |
    statement_list
    {
        ProgramAST *prog = new ProgramAST((exprStmtList *)$1);
                if (printAST) {
                        output += getString(prog);
                }

        delete prog;
    }


statement_list: expression statement_list
    { exprStmtList *slist = (exprStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { exprStmtList *slist = new exprStmtList(); $$ = slist; }
    ;

expression: 
      expression PLUS term                {$$ = new BinaryExprAST(PLUS,$1,$3);}
    | term                                {$$ = new TermExprAst($1);}
    ;

term: 
      term TIMES factor                   {$$ = new BinaryExprAST(TIMES, $1, $3);}
    | factor                              {$$ = new FactorExprAst($1);}
    ;

factor: 
	  L_PAREN expression R_PAREN          {$$ = new FactorExprAst(L_PAREN,$2,R_PAREN);}
    | ID                                  {$$ = new VariableExprAST($1);}
    ;
%%

// 
int main(){
    // 1: error 0: no error
    int retVal = yyparse();

    // Return error without displaying output b/c Syntax Error
    if(retVal){
    exit(1);
    }

    // Returns error if there is no input
    if(output.empty()){
    yyerror("syntax error");
        exit(1);
    }

    cout << output << endl;
    exit (0);

}
