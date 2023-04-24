#!/bin/zsh

# declare an integer variable `x` with an initial value of 10
declare -i x=10

# print out the value of x to the console as long as x is greater than 0
while (( x > 0 )) ; do
  echo $x
  # decrement x
  x=x-1
done
