#!/bin/sh

srcdir="$(realpath "$0" | xargs dirname)"

srcdir="$srcdir/.."

die() { echo "$*"; exit 1; }

# Import the makerelease.lib
# https://bues.ch/cgit/misc.git/tree/makerelease.lib
for path in $(echo "$PATH" | tr ':' ' '); do
	[ -f "$MAKERELEASE_LIB" ] && break
	MAKERELEASE_LIB="$path/makerelease.lib"
done
[ -f "$MAKERELEASE_LIB" ] && . "$MAKERELEASE_LIB" || die "makerelease.lib not found."

hook_get_version()
{
	version="$(cat piccol | grep -e PICCOL_VERSION | head -n1 | cut -d'"' -f2)"
}

project=piccol
default_archives=py-sdist-xz
makerelease "$@"
