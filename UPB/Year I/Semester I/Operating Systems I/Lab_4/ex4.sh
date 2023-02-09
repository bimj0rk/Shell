#! /bin/bash

echo "linux, bash, scripting, tutorial"
read val
if [ $val = "scripting" ] ; then
	echo $val
elif [ $val = "linux" ]; then
	echo $val
elif [ $val = "bash" ]; then
	echo $val
elif [ $val = "tutorial" ]; then
	echo $val
else echo "not reachable"
fi
