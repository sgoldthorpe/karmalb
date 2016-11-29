#!/bin/sh -e

lookup() {
        awk "/^$1=/ { split(\$0,s,\"=\"); print s[2]; exit }" $VF
}

# DEFINITIONS
VF="../VERSION"
PROJREL="`lookup VERSION`"
ISOVER="`lookup ISOVERSION`"
ISOREL="${PROJREL}r${ISOVER}"
ARCH="`lookup ARCH`"
#
# DERIVED DEFINITIONS
TARGETISO=karmalb-${ISOREL}-$ARCH.iso
#

if [ "x$KARMARELEASEFILES" = "x" ]; then
	echo "please define env var \"$KARMARELEASEFILES in scp format i.e. user@host:/path/"
	exit 2
fi
echo "tip: any password will be for the external release files server"
if [ "x$1" != "x" ]; then
	for F in $*; do
		if [ ! -f $F ]; then
			echo "Can't find $F to upload - skipping..."
		else
			scp $F $KARMARELEASEFILES
		fi
		shift
	done
else
	scp $TARGETISO $KARMARELEASEFILES
fi
exit 0
