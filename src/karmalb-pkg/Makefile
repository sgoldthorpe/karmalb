PKGNAME := $(shell awk -F= '/^PKGNAME=/ { print $$2; exit }' $(CURDIR)/../../VERSION)
VERSION := $(shell awk -F= '/^VERSION=/ { print $$2; exit }' $(CURDIR)/../../VERSION)
ARCH := $(shell awk -F= '/^ARCH=/ { print $$2; exit }' $(CURDIR)/../../VERSION)

DEB = $(PKGNAME)_$(VERSION)_$(ARCH).deb

all: $(DEB)

$(DEB):
	sh ./make_package.sh

clean:
	$(RM) -rf workdir $(DEB)
