%{ 
#include <iostream>
#include <ostream>
#include "exprdefs.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/Verifier.h"
#include <cstdio> 
#include <stdexcept>


using namespace llvm;
using namespace std;

#include "decaf-ast.cc"

bool printAST = true;
bool debugging = true;

// this global variable contains all the generated code
static Module *TheModule;

// this is the method used to construct the LLVM intermediate code (IR)
static IRBuilder<> Builder(getGlobalContext());
// the calls to getGlobalContext() in the init above and in the
// following code ensures that we are incrementally generating
// instructions in the right order
//static std::map<std::string, Value*> NamedValues;

typedef map<string, AllocaInst*> symbol_table;

typedef list<symbol_table*> symbol_table_list;

// program stack
static symbol_table_list symtbl_list;

// active record
static symbol_table *currentSymTable = new symbol_table();

Type *getLLVMType(decafType ty) {
 switch (ty) {
 case voidTy: return Builder.getVoidTy();
 case intTy: return Builder.getInt32Ty();
 case boolTy: return Builder.getInt1Ty();
 case stringTy: return Builder.getInt8PtrTy();
 default: throw runtime_error("unknown type");
 }
}

static AllocaInst *CreateEntryBlockAlloca(Function *TheFunction, const string &VarName) {
  IRBuilder<> TmpB(&TheFunction->getEntryBlock(), TheFunction->getEntryBlock().begin());
   return TmpB.CreateAlloca(Type::getDoubleTy(getGlobalContext()), 0,
                           VarName.c_str());
}

Value* access_symtbl(string ident) {
for (symbol_table_list::iterator i = symtbl_list.begin(); i != symtbl_list.end(); ++i) {
symbol_table::iterator find_ident;
if ((find_ident = (*i)->find(ident)) != (*i)->end())
return find_ident->second;
}
return NULL;
}

void updateSymTable(string ident,AllocaInst* alloca){

    //currentSymTable[ident]->lineno = variableInfo.

    (*currentSymTable)[ident] = alloca;
    //symbol_table *yes = symtbl_list.front();

    //cout << (*yes)[ident]->location << endl;
    //cout << currentSymTable[ident]->varname << endl;
    //cout << currentSymTable[ident]->type << endl;
    //cout << currentSymTable[ident]->lineno << endl;
}


AllocaInst *defineVariable(Type *llvmTy, string ident)
{
 AllocaInst *Alloca =
    Builder.CreateAlloca(llvmTy, 0, ident.c_str());
 updateSymTable(ident, Alloca);

 return Alloca;
}


Function *gen_print_int_def() {
  // create a extern definition for print_int
  std::vector<Type*> args;
  args.push_back(IntegerType::get(getGlobalContext(), 32)); // print_int takes one integer argument
  FunctionType *print_int_type = FunctionType::get(IntegerType::get(getGlobalContext(), 32), args, false);
  return Function::Create(print_int_type, Function::ExternalLinkage, "print_int", TheModule);
}

// we also have to create a main function that contains
// all the code generated for the expression and the print_int call
Function *gen_main_def(Value *RetVal, Function *print_int) {
  if (RetVal == 0) {
    throw runtime_error("something went horribly wrong\n");
  }
  // create the top-level definition for main
  FunctionType *FT = FunctionType::get(IntegerType::get(getGlobalContext(), 32), false);
  Function *TheFunction = Function::Create(FT, Function::ExternalLinkage, "main", TheModule);
  if (TheFunction == 0) {
    throw runtime_error("empty function block"); 
  }
  // Create a new basic block which contains a sequence of LLVM instructions
  BasicBlock *BB = BasicBlock::Create(getGlobalContext(), "entry", TheFunction);
  // All subsequent calls to IRBuilder will place instructions in this location
  Builder.SetInsertPoint(BB);


  
  Function *CalleeF = TheModule->getFunction(print_int->getName());
  if (CalleeF == 0) {
    throw runtime_error("could not find the function print_int\n");
  }

  // print the value of the expression and we are done
  Value *CallF = Builder.CreateCall(CalleeF, RetVal, "calltmp");
  
  // Finish off the function.
  // return 0 from main, which is EXIT_SUCCESS
  Builder.CreateRet(ConstantInt::get(getGlobalContext(), APInt(32, 0)));
  return TheFunction;
}

%}

%union{
  class decafAST *ast;
  int number;
  std::string *sval;
  int decaftype;
}

