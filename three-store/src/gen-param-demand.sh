#!/bin/sh
# generate parameter file for simulating demand paths

if [ $# -eq 0 ]
then
    file='params-demand.txt'
else
    file=$1
fi

if [ -f $file ]
then
    rm $file
fi

id=0
for a in 1 2 4 8
do
    for meanLm in 10 20 30 40 50 60
    do
        for gm in 1 2 3 4 5
        do
            (( id++ ))
            printf '%03d %d %d %d\n' $id $a $meanLm $gm >> $file
        done
    done
done
