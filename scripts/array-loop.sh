#!/bin/zsh

# declare an indexed array
declare -a users=("bob" "joe" "sue")

# count elements in array
echo ${#users[*]}

for ((i=1; i<=${#users[*]}; i++)); do
  echo ${users[$i]}
  # sudo useradd ${users[$i]}
done
