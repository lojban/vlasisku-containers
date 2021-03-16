#!/bin/bash

exec 2>&1
set -e

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$HOME/bin:$HOME/.local/bin

maindir="$(readlink -f "$(dirname "$0")"/..)"
lbcsdir="/opt/lbcs"

. $lbcsdir/config
. $maindir/config

echo
echo "Killing container bots inside the previous container instance"
echo

for num in $(seq 1 10)
do
	if ! $CONTAINER_BIN exec web pgrep -f runbots
	then
		break
	fi

        $CONTAINER_BIN exec web pkill -f runbots || true
        sleep 1
        $CONTAINER_BIN exec web pkill -9 -f runbots || true
done

$CONTAINER_BIN exec web pgrep -f runbots || exit 0
