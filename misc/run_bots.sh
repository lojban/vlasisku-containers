#!/bin/bash

exec 2>&1
set -e

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$HOME/bin:$HOME/.local/bin

maindir="$(readlink -f "$(dirname "$0")"/..)"
lbcsdir="/opt/lbcs"

. $lbcsdir/config
. $maindir/config

# Stolen from run_container.sh
for after_container in web
do
    for num in $(seq 1 10)
    do
        if [[ $($CONTAINER_BIN container inspect --format '{{.State.Status}}' $after_container) == 'running' ]]
        then
            break
        fi
        echo -e "\nWaiting for required container $after_container to start.\n"
        sleep 30
    done

    if [[ $($CONTAINER_BIN container inspect --format '{{.State.Status}}' $after_container) == 'running' ]]
    then
        echo -e "\nRequired container $after_container has started.\n"
    else
        echo -e "\nRequired container $after_container has not started; exiting.\n"
        exit 1
    fi
done

echo
echo "Launching container bots inside the previous container instance"
echo

$CONTAINER_BIN exec web /srv/lojban/vlasisku/inside_run_bots.sh
