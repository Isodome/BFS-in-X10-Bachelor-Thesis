BINDIR = ../../x10-2.2.2.2/bin/
CC=$(BINDIR)x10c++
JCC=$(BINDIR)x10c 
JSIM=$(BINDIR)x10
BINARY=bfs_start

FILES = Bfs.x10 graph/IGraph.x10 graph/Graph.x10 bfs/BfsSerial.x10 bfs/IBfs.x10



# c++ Regeln
$(BINARY): 
	$(CC) Bfs.x10 -o $(BINARY)

.PHONY: cpp 
cpp: $(BINARY)

.PHONY: csim
csim: $(BINARY)
	./$(BINARY)


# Java Regeln
Bfs.class:
	$(JCC) -VERBOSE_CHECKS Bfs.x10

.PHONY: java
java: Bfs.class

.PHONY: jsim
jsim:
	$(JSIM) Bfs


# Aufreaumen
.PHONY:	clean
clean: 
	rm -Rf *.cc *.h *.java $(BINARY)
