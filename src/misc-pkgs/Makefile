
all: karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb mini-httpd_1.23-1_amd64.deb

karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb:
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -b
	rm -rf karmalb-keyring/build/
	rm -rf karmalb-keyring/debian/files karmalb-keyring/debian/karmalb-keyring-udeb \
		karmalb-keyring/debian/karmalb-keyring/
	rm -f karmalb-keyring_*.changes karmalb-keyring/debian/karmalb-keyring-udeb.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring-udeb.substvars \
	 	karmalb-keyring/debian/karmalb-keyring.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring.substvars


mini-httpd_1.23-1_amd64.deb:
	sh make_minihttpd

clean:
	rm -f karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb mini-httpd_1.23-1_amd64.deb
	rm -f karmalb-keyring_1.0-1_amd64.changes
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -Tclean
	rm -rf mini_httpd-*
	
