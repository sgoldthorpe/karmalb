#!/bin/bash
###############################################################################
#     Karma Load Balancer CE Software License
#     This file is part of the Karma Load Balancer CE software package, a true
#     Community Edition derived from the Zen Load Balancer software package.
#     Sources available at https://github.com/sgoldthorpe/karmalb
#
#     Copyright (C) 2016 Steve Goldthorpe <dev@karmalb.org.uk>
#
#     This library is free software; you can redistribute it and/or modify it
#     under the terms of the GNU Lesser General Public License as published
#     by the Free Software Foundation; either version 2.1 of the License, or
#     (at your option) any later version.
#
#     This library is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
#     General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this library; if not, write to the Free Software Foundation,
#     Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
###############################################################################

# Extract files from a tar backup file.
# To be completely secure, we should really parse the input files, however this
# script is much better than just extracting what we're given.
# Initially written to be run as root (as it needs to extract some system files),
# but will be enhanced for non-root with sudo perms later.

syntax() {
	echo "Syntax: extract-backup.sh [ -r <root> ] <tarfile> <extract list...>"
	exit 2
}

TMPDIR=/tmp/extract.$$
FLAGS="xvpf"
ROOT="/"

if [ "x$1" = "x-r" ]; then
	if [ "x$" = "x" -o ! -d "$2" ]; then
		syntax
	fi
	ROOT="$2"
	shift 2
fi

TARFILE="$1"

if [ "x$2" = "x" ]; then
	syntax
fi
shift

case "$TARFILE" in
	*.gz)
		FLAGS="z$FLAGS";;
esac

mkdir -p $TMPDIR
echo "Extracying files.."
tar -${FLAGS} "${TARFILE}" -C ${TMPDIR}
if [ $? -ne 0 ]; then
	rm -rf $TMPDIR
	echo "extract-backup.sh: Problem extracting backup."
	exit 3
fi

while [ "$1" ]; do
	if [ -d "$1" ]; then
		echo "Restoring directory ${1}..."
		test -d "$1" | mkdir -p "${ROOT}$1"
		L="`cd ${TMPDIR}$1; find . -type f -print`"
		if [ "$L" ]; then
			rm -f "${ROOT}${1}/*"
			test -d "${ROOT}$1" || mkdir -p "${ROOT}$1"
			for F in $L; do
				cp -p "${TMPDIR}$1/$F" "${ROOT}$1"
			done
		fi
	else
		if [ ! -f "${TMPDIR}$1" ]; then
			echo "Warning: couldn't find ${1}."
		else
			D="`dirname ${ROOT}$1`"
			test -d $D || mkdir -p $D
			cp -p "${TMPDIR}$1" "${ROOT}$1"
		fi
	fi
	shift
done

rm -rf $TMPDIR

echo "Done."

exit 0
