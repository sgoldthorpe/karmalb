#!/bin/sh
WORKDIR=workdir

if [ "x$1" = "x-k" ]; then
	KEEPDIR=1
	shift
else
	KEEPDIR=0
fi

rm -rf $WORKDIR
mkdir -p $WORKDIR
mkdir $WORKDIR/DEBIAN
cp control/* $WORKDIR/DEBIAN
cat filelist | while read T F X; do
	case $T in
		d)	mkdir $WORKDIR/$F;;
		f)	cp -p files/$F $WORKDIR/$F
			if [ -x files/$F ]; then
				chmod 755 $WORKDIR/$F
			fi;;
		l)	ln -s $WORKDIR/$F $X;;
		\#*)	# skip
			;;
	esac
done
fakeroot dpkg-deb -b $WORKDIR .

test $KEEPDIR -eq 1 || rm -rf $WORKDIR
