#!/bin/bash

# Utility for comparing files in different directories
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} <url>"
    echo "where <url> is the repository clone url"
    echo "This script will create the appropriate directory sub tree under $HOME/go/src"
    echo "then changes to parent directory and clones"
    echo "if the repository directory already exists, it does a fetch"
}

function args() {
  unset dry_run
  unset force
  unset url
  unset debug

  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--debug") debug=1;set -x;;
        "--dry-run") dry_run=1;;
          "--force") force=1;;
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
  url="${arg_list[*]:$arg_index:$(( arg_count - arg_index + 1))}"
  if [ -z "${target:-}" ] ; then
      usage; exit 1
  fi
}

function clone_repo()
{
    local dest
}

function pull_repo()
{
    local repo_dir
}

args $@

