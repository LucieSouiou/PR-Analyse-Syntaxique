# Makefile TP Flex

# $@ : the current target
# $^ : the current prerequisites
# $< : the first current prerequisite

CC=gcc
CFLAGS=-Wall -lfl -I./src

all: bin/tpcas

bin/tpcas : obj/tpcas.tab.o obj/lex.yy.o obj/tree.o
	$(CC) $^ -o $@ $(CFLAGS)

obj/tree.o : src/tree.c src/tree.h
	$(CC) -o $@ -c $<

obj/lex.yy.c : src/tpcas.lex
	flex -o $@ src/tpcas.lex

obj/tpcas.tab.c : src/tpcas.y
	bison -d src/tpcas.y -o $@

%.o : %.
	$(CC) $< -c -o $@

clean:
	rm -f obj/*
	rm -f bin/*