%error-verbose
%locations
%{
#include "stdio.h"
#include "math.h"
#include "string.h"
#include "def.h"
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
char filename[50]; 
int isSyntacError;
void yyerror(const char* fmt, ...);
void display(struct node *,int);
int yylex();
%}

%union {
	int    type_int;
	float  type_float;
	char   type_id[32];
	struct node *ptr;
};

//  %type 定义非终结符的语义值类型
%type  <ptr> program ExtDefList ExtDef  Specifier ExtDecList FuncDec CompSt VarList VarDec ParamDec Stmt StmList DefList Def DecList Dec Exp Args ArrayArgs ArrayArgsList

//% token 定义终结符的语义值类型
%token <type_int> INT              //指定INT的语义值是type_int，有词法分析得到的数值
%token <type_id> ID RELOP TYPE VOID
%token <type_float> FLOAT         //指定ID的语义值是type_id，有词法分析得到的标识符字符串
%token CONTINUE BREAK
%token LP RP LC RC LB RB SEMI COMMA
%token PLUS SELFPLUS MINUS STAR DIV MOD ASSIGNOP AND OR NOT IF ELSE WHILE FOR RETURN

%left ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS SELFPLUS
%left STAR DIV MOD
%right UMINUS NOT

%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE

%%

program: ExtDefList    { display($1,0); }
         ; 
ExtDefList: {$$=NULL;}
          | ExtDef ExtDefList {$$=mknode(EXT_DEF_LIST,$1,$2,NULL,yylineno,NULL);}
          ;  
ExtDef:   Specifier ExtDecList SEMI   {$$=mknode(EXT_VAR_DEF,$1,$2,NULL,yylineno,NULL);}
         |Specifier FuncDec CompSt    {$$=mknode(FUNC_DEF,$1,$2,$3,yylineno,NULL);}
         | error SEMI   {$$=NULL; }
         ;
Specifier:  TYPE    {$$=mknode(TYPE,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);$$->type=!strcmp($1,"int")?INT:FLOAT;}   
        | VOID {$$=mknode(VOID,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);$$->type=VOID;}
           ;      
ExtDecList:  VarDec      {$$=$1;}       /*每一个EXT_DECLIST的结点，其第一棵子树对应一个变量名(ID类型的结点),第二棵子树对应剩下的外部变量名*/
           | VarDec COMMA ExtDecList {$$=mknode(EXT_DEC_LIST,$1,$3,NULL,yylineno,NULL);}
           ;  
