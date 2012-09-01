#!/bin/bash
GRAPH="../../graphs/100ksparse.sgraph"
RESULT="100ksparse.results"
PLACES="1"

rm $RESULT
PLACES="1"
export X10_NPLACES=$PLACES
echo -e "\n $PLACES Place "| tee -a $RESULT
echo -e "serial_list mode"| tee -a $RESULT
./bfs_start -alg serial_list $GRAPH -benchmark 3|  tee -a $RESULT
echo -e "serial_sparse mode"| tee -a $RESULT
./bfs_start -alg serial_sparse $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "1d_list mode"| tee -a $RESULT
./bfs_start -alg 1d_list $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "2d_list_alt mode"| tee -a $RESULT
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 | tee -a $RESULT

PLACES="2"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "| tee -a $RESULT
echo -e "1d_list mode"| tee -a $RESULT
./bfs_start -alg 1d_list $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "2d_list_alt mode"| tee -a $RESULT
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 | tee -a $RESULT

PLACES="4"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "| tee -a $RESULT
echo -e "1d_list mode"| tee -a $RESULT
./bfs_start -alg 1d_list $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "2d_list_alt mode"| tee -a $RESULT
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 | tee -a $RESULT

PLACES="6"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "| tee -a $RESULT
echo -e "1d_list mode"| tee -a $RESULT
./bfs_start -alg 1d_list $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "2d_list_alt mode"| tee -a $RESULT
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 | tee -a $RESULT

PLACES="8"
export X10_NPLACES=$PLACES
echo -e "\n\n$PLACES Place "| tee -a $RESULT
echo -e "1d_list mode"| tee -a $RESULT
./bfs_start -alg 1d_list $GRAPH -benchmark 3 | tee -a $RESULT
echo -e "2d_list_alt mode"| tee -a $RESULT
./bfs_start -alg 2d_list_alt $GRAPH -benchmark 3 | tee -a $RESULT
