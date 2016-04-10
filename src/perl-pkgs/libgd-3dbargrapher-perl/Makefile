VERSION = 0.9.6
RELEASE = 1
MODULE = libgd-3dbargrapher-perl
CPANNAME = GD::3DBarGrapher
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Create 3D bar graphs using GD"
DEPENDS = --depends libgd-perl
ARCH = all
DEB = $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

.SECONDARY: $(DEB)

all: $(DEB)

$(DEB):
	env -i HOME=$(HOME) PWD=$(CURDIR) PATH=$(PATH) dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)
	test "$(KARMALBKEY)" && dpkg-sig -k $(KARMALBKEY) --sign builder $(DEB)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*
