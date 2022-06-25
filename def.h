#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdarg.h"
#include "sysy.tab.h"

enum node_kind  { EXT_DEF_LIST,EXT_VAR_DEF,FUNC_DEF,FUNC_DEC,EXT_DEC_LIST,PARAM_LIST,PARAM_DEC,                   VAR_DEF,DEC_LIST,DEF_LIST,COMP_STM,STM_LIST,EXP_STMT,IF_THEN,IF_THEN_ELSE, FUNC_CALL,ARGS, FUNCTION,PARAM,ARG,CALL,LABEL,GOTO,JLT,JLE,JGT,JGE,EQ,NEQ,ARRAY_ARGS,ARRAY_ARGS_LIST,ARRAY,RETURN_N};
extern char filename[50]; 
extern int has_syntacc_err;
#define MAXLENGTH   1000
#define DX 3*sizeof(int)
struct opn{
    int kind;
    int type;
    union {
        int     const_int;
        float   const_float;
        char    const_char;
        char    id[33];
        };
    int level;
    int offset;
    };

struct codenode {
        int  op;
        struct opn opn1,opn2,result;
        struct codenode  *next,*prior;
         };

struct node {
	enum node_kind kind;
	union {
		  char type_id[33];
		  int type_int;
		  float type_float;
	      };
    struct node *ptr[3];
    int level;
    int place;
    char Etrue[15],Efalse[15];
    char Snext[15];
    struct codenode *code;
    char op[10];
    int  type;
    int pos;
    int offset;
    int width;
    };

struct symbol {
    char name[33];
    int level;
    int type;
    int  paramnum;
    char alias[10];
    char flag;
    char offset;
    };
struct symboltable{
    struct symbol symbols[MAXLENGTH];
    int index;
    } symbolTable;

struct symbol_scope_begin {
    int TX[30];
    int top;
    } symbol_scope_TX;


struct node * mknode(int kind,struct node *first,struct node *second, struct node *third,int pos, struct node *forth);

void semantic_Analysis0(struct node *T);
void semantic_Analysis(struct node *T);
void boolExp(struct node *T);
void Exp(struct node *T);
void objectCode(struct codenode *head);
