#!/bin/bash


GRAPHFILE=$1
export X10_NTHREADS=2

echo  ",1 Place,2 Places,4 Places,8 Places, 9 Places"

echo -n "Seriell,"
export X10_NPLACES=1
./bfs_start -alg serial_list  -q $GRAPHFILE
echo  ",,,,"



export X10_NPLACES=1
echo -n "1D,"
./bfs_start -alg 1d_list  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=2
./bfs_start -alg 1d_list  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=4
./bfs_start -alg 1d_list -q $GRAPHFILE
echo -n ","

export X10_NPLACES=8
./bfs_start -alg 1d_list  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=9
./bfs_start -alg 1d_list  -q $GRAPHFILE


export X10_NPLACES=1
echo -n -e "\n2D,"
./bfs_start -alg 2d_list_alt  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=2
./bfs_start -alg 2d_list_alt  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=4
./bfs_start -alg 2d_list_alt  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=8
./bfs_start -alg 2d_list_alt  -q $GRAPHFILE
echo -n ","

export X10_NPLACES=9
./bfs_start -alg 2d_list_alt  -q $GRAPHFILE


export X10_NPLACES=1
echo -n -e "\nInvasive,"
./bfs_start -alg invasive  -q -pes0 $GRAPHFILE
echo -n ","

export X10_NPLACES=2
./bfs_start -alg invasive  -q -pes0,1 $GRAPHFILE
echo -n ","

export X10_NPLACES=4
./bfs_start -alg invasive  -q -pes0,1,2,3 $GRAPHFILE
echo -n ","

export X10_NPLACES=8
./bfs_start -alg invasive  -q -pes0,1,2,3,4,5,6,7 $GRAPHFILE
echo -n ","

export X10_NPLACES=9
./bfs_start -alg invasive  -q -pes0,1,2,3,4,5,6,7,8 $GRAPHFILE

echo -e "\n,,,,,"