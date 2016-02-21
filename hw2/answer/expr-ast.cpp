#include "usingcpp-defs.h"
#include <list>
#include <ostream>
#include <iostream>
#include <sstream>

#ifndef YYTOKENTYPE
#include "expr-parse.tab.h"
#endif

using namespace std;

string BinaryOpString(int Op) {
	switch (Op) {
		case PLUS: return string("PLUS");
  		case TIMES: return string("TIMES");
		default: throw runtime_error("unknown type in BinaryOpString call");
	}
}

string convertInt(int number) {
	stringstream ss;
	ss << number;
	return ss.str();
}


class exprParseAST{
public:
  virtual ~exprParseAST() {}
  virtual string str() { return string(""); }

};

string getString(exprParseAST *d) {
	if (d != NULL) {
		return d->str();
	} else {
		return string("None");
	}
}

string buildString1(const char *Name, exprParseAST *a) {
	return string(Name) + "(" + getString(a) + ")";
}

string buildString1(const char *Name, string a) {
	return string(Name) + "(" + a + ")";
}

string buildString2(const char *Name, exprParseAST *a, exprParseAST *b) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + ")";
}

string buildString2(const char *Name, string a, exprParseAST *b) {
	return string(Name) + "(" + a + "," + getString(b) + ")";
}

string buildString3(const char *Name, exprParseAST *a, exprParseAST *b, exprParseAST *c) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, exprParseAST *b, exprParseAST *c) {
	return string(Name) + "(" + a + "," + getString(b) + "," + getString(c) + ")";
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

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public exprParseAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return buildString1("VariableExpr", Name); }
	//const std::string &getName() const { return Name; }
};


/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public exprParseAST {
	int Op; // use the token value of the operator
	exprParseAST *LHS, *RHS;
public:
	BinaryExprAST(int op, exprParseAST *lhs, exprParseAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
	string str() { return buildString3("BinaryExpr", BinaryOpString(Op), LHS, RHS); }
};

// /// ProgramAST - the simplified decaf program
// class ProgramAST : public decafAST {
// 	decafStmtList *ExternList;
// public:
// 	ProgramAST(decafStmtList *externs) : ExternList(externs) {}
// 	~ProgramAST() { 
// 		if (ExternList != NULL) { delete ExternList; } 
// 	}
// 	string str() { return buildString1("Program", ExternList); }
// };

