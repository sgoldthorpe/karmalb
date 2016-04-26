#!/bin/sh -e

lookup() {
	awk "/^$1=/ { split(\$0,s,\"=\"); print s[2]; exit }" $VF
}

# DEFINITIONS
VF="../VERSION"
DIST="`lookup DEBDIST`"
ARCH="`lookup ARCH`"
#
DEST=repo
# DERIVED DEFINITIONS
REPOCONF=$DEST/conf
REPOOPTS=$REPOCONF/options
REPODISTS=$REPOCONF/distributions

# MAIN SCRIPT

rm -rf $DEST
mkdir -p $REPOCONF
touch $REPOOPTS
test "$KARMALBKEY" && echo "ask-passphrase" >> $REPOOPTS
echo "Codename: $DIST" > $REPODISTS
echo "Components: main" >> $REPODISTS
echo "Architectures: $ARCH" >> $REPODISTS
test "$KARMALBKEY" && echo "SignWith: $KARMALBKEY" >> $REPODISTS

PKGLIST=""
# ADD CUSTOM PACKAGES HERE
echo "Adding custom packages..."
# PERL
PERLPKGS="`ls ../src/perl-pkgs/*/*.deb 2>&1`"
set -- $PERLPKGS
if [ $# -ne 5 ]; then
	echo "ERROR: Not all custom perl packages found."
	exit 5
else
	PKGLIST="$PKGLIST $PERLPKGS"
fi
# MISC
MISCPKGS="`ls ../src/misc-pkgs/*.deb 2>&1`"
set -- $MISCPKGS
if [ $# -ne 3 ]; then
	echo "ERROR: Not all packages found."
	exit 5
else
	PKGLIST="$PKGLIST $MISCPKGS"
fi

# FINALLY KARMA PKG ITSELF
KARMAPKG="`ls ../src/karmalb-pkg/karmalb*.deb 2>&1`"
if [ "$KARMAPKG" ]; then
	PKGLIST="$PKGLIST $KARMAPKG"
else
	echo "ERROR: Not all packages found."
	exit 5
fi

echo "Rebuilding apt archive..."
export GZIP="-9v" # ensure we shrink things as small as they will go
reprepro -b $DEST includedeb $DIST $PKGLIST

if [ "$KARMALBREPOSYNC" ]; then
	echo "Syncing to local repo..."
	rsync -av --delete-delay repo/dists repo/pool $KARMALBREPOSYNC
fi
if [ "$KARMALBPXESEEDTARGET" ]; then
	echo "Copying PXE preseed file..."
	scp karmalb_pxe_preseed.cfg $KARMALBPXESEEDTARGET
fi

echo "Done."
exit 0
