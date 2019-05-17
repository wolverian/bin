#!/bin/bash

set -eu

cmd=$1; shift

case $cmd in
add)
  profile=${1?usage: k add <profile>}; shift
  ln -s ~/bin/kubectl.wrapper ~/bin/kubectl.$profile
  ;;
remove)
  profile=${1?usage: k remove <profile>}; shift
  rm ~/bin/kubectl.$profile
  ;;
ls|list)
  (cd ~/bin && ls kubectl.*) | grep -v kubectl.wrapper | sed 's|^kubectl\.||'
  ;;
*)
  echo >&2 unsupported: $cmd
  exit 1
esac
