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
string output = "";

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
%type <ast> statement statement_list assigns
%type <ast> block vardecls
%type <ast> return 
%type <ast> methodcall methodargument methodarguments
%type <ast> methoddecls methoddecl methodblock vardefmethod vardefmethods methodtype
%type <ast> fielddecl fielddecls fieldtype
%type <ast> externtype externdefn externdefns externvar externvars
%type <ast> class
%type <ast> if

%right UMINUS
%left T_NOT
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_PLUS T_MINUS
%left T_EQ T_GEQ T_GT T_LEQ T_LT T_NEQ
%left T_AND
%left T_OR

%%

start: program

program: class
    {
        ProgramAST *prog = new ProgramAST((decafStmtList *)$1);
                if (printAST) {
                       output += getString(prog);
                }
        delete prog;
    }
    ;

statement_list: statement statement_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

// Class Def
// Program = Externs class identifier "{" FieldDecls MethodDecls "}" .
class: externdefns T_CLASS T_ID T_LCB fielddecls methoddecls T_RCB
      {$$ = new ClassAST($1,*$3,$5,$6);}
      ;

// Extern Def
externdefns: externdefn externdefns
            { decafStmtList *slist2= (decafStmtList *)$2; slist2->push_front($1); $$ = slist2; }
            | /* empty */ 
            { decafStmtList *slist2 = new decafStmtList(); $$ = slist2; }
            ;

externdefn: T_EXTERN externtype T_ID T_LPAREN T_RPAREN T_SEMICOLON
            { $$ = new ExternAST($2,*$3, NULL); }
            | T_EXTERN externtype T_ID T_LPAREN externvars T_RPAREN T_SEMICOLON
            { $$ = new ExternAST($2,*$3,$5);}
            ;

//ExternType = ( string | MethodType ) .
//MethodType = ( void | Type ) .
//Type = ( int | bool ) 

externvars: externvar externvars
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | externvar T_COMMA externvars
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

externvar:  T_STRINGTYPE
            {$$ = new VarDefExternAST(T_STRINGTYPE);}
            | T_INTTYPE
            {$$ = new VarDefExternAST(T_INTTYPE);}
            | T_BOOL
            {$$ = new VarDefExternAST(T_BOOL);}
            | T_VOID
            { $$ = new VarDefExternAST(T_VOID);}
            ;


externtype: T_STRINGTYPE
            {$$ = new StandAloneAST("StringType");}
            | T_INTTYPE
            {$$ = new StandAloneAST("IntType");}
            | T_BOOL
            {$$ = new StandAloneAST("BoolType");}
            | T_VOID
            { $$ = new StandAloneAST("VoidType");}
            ;


// Field Declarartions
fielddecls: fielddecl fielddecls
            { decafStmtList *slist2= (decafStmtList *)$2; slist2->push_front($1); $$ = slist2; }
            | /* empty */ 
            { decafStmtList *slist2 = new decafStmtList(); $$ = slist2; }
            ;

fielddecl: fieldtype T_ID T_ASSIGN constant T_SEMICOLON
         { $$ = new FieldDeclarationAST($1,*$2, $4);}
         | fieldtype T_ID T_SEMICOLON
         { $$ = new FieldDeclarationNoAssignAST($1,*$2);}
         ;

fieldtype: T_INTTYPE
        { $$ = new StandAloneAST("IntType"); }
        | T_BOOL
        { $$ = new StandAloneAST("BoolType");}
        ;


