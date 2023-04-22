#!/bin/zsh

# short form of current month, eg: `Apr`, then lower case it, eg: `apr`
# declare and populate in the same line
# note that $(...) executes a subshell and returns output of the command inside it, aka command substitution
declare -l month=$(date +%b)

# output what season it is based on the current month
case $month in
  dec | jan | feb )
    echo "Winter";;
  mar | apr | may )
    echo "Spring";;
  jun | jul | aug )
    echo "Summer";;
  sep | oct | nov )
    echo "Winter";;
esac
