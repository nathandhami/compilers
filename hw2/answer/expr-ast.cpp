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
		case PLUS: return string(" (PLUS +) ");
  		case TIMES: return string(" (TIMES *) ");
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
	return "(" + string(Name) + " " + getString(a) + ")";
}

// for variable/identifier test case input: x ==> (e (t (f (ID x))))
string buildString1(const char *Name, string a) {
	return "(" + string(Name) + a + ")))";
}

string buildString2(const char *Name, exprParseAST *a, exprParseAST *b) {
	return string(Name) + "(" + getString(a) + "," + getString(b) + ")";
}

string buildString2(const char *Name, string a, exprParseAST *b) {
	return string(Name) + "(" + a + "," + getString(b) + ")";
}

string buildString3(const char *Name, exprParseAST *a, exprParseAST *b, exprParseAST *c) {
	return string(Name) + "(" + getString(a) + " " + getString(b) + "," + getString(c) + ")";
}

string buildString3(const char *Name, string a, exprParseAST *b, exprParseAST *c) {
	return "(" + string(Name) + " " + getString(b) + a + " " + getString(c) + ")";
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

/// exprStmtList - List of Decaf statements
class exprStmtList : public exprParseAST {
	list<exprParseAST *> stmts;
public:
	exprStmtList() {}
	~exprStmtList() {
		for (list<exprParseAST *>::iterator i = stmts.begin(); i != stmts.end(); i++) { 
			delete *i;
		}
	}
	int size() { return stmts.size(); }
	void push_front(exprParseAST *e) { stmts.push_front(e); }
	void push_back(exprParseAST *e) { stmts.push_back(e); }
	string str() { return commaList<class exprParseAST *>(stmts); }
};

/// VariableExprAST - Expression class for variables like "a".
class VariableExprAST : public exprParseAST {
	string Name;
public:
	VariableExprAST(string name) : Name(name) {}
	string str() { return buildString1("t (f (ID ", Name); }
	//const std::string &getName() const { return Name; }
};

// /// ExpressionExprAst - Expression class for production rule e.
// class ExpressionExprAst : public exprParseAST {
// 	string Name;
// public:
// 	ExpressionExprAst(string name) : Name(name) {}
// 	string str() { return buildString1("e ", Name); }
// 	//const std::string &getName() const { return Name; }
// };

// /// TermExprAst - Expression class for production rule t.
// class TermExprAst : public exprParseAST {
// 	string Name;
// public:
// 	TermExprAst(string name) : Name(name) {}
// 	string str() { return buildString1("t ", Name); }
// 	//const std::string &getName() const { return Name; }
// };

// /// FactorExprAst - Expression class for production rule f.
// class FactorExprAst : public exprParseAST {
// 	string Name;
// public:
// 	FactorExprAst(string name) : Name(name) {}
// 	string str() { return buildString1("f ", Name); }
// 	//const std::string &getName() const { return Name; }
// };


/// BinaryExprAST - Expression class for a binary operator.
class BinaryExprAST : public exprParseAST {
	int Op; // use the token value of the operator
	exprParseAST *LHS, *RHS;
public:
	BinaryExprAST(int op, exprParseAST *lhs, exprParseAST *rhs) : Op(op), LHS(lhs), RHS(rhs) {}
	~BinaryExprAST() { delete LHS; delete RHS; }
	string str() { return buildString3("e", BinaryOpString(Op), LHS, RHS); }
};

// /// ProgramAST - the simplified expr-parse program
class ProgramAST : public exprParseAST {
	exprStmtList *ExternList;
public:
	ProgramAST(exprStmtList *externs) : ExternList(externs) {}
	~ProgramAST() { 
		if (ExternList != NULL) { delete ExternList; } 
	}
	string str() { return buildString1("e", ExternList); }
};

