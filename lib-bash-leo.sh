#!/bin/bash
set -o nounset
set -o pipefail
#set -o errexit	# see enable_errexit_and_errtrace
#set -o errtrace # see enable_errexit_and_errtrace
shopt -s nullglob
shopt -s failglob

readonly ORIGINAL_WORKING_DIR="$PWD"

secho() {
	printf '%s\n' "$*"
}

stdout() {
	secho "$@" >&1
}

stderr() {
	secho "$@" >&2
}

die() {
	stderr 'ERROR:' "$@"
	exit 1
}

err_handler() {
	die "error at line $1, last exit code is $2"
}

enable_errexit_and_errtrace() {
	set -o errexit
	set -o errtrace
	trap 'err_handler "$LINENO" "$?"' ERR
}

remove_trailing_slash_on_path() {
	if [ "$#" -ne 1 ] ; then
		die "Invalid parameter count: $#"
	fi
	
	if [[ "$1" != '/' ]] ; then
		secho "${1%/}"
	else
		secho "$1"
	fi
}

make_path_absolute_to_original_working_dir() {
	if [ "$#" -ne 1 ] ; then
		die "Invalid parameter count: $#"
	fi
	
	if [[ "$1" != /* ]] ; then
		secho "$ORIGINAL_WORKING_DIR/$1"
	else
		secho "$1"
	fi
}

enable_errexit_and_errtrace
