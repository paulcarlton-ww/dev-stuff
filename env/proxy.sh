#!/bin/bash

function usage()
{
    echo "USAGE: ${0##*/} [set | unset]"
    echo "This script sets or unsets proxys"
    echo "Without any arguments it determines if the host is connected the HPE network"
    echo "and sets or unsets proxys as appropriate"
    echo "To force setting or unsetting of proxies, use the set or unset arguments"
    echo
}

function set_mode()
{
	if [ -n "$1" ] ; then
		mode=$1
		if [ "$mode" == "set" ] ; then
			proxys=0
			return
		fi
		if [ "$mode" == "unset" ] ; then
			proxys=1
			return
		fi
		usage
	fi
}


uname -a | grep "Linux" > /dev/null
if [ "$?" != "0" ] ; then
    ipconfig | grep "IPv4 Address" | grep "10.37" >/dev/null
    proxys=$?
else
    ip=$(ip -4 route get 1 | awk '{ for(i=1;i<=NF;i++) if ($i ~ /^src$/) print $(i+1)}')
    timeout 1 ping -c 1 pcarlton4.emea.hpqcorp.net >/dev/null
    [[ "$?" == "0"  || "$ip" =~ "^10.37." ]] && proxys=0 || proxys=1
fi

mode=default
set_mode $1

#echo "proxys: $proxys, mode: $mode"

if [ "$proxys" == "0" ] ; then
	if [[ -z "$http_proxy" || "$mode" == "set"  ]] ; then
		. $d/env/set-proxy.sh
		sudo cp $d/info/proxy.conf /etc/apt/apt.conf.d
	fi
	if [ -n "$DOCKER_PROXY_UPDATE" ]; then
        docker info 2>/dev/null | grep -i proxy.sdc >/dev/null
        if [[ "$?" == "1" ]] ; then
            echo "Docker proxies not set, setting"
            sudo cp $d/info/http-proxy.conf /etc/systemd/system/docker.service.d/http-proxy.conf
            sudo systemctl daemon-reload
            sudo systemctl restart docker
        fi
    fi
else
	echo "Non office, no proxys needed"
	if [[ -n "$http_proxy" || "$mode" == "unset" ]] ; then
		. $d/env/unset-proxy.sh
		sudo rm /etc/apt/apt.conf.d/proxy.conf
	fi
	if [ -n "$DOCKER_PROXY_UPDATE" ]; then
	    docker info 2>/dev/null | grep -i proxy >/dev/null
        if [[ "$?" == "0" || "$mode" == "unset" ]] ; then
            echo "Docker proxies set, reseting"
            if [ -e /etc/systemd/system/docker.service.d/http-proxy.conf ] ; then
                sudo rm -rf /etc/systemd/system/docker.service.d/http-proxy.conf
            fi
            sudo systemctl daemon-reload
            sudo systemctl restart docker
        fi
    fi
fi
