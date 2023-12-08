#! /bin/bash

read c1
read c2

while [ $c1 -le $c2 ]
do
	echo $c1
	c1=$(( $c1 + 1 ))
done	
