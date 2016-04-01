
all: karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb

karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb:
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -b

clean:
	rm -f karmalb-keyring_1.0-1_all.deb  karmalb-keyring-udeb_1.0-1_all.udeb
	rm -f karmalb-keyring_1.0-1_amd64.changes
	cd karmalb-keyring; \
		dpkg-buildpackage -rfakeroot -Tclean
