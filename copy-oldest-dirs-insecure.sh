#!/bin/bash
if ! source "lib-bash-leo.sh" ; then
	echo 'lib-bash-leo.sh is missing in PATH!'
	exit 1
fi


if [ $# -ne 3 ] ; then
	echo "Syntax: $0 SOURCE DEST MEGABYTES"
	exit 1
fi

get_size_mb() {
	size="$(du -b -s -BM "$1")"
	IFS=$'\t' read -r -a size_array <<< "$size"
	echo "${size_array[0]%M}"
}

echo "WARNING: This will NOT work for directories which contain files with \n in their name!" >&2

listing="$(ls -t -u -r "$1")" 

while IFS= read -r -a file ; do
	if [ "$(get_size_mb "$2")" -gt "$3" ] ; then
		echo "Copied $3 MB, quitting"
		exit 0
	fi

	cp -aix "$file" "$2"
done <<< "$listing"