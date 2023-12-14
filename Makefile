# Makefile TP Flex

# $@ : the current target
# $^ : the current prerequisites
# $< : the first current prerequisite

CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl

all: bin/tpcas

bin/tpcas : obj/tpcas.tab.o obj/lex.yy.o
	$(CC) $^ -o $@

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

obj/lex.yy.c :
	flex src/tpcas.lex
	mv lex.yy.c $@

obj/tpcas.tab.c :
	bison -d src/tpcas.y -o obj/tpcas.tab.c

clean:
	rm -f obj/*
	rm -f bin/*