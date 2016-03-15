%{
#include <iostream>
#include <ostream>
#include <string>
#include <cstdlib>
#include "usingcpp-defs.h"
#include <map>


int yylex(void);
int yyerror(char *); 
extern int lineno;

using namespace std;

// print AST?
bool printAST = true;

#include "decaf-sym.cc"



struct descriptor{
    string *location;
    string varname;
    int lineno;
    int type;
};


// type declarations
typedef map<string, descriptor*> symbol_table;

typedef list<symbol_table*> symbol_table_list;


// prototypes

int getLineNumberOfVar(string);
void updateSymTable(string ,descriptor *);
int getTypeFromPreviousVar(int);
descriptor* access_symtbl(string);

// program stack
symbol_table_list symtbl_list;

// active record
symbol_table *currentSymTable;



// FUNCTIONS
// ------------------

descriptor* access_symtbl(string ident) {
for (symbol_table_list::iterator i = symtbl_list.begin(); i != symtbl_list.end(); ++i) {
symbol_table::iterator find_ident;
if ((find_ident = (*i)->find(ident)) != (*i)->end())
return find_ident->second;
}
return NULL;
}

// int a,b,c; retrieves the s type from previous var declaration
int getTypeFromPreviousVar(int lineno) {

    for(symbol_table::iterator i = currentSymTable->begin(); i!= currentSymTable->end(); ++i){
       if(i->second->lineno == lineno){
       return i->second->type;
       }
    }
return 0;
}

void updateSymTable(string ident,descriptor *variableInfo){

    currentSymTable = symtbl_list.front();
    //currentSymTable[ident]->lineno = variableInfo.

    (*currentSymTable)[ident] = variableInfo;
    //symbol_table *yes = symtbl_list.front();

    //cout << (*yes)[ident]->location << endl;
    //cout << currentSymTable[ident]->varname << endl;
    //cout << currentSymTable[ident]->type << endl;
    //cout << currentSymTable[ident]->lineno << endl;
}

int getLineNumberOfVar(string ident){

   descriptor* getDesc = access_symtbl(ident);

   if (getDesc!=NULL)
  // cout << (*getDesc).lineno;
   return (*getDesc).lineno;
}


%}

%union{
    class decafAST *ast;
    std::string *sval;
    int number;
    int decaftype;
 }

%token T_AND T_ASSIGN T_BREAK T_CLASS T_COMMENT T_COMMA T_CONTINUE T_DIV T_DOT T_ELSE T_EQ T_EXTENDS T_EXTERN 
%token T_FOR T_GEQ T_GT T_IF T_LCB T_LEFTSHIFT T_LEQ T_LPAREN T_LSB T_LT T_MINUS T_MOD T_MULT T_NEQ T_NEW T_NOT 
%token T_NULL T_OR T_PLUS T_RCB T_RETURN T_RIGHTSHIFT T_RPAREN T_RSB T_SEMICOLON T_STRINGTYPE
%token T_VOID T_WHILE T_WHITESPACE
%token T_INTTYPE T_BOOL

%token <number> T_CHARCONSTANT T_INTCONSTANT T_FALSE T_TRUE 
%token <sval> T_ID T_STRINGCONSTANT

%type <decaftype> type method_type extern_type
%type <ast> rvalue expr constant bool_constant method_call method_arg method_arg_list assign assign_comma_list
%type <ast> block method_block statement statement_list var_decl_list var_decl var_list param_list param_comma_list 
%type <ast> method_decl method_decl_list field_decl_list field_decl field_list extern_type_list extern_defn
%type <ast> extern_list decafclass

%left T_OR
%left T_AND
%left T_EQ T_NEQ T_LT T_LEQ T_GEQ T_GT
%left T_PLUS T_MINUS
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_NOT
%right UMINUS

%%

start: program

program: extern_list decafclass
    { 
        ProgramAST *prog = new ProgramAST((decafStmtList *)$1, (ClassAST *)$2); 
        if (printAST) {
           // cout << getString(prog) << endl;
        }
        delete prog;
    }

