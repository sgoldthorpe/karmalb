KEYRINGDEB = karmalb-keyring_1.0-1_all.deb
KEYRINGUDEB = karmalb-keyring-udeb_1.0-1_all.udeb
MHTTPDDEB = mini-httpd_1.23-1_amd64.deb

all: $(KEYRINGDEB) $(KEYRINGUDEB) $(MHTTPDDEB)


$(KEYRINGDEB) $(KEYRINGUDEB):
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -b -uc
	dpkg-sig --sign builder $(KEYRINGDEB)
	rm -rf karmalb-keyring/build/
	rm -rf karmalb-keyring/debian/files karmalb-keyring/debian/karmalb-keyring-udeb \
		karmalb-keyring/debian/karmalb-keyring/
	rm -f karmalb-keyring_*.changes karmalb-keyring/debian/karmalb-keyring-udeb.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring-udeb.substvars \
	 	karmalb-keyring/debian/karmalb-keyring.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring.substvars


$(MHTTPDDEB):
	sh make_minihttpd
	dpkg-sig --sign builder $(MHTTPDDEB)

clean:
	rm -f $(KEYRINGDEB) $(KEYRINGUDEB) $(MHTTPDDEB)
	rm -f karmalb-keyring_1.0-1_amd64.changes
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -Tclean
	rm -rf mini_httpd-*

.PHONY: all clean
