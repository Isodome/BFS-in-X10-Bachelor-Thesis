CCDIR = ../../x10-2.2.3/bin/
CC=$(CCDIR)x10c++
CC_LEGACY_DIR=../../x10-2.2.2.2/bin/
CC_LEGACY=$(CC_LEGACY_DIR)x10c++
JCC=$(CCDIR)x10c 
JSIM=$(CCDIR)x10
BINARY=bfs_start
FLAGS= -O -VERBOSE_CHECKS

# FILES = Bfs.x10 parser/Graph.x10 parser/GraphStructure.x10 bfs/BfsSerial.x10 bfs/IBfs.x10
FILES = $(wildcard *.x10) $(wildcard parser/*.x10) $(wildcard bfs/*.x10) $(wildcard invasic/*.x10) $(wildcard x10/array/*.x10)

# c++ Regeln
$(BINARY): $(FILES)
	$(CC) $(FLAGS) Bfs.x10 -o $(BINARY)

.PHONY: cpp 
cpp: $(BINARY)

.PHONY: legacy
legacy: $(FILES)
	$(CC_LEGACY) $(FLAGS) Bfs.x10 -o $(BINARY)

.PHONY: csim
csim: $(BINARY)
	./$(BINARY) -alg 1d_matrix  test.sgraph


# Java Regeln
Bfs.class:$(FILES)
	$(JCC) -VERBOSE_CHECKS Bfs.x10

.PHONY: java
java: Bfs.class

.PHONY: jsim
jsim:
	$(JSIM) Bfs -alg serial_matrix test.sgraph


# Aufreaumen
.PHONY:	clean
clean: 
	rm -rf $(BINARY)
	find . -type f -name "*.cc" -delete
	find . -type f -name "*.h" -delete
	find . -type f -name "*.java" -delete
	find . -type f -name "*.class" -delete

.PHONY: simclean
simclean:
	rm -f -dr simresults
