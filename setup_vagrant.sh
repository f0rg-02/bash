#!/usr/bin/env bash

echo "[*] Setting up vagrant box"

DIR=$(echo "$1" | cut -d"/" -f2)
cd $HOME && mkdir $DIR && cd $DIR
vagrant init "$1" && vagrant up && vagrant suspend

echo "[*] Done"
