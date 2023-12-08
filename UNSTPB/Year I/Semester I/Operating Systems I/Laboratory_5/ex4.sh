#!/bin/bash

read site
traceroute -n -4 $site| tail -n 1 > test

IFS=' '
file=/home/adiicmp/OSA/OSA_Lab/OSA_Lab_5/test
col=`cat $file | awk '{print NF}'`
file1=/home/adiicmp/OSA/OSA_Lab/OSA_Lab_5/test1
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $file > $file1


while read -ra ip ; do
ip1=${ip[0]}
ip2=${ip[1]}
done < $file1

while read -ra val; do

        for (( i=0; i<=$col; i++ )); do
#       echo $i
#        echo ${val[($i+1)]}    
                if [ "$ip1" = "${val[$i]}" ];
                then
                        if [ "${val[($i+1)]}" != "*" ]
                        then echo "$ip1 is up"
                        elif [ "$ip2" = "${val[$i]}" ]
                        then
                                if [ "${val[($i+1)]}" != "*" ]
                                then echo "$ip1 is down, $ip2 is up"
                                fi
                        fi
                fi
        done

done < $file

