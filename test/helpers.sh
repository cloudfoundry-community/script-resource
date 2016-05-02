#!/bin/bash

set -e -u
set -o pipefail

resource_dir=/opt/resource

run() {
  export TMPDIR=$(mktemp -d ${TMPDIR_ROOT}/script-tests.XXXXXX)

  echo -e 'running \e[33m'"$@"'\e[0m...'
  eval "$@" 2>&1 | sed -e 's/^/  /g'
  echo -e '\e[32m'"$@ passed!"'\e[0m'
  echo ""
  echo ""
}

test_check() {

  local addition=""
  local arg=""
  local json="{}"

  while [ $# -gt 0 ] ; do

    arg=$1 ; shift
    addition=""
    case $arg in
      "shell" )
        addition="$(jq -n "{
          source: {
            uri: $(echo $1 | jq -R .)
          }
        }")"
        shift;;

      "script" )
        addition="$(jq -n "{
          source: {
            body: $(cat $1 | jq -s -R .)
          }
        }")"
        shift;;

      "filename" )
        addition="$(jq -n "{
          source: {
          filename: $(echo $1 | jq -R .)
          }
        }")"
        shift;;

      * )
        echo -e '\e[31m'"Unknown argument '$arg'"'\e[0m' >&2
        exit 1;;

    esac

    if [ "$addition" != "" ] ; then
      json="$(echo "$json" "$addition" | jq -s '.[0] * .[1]')"
    fi

  done

  echo "$json" | ${resource_dir}/check | tee /dev/stderr
}

test_get() {
  local addition=""
  local arg=""
  local json="{}"
  local destination

  while [ $# -gt 0 ] ; do

    arg=$1 ; shift
    addition=""
    case $arg in
      "shell" )
        addition="$(jq -n "{
          source: {
            uri: $(echo $1 | jq -R .)
          }
        }")"
        shift;;

      "script" )
        addition="$(jq -n "{
          source: {
            body: $(cat $1 | jq -s -R .)
          }
        }")"
        shift;;

      "filename" )
        addition="$(jq -n "{
          source: {
          filename: $(echo $1 | jq -R .)
          }
        }")"
        shift;;

      * )
        if [ -z ${destination+is_set} ] ; then
          destination=$arg
        else
          echo -e '\e[31m'"Unknown argument '$arg'"'\e[0m' >&2
          exit 1
        fi
        ;;

    esac

    if [ "$addition" != "" ] ; then
      json="$(echo "$json" "$addition" | jq -s '.[0] * .[1]')"
    fi

  done

  if [ -z ${destination+is_set} ] ; then
    echo -e '\e[31m'"ERROR: destination not specified for test_get"'\e[0m' >&2
    exit 1
  fi

  echo "$json" | ${resource_dir}/in $destination | tee /dev/stderr
}
