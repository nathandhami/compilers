
#include "usingcpp-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "decaf-ast.tab.h"
#endif

using namespace std;

string BinaryOpString(int Op) {
	switch (Op) {
		case T_PLUS: return string("Plus");
  		case T_MINUS: return string("Minus");
  		case T_MULT: return string("Mult");
  		case T_DIV: return string("Div");
  		case T_MOD: return string("Mod");
  		case T_LEFTSHIFT: return string("Leftshift");
  		case T_RIGHTSHIFT: return string("Rightshift");
  		case T_AND: return string("And");
  		case T_OR: return string("Or");
  		case T_EQ: return string("Eq");
  		case T_GEQ: return string("Geq");
  		case T_GT: return string("Gt");
  		case T_LEQ: return string("Leq");
  		case T_LT: return string("Lt");
  		case T_NEQ: return string("Neq");
  
		default: throw runtime_error("unknown type in BinaryOpString call");
	}
}

string TypeString(int Op) {
	switch (Op) {
		case T_INTTYPE: return string("IntType");
		case T_VOID: return string("VoidType");
		case T_BOOL: return string("BoolType");
		case T_STRINGTYPE: return string("StringType");

		default: throw runtime_error("unknown type in TypeString call");
	}
}

string UnaryOpString(int Op) {
	switch (Op) {
  		case T_MINUS: return string("UnaryMinus");
  		case T_NOT: return string("Not");
  		case T_BREAK: return string("BreakStmt");
		default: throw runtime_error("unknown type in UnaryOpString call");
	}
}

string convertInt(int number) {
	stringstream ss;
	ss << number;
	return ss.str();
}

/// decafAST - Base class for all abstract syntax tree nodes.
class decafAST {
public:
  virtual ~decafAST() {}
  virtual string str() { return string(""); }
};

string getString(decafAST *d) {
	if (d != NULL) {
		return d->str();
	} else {
		return string("None");
	}
}

string buildString1(const char *Name, decafAST *a) {
	return string(Name) + "(" + getString(a) + ")";
}

string buildString1(const char *Name, string a) {
	return string(Name) + "(" + a + ")";
}

string buildString2(const char *Name, decafAST *a, decafAST *b) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + ")";
}


string buildString2(const char *Name, string a, decafAST *b) {
	return string(Name) + "(" + a + "," + getString(b) + ")";
}

string buildString2(const char *Name, string a, string b) {
	return string(Name) + "(" + a + "," + b + ")";
}

string buildString3(const char *Name, decafAST *a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, decafAST *b, decafAST *c) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, decafAST *b, const char *Name2) {
	return string(Name) + "(" + a + "," + getString(b) + "," + string(Name2) + ")";
}


string buildString4(const char *Name, decafAST *a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}

string buildString4(const char *Name, string a, decafAST *b, decafAST *c, decafAST *d) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + "," + getString(d) + ")";
}

string buildStringFinal(const char *Name, string a, decafAST *b, decafAST *c, decafAST *d) {
	return getString(b) + "," + string(Name) + "(" + a + "," + getString(c) + "," + getString(d) + ")";
}




template <class T>
string commaList(list<T> vec) {
	string s("");
	for (typename list<T>::iterator i = vec.begin(); i != vec.end(); i++) { 
		s = s + (s.empty() ? string("") : string(",")) + (*i)->str(); 
	}
	if (s.empty()) {
		s = string("None");
	} 
	return s;
}

/// decafStmtList - List of Decaf statements
class decafStmtList : public decafAST {
	list<decafAST *> stmts;
public:
	decafStmtList() {}
	~decafStmtList() {
		for (list<decafAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) { 
			delete *i;
		}
	}
	int size() { return stmts.size(); }
	void push_front(decafAST *e) { stmts.push_front(e); }
	void push_back(decafAST *e) { stmts.push_back(e); }
	string str() { return commaList<class decafAST *>(stmts); }
};

/// NumberExprAST - Expression class for integer numeric literals like "12".
class NumberExprAST : public decafAST {
	int Val;
public:
	NumberExprAST(int val) : Val(val) {}
	string str() { return buildString1("Number", convertInt(Val)); }
};

