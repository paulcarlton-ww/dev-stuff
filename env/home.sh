#!/bin/bash

# Utilitiy for setting proxy for home use
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

export DOCKER_PROXY_UPDATE=1
. $d/env/proxy.sh unset
unset DOCKER_PROXY_UPDATE