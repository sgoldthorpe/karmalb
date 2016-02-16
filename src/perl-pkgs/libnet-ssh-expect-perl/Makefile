VERSION = 1.09
RELEASE = 1
MODULE = libnet-ssh-expect-perl
CPANNAME = Net::SSH::Expect
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "SSH wrapper to execute remote commands"
DEPENDS = --depends libexpect-perl
ARCH = all
DEB = $(MODULE)_$(VERSION)-$(RELEASE)_$(ARCH).deb

.SECONDARY: $(DEB)

all: $(DEB)

$(DEB):
	env -i HOME=$(HOME) PWD=$(CURDIR) PATH=$(PATH) dh-make-perl --cpan $(CPANNAME) -e $(MAINTAINER) $(DEPENDS) --desc $(DESCRIPTION) --build --version $(VERSION)-$(RELEASE)

clean:
	rm -rf $(MODULE)* $(subst ::,-,$(CPANNAME))*
