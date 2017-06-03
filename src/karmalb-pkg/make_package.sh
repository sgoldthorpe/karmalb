#!/bin/sh -e

lookup() {
        awk "/^$1=/ { split(\$0,s,\"=\"); print s[2]; exit }" $VF
}

VF=../../VERSION
PKGNAME="`lookup PKGNAME`"
VERSION="`lookup VERSION`"
MAINTAINER="`lookup MAINTAINER`"
ARCH="`lookup ARCH`"
LONGNAME="`lookup FULLNAME`"
SHORTNAME="`lookup PROJNAME`"
WORKDIR=workdir
DEB="${PKGNAME}_${VERSION}_${ARCH}.deb"

if [ "x$1" = "x-k" ]; then
	KEEPDIR=1
	shift
else
	KEEPDIR=0
fi

rm -rf $WORKDIR
mkdir -p $WORKDIR
mkdir $WORKDIR/DEBIAN

for F in control/*; do
	sed -e "s/@PKGNAME@/$PKGNAME/g" \
		-e "s/@VERSION@/$VERSION/g" \
		-e "s/@MAINTAINER@/$MAINTAINER/g" \
		-e "s/@ARCH@/$ARCH/g" \
		-e "s/@LONGNAME@/$LONGNAME/g" \
		-e "s/@SHORTNAME@/$SHORTNAME/g" \
		$F > $WORKDIR/DEBIAN/`basename $F`
done
chmod +x $WORKDIR/DEBIAN/postinst
chmod +x $WORKDIR/DEBIAN/prerm

cat filelist | while read T F X; do
	case $T in
		d)	mkdir $WORKDIR/$F;;
		f)	cp -p files/$F $WORKDIR/$F
			if [ -x files/$F ]; then
				chmod 755 $WORKDIR/$F
			fi;;
		F)
			sed -e "s/@PKGNAME@/$PKGNAME/g" \
				-e "s/@VERSION@/$VERSION/g" \
				-e "s/@MAINTAINER@/$MAINTAINER/g" \
				-e "s/@ARCH@/$ARCH/g" \
				-e "s/@LONGNAME@/$LONGNAME/g" \
				-e "s/@SHORTNAME@/$SHORTNAME/g" \
				files/$F > $WORKDIR/$F
			if [ -x files/$F ]; then
				chmod 755 $WORKDIR/$F
			fi;;
		l)	ln -s $X $WORKDIR/$F;;
		\#*)	# skip
			;;
	esac
done
( cd $WORKDIR; find . -name DEBIAN -prune -o -type f -printf '%P ' | xargs md5sum > DEBIAN/md5sums )
fakeroot dpkg-deb -b $WORKDIR .
test "$KARMALBKEY" && dpkg-sig -k $KARMALBKEY --sign builder $DEB

test $KEEPDIR -eq 1 || rm -rf $WORKDIR
