BINDIR = ../x10-2.2.2.2/bin/
CC=$(BINDIR)x10c++
JCC=$(BINDIR)x10c 
JSIM=$(BINDIR)x10
BINARY=bfs


.PHONY: all
all: Hello.x10 graph/Graph.x10
	$(CC) Hello.x10 -o $(BINARY)

.PHONY: sim
sim:
	make all && ./$(BINARY)

.PHONY: java
java:
	$(JCC) -VERBOSE_CHECKS Hello.x10

.PHONY:	clean
clean: 
	rm -Rf *.cc *.h *.java $(BINARY)
