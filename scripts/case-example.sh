#!/bin/zsh

case $USER in
  tux )
    echo "You are the course instructor"
    ;;
  dbaron )
    echo "You are a course participant"
    ;;
  root )
    echo "You are the boss"
    ;;
esac
