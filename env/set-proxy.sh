#!/bin/bash

export http_proxy="http://web-proxy.sdc.hpecorp.net:8080/"
export https_proxy="http://web-proxy.sdc.hpecorp.net:8080/"
export ftp_proxy="ftp://web-proxy.sdc.hpecorp.net:8080/"
export socks_proxy="socks://web-proxy.sdc.hpecorp.net:8080/"
export all_proxy="http://web-proxy.sdc.hpecorp.net:8080/"
export ALL_PROXY=$all_proxy
export no_proxy=127.0.0.0/8,127.0.0.1,localhost,192.168.0.0/16,16.0.0.0/8,::1,.hpecorp.net
