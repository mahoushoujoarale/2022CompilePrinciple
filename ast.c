#include "def.h"
struct node *mknode(int kind, struct node *first, struct node *second, struct node *third, int pos, struct node *forth)
{
  struct node *T = (struct node *)malloc(sizeof(struct node));
  T->kind = kind;
  T->ptr[0] = first;
  T->ptr[1] = second;
  T->ptr[2] = third;
  T->ptr[3] = forth;
  T->pos = pos;
  return T;
}

void display(struct node *T, int indent)
{
  int i = 1;
  struct node *T0;
  if (T)
  {
    switch (T->kind)
    {
    case ARRAY:
      printf("%*c数组定义: \n", indent, ' ');
      printf("%*cID:  %s\n", indent, ' ', T->type_id);
      display(T->ptr[0], indent + 3);
      break;
    case ARRAY_ARGS_LIST:
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case ARRAY_ARGS:
      printf("%*c数组维度: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      break;
    case EXT_DEF_LIST:
      printf("%*cCompUnit", indent, ' ');
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case EXT_VAR_DEF:
      printf("%*c外部变量定义: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      printf("%*c变量名: \n", indent + 3, ' ');
      display(T->ptr[1], indent + 6);
      break;
    case VOID:
      printf("%*c类型:  %s\n", indent, ' ', T->type_id);
      break;
    case TYPE:
      printf("%*c类型:  %s\n", indent, ' ', T->type_id);
      break;
    case EXT_DEC_LIST:
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case FUNC_DEF:
      printf("%*cCompUnit", indent, ' ');
      printf("%*c`--FuncDef", indent, ' ');
      printf("%*c函数定义: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      display(T->ptr[1], indent + 3);
      display(T->ptr[2], indent + 3);
      break;
    case FUNC_DEC:
      printf("%*c函数名: %s\n", indent, ' ', T->type_id);
      if (T->ptr[0])
      {
        printf("%*c函数形参: \n", indent, ' ');
        display(T->ptr[0], indent + 3);
      }
      else
        printf("%*c无参函数\n", indent + 3, ' ');
      break;
    case PARAM_LIST:
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case PARAM_DEC:
      printf("%*c类型: %s, 参数名: %s\n", indent, ' ',
             T->ptr[0]->type == INT ? "int" : "float", T->ptr[1]->type_id);
      break;
    case EXP_STMT:
      printf("%*c表达式语句: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      break;
    case RETURN:
      printf("%*c返回语句: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      break;
    case BREAK:
      printf("%*c语句: \n", indent, ' ');
      break;
    case CONTINUE:
      printf("%*c语句: \n", indent, ' ');
      break;
    case COMP_STM:
      printf("%*c复合语句: \n", indent, ' ');
      printf("%*c复合语句的变量定义: \n", indent + 3, ' ');
      display(T->ptr[0], indent + 6);
      printf("%*c复合语句的语句部分: \n", indent + 3, ' ');
      display(T->ptr[1], indent + 6);
      break;
    case STM_LIST:
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case WHILE:
      printf("%*c循环语句: \n", indent, ' ');
      printf("%*c循环条件: \n", indent + 3, ' ');
      display(T->ptr[0], indent + 6);
      printf("%*c循环体: \n", indent + 3, ' ');
      display(T->ptr[1], indent + 6);
      break;
    case FOR:
      printf("%*c循环语句: \n", indent, ' ');
      printf("%*c循环条件: \n", indent + 3, ' ');
      display(T->ptr[0], indent + 6);
      display(T->ptr[1], indent + 6);
      display(T->ptr[2], indent + 6);
      printf("%*c循环体: \n", indent + 3, ' ');
      display(T->ptr[3], indent + 6);
      break;
    case IF_THEN:
      printf("%*c条件语句(IF_THEN): \n", indent, ' ');
      printf("%*c条件: \n", indent + 3, ' ');
      display(T->ptr[0], indent + 6);
      printf("%*cIF子句: \n", indent + 3, ' ');
      display(T->ptr[1], indent + 6);
      break;
    case IF_THEN_ELSE:
      printf("%*c条件语句(IF_THEN_ELSE): \n", indent, ' ');
      printf("%*c条件: \n", indent + 3, ' ');
      display(T->ptr[0], indent + 6);
      printf("%*cIF子句: \n", indent + 3, ' ');
      display(T->ptr[1], indent + 6);
      printf("%*cELSE子句: \n", indent + 3, ' ');
      display(T->ptr[2], indent + 6);
      break;
    case DEF_LIST:
      display(T->ptr[0], indent);
      display(T->ptr[1], indent);
      break;
    case VAR_DEF:
      printf("%*cLOCAL VAR_NAME: \n", indent, ' ');
      display(T->ptr[0], indent + 3);
      display(T->ptr[1], indent + 3);
      break;
    case DEC_LIST:
      printf("%*cVAR_NAME: \n", indent, ' ');
      T0 = T;
      while (T0)
      {
        if (T0->ptr[0]->kind == ID)
          printf("%*c %s\n", indent + 3, ' ', T0->ptr[0]->type_id);
        else if (T0->ptr[0]->kind == ASSIGNOP)
        {
          printf("%*c %s ASSIGNOP\n ", indent + 3, ' ', T0->ptr[0]->ptr[0]->type_id);
          //显示初始化表达式
          display(T0->ptr[0]->ptr[1], indent + strlen(T0->ptr[0]->ptr[0]->type_id) + 4);
        }
        T0 = T0->ptr[1];
      }
      break;

    case ID:
      printf("%*cID:  %s\n", indent, ' ', T->type_id);
      break;
    case INT:
      printf("%*cINT: %d\n", indent, ' ', T->type_int);
      break;
    case FLOAT:
      printf("%*cFLAOT: %f\n", indent, ' ', T->type_float);
      break;
    case ASSIGNOP:
    case AND:
    case OR:
    case RELOP:
    case PLUS:
    case MINUS:
    case STAR:
    case DIV:
    case MOD:
      printf("%*c%s\n", indent, ' ', T->type_id);
      display(T->ptr[0], indent + 3);
      display(T->ptr[1], indent + 3);
      break;
    case NOT:
    case UMINUS:
      printf("%*c%s\n", indent, ' ', T->type_id);
      display(T->ptr[0], indent + 3);
      break;
    case FUNC_CALL:
      printf("%*c函数调用: \n", indent, ' ');
      printf("%*c函数名: %s\n", indent + 3, ' ', T->type_id);
      display(T->ptr[0], indent + 3);
      break;
    case ARGS:
      i = 1;
      while (T)
      {
        struct node *T0 = T->ptr[0];
        printf("%*c第%d个实际参数表达式: \n", indent, ' ', i++);
        display(T0, indent + 3);
        T = T->ptr[1];
      }
      printf("\n");
      break;
    }
  }
}