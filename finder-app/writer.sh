#!/bin/sh

writefile=$1
writestr=$2

if [ -z "$1" ] || [ -z "$2" ]
then 
    echo "Error: with passed arguments"
    exit 1
fi

dir="${writefile%/*}"

mkdir -p ${dir}

touch $writefile

echo ${writestr} > ${writefile}

