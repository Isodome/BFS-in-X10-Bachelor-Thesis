#!/bin/bash

RESULTS_DIR=../TestResults/
GRAPH_DIR=../../graphs/

./run.sh $GRAPH_DIR$1 | tee $RESULTS_DIR/$1.csv
./run.sh $GRAPH_DIR$1 | tee -a $RESULTS_DIR/$1.csv
./run.sh $GRAPH_DIR$1 | tee -a $RESULTS_DIR/$1.csv
