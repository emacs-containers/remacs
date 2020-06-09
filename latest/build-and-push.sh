#!/bin/bash
set -eu -o pipefail
cd "$(dirname "$0")"
echo "Entering directory '$PWD'"
set -x
# Ensure ASLR is turned off. Otherwise the dumper will fail in "docker build".
grep -q 0 /proc/sys/kernel/randomize_va_space
# Ensure we are running in a terminal for interactive testing in "docker run".
test -t 0
user="$(whoami)"
docker build -t remacs . 2>&1 | tee build.log
docker rm -f remacs || true
docker run --name remacs -it remacs
echo "Press Enter if it ran ok, Ctrl+C otherwise"
read
hash="$(docker ps -aqf name='^remacs$')"
test -n "$hash"
docker commit -m "Rebuild" -a "$user" "$hash" emacsen/remacs:latest
docker rm -f remacs
docker login
docker push emacsen/remacs:latest
