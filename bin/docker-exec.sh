#!/bin/bash

# Utility access minikube container
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton2@hp.com)


function usage()
{
    echo "USAGE: ${0##*/} <container> [<commands>]"
	echo "<commands> default to 'sh'"  
}

if [ -n "$1" ] ;then
	container_name="$1"
	shift
fi

if [ -n "$1" ] ;then
	commands="$@"
else
	commands="sh"
fi

if [[ "$container_name" == "" || "$container_name" == "--help" || "$container_name" == "-h" ]] ; then
	usage
	exit
fi

docker exec -it $container_name $commands