VarDec:  ID ArrayArgsList {$$=mknode(ARRAY,$2,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
        | ID          {$$=mknode(ID,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
         ;
FuncDec: ID LP VarList RP   {$$=mknode(FUNC_DEC,$3,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
		|ID LP  RP   {$$=mknode(FUNC_DEC,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}

        ;  
VarList: ParamDec  {$$=mknode(PARAM_LIST,$1,NULL,NULL,yylineno,NULL);}
        | ParamDec COMMA  VarList  {$$=mknode(PARAM_LIST,$1,$3,NULL,yylineno,NULL);}
        ;
ParamDec: Specifier VarDec         {$$=mknode(PARAM_DEC,$1,$2,NULL,yylineno,NULL);}
         ;

CompSt: LC DefList StmList RC    {$$=mknode(COMP_STM,$2,$3,NULL,yylineno,NULL);}
       ;
StmList: {$$=NULL; }  
        | Stmt StmList  {$$=mknode(STM_LIST,$1,$2,NULL,yylineno,NULL);}
        | DefList StmList {$$=mknode(STM_LIST,$1,$2,NULL,yylineno,NULL);}
        ;
Stmt:   Exp SEMI    {$$=mknode(EXP_STMT,$1,NULL,NULL,yylineno,NULL);}
      | CompSt      {$$=$1;}      //复合语句结点直接最为语句结点，不再生成新的结点
      | CONTINUE SEMI {$$=mknode(CONTINUE,NULL,NULL,NULL,yylineno,NULL);}
      | BREAK SEMI {$$=mknode(BREAK,NULL,NULL,NULL,yylineno,NULL);}
      | RETURN Exp SEMI   {$$=mknode(RETURN,$2,NULL,NULL,yylineno,NULL);}
      | RETURN SEMI   {$$=mknode(RETURN_N,NULL,NULL,NULL,yylineno,NULL);}
      | IF LP Exp RP Stmt {$$=mknode(IF_THEN,$3,$5,NULL,yylineno,NULL);}
//      | IF LP Exp RP Stmt %prec LOWER_THEN_ELSE   {$$=mknode(IF_THEN,$3,$5,NULL,yylineno,NULL);}
      | IF LP Exp RP Stmt ELSE Stmt   {$$=mknode(IF_THEN_ELSE,$3,$5,$7,yylineno,NULL);}
      | WHILE LP Exp RP Stmt {$$=mknode(WHILE,$3,$5,NULL,yylineno,NULL);}
      | FOR LP Exp SEMI Exp SEMI Exp RP Stmt {$$=mknode(FOR,$3,$5,$7,yylineno,$9);}
      ;
  
DefList: {$$=NULL; }
        | Def DefList {$$=mknode(DEF_LIST,$1,$2,NULL,yylineno,NULL);}
        ;
Def:    Specifier DecList SEMI {$$=mknode(VAR_DEF,$1,$2,NULL,yylineno,NULL);}
        ;
DecList: Dec  {$$=mknode(DEC_LIST,$1,NULL,NULL,yylineno,NULL);}
       | Dec COMMA DecList  {$$=mknode(DEC_LIST,$1,$3,NULL,yylineno,NULL);}
	   ;
Dec:     VarDec  {$$=$1;}
       | VarDec ASSIGNOP Exp  {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"ASSIGNOP");}
       ;
Exp:    Exp ASSIGNOP Exp {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"ASSIGNOP");}
      | Exp AND Exp   {$$=mknode(AND,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"AND");}
      | Exp OR Exp    {$$=mknode(OR,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"OR");}
      | Exp RELOP Exp {$$=mknode(RELOP,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,$2);}
      | Exp PLUS Exp  {$$=mknode(PLUS,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"PLUS");}
      | Exp MINUS Exp {$$=mknode(MINUS,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"MINUS");}
      | Exp STAR Exp  {$$=mknode(STAR,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"STAR");}
      | Exp DIV Exp   {$$=mknode(DIV,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"DIV");}
      | Exp MOD Exp   {$$=mknode(MOD,$1,$3,NULL,yylineno,NULL);strcpy($$->type_id,"MOD");}
      | LP Exp RP     {$$=$2;}
      | MINUS Exp %prec UMINUS   {$$=mknode(UMINUS,$2,NULL,NULL,yylineno,NULL);strcpy($$->type_id,"UMINUS");}
      | NOT Exp       {$$=mknode(NOT,$2,NULL,NULL,yylineno,NULL);strcpy($$->type_id,"NOT");}
      | ID LP Args RP {$$=mknode(FUNC_CALL,$3,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
      | ID LP RP      {$$=mknode(FUNC_CALL,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
      | ID SELFPLUS   {$$=mknode(SELFPLUS,$1,NULL,NULL,yylineno,NULL);strcpy($$->type_id,"SELFPLUS");} 
      | ID ArrayArgsList {$$=mknode(ARRAY,$2,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
      | ID            {$$=mknode(ID,NULL,NULL,NULL,yylineno,NULL);strcpy($$->type_id,$1);}
      | INT           {$$=mknode(INT,NULL,NULL,NULL,yylineno,NULL);$$->type_int=$1;$$->type=INT;}
      | FLOAT         {$$=mknode(FLOAT,NULL,NULL,NULL,yylineno,NULL);$$->type_float=$1;$$->type=FLOAT;}
      ;
Args:    Exp COMMA Args    {$$=mknode(ARGS,$1,$3,NULL,yylineno,NULL);}
       | Exp               {$$=mknode(ARGS,$1,NULL,NULL,yylineno,NULL);}
       ;
ArrayArgsList: ArrayArgs ArrayArgs {$$=mknode(ARRAY_ARGS_LIST,$1,$2,NULL,yylineno,NULL);}
        | ArrayArgs {$$=$1;}
ArrayArgs: LB Exp RB {$$=mknode(ARRAY_ARGS,$2,NULL,NULL,yylineno,NULL);}
        ;
       
%%

int main(int argc, char *argv[]){
	yyin=fopen(argv[1],"r");
	if (!yyin) return 1;
        strcpy(filename, strrchr(argv[1], '/')+1);
        isSyntacError = 0;
	yylineno=1;
	yyparse();
	return 0;
}

#include<stdarg.h>
void yyerror(const char* fmt, ...)
{
        isSyntacError = 1;
        va_list ap;
        va_start(ap, fmt);
        fprintf(stderr, "%s:%d", filename, yylloc.first_line);
        fprintf(stderr, "Grammar Error at Line %d Column %d: ", yylloc.first_line,yylloc.first_column);
        vfprintf(stderr, fmt, ap);
        fprintf(stderr, ".\n");
}	
