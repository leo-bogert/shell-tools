#!/bin/bash
set -o nounset
#set -o pipefail	# The "head" in the pipe would make the script fail
set -o errexit
set -o errtrace
shopt -s nullglob
shopt -s failglob

tr -cd '[:alnum:]' < /dev/urandom | head -c"$1"
echo
