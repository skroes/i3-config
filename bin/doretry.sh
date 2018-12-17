#!/bin/bash -x
#
# "<cmd>" <retry times> <retry wait>
#
do_retry()
{
  cmd="$1"
  retry_times=$2
  retry_wait=$3

  c=0
  while [ $c -lt $((retry_times+1)) ]; do
    c=$((c+1))
    echo "Executing \"$cmd\", try $c"
    $cmd && return $?
    if [ ! $c -eq $retry_times ]; then
      echo "Command failed, will retry in $retry_wait secs"
      sleep $retry_wait
    else
      echo "Command failed, giving up."
      return 1
    fi
  done
}

do_retry "exit 1" 2 20
