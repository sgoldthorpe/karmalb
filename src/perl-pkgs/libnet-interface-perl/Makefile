VERSION = 1.016
RELEASE = 1
MODULE = libnet-interface-perl
CPANNAME = Net::Interface
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Perl module for manipulating host network interfaces"
DEPENDS =
ARCH = $(shell dpkg-architecture -qDEB_HOST_ARCH)
DEB = $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

.SECONDARY: $(DEB)

all: $(DEB)

$(DEB):
	env -i HOME=$(HOME) PWD=$(CURDIR) PATH=$(PATH) dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)
	test "$(KARMALBKEY)" && dpkg-sig -k $(KARMALBKEY) --sign builder $(DEB)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*

