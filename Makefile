FILE_lex := b081020008.l
PROG_lex := lex.yy.c
FILE_yacc := b081020008.y 
PROG_yacc := y.tab.c
HEADER_yacc := $(PROG_yacc:.c=.h)
MY_LIB := stack.c

.PHONY: all test clean

all: $(PROG_lex) $(PROG_yacc)
	gcc $(PROG_lex) $(PROG_yacc) $(MY_LIB) -ly -o a.out

$(PROG_yacc): $(FILE_yacc)
	bison -y -d $(FILE_yacc)

$(PROG_lex): $(FILE_lex)
	flex $(FILE_lex)

test:
	echo $(PROG_yacc)
	echo $(HEADER_yacc)

clean:
	rm -f a.out $(PROG_lex) $(PROG_yacc) $(HEADER_yacc)

