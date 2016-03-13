%{ 
#include "exprdefs.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/Verifier.h"
#include <cstdio> 
#include <stdexcept>

using namespace llvm;

// this global variable contains all the generated code
static Module *TheModule;

// this is the method used to construct the LLVM intermediate code (IR)
static IRBuilder<> Builder(getGlobalContext());
// the calls to getGlobalContext() in the init above and in the
// following code ensures that we are incrementally generating
// instructions in the right order
static std::map<std::string, Value*> NamedValues;

/// ExprAST - Base class for all expression nodes.
class ExprAST {
public:
  virtual ~ExprAST() {}
  virtual Value *Codegen() = 0;
};

/// NumberExprAST - Expression class for integer numeric literals like "12".
class NumberExprAST : public ExprAST {
  int Val;
public:
  NumberExprAST(int val) : Val(val) {}
  virtual Value *Codegen();
};

/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public ExprAST {
  char Op;
  ExprAST *LHS, *RHS;
public:
  BinaryExprAST(char op, ExprAST *lhs, ExprAST *rhs) 
    : Op(op), LHS(lhs), RHS(rhs) {}
  virtual Value *Codegen();
  ~BinaryExprAST() {
    delete LHS;
    delete RHS;
  }
};


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
  class ExprAST *ast;
  int number;
}

%token T_DIV T_PLUS T_MINUS T_MULT T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%token T_EQ T_LT

%token <number> T_INTCONSTANT
%type <ast> expr constant

%left T_DIV T_PLUS T_MINUS T_MULT T_MOD T_LEFTSHIFT T_RIGHTSHIFT
%left T_EQ T_LT

%%
statement: expr
	   { 
	     // IRBuilder does constant folding by default so all the
	     // addition and subtraction operations are computed and always result in
	     // a constant integer value in this simple example
	     Value *RetVal = $1->Codegen();
	     delete $1; // get rid of abstract syntax tree	     

	     // we create an implicit print_int function call to print
	     // out the value of the expression.
	     Function *print_int = gen_print_int_def();

	     // create the top-level function called main
	     Function *TheFunction = gen_main_def(RetVal, print_int);
	     // Validate the generated code, checking for consistency.
	     verifyFunction(*TheFunction);
  	   }
         ;

expr: constant
	{ $$ = $1; }
	| expr T_PLUS expr 
	{ $$ = new BinaryExprAST((char)T_PLUS, $1, $3); }
	| expr T_MINUS expr 
	{  $$ = new BinaryExprAST((char)T_MINUS, $1, $3); }
	| expr T_MULT expr 
	{  $$ = new BinaryExprAST((char)T_MULT, $1, $3); }
	| expr T_DIV expr 
	{  $$ = new BinaryExprAST((char)T_DIV, $1, $3); }
	| expr T_LEFTSHIFT expr 
	{  $$ = new BinaryExprAST((char)T_LEFTSHIFT, $1, $3); }
	| expr T_RIGHTSHIFT expr 
	{  $$ = new BinaryExprAST((char)T_RIGHTSHIFT, $1, $3); }
	| expr T_MOD expr 
	{  $$ = new BinaryExprAST((char)T_MOD, $1, $3); }
	| expr T_EQ expr
    	{ $$ = new BinaryExprAST((char)T_EQ, $1, $3); }
        | expr T_LT expr
    	{ $$ = new BinaryExprAST((char)T_LT, $1, $3); }
	;

constant: T_INTCONSTANT
    	{ $$ = new NumberExprAST($1); }
	;

%%

Value *NumberExprAST::Codegen() {
  return ConstantInt::get(getGlobalContext(), APInt(32, Val));
}

Value *BinaryExprAST::Codegen() {
  Value *L = LHS->Codegen();
  Value *R = RHS->Codegen();
  if (L == 0 || R == 0) return 0;
  
  switch (Op) {
  case (char)T_PLUS: return Builder.CreateAdd(L, R, "addtmp");
  case (char)T_MINUS: return Builder.CreateSub(L, R, "subtmp");
  case (char)T_MULT: return Builder.CreateMul(L, R, "multmp");
  case (char)T_DIV: return Builder.CreateSDiv(L, R, "divtmp");
  case (char)T_LEFTSHIFT: return Builder.CreateShl(L, R, "shltmp");
  case (char)T_RIGHTSHIFT: return Builder.CreateLShr(L, R, "shrtmp");
  case (char)T_MOD: return Builder.CreateSRem(L, R, "remtmp");
  case (char)T_EQ: return Builder.CreateFCmpUEQ(L, R, "booltmp");
  case (char)T_LT: return Builder.CreateFCmpUEQ(L, R, "booltmp");
  default: throw runtime_error("what operator is this? never heard of it.");
  }
}


int main() {
  fprintf(stderr, "ready> ");
  // initialize LLVM
  LLVMContext &Context = getGlobalContext();
  // Make the module, which holds all the code.
  TheModule = new Module("module for very simple expressions", Context);
  // parse the input and create the abstract syntax tree
  int retval = yyparse();
  // Print out all of the generated code to stderr
  TheModule->dump();
  return(retval >= 1 ? 1 : 0);
}
