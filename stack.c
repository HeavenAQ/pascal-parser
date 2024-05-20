#include "stack.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void *must_calloc(size_t nmemb, size_t size) {
  void *ptr = calloc(nmemb, size);
  if (ptr == NULL) {
    fprintf(stderr, "calloc failed\n");
    exit(EXIT_FAILURE);
  }
  return ptr;
}

Node *init_node(const char *data) {
  Node *newnode = (Node *)must_calloc(1, sizeof(Node));
  newnode->data = (char *)must_calloc(1, strlen(data));
  newnode->type = 0;
  newnode->is_array = false;
  memcpy(newnode->data, data, strlen(data));
  newnode->next = NULL;
  return newnode;
}

static void free_node(Node *node) {
  free(node->data);
  free(node);
}

static void push(Stack *self, const char *data) {
  Node *newnode = init_node(data);
  newnode->next = self->head;
  self->head = newnode;
}

static Node *pop(Stack *self) {
  if (self->head == NULL) {
    return NULL;
  }
  Node *tmp = self->head;
  self->head = self->head->next;
  return tmp;
}

static Node *search(Stack *self, const char *data) {
  Node *current = self->head;
  while (current != NULL) {
    if (strcmp(current->data, data) == 0) {
      return current;
    }
    current = current->next;
  }
  return NULL;
}

void destroy_stack(Stack *stack) {
  while (stack->head != NULL) {
    Node *tmp = stack->head;
    stack->head = stack->head->next;
    free_node(tmp);
  }
  free(stack);
}

void init_stack(Stack **self) {
  *self = (Stack *)must_calloc(1, sizeof(Stack));
  (*self)->head = NULL;
  (*self)->push = &push;
  (*self)->pop = &pop;
  (*self)->search = &search;
}
