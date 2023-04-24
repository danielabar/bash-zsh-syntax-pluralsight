#!/bin/zsh

declare -i x=10

until (( x == 0 )) ; do
  echo $x
  x=x-1
done
