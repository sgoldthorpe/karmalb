#!/bin/sh -e
NEW_VERSION=2.7
DEB_VERSION=2.6
NEW_RELEASE=1
export SUFFIX=${NEW_RELEASE}karmalb
export DEBFULLNAME="Steve Goldthorpe"
export DEBEMAIL="dev@karmalb.org.uk"
ARCH=`dpkg-architecture -qDEB_HOST_ARCH`
NEW_DEB=pound_${NEW_VERSION}-${SUFFIX}_${ARCH}.deb
SRC_FILES="`apt-cache showsrc pound|sed '/^Files:/,/^Checksums/!d;//d'|awk '{ print $3 }'|sort -u`"

if [ "x$1" = "x-k" ]; then
	KEEP=1
else
	KEEP=0
fi

test -f Pound-${NEW_VERSION}.tgz || wget http://www.apsis.ch/pound/Pound-${NEW_VERSION}.tgz
rm -rf pound-${DEB_VERSION}
for F in $SRC_FILES; do
	if [ ! -f $F ]; then
		apt-get source pound
		break
	fi
done
if [ ! -d pound-${DEB_VERSION} ]; then
	dpkg-source -x pound_${DEB_VERSION}-*.dsc
fi

test -f uupdate-mod || sed 's/^SUFFIX=.*/SUFFIX="${SUFFIX:-1}"/' `which uupdate` > ./uupdate-mod

rm -rf pound-${NEW_VERSION}* Pound-${NEW_VERSION} pound_${NEW_VERSION}.orig.tar.gz
chmod +x ./uupdate-mod
(
	cd pound-${DEB_VERSION}
	../uupdate-mod ../Pound-${NEW_VERSION}.tgz -v ${NEW_VERSION} -r fakeroot
)
# There are patches that aren't needed
BADPATCH="0001-anti_beast.patch 0002-xss_redirect_fix.patch 0003-tls_compression_disable.patch 0004-add_http_patch_support.patch 0007-anti_poodle.patch 0008-disable_client_initiated_renegotiation.patch"
for P in $BADPATCH; do
	rm pound-${NEW_VERSION}/debian/patches/$P
	sed -i "-e /$P/d" pound-${NEW_VERSION}/debian/patches/series
done
NEWPATCH="9999-remove-unneeded-libs.patch"
for P in $NEWPATCH; do
	cp -p $P pound-${NEW_VERSION}/debian/patches/$P
	echo $P >> pound-${NEW_VERSION}/debian/patches/series
done

test $KEEP -eq 0 && rm -rf pound-${DEB_VERSION}
(
	cd pound-${NEW_VERSION}
	dpkg-buildpackage -rfakeroot -b -uc -us
)
rm -f pound_${NEW_VERSION}-${SUFFIX}_${ARCH}.changes
test $KEEP -eq 0 && rm -rf pound-${NEW_VERSION}* Pound-${NEW_VERSION} pound_${NEW_VERSION}.orig.tar.gz
test "${KARMALBKEY}" && dpkg-sig -k ${KARMALBKEY} --sign builder ${NEW_DEB}
cp -p ${NEW_DEB} ..
exit 0
