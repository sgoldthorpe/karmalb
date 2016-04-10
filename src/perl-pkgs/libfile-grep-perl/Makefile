VERSION = 0.02
RELEASE = 1
MODULE = libfile-grep-perl
CPANNAME = File::Grep
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Find matches to a pattern in a series of files and related functions"
DEPENDS =
ARCH = all
DEB = $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

.SECONDARY: $(DEB)

all: $(DEB)

$(DEB):
	env -i HOME=$(HOME) PWD=$(CURDIR) PATH=$(PATH) dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)
	test "$(KARMALBKEY)" && dpkg-sig -k $(KARMALBKEY) --sign builder $(DEB)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*

.PHONY: all
.PHONY: clean
