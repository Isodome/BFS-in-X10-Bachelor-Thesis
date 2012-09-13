#!/bin/bash

GRAPHFILE=$1

echo  ",1 Place,2 Places,4 Places,8 Places, 9 Places"
echo -n "Seriell,"


export X10_NPLACES=1
echo -n `./bfs_start -alg serial_list  -q $GRAPHFILE`
echo  ",,,,,"



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

echo -e "\n,,,,,"