#!/usr/bin/env bash

# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton2@hp.com)

projects_file="$GOPATH/src/github.com/paulcarlton-ww/dev/projects.txt"
project="${1:-}"
if [ -z "${project}" ]; then
    echo "usage ${0} <project>"
    echo "where project is registered in ${projects_file}"
fi

. $GOPATH/src/github.com/paulcarlton-ww/dev/env/reset-path.sh

dir=$(grep "^${project}:" ${projects_file} | head -1 | awk -F: '{print $2}')
pushd $GOPATH/src/${dir}
set-title $project
git-info.sh
if [ -e $d/env/${project}.sh ]; then
    . $d/env/${project}.sh
fi

if [ -d $d/bin/${project} ]; then
    add_to_path $d/bin/${project}
fi

if [ -d $d/env/${project} ]; then
    add_to_path $d/env/${project}
fi