#! /bin/bash

file="/home/adiicmp/OSA"
if [ -f "$file" ]; then
	echo "exists"
else touch /home/adiicmp/OSA
fi