/// StringConstAST - string constant
class StringConstAST : public decafAST {
	string StringConst;
public:
	StringConstAST(string s) : StringConst(s) {}
	string str() { return buildString1("StringConstant", "\"" + StringConst + "\""); }
};

/// BoolExprAST - Expression class for boolean literals: "true" and "false".
class BoolExprAST : public decafAST {
	bool Val;
public:
	BoolExprAST(bool val) : Val(val) {}
	string str() { return buildString1("BoolExpr", Val ? string("True") : string("False")); }
};

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public decafAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return buildString1("VariableExpr", Name); }
	//const std::string &getName() const { return Name; }
};

/// VariableExprAST - Expression class for variables like "a".
class ReturnAST : public decafAST {
	decafAST *AST;
public:
	ReturnAST(decafAST *ast) : AST(ast) {}
	string str() { return buildString1("ReturnStmt", AST); }
	//const std::string &getName() const { return Name; }
};

class StandAloneAST : public decafAST {
	string Name;
public:
	StandAloneAST(string name) : Name(name) {}
	string str() { return Name;}
};


/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *LHS, *RHS;
public:
	BinaryExprAST(int op, decafAST *lhs, decafAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
	string str() { return buildString3("BinaryExpr", BinaryOpString(Op), LHS, RHS); }
};

class ClassAST : public decafAST {
	decafAST *LHS1,*RHS1,*RHS2;
	string Name;
public:
	ClassAST(decafAST *lhs1, string name, decafAST *rhs1, decafAST *rhs2) : LHS1(lhs1), Name(name), RHS1(rhs1), RHS2(rhs2) {}
	~ClassAST() { delete LHS1; delete RHS1; delete RHS2; }
	string str() { return buildStringFinal("Class",Name, LHS1, RHS1, RHS2); }
};

/// BlockAST -  class for a block
class BlockAST : public decafAST {
	decafAST *LHS, *RHS;
public:
	BlockAST(decafAST *lhs, decafAST *rhs) : LHS(lhs), RHS(rhs) {}
	~BlockAST() { delete LHS; delete RHS; }
	string str() { return buildString2("Block", LHS, RHS); }
};

/// IfAst -  class for a if
class IfAST : public decafAST {
	decafAST *LHS, *RHS;
public:
	IfAST(decafAST *lhs, decafAST *rhs) : LHS(lhs), RHS(rhs) {}
	~IfAST() { delete LHS; delete RHS; }
	string str() { return buildString2("IfStmt", LHS, RHS); }
};

/// IfElseAst -  class for a if
class IfElseAST: public decafAST {
	decafAST *LHS, *RHS, *EHS;
public:
	IfElseAST(decafAST *lhs, decafAST *rhs, decafAST *ehs) : LHS(lhs), RHS(rhs), EHS(ehs) {}
	~IfElseAST() { delete LHS; delete RHS; delete EHS; }
	string str() { return buildString3("IfStmt", LHS, RHS, EHS); }
};

/// WhileAst -  class for a while
class WhileAST : public decafAST {
	decafAST *LHS, *RHS;
public:
	WhileAST(decafAST *lhs, decafAST *rhs) : LHS(lhs), RHS(rhs) {}
	~WhileAST() { delete LHS; delete RHS; }
	string str() { return buildString2("WhileStmt", LHS, RHS); }
};

class ForAST : public decafAST {
	decafAST *LHS1,*LHS2,*RHS1,*RHS2;
public:
	ForAST(decafAST *lhs1, decafAST *lhs2, decafAST *rhs1, decafAST *rhs2) : LHS1(lhs1), LHS2(lhs2), RHS1(rhs1), RHS2(rhs2) {}
	~ForAST() { delete LHS1; delete LHS2; delete RHS1; delete RHS2; }
	string str() { return buildString4("ForStmt", LHS1, LHS2, RHS1, RHS2); }
};

