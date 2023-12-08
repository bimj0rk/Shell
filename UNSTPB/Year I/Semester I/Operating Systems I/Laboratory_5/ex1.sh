#! /bin/bash

echo "volvo, lexus"
read val

if [ "$val" == "volvo" ]; then
	echo "volvo"
elif [ "$val" == "lexus" ]; then
       echo "lexus"
else break
fi	
