VERSION = 0.02
RELEASE = 1
MODULE = libfile-grep-perl
CPANNAME = File::Grep
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Find matches to a pattern in a series of files and related functions"
DEPENDS =

all: ${MODULE}_${VERSION}-${RELEASE}_all.deb

${MODULE}_${VERSION}-${RELEASE}_all.deb:
	dh-make-perl --cpan ${CPANNAME} -e ${MAINTAINER} ${DEPENDS} --desc ${DESCRIPTION} --build --version ${VERSION}

clean:
	rm -rf ${MODULE}*