%token T_AND T_OR
%token T_ASSIGN T_CLASS T_COMMA T_DIV T_PLUS T_MINUS T_MULT T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%token T_EQ T_LT T_LPAREN T_RPAREN T_SEMICOLON T_EXTERN T_LCB T_RCB
%token T_INTTYPE T_STRINGTYPE T_BOOL T_VOID

%token <number> T_INTCONSTANT T_CHARCONSTANT T_FALSE T_TRUE 
%token <sval> T_ID

%type <decaftype> type method_type extern_type

%type <ast> expr constant bool_constant
%type <ast> rvalue assign method_call method_arg_list method_arg
%type <ast> block method_block statement statement_list var_decl_list var_decl var_list param_list param_comma_list 
%type <ast> method_decl method_decl_list extern_type_list extern_defn
%type <ast> extern_list decafclass

%left T_OR
%left T_AND
%left T_EQ T_LT
%left T_PLUS T_MINUS    
%left T_MULT T_DIV T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%right UMINUS

%%

start: program

program: extern_list decafclass
    { 

     symtbl_list.push_front(currentSymTable); 
  
        ProgramAST *prog = new ProgramAST((decafStmtList *)$1, (ClassAST *)$2); 

        /*
        if (printAST) {
            cout << getString(prog) << endl;
        }*/

        // IRBuilder does constant folding by default so all the
       // addition and subtraction operations are computed and always result in
       // a constant integer value in this simple example

       Value *RetVal = prog->Codegen();
       delete $1; // get rid of abstract syntax tree    
       //delete $2; // get rid of abstract syntax tree   

       // we create an implicit print_int function call to print
       // out the value of the expression.
       //Function *print_int = gen_print_int_def();



       // create the top-level function called main
     //  Function *TheFunction = gen_main_def(RetVal, print_int);
       // Validate the generated code, checking for consistency.
      // verifyFunction(*TheFunction); 


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

decafclass: T_CLASS T_ID T_LCB method_decl_list T_RCB
    { $$ = new ClassAST(*$2, (decafStmtList *)$4); delete $2; }


method_decl_list: method_decl_list method_decl 
    { decafStmtList *slist = (decafStmtList *)$1; slist->push_back($2); $$ = slist; }
    | method_decl
    { decafStmtList *slist = new decafStmtList(); slist->push_back($1); $$ = slist; }
    ;

method_decl: T_VOID T_ID T_LPAREN param_list T_RPAREN method_block
    { $$ = new MethodDeclAST(voidTy, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    | type T_ID T_LPAREN param_list T_RPAREN method_block
    { $$ = new MethodDeclAST((decafType)$1, *$2, (TypedSymbolListAST *)$4, (MethodBlockAST *)$6); delete $2; }
    ;

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
        delete $2;
    }
    | type T_ID
    { $$ = new TypedSymbolListAST(*$2, (decafType)$1); delete $2; }
    ;

type: T_INTTYPE
    { $$ = intTy; }
    | T_BOOL
    { $$ = boolTy; }
    ;

block: T_LCB var_decl_list statement_list T_RCB
    { $$ = new BlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

method_block: T_LCB var_decl_list statement_list T_RCB
    { $$ = new MethodBlockAST((decafStmtList *)$2, (decafStmtList *)$3); }

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
        delete $3;
    }
    | type T_ID
    {   $$ = new TypedSymbolListAST(*$2, (decafType)$1); 


    delete $2; }
    ;

statement_list: statement statement_list
    { decafStmtList *slist = (decafStmtList *)$2; slist->push_front($1); $$ = slist; }
    | /* empty */ 
    { decafStmtList *slist = new decafStmtList(); $$ = slist; }
    ;
  
statement: assign T_SEMICOLON
    { $$ = $1; }
    | method_call T_SEMICOLON
    { $$ = $1; }


assign: T_ID T_ASSIGN expr
    { $$ = new AssignVarAST(*$1, $3); delete $1; }
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
    ;

rvalue: T_ID
    { $$ = new VariableExprAST(*$1); delete $1; }
    ;

expr:
    rvalue 
  { $$ = $1;}
  | constant
	{ $$ = $1; }
	| expr T_PLUS expr 
	{ $$ = new BinaryExprAST(T_PLUS, $1, $3); }
	| expr T_MINUS expr 
	{  $$ = new BinaryExprAST(T_MINUS, $1, $3); }
	| expr T_MULT expr 
	{  $$ = new BinaryExprAST(T_MULT, $1, $3); }
	| expr T_DIV expr 
	{  $$ = new BinaryExprAST(T_DIV, $1, $3); }
	| expr T_LEFTSHIFT expr 
	{  $$ = new BinaryExprAST(T_LEFTSHIFT, $1, $3); }
	| expr T_RIGHTSHIFT expr 
	{  $$ = new BinaryExprAST(T_RIGHTSHIFT, $1, $3); }
	| expr T_MOD expr 
	{  $$ = new BinaryExprAST(T_MOD, $1, $3); }
	| expr T_EQ expr
  { $$ = new BinaryExprAST(T_EQ, $1, $3); }
  | expr T_LT expr
  { $$ = new BinaryExprAST(T_LT, $1, $3); }
  | expr T_AND expr
  { $$ = new BinaryExprAST(T_AND, $1, $3); }
  | expr T_OR expr
  { $$ = new BinaryExprAST(T_OR, $1, $3); }
  | T_MINUS expr %prec UMINUS 
  { $$ = new UnaryExprAST(T_MINUS, $2); }
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

// Code Generation

Value *ProgramAST::Codegen(){

 
 for (list<decafAST*>::iterator it = ExternList->stmts.begin(); 
      it != ExternList->stmts.end(); 
      it++) {
               (*it)->Codegen();
            }

  Value* classDef = ClassDef->Codegen();

  return classDef;
  
}

Function *ExternAST::Codegen(){

  vector<Type*> Ints(FunctionArgs->arglist.size(),
                             Type::getInt32Ty(getGlobalContext()));
  FunctionType *FT =
    FunctionType::get(Type::getVoidTy(getGlobalContext()), Ints, false);

  Function *F =
    Function::Create(FT, Function::ExternalLinkage, Name, TheModule);

    return F;  
}

Value *ClassAST::Codegen(){
 Value *val = ConstantInt::get(getGlobalContext(),APInt(32,0));

for (list<decafAST*>::iterator it = MethodDeclList->stmts.begin(); 
      it != MethodDeclList->stmts.end(); 
      it++) {
              val = (*it)->Codegen();
            }
    return val;
}

Function *MethodDeclAST::Codegen(){
  if(debugging)
  cout << "method declaration node" << endl;
  //vector<Type *> argTypes;
  //vector<string> argNames;

  FunctionType *FT = FunctionType::get(IntegerType::get(getGlobalContext(), 32), false);
  Function *TheFunction = Function::Create(FT, Function::ExternalLinkage, Name, TheModule);

  if (TheFunction == 0) {
    throw runtime_error("empty function block"); 
  }


  BasicBlock *BB = BasicBlock::Create(getGlobalContext(), "entry", TheFunction);

  // All subsequent calls to IRBuilder will place instructions in this location
  Builder.SetInsertPoint(BB);

  if(debugging)
  cout << "allocating instructions"<<endl;


   Block->Codegen();


  //Builder.CreateRet(returnValue);


  //verifyFunction(*TheFunction); 


 // return TheFunction;


  //Function *func = Function::Create(FunctionType::)


   Builder.CreateRet(ConstantInt::get(getGlobalContext(), APInt(32, 0)));

 // func->dump();
  //for(list<TypedSymbolListAST*> it = )
}

Value *UnaryExprAST::Codegen(){
  Value *val = Expr->Codegen();

  if(UnaryOpString(Op) == "UnaryMinus"){

   val = Builder.CreateNeg(val);
  }


  return val;
}

Value *BoolExprAST::Codegen(){
      if(Val == 1)
    return ConstantInt::get(getGlobalContext(),APInt(1,1));
    else if(Val ==0)
    return ConstantInt::get(getGlobalContext(),APInt(1,0));

}

Value *TypedSymbolListAST::Codegen(){
Value *val = ConstantInt::get(getGlobalContext(),APInt(32,1));
Value *initialValue;
if(debugging)
cout << "allocating variables.."<<endl;
 //Function *TheFunction = Builder.GetInsertBlock()->getParent();
 // TypedSymbol *symbol = arglist.front();
  for (list <TypedSymbol*>::iterator it = arglist.begin(); it != arglist.end(); it++) {
     AllocaInst* alloca = defineVariable(getLLVMType(((*it)->Ty)),(*it)->Sym);
/*
     if(TyString((*it)->Ty) == "IntType"){
        initialValue = ConstantInt::get(getGlobalContext(),APInt(32,0));
     }

     else if( TyString((*it)->Ty) == "BoolType"){
        initialValue = ConstantInt::get(getGlobalContext(),APInt(32,0));
     }


     Builder.CreateStore(initialValue, alloca);
     */
  }
// Value* definedvar = defineVariable(Builder.getInt32Ty(),arglist.front()->Sym);
 //cout << arglist.fron


   return val;
}

Value *decafStmtList::Codegen(){
Value *val = ConstantInt::get(getGlobalContext(),APInt(32,1));
  return val;
}

Value *BlockAST::Codegen(){
  if(debugging)
  cout << "generating block.." << endl;
  Value* val = ConstantInt::get(getGlobalContext(),APInt(32,1));

  return val;
}

Value *MethodBlockAST::Codegen(){
  if(debugging)
  cout << "generating block.." << endl;
  Value* val = ConstantInt::get(getGlobalContext(),APInt(32,1));

  for (list<decafAST*>::iterator it = Vars->stmts.begin(); 
      it != Vars->stmts.end(); 
      it++) {
              val = (*it)->Codegen();
            }

  for (list<decafAST*>::iterator it = Statements->stmts.begin(); 
      it != Statements->stmts.end(); 
      it++) {
              val = (*it)->Codegen();
            }

  return val;
}

Function *ReturnStmtAST::Codegen(){

}


Value *AssignVarAST::Codegen(){
        if(debugging)
      cout << "generating instructions for assignment" << endl;

      Value *R = RHS->Codegen();
   
      Value* var = access_symtbl(Name);

      Builder.CreateStore(R,var);

      return R;

}


Value *MethodCallAST::Codegen(){
    if(debugging)
  cout << "generating method call .." << endl;

  Function *CalleeF = TheModule->getFunction(Name);
  if (CalleeF == 0) {
      if(debugging)
    cout << "Couldnt find call statement" << endl;
  }

Value *promo;

    cout << "Has multiple: " << CalleeF->arg_empty() << endl;

   vector<Value*> arguments;
   
   for (list<decafAST *>::iterator it = Args->stmts.begin(); it != Args->stmts.end(); it++) { 
     // promo = Builder.CreateZExt((*it)->Codegen(), Builder.getInt32Ty(), "zexttmp");
      //arguments.push_back(promo);

      //if(CalleeF.getType != ))

      arguments.push_back((*it)->Codegen());

     }

  Value* val = Builder.CreateCall(CalleeF,arguments);
  return val;
}


Value *VariableExprAST::Codegen() {
  //Value* definedvar = defineVariable(type,ident);
  Value *getvar = access_symtbl(Name);
 return Builder.CreateLoad(getvar, Name.c_str());
}

Value *NumberExprAST::Codegen() {
  return ConstantInt::get(getGlobalContext(), APInt(32, Val));
}

Value *BinaryExprAST::Codegen() {
  Value *L = LHS->Codegen();
  Value *R = RHS->Codegen();
  if (L == 0 || R == 0) return 0;
  
  switch (Op) {
  case T_PLUS: return Builder.CreateAdd(L, R, "addtmp");
  case T_MINUS: return Builder.CreateSub(L, R, "subtmp");
  case T_MULT: return Builder.CreateMul(L, R, "multmp");
  case T_DIV: return Builder.CreateSDiv(L, R, "divtmp");
  case T_LEFTSHIFT: return Builder.CreateShl(L, R, "shltmp");
  case T_RIGHTSHIFT: return Builder.CreateLShr(L, R, "shrtmp");
  case T_MOD: return Builder.CreateSRem(L, R, "remtmp");
  case T_EQ: return Builder.CreateFCmpUEQ(L, R, "booltmp");
  case T_LT: return Builder.CreateFCmpUEQ(L, R, "booltmp");
  case T_AND: return Builder.CreateAnd(L,R,"condtmp");
  case T_OR: return Builder.CreateOr(L,R,"condtmp");
  default: throw runtime_error("what operator is this? never heard of it.");
  }
}

// Main 

int main() {

  // initialize LLVM
  LLVMContext &Context = getGlobalContext();
  // Make the module, which holds all the code.
  TheModule = new Module("Test", Context);

  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  // Print out all of the generated code to stderr
  TheModule->dump();
  return(retval >= 1 ? 1 : 0);
}
