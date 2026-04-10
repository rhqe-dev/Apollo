#!/bin/bash

# Resolve directory this script lives in so it works from any cwd
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

export TERM=xterm-256color

while true; do
    ./apollo
    echo "[apollo] process exited — restarting in 1s..."
    sleep 1
done
