#!/bin/bash

# This script takes all .sgraph files from the specified folder, runs
# all tests on all files 3 times and writes the result as csv in the specified output folder

EXPECTED_ARGS=2
if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: 'runall.sh <folder with graph files> <folder for result files>' "
  exit 1
fi

if [ -z "$1" ]
then
	echo "No graph files specified"
	exit
else 
	GRAPHFOLDER="$1"
fi

RESULTS_DIR="$2"



mkdir $2
FILES=`find $1 -name "*.sgraph"`
echo -e "Found Files: \n $FILES" > /dev/stderr
for f in $FILES
do
	echo "test"
	./TripleRun.sh $f $RESULTS_DIR
done

