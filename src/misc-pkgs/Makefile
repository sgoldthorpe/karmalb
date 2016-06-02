KEYRINGDEB = karmalb-keyring_1.0-1_all.deb
KEYRINGUDEB = karmalb-keyring-udeb_1.0-1_all.udeb
MHTTPDDEB = mini-httpd_1.23-1_amd64.deb
MONPLUGDEB= monitoring-plugins-ldap-karmalb_1.0-1_amd64.deb
POUNDDEB = pound_2.7-1karmalb_amd64.deb

all: $(KEYRINGDEB) $(KEYRINGUDEB) $(MHTTPDDEB) $(MONPLUGDEB) $(POUNDDEB)


$(KEYRINGDEB) $(KEYRINGUDEB):
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -b -uc
	test "$(KARMALBKEY)" && dpkg-sig -k $(KARMALBKEY) --sign builder $(KEYRINGDEB)
	rm -rf karmalb-keyring/build/
	rm -rf karmalb-keyring/debian/files karmalb-keyring/debian/karmalb-keyring-udeb \
		karmalb-keyring/debian/karmalb-keyring/
	rm -f karmalb-keyring_*.changes karmalb-keyring/debian/karmalb-keyring-udeb.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring-udeb.substvars \
	 	karmalb-keyring/debian/karmalb-keyring.debhelper.log \
		karmalb-keyring/debian/karmalb-keyring.substvars


$(MHTTPDDEB):
	sh make_minihttpd
	test "$(KARMALBKEY)" && dpkg-sig -k $(KARMALBKEY) --sign builder $(MHTTPDDEB)

clean:
	rm -f $(KEYRINGDEB) $(KEYRINGUDEB) $(MHTTPDDEB) $(MONPLUGDEB) $(POUNDDEB)
	rm -f karmalb-keyring_1.0-1_amd64.changes
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -Tclean
	rm -rf mini_httpd-* monitoring-plugins-ldap
	cd pound; \
		sh clean-pound.sh

$(MONPLUGDEB):
	sh make_ldap_plugins

$(POUNDDEB):
	cd pound; \
		sh build-pound.sh

.PHONY: all clean
