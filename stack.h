#ifndef STACK_H
#define STACK_H
#include <stdbool.h>
typedef struct Node Node;
typedef struct Stack Stack;
struct Node {
  char *data;
  int type;
  bool is_array;
  Node *next;
};

struct Stack {
  Node *head;
  void (*push)(Stack *self, const char *data);
  Node *(*pop)(Stack *self);
  Node *(*search)(Stack *self, const char *data);
};

extern void destroy_stack(Stack *self);
extern void init_stack(Stack **self);
extern Node *init_node(const char *data);

#endif
