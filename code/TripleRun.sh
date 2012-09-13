#!/bin/bash

# This script runs a BFS for the graph specified in the argument

if [[ "$1" = /* ]]; then
    # Absolute path
    GRAPH_FILE=$1
else
    # Relative path
    GRAPH_FILE=../../graphs/$1
fi
BASENAME=`basename $GRAPH_FILE`

if [ -z "$2"]; then
	RESULTS_DIR="$2"
else 
	RESULTS_DIR=../TestResults/
fi




./run.sh $GRAPH_FILE | tee $RESULTS_DIR/BASENAME.csv
./run.sh $GRAPH_FILE | tee -a $RESULTS_DIR/BASENAME.csv
./run.sh $GRAPH_FILE | tee -a $RESULTS_DIR/BASENAME.csv

echo -e -n "\a"