// Methods Declarations
methoddecls: methoddecl methoddecls
            { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
            | /* empty */ 
            { decafStmtList *slist = new decafStmtList(); $$ = slist; }
            ;

methoddecl : methodtype T_ID T_LPAREN T_RPAREN methodblock
             {$$ = new MethodDeclarationAST($1,*$2,NULL,$5);}
             | methodtype T_ID T_LPAREN vardefmethods T_RPAREN methodblock
             {$$ = new MethodDeclarationAST($1,*$2,$4,$6);}
             ;

methodtype: T_VOID
            {$$ = new StandAloneAST("VoidType");}
            | T_INTTYPE
            {$$ = new StandAloneAST("IntType");}
            | T_BOOL
            {$$ = new StandAloneAST("BoolType");}
            ;

methodblock: T_LCB vardecls statement_list T_RCB
      { $$ = new MethodBlockAST($2,$3);}
      ;

vardefmethods: vardefmethod vardefmethods
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | vardefmethod T_COMMA vardefmethods
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;


vardefmethod: T_INTTYPE T_ID      
        { $$ = new VarDefMethodAST(T_INTTYPE,*$2);}
        | T_VOID T_ID
        { $$ = new VarDefMethodAST(T_VOID,*$2);}
        ;

statement: assign T_SEMICOLON 
        { $$ = $1; }
        | if
        { $$ = $1; }
        | T_WHILE T_LPAREN expr T_RPAREN block
        { $$ = new WhileAST($3,$5);}
        | T_FOR T_LPAREN assigns T_SEMICOLON expr T_SEMICOLON assigns T_RPAREN block
        { $$ = new ForAST($3,$5,$7,$9);}
        | T_BREAK T_SEMICOLON
        { $$ = new StandAloneAST("BreakStmt");}
        | T_CONTINUE T_SEMICOLON
        { $$ = new StandAloneAST("ContinueStmt");}
        | methodcall T_SEMICOLON
        { $$ = $1;}
        | return
        { $$ = $1;}
        ;

if:   T_IF T_LPAREN expr T_RPAREN block
    { $$ = new IfElseAST($3,$5, NULL); }
    | T_IF T_LPAREN expr T_RPAREN block T_ELSE block
    { $$ = new IfElseAST($3,$5,$7); }

// return [expr]-optional semicolon
return:  T_RETURN T_SEMICOLON
         { $$ = new ReturnAST(NULL); }
         | T_RETURN T_LPAREN T_RPAREN T_SEMICOLON
         { $$ = new ReturnAST(NULL); }
         | T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON
         { $$ = new ReturnAST($3); }

block: T_LCB vardecls statement_list T_RCB
      { $$ = new BlockAST($2,$3);}
      ;

// Work in progress: sneed to add variable declaration
// still need to add more variables  int num1,num2,num3;
// VarDecl  = Type { identifier }+ ";" 
vardecls: /* empty */
        {$$ = new StandAloneAST("None");}


// recursion
assigns: assign assigns
        { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }

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
    | methodcall
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
    | expr T_LEFTSHIFT expr
    { $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3); }
    | expr T_RIGHTSHIFT expr
    { $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3); }
    | expr T_AND expr
    { $$ = new BinaryExprAST(T_AND, $1, $3); }
    | expr T_OR expr
    { $$ = new BinaryExprAST(T_OR, $1, $3); }
    | expr T_EQ expr
    { $$ = new BinaryExprAST(T_EQ, $1, $3); }
    | expr T_GEQ expr
    { $$ = new BinaryExprAST(T_GEQ, $1, $3); }
    | expr T_GT expr
    { $$ = new BinaryExprAST(T_GT, $1, $3); }
    | expr T_LEQ expr
    { $$ = new BinaryExprAST(T_LEQ, $1, $3); }
    | expr T_LT expr
    { $$ = new BinaryExprAST(T_LT, $1, $3); }
    | expr T_NEQ expr
    { $$ = new BinaryExprAST(T_NEQ, $1, $3); }
    | T_MINUS expr %prec UMINUS 
    { $$ = new UnaryExprAST(T_MINUS, $2); }
    | T_NOT expr
    { $$ = new UnaryExprAST(T_NOT, $2); }
    | T_LPAREN expr T_RPAREN
    { $$ = $2; }
    ;

// method calls (3 shift-reduce conflicts that need to be fixed)

methodcall: T_ID T_LPAREN T_RPAREN
        {$$ = new MethodCallAST(*$1, NULL); }
        |T_ID T_LPAREN methodarguments T_RPAREN
        { $$ = new MethodCallAST(*$1,$3); }
        

methodarguments: methodargument methodarguments
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | methodargument T_COMMA methodarguments
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist;}
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }

// missing string literal
methodargument: expr 
        {$$ = $1;}

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
  // 1: error 0: no error
    int retVal = yyparse();

    // Return error without displaying output b/c Syntax Error
    if(retVal){
    exit(1);
    }

    // Returns error if there is no input
    if(output.empty()){
    yyerror("");
        exit(1);
    }

    cout << output << endl;
    exit (0);
}
