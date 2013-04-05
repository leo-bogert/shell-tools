#!/bin/bash
if ! source "lib-bash-leo.sh" ; then
	echo 'lib-bash-leo.sh is missing in PATH!'
	exit 1
fi


set +o pipefail # Disable pipefail because the "head" in the pipe would make the script fail

tr -cd '[:alnum:]' < /dev/urandom | head -c"$1"
echo
