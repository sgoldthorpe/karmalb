VERSION = 0.9.6
RELEASE = 1
MODULE = libgd-3dbargrapher-perl
CPANNAME = GD::3DBarGrapher
MAINTAINER = "Steve Goldthorpe <steve@karmalb.org.uk>"
DESCRIPTION = "Create 3D bar graphs using GD"
DEPENDS = --depends libgd-perl

all: ${MODULE}_${VERSION}-${RELEASE}_all.deb

${MODULE}_${VERSION}-${RELEASE}_all.deb:
	dh-make-perl --cpan ${CPANNAME} -e ${MAINTAINER} ${DEPENDS} --desc ${DESCRIPTION} --build --version ${VERSION}

clean:
	rm -rf ${MODULE}*
