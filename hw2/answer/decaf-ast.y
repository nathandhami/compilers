%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "usingcpp-defs.h"

int yylex(void);
int yyerror(char *); 

using namespace std;

// print AST?
bool printAST = true;

#include "decaf-ast.cc"

%}

%union{
    class decafAST *ast;
    std::string *sval;
    int number;
    int decaftype;
 }


%token T_AND T_ASSIGN T_BOOL T_BREAK 
%token T_CLASS T_COMMA T_COMMENT T_CONTINUE T_DIV 
%token T_DOT T_ELSE T_EQ T_EXTENDS T_EXTERN 
%token T_FOR T_GEQ T_GT T_IF T_INTTYPE 
%token T_LCB T_LEFTSHIFT T_LEQ T_LPAREN T_LSB T_LT T_MINUS 
%token T_MOD T_MULT T_NEQ T_NEW T_NOT T_NULL T_OR T_PLUS 
%token T_RCB T_RETURN T_RIGHTSHIFT T_RPAREN T_RSB T_SEMICOLON 
%token T_STRINGTYPE T_VOID T_WHILE T_WHITESPACE

%token <number> T_CHARCONSTANT T_INTCONSTANT T_FALSE T_TRUE
%token <sval> T_ID T_STRINGCONSTANT

%type <ast> rvalue expr constant bool_constant assign
%type <ast> statement statement_list

%right UMINUS
%left T_NOT
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_PLUS T_MINUS
%left T_EQ T_GEQ T_GT T_LEQ T_LT T_NEQ
%left T_AND
%left T_OR

%%

start: program

program: statement_list
    {
        ProgramAST *prog = new ProgramAST((decafStmtList *)$1);
                if (printAST) {
                        cout << getString(prog) << endl;
                }
        delete prog;
    }


statement_list: statement statement_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

statement: assign T_SEMICOLON { $$ = $1; }

assign: T_ID T_ASSIGN expr
    { $$ = new AssignVarAST(*$1, $3); delete $1; }
    ;

rvalue: T_ID
    { $$ = new VariableExprAST(*$1); delete $1; }
    ;

expr: rvalue
    { $$ = $1; }
    | constant
    { $$ = $1; }
    | expr T_PLUS expr
    { $$ = new BinaryExprAST(T_PLUS, $1, $3); }
    | expr T_MINUS expr
    { $$ = new BinaryExprAST(T_MINUS, $1, $3); }
    | expr T_MULT expr
    { $$ = new BinaryExprAST(T_MULT, $1, $3); }
    | expr T_DIV expr
    { $$ = new BinaryExprAST(T_DIV, $1, $3); }
    | expr T_MOD expr
    { $$ = new BinaryExprAST(T_MOD, $1, $3); }
    | T_MINUS expr %prec UMINUS 
    { $$ = new UnaryExprAST(T_MINUS, $2); }
    | T_NOT expr
    { $$ = new UnaryExprAST(T_NOT, $2); }
    | T_LPAREN expr T_RPAREN
    { $$ = $2; }
    ;

constant: T_INTCONSTANT
    { $$ = new NumberExprAST($1); }
    | T_CHARCONSTANT
    { $$ = new NumberExprAST($1); }
    | bool_constant
    { $$ = $1; }
    ;

bool_constant: T_TRUE
    { $$ = new BoolExprAST(true); }
    | T_FALSE 
    { $$ = new BoolExprAST(false); }
    ;

%%

int main() {
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  return(retval >= 1 ? 1 : 0);
}
