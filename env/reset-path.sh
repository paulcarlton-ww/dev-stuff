#!/usr/bin/env bash

# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton2@hp.com)

if [ -f "/etc/environment" ] ; then
    . /etc/environment
fi
export PATH=$HOME/bin:$PATH:/usr/local/go/bin:$HOME/.local/bin
. ~/src/github.com/paulcarlton-ww/dev/env/go-dev.sh
