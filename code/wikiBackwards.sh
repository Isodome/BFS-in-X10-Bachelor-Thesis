#!/bin/bash
GRAPH="../../graphs/wiki_first_backwards.sgraph"
RESULT="wiki_backwards.results"
PLACES="1"
STARTNODES="253167"

rm $RESULT
PLACES="1"
export X10_NPLACES=$PLACES
echo -e "\n $PLACES Place "
echo -e "serial_list mode"
./bfs_start -alg serial_list $GRAPH -runs $STARTNODES
echo -e "serial_sparse mode"
./bfs_start -alg serial_sparse $GRAPH -runs $STARTNODES 
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -runs $STARTNODES 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -runs $STARTNODES 

PLACES="2"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -runs $STARTNODES 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -runs $STARTNODES 

PLACES="4"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -runs $STARTNODES 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -runs $STARTNODES 

PLACES="6"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -runs $STARTNODES 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -runs $STARTNODES 

PLACES="8"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -runs $STARTNODES 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -runs $STARTNODES 
