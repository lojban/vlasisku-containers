#!/bin/bash

exec 2>&1
set -e

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$HOME/bin:$HOME/.local/bin

maindir="$(readlink -f "$(dirname "$0")"/..)"
lbcsdir="/opt/lbcs"

. $lbcsdir/config
. $maindir/config

echo
echo "Launching container bots inside the previous container instance"
echo

$CONTAINER_BIN exec web /srv/lojban/vlasisku/manage.py updatedb
