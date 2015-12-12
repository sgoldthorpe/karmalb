REQPKGS="apt-file \
	apt-utils \
	dh-make-perl \
	libemail-valid-perl \
	libexpect-perl \
	libgd-perl \
	libipc-run3-perl \
	libmoose-perl \
	libnetaddr-ip-perl \
	libnet-dns-perl \
	libnet-ip-perl \
	libreadonly-perl \
	libtest-exception-perl \
	lintian \
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
