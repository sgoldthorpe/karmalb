VERSION = 1.012
RELEASE = 1
MODULE = libnet-interface-perl
CPANNAME = Net::Interface
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Perl module for manipulating host network interfaces"
DEPENDS =
ARCH = $(shell dpkg-architecture -qDEB_HOST_ARCH)

all: $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

$(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb:
	dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*

