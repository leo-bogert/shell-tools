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

set_working_directory_or_die() {
	if [ "$#" -ne 1 ] ; then
		die 'Invalid parameter count'
	fi
	
	if ! cd "$1" ; then
		die 'Setting working directory failed!'
	fi
}

obtain_two_parameters_as_inputdir_output_dir() {
	if [ "$#" -ne 2 ] ; then
		die "Syntax: $0 INPUT_DIR OUTPUT_DIR"
	fi

	local input_dir="$(remove_trailing_slash_on_path "$1")"
	local output_dir="$(remove_trailing_slash_on_path "$2")"
	
	INPUT_DIR_ABSOLUTE="$(make_path_absolute_to_original_working_dir "$input_dir")"
	OUTPUT_DIR_ABSOLUTE="$(make_path_absolute_to_original_working_dir "$output_dir")"

    stdout "Input directory: $INPUT_DIR_ABSOLUTE"
    stdout "Output directory: $OUTPUT_DIR_ABSOLUTE"
}

ask_to_continue_or_die() {
	local confirmed=n
	read -p 'Continue? (y/n)' confirmed
	
	if [ "$confirmed" != 'y' ] ; then
		stderr 'Aborting because you said so.'
		exit 1
	fi
}


enable_errexit_and_errtrace
