#! /bin/bash

read s1
read s2

if [ "$s1" = "$s2" ]; then
	echo "equal"
else echo "not equal"
fi
