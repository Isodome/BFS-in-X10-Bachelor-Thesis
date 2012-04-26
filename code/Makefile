BINDIR = ../../x10-2.2.2.2/bin/
CC=$(BINDIR)x10c++ -VERBOSE_CHECKS
JCC=$(BINDIR)x10c 
JSIM=$(BINDIR)x10
BINARY=bfs_start

FILES = Bfs.x10 graph/IGraph.x10 graph/Graph.x10 bfs/BfsSerial.x10 bfs/IBfs.x10



# c++ Regeln
$(BINARY): $(FILES)
	$(CC) Bfs.x10 -o $(BINARY)

.PHONY: cpp 
cpp: $(BINARY)

.PHONY: csim
csim: $(BINARY)
	./$(BINARY) -alg serial_matrix  test.tgf


# Java Regeln
Bfs.class:$(FILES)
	$(JCC) -VERBOSE_CHECKS Bfs.x10

.PHONY: java
java: Bfs.class

.PHONY: jsim
jsim:
	$(JSIM) Bfs


# Aufreaumen
.PHONY:	clean
clean: 
	rm -rf $(BINARY)
	find . -type f -name "*.cc" -delete
	find . -type f -name "*.h" -delete
	find . -type f -name "*.java" -delete
	find . -type f -name "*.class" -delete
