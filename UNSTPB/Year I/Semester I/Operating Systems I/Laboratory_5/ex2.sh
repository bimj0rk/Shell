#1 /bin/bash

read site

if ping -c 1 $site
then
	echo "success"
else echo "fail"
fi
