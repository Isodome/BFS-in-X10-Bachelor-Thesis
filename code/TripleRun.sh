#!/bin/bash

# This script runs a BFS for the graph specified in the argument

RESULTS_DIR=../TestResults/

if [[ "$1" = /* || "$1" = ~* ]]
then
    # Absolute path
    GRAPH_FILE=$1
else
    # Relative path
    GRAPH_FILE=../../graphs/$1
fi


./run.sh $GRAPH_FILE | tee $RESULTS_DIR/$1.csv
./run.sh $GRAPH_FILE | tee -a $RESULTS_DIR/$1.csv
./run.sh $GRAPH_FILE | tee -a $RESULTS_DIR/$1.csv

echo -e -n "\a"
