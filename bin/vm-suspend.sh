#!/bin/bash

# Utility to stop devstack
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

if [ -z "$1" ] ; then 
    echo "usage: $0 <vm name>"
    exit
fi
dir_name=`sudo find ~/vmware* -name $1 | sed s#$HOME/## | sed s#/$1##`
nohup vmrun suspend ~/$dir_name/$1/$1.vmx >/tmp/$1.log 2>&1

