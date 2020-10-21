export GOPATH=$HOME
export GOBIN=$GOPATH/bin
export GOROOT=$HOME/bin/go
export PATH=$PATH:$GOROOT/bin
export root_pwd=Olivia17%

source <(kubectl completion bash)
export KUBECONFIG=~/.kube/config

export host_id=`hostname`

function set-title(){
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  sep=""
  if [[ -n "$*" ]] ; then
    sep="-"
  fi
  TITLE="\[\e]2;$host_id$sep$*\a\]"
  PS1=${ORIG}${TITLE}
}
. ~/src/github.com/paulcarlton-ww/dev-stuff/env/go-dev.sh


