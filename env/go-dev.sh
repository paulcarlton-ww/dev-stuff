#!/usr/bin/env bash

# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)


function add_to_path() {
    new_path="${1:-}"
    if [ -z "${new_path}" ]; then
        echo "no path provided"
        return 1
    fi

    if { show-path.sh | grep -q "^${new_path}$"; }; then
        echo "path already contains: $new_path"
        return
    fi
    PATH="$PATH:${new_path}"
}

set-title dev
export d=`dirname $(dirname "${BASH_SOURCE[0]:-}")`

echo "$PATH" | grep "$d" >/dev/null 2>&1
if [ "$?" == "1" ] ; then
    export PATH=$PATH:$d:$d/env:$d/bin
fi

export MY_IP=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
