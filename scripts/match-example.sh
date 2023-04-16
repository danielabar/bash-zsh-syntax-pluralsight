#!/bin/zsh

# Declare variable in lowercase
typeset -l test_var

# Set a value for test_var
test_var="color"

# Perform regular expression matching
if [[ $test_var =~ 'colou?r' ]]; then
  # Extract captured substring
  match=$MATCH
  echo "Match: $match"
else
  echo "No match found."
fi
