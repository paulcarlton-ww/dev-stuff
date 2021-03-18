#!/bin/bash

# Utility for comparing files in different directories
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--dry-run] [--debug] <path>"
    echo "where <path> is the repository path, i.e. github.com/weaveworks/wksctl"
    echo "This script will create the appropriate directory sub tree under $HOME/go/src"
    echo "then clones the repository if the final element of the path does not exist"
    echo "if the repository directory already exists, it does a pull"
    echo "currently only works for github"
}

function args() {
  dry_run=""
  #unset force
  unset path
  #unset debug

  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--debug") set -x;;
        "--dry-run") dry_run="echo ";;
        #  "--force") force=1;;
               "-h") usage; exit;;
           "--help") usage; exit;;
               "-?") usage; exit;;
        *) if [ "${arg_list[${arg_index}]:0:2}" == "--" ];then
               echo "invalid argument: ${arg_list[${arg_index}]}"
               usage; exit
           fi;
           break;;
    esac
    (( arg_index+=1 ))
  done
  path="${arg_list[*]:$arg_index:$(( arg_count - arg_index + 1))}"
  if [ -z "${path:-}" ] ; then
      usage; exit 1
  fi
  path="$(echo "${path}" | cut -f1-3 -d/)"
}

args "$@"

repo=$(basename "${HOME}/go/src/${path}")
dir=$(dirname "${HOME}/go/src/${path}")

if [ ! -d "${HOME}/go/src/${path}" ] ; then
    $dry_run mkdir -p "${HOME}/go/src/${path}"
    $dry_run git clone git@github.com:"$(basename "${dir}")"/"${repo}".git "${HOME}/go/src/${path}"
fi

$dry_run git -C "${HOME}/go/src/${path}" pull