// Extern Declarations
// Field Declarations
class ExternAST : public decafAST {
	decafAST *LHS,*RHS;
	string Name;
public:
	ExternAST(decafAST *lhs, string name, decafAST *rhs) : LHS(lhs), Name(name), RHS(rhs) {}
	~ExternAST() { delete LHS; delete RHS; }
	string str() { return buildString3("ExternFunction", Name, LHS, RHS); }
};

class VarDefExternAST : public decafAST {
	int Op; // use the token value of the operator
public:
	VarDefExternAST(int op) : Op(op) {}
	~VarDefExternAST() {  }
	string str() { return buildString1("VarDef", TypeString(Op)); }
};

// Field Declarations
class FieldDeclarationAST : public decafAST {
	decafAST *LHS,*RHS;
	string Name;
public:
	FieldDeclarationAST(decafAST *lhs, string name, decafAST *rhs) : LHS(lhs), Name(name), RHS(rhs) {}
	~FieldDeclarationAST() { delete LHS; delete RHS; }
	string str() { return buildString3("FieldDecl", Name, LHS, RHS); }
};

class FieldDeclarationNoAssignAST : public decafAST {
	decafAST *LHS;
	string Name;
public:
	FieldDeclarationNoAssignAST(decafAST *lhs, string name) : LHS(lhs), Name(name) {}
	~FieldDeclarationNoAssignAST() { delete LHS; }
	string str() { return buildString3("FieldDecl", Name, LHS, "Scalar"); }
};

// method decelarations
class MethodDeclarationAST : public decafAST {
	decafAST *LHS1,*RHS1,*RHS2;
	string Name;
public:
	MethodDeclarationAST(decafAST *lhs1, string name, decafAST *rhs1, decafAST *rhs2) : LHS1(lhs1), Name(name), RHS1(rhs1), RHS2(rhs2) {}
	~MethodDeclarationAST() { delete LHS1; delete RHS1; delete RHS2; }
	string str() { return buildString4("Method", Name, LHS1, RHS1, RHS2); }
};

/// BlockAST -  class for a block
class MethodBlockAST : public decafAST {
	decafAST *LHS, *RHS;
public:
	MethodBlockAST(decafAST *lhs, decafAST *rhs) : LHS(lhs), RHS(rhs) {}
	~MethodBlockAST() { delete LHS; delete RHS; }
	string str() { return buildString2("MethodBlock", LHS, RHS); }
};

/// VarDeMethod -Variables in methods
class VarDefMethodAST : public decafAST {
	int Op; // use the token value of the operator
	string Name;
public:
	VarDefMethodAST(int op, string name) : Op(op), Name(name){}
	~VarDefMethodAST() {  }
	string str() { return buildString2("VarDef", Name, TypeString(Op)); }
};


/// UnaryExprAST - Expression class for a unary operator.
class UnaryExprAST : public decafAST {
	int Op; // use the token value of the operator
	decafAST *Expr;
public:
	UnaryExprAST(int op, decafAST *expr) : Op(op), Expr(expr) {}
	~UnaryExprAST() { delete Expr; }
	string str() { return buildString2("UnaryExpr", UnaryOpString(Op), Expr); }
};

/// AssignVarAST - assign value to a variable
class AssignVarAST : public decafAST {
	string Name; // location to assign value
	decafAST *Value;
public:
	AssignVarAST(string name, decafAST *value) : Name(name), Value(value) {}
	~AssignVarAST() { 
		if (Value != NULL) { delete Value; }
	}
	string str() { return buildString2("AssignVar", Name, Value); }
};

// methodcall - g(int a, int b);
class MethodCallAST : public decafAST {
	string Name; // location to assign value
	decafAST *AST;
public:
	MethodCallAST(string name, decafAST *ast) : Name(name), AST(ast) {}
	~MethodCallAST() { 
		if (AST != NULL) { delete AST; }
	}
	string str() { return buildString2("MethodCall", Name, AST); }
};


/// ProgramAST - the simplified decaf program
class ProgramAST : public decafAST {
	decafStmtList *ExternList;
public:
	ProgramAST(decafStmtList *externs) : ExternList(externs) {}
	~ProgramAST() { 
		if (ExternList != NULL) { delete ExternList; } 
	}
	string str() { return buildString1("Program", ExternList); }
};

