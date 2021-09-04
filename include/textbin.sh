#!/bin/bash

encode() {
  eval "$1"='$(
    shift
    "$@" | xxd -p  -c 0x7fffffff
    exit "${PIPESTATUS[0]}")'
}

decode() {
 #local -n result="$1"
 #result=$(
  printf %s "$1" | xxd -p -r
 #)
}