extern_list: extern_list extern_defn
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | /* extern_list can be empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

extern_defn: T_EXTERN method_type T_ID T_LPAREN extern_type_list T_RPAREN T_SEMICOLON
    { $$ = new ExternAST((decafType)$2, *$3, (TypedSymbolListAST *)$5); delete $3; }
    | T_EXTERN method_type T_ID T_LPAREN T_RPAREN T_SEMICOLON
    { $$ = new ExternAST((decafType)$2, *$3, NULL); delete $3; }
    ;

extern_type_list: extern_type
    { $$ = new TypedSymbolListAST(string(""), (decafType)$1); }
    | extern_type T_COMMA extern_type_list
    { 
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$3; 
        tlist->push_front(string(""), (decafType)$1); 
        $$ = tlist;
    }
    ;

extern_type: T_STRINGTYPE
    { $$ = stringTy; }
    | type
    { $$ = $1; }
    ;

decafclass: T_CLASS T_ID block_begin field_decl_list method_decl_list block_end
    { $$ = new ClassAST(*$2, (FieldDeclListAST *)$4, (decafStmtList *)$5); delete $2; }
    | T_CLASS T_ID block_begin field_decl_list block_end
    { $$ = new ClassAST(*$2, (FieldDeclListAST *)$4, new decafStmtList()); delete $2; }
    ;

field_decl_list: field_decl_list field_decl
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | /* empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

// still need to work on
field_decl: field_list T_SEMICOLON
    { $$ = $1; }
    | type T_ID T_ASSIGN constant T_SEMICOLON
    {  descriptor *variableInfo; 
    variableInfo = new descriptor();
    (*variableInfo).type = $1; 
    (*variableInfo).location = (string*)$2; 
    (*variableInfo).varname = *$2; 
    (*variableInfo).lineno = lineno; 

    updateSymTable(*$2, variableInfo); 
    $$ = new AssignGlobalVarAST((decafType)$1, *$2, $4); delete $2; }
    ;
// array decl?
field_list: field_list T_COMMA T_ID
    { 
    descriptor *variableInfo; 
    variableInfo = new descriptor();
    (*variableInfo).type = getTypeFromPreviousVar(lineno); 
    (*variableInfo).location = (string*)$3; 
    (*variableInfo).varname = *$3; 
    (*variableInfo).lineno = lineno; 
    updateSymTable(*$3, variableInfo); 

    FieldDeclListAST *flist = (FieldDeclListAST *)$1; flist->new_sym(*$3, -1); $$ = flist; delete $3; }
    | field_list T_COMMA T_ID T_LSB T_INTCONSTANT T_RSB
    { FieldDeclListAST *flist = (FieldDeclListAST *)$1; flist->new_sym(*$3, $5); $$ = flist; delete $3; }
    | type T_ID
    { 
    descriptor *variableInfo; 
    variableInfo = new descriptor();
    (*variableInfo).type = $1; 
    (*variableInfo).location = (string*)$2; 
    (*variableInfo).varname = *$2; 
    (*variableInfo).lineno = lineno; 
    updateSymTable(*$2, variableInfo); 
    $$ = new FieldDeclListAST(*$2, (decafType)$1, -1); delete $2; }
    | type T_ID T_LSB T_INTCONSTANT T_RSB
    { $$ = new FieldDeclListAST(*$2, (decafType)$1, $4); delete $2; }
    ;

method_decl_list: method_decl_list method_decl 
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | method_decl
    { decafStmtList *slist = new decafStmtList(); slist->push_back($1); $$ = slist; }
    ;

method_decl: T_VOID T_ID method_begin param_list T_RPAREN method_block
    { $$ = new MethodDeclAST(voidTy, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    | type T_ID method_begin param_list T_RPAREN method_block
    { $$ = new MethodDeclAST((decafType)$1, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    ;

method_begin: T_LPAREN
    { symbol_table* newSymTable = new symbol_table(); symtbl_list.push_front(newSymTable); }



method_type: T_VOID
    { $$ = voidTy; }
    | type
    { $$ = $1; }
    ;

param_list: param_comma_list
    { $$ = $1; }
    | /* empty */
    { $$ = NULL; }
    ;

param_comma_list: type T_ID T_COMMA param_comma_list
    { 
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$4; 
        tlist->push_front(*$2, (decafType)$1); 
        $$ = tlist;
        descriptor *variableInfo; 
        variableInfo = new descriptor();
        (*variableInfo).type = $1; 
        (*variableInfo).location = (string*)$2; 
        (*variableInfo).varname = *$2; 
        (*variableInfo).lineno = lineno; 
         updateSymTable(*$2, variableInfo);
        delete $2;
    }
    | type T_ID
    {  
        descriptor *variableInfo; 
        variableInfo = new descriptor();
        (*variableInfo).type = $1; 
        (*variableInfo).location = (string*)$2; 
        (*variableInfo).varname = *$2;
         (*variableInfo).lineno = lineno; 
        updateSymTable(*$2, variableInfo);
       $$ = new TypedSymbolListAST(*$2, (decafType)$1); delete $2; }
    ;

type: T_INTTYPE
    { $$ = intTy; 
    }
    | T_BOOL
    { $$ = boolTy; }
    ;

