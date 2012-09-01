#!/bin/bash
GRAPH="../../graphs/1msparse.sgraph"
RESULT="1msparse.results"
PLACES="1"

rm $RESULT
PLACES="1"
export X10_NPLACES=$PLACES
echo -e "\n $PLACES Place "
echo -e "serial_list mode"
./bfs_start -alg serial_list $GRAPH -benchmark 3
echo -e "serial_sparse mode"
./bfs_start -alg serial_sparse $GRAPH -benchmark 3 
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -benchmark 3 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 

PLACES="2"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -benchmark 3 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 

PLACES="4"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -benchmark 3 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 

PLACES="6"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -benchmark 3 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 

PLACES="8"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "
echo -e "1d_list mode"
./bfs_start -alg 1d_list $GRAPH -benchmark 3 
echo -e "2d_list_alt mode"
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 
