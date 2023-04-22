#!/bin/zsh

declare -l DIR
# Use -n with echo so it will not generate new line char,
# This way when user enters their value, its on the same line as the prompt
echo -n "Enter the name of the directory to create: "
read DIR

# check if a file or dir named $DIR already exists
if [[ -e $DIR ]]; then
  echo "A file or directory already exists with the name $DIR"
  exit 1
else
  # check that the user has permission to write to the current working directory
  if [[ -w $PWD ]]; then
    # if entered `FOO` at prompt, this will create a dir named `foo`
    echo "Creating directory $DIR"
    mkdir $DIR
  else
    echo "You don't have write permission to create $DIR within $PWD"
    exit 2
  fi
fi
