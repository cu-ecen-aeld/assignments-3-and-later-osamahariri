#!/bin/sh

filesdir=$1
searchstr=$2

if [ -z "$1" ] || [ -z "$2" ]
then 
    echo "Error: with passed arguments"
    exit 1
fi

if [ ! -d "$filesdir" ];then
    echo "Error: invalid directory $filesdir"
    exit 1 
fi 

fileList="$(find "${filesdir}" -type f )"

matching="$(grep -r "$searchstr" $fileList | wc -l)"

fileCount="$(find "${filesdir}" -type f | wc -l)"

echo "The number of files are ${fileCount} and the number of matching lines are ${matching}"

