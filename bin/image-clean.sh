#!/bin/bash

# Utility access minikube container
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton2@hp.com)


function usage()
{
    echo "USAGE: ${0##*/} <image> <version>"
	echo "<commands> default to 'sh'"  
}

if [ -n "$1" ] ;then
	image="$1"
	shift
fi

if [ -n "$1" ] ;then
	version="$1"
	shift
else
    usage
    exit
fi

if [[ "$image" == "" || "$image" == "--help" || "$image" == "-h" ]] ; then
	usage
	exit
fi

for c in `docker images | grep -v REPO | grep "$image" | grep "$version" | awk '{print $3}'`; do docker rmi -f $c;done