block: block_begin var_decl_list statement_list block_end
    {
    $$ = new BlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

method_block: T_LCB var_decl_list statement_list block_end
    { $$ = new MethodBlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

block_begin: T_LCB
    {     symbol_table* newSymTable = new symbol_table(); symtbl_list.push_front(newSymTable);           }

block_end: T_RCB
    {        symtbl_list.pop_front();}




var_decl_list: var_decl var_decl_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

var_decl: var_list T_SEMICOLON
    { $$ = $1; }

var_list: var_list T_COMMA T_ID
    { 
        TypedSymbolListAST *tlist = (TypedSymbolListAST *)$1; 
        tlist->new_sym(*$3); 
        $$ = tlist;

        descriptor *variableInfo;
        variableInfo = new descriptor();
        (*variableInfo).type = getTypeFromPreviousVar(lineno);
         (*variableInfo).location = (string*)$3; 
         (*variableInfo).varname = *$3; 
         (*variableInfo).lineno = lineno; 

        updateSymTable(*$3, variableInfo);


        delete $3;
    }
    | type T_ID
    { $$ = new TypedSymbolListAST(*$2, (decafType)$1); 
      descriptor *variableInfo; 
      variableInfo = new descriptor();
      (*variableInfo).type = $1; 
      (*variableInfo).location = (string*)$2; 
      (*variableInfo).varname = *$2; 
      (*variableInfo).lineno = lineno; 
      updateSymTable(*$2, variableInfo);
      delete $2; 
    }
    ;

statement_list: statement statement_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;

statement: assign T_SEMICOLON
    { $$ = $1;}
    | method_call T_SEMICOLON
    { $$ = $1; }
    | T_IF T_LPAREN expr T_RPAREN block T_ELSE block
    { $$ = new IfStmtAST($3, (BlockAST *)$5, (BlockAST *)$7); }
    | T_IF T_LPAREN expr T_RPAREN block 
    { $$ = new IfStmtAST($3, (BlockAST *)$5, NULL); }
    | T_WHILE T_LPAREN expr T_RPAREN block
    { $$ = new WhileStmtAST($3, (BlockAST *)$5); }
    | T_FOR T_LPAREN assign_comma_list T_SEMICOLON expr T_SEMICOLON assign_comma_list T_RPAREN block
    { $$ = new ForStmtAST((decafStmtList *)$3, $5, (decafStmtList *)$7, (BlockAST *)$9); }
    | T_RETURN T_LPAREN expr T_RPAREN T_SEMICOLON
    { $$ = new ReturnStmtAST($3); }
    | T_RETURN T_LPAREN T_RPAREN T_SEMICOLON
    { $$ = new ReturnStmtAST(NULL); }
    | T_RETURN T_SEMICOLON
    { $$ = new ReturnStmtAST(NULL); }
    | T_BREAK T_SEMICOLON
    { $$ = new BreakStmtAST(); }
    | T_CONTINUE T_SEMICOLON
    { $$ = new ContinueStmtAST(); }
    | block
    { $$ = $1; }
    ;

assign: T_ID T_ASSIGN expr
    { cout << " // using decl on line: " << getLineNumberOfVar(*$1); 
      $$ = new AssignVarAST(*$1, $3); delete $1; }
    | T_ID T_LSB expr T_RSB T_ASSIGN expr
    { $$ = new AssignArrayLocAST(*$1, $3, $6); delete $1; }
    ;

method_call: T_ID T_LPAREN method_arg_list T_RPAREN
    { $$ = new MethodCallAST(*$1, (decafStmtList *)$3); delete $1; }
    | T_ID T_LPAREN T_RPAREN
    { $$ = new MethodCallAST(*$1, (decafStmtList *)NULL); delete $1; }
    ;

method_arg_list: method_arg
    { decafStmtList *slist = new decafStmtList(); slist->push_front($1); $$ = slist; }
    | method_arg T_COMMA method_arg_list
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist; }
    ;

method_arg: expr
    { $$ = $1; }
    | T_STRINGCONSTANT
    { $$ = new StringConstAST(*$1); delete $1; }
    ;
   
assign_comma_list: assign
    { decafStmtList *slist = new decafStmtList(); slist->push_front($1); $$ = slist; }
    | assign T_COMMA assign_comma_list
    { decafStmtList *slist = (decafStmtList *)$3; slist->push_front($1); $$ = slist; }
    ;

rvalue: T_ID
    { cout << " // using decl on line: " << getLineNumberOfVar(*$1); $$ = new VariableExprAST(*$1); delete $1; }
    | T_ID T_LSB expr T_RSB
    { $$ = new ArrayLocExprAST(*$1, $3); delete $1; }
    ;

expr: rvalue
    { $$ = $1; }
    | method_call
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
    | expr T_LEFTSHIFT expr
    { $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3); }
    | expr T_RIGHTSHIFT expr
    { $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3); }
    | expr T_MOD expr
    { $$ = new BinaryExprAST(T_MOD, $1, $3); }
    | expr T_LT expr
    { $$ = new BinaryExprAST(T_LT, $1, $3); }
    | expr T_GT expr
    { $$ = new BinaryExprAST(T_GT, $1, $3); }
    | expr T_LEQ expr
    { $$ = new BinaryExprAST(T_LEQ, $1, $3); }
    | expr T_GEQ expr
    { $$ = new BinaryExprAST(T_GEQ, $1, $3); }
    | expr T_EQ expr
    { $$ = new BinaryExprAST(T_EQ, $1, $3); }
    | expr T_NEQ expr
    { $$ = new BinaryExprAST(T_NEQ, $1, $3); }
    | expr T_AND expr
    { $$ = new BinaryExprAST(T_AND, $1, $3); }
    | expr T_OR expr
    { $$ = new BinaryExprAST(T_OR, $1, $3); }
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