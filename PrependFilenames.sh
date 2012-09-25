#!/bin/bash

# This script takes all .sgraph files from the specified folder, runs
# all tests on all files 3 times and writes the result as csv in the specified output folder

EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: 'AnalyserAll.sh <folder with csv files> "
  exit 1
fi

if [ -z "$1" ]
then
	echo "No graph files specified"
	exit
else 
	GRAPHFOLDER="$1"
fi



FILES=`find $1 -name "*.csv"`
echo "Found Files:"
echo "$FILES"
for f in $FILES
do
	base=`basename $f .csv`
	echo "$base,,,,," > /tmp/newfile
	cat "$f" >> /tmp/newfile
	cp /tmp/newfile "$f"
done

