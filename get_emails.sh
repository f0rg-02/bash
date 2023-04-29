#!/usr/bin/env bash
# i did this before 8 am on a wednesday. dont judge.
#directory=$(`dirname "$0"`)
#directory=$("$(dirname "${BASH_SOURCE[0]}")")
#echo "$directory"
zcat $(dirname "${BASH_SOURCE[0]}")/**/**/*.gz | grep -a "$1" # either im stupid or this is harder than it should be to get the fucking directory of the script. baka. owo

