#!/bin/bash

# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

my_path=`dirname $(dirname "${BASH_SOURCE[0]:-}")`
pushd "${my_path}" >/dev/null
set-title dev
git fetch --all

git status | grep "nothing to commit, working directory clean" >/dev/null
if [ "$?" == "0" ] ; then
	echo "no local updates, pulling"
	git pull
else
	echo "local updates, committing"
	git pull
	git add -A
	git commit -a -m "update from `hostname`"
	git pull
	git status | tee /tmp/status.log
	grep "conflicts" /tmp/status.log >/dev/null
	if [ "$?" == "0" ] ; then
		read -p "fix conflicts and then press any key to continue... " -n1 -s
		git add -A
		git commit --no-edit
	fi
	git push
fi


