VERSION = 0.02
RELEASE = 1
MODULE = libnet-route-perl
CPANNAME = Net::Route
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Portable interface to the routing table"
DEPENDS = --depends perl --depends libipc-run3-perl --depends libmoose-perl --depends libnetaddr-ip-perl --depends libreadonly-perl
ARCH = all

all: $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

$(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb:
	dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*

