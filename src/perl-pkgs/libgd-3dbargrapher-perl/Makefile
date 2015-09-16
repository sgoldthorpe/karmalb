VERSION = 0.9.6
RELEASE = 1
MODULE = libgd-3dbargrapher-perl
CPANNAME = GD::3DBarGrapher
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Create 3D bar graphs using GD"
DEPENDS = --depends libgd-perl
ARCH = all

all: $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

$(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb:
	dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*
