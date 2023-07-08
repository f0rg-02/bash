#!/usr/bin/env bash

# Find all directories with .git and git pull any new changes

git config --global safe.directory '*'
find . -name .git -execdir git pull -v ';'
