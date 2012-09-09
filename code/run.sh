#!/bin/bash

echo "1 Place"
export X10_NPLACES=1
perl sim.pl $1 $2 -q

echo "2 Places"
export X10_NPLACES=2
perl sim.pl $1 $2 -q

echo "4 Places"
export X10_NPLACES=4
perl sim.pl $1 $2 -q

echo "6 Places"
export X10_NPLACES=6
perl sim.pl $1 $2 -q

echo "8 Places"
export X10_NPLACES=8
perl sim.pl $1 $2 -q

echo "9 Places"
export X10_NPLACES=9
perl sim.pl $1 $2 -q