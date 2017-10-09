REQPKGS="apt-file \
	apt-utils \
	autotools-dev \
	checkinstall \
	debhelper \
	devscripts \
	dh-make-perl \
	dpkg-sig \
	libemail-valid-perl \
	libexpect-perl \
	libgd-perl \
	libipc-run3-perl \
	libgoogle-perftools-dev \
	libmoose-perl \
	libnetaddr-ip-perl \
	libnet-dns-perl \
	libnet-ip-perl \
	libpcre3-dev \
	libreadonly-perl \
	libssl-dev \
	libtest-exception-perl \
	lintian \
	openssl \
	packaging-dev \
	quilt \
	reprepro \
	sudo \
	wget \
	xorriso"



INSTALL=""
for PKG in $REQPKGS; do
 	dpkg -s $PKG >/dev/null 2>&1 || INSTALL="$INSTALL $PKG"
done
if [ "$INSTALL" ]; then
	sudo apt-get install $INSTALL
fi
sudo apt-file update
