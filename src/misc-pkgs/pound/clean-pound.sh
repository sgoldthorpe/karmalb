NEW_VERSION=2.7
DEB_VERSION=2.6
NEW_RELEASE=1
SUFFIX=${NEW_RELEASE}karmalb

rm -rf pound-${DEB_VERSION} pound_${DEB_VERSION}-*.tar.xz pound_${DEB_VERSION}-*.dsc \
	pound_${DEB_VERSION}-*.dsc pound_${DEB_VERSION}.orig.tar.gz \
	pound_${DEB_VERSION}-*.deb pound_${DEB_VERSION}-*.changes \
	pound_${NEW_VERSION}* pound-${NEW_VERSION}* Pound-${NEW_VERSION}.tgz \
	../pound-{NEW_VERSION}-*.deb
