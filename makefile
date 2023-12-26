YFLAGS=-dt --debug --verbose -Dparse.trace
PROGRAM=assembler
OBJS=$(PROGRAM).tab.o lex.yy.o
SRCS=$(PROGRAM).tab.c lex.yy.c
CC=gcc
CFLAGS=-g

all: $(PROGRAM) makefile

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ -O

$(PROGRAM).tab.c: $(PROGRAM).y
	bison $(YFLAGS) $(PROGRAM).y

lex.yy.c: $(PROGRAM).l
	flex $(PROGRAM).l

$(PROGRAM): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ -lm

clean:
	rm $(OBJS) $(SRCS) $(PROGRAM).tab.h $(PROGRAM) $(PROGRAM).output
