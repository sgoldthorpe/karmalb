#/!bin/sh -e
PKGNAME=karmalb
PKGVERS=1.0a2
PKGMAIN="KarmaLB Developers <dev@karmalb.org.uk>"
OLDPREFIX=usr/local
NEWPREFIX=opt
OLDPATH=${OLDPREFIX}/zenloadbalancer
NEWPATH=${NEWPREFIX}/klb
#
ZENPKG=zenloadbalancer_3.10.deb
ZENISO=zenloadbalancer-distro_3.10.iso
#
TMPDIR=tmp
FILELIST=../filelist
FILESDIR=../files
CONTROLDIR=../control
PKGARCH=`dpkg-architecture -qDEB_BUILD_ARCH`
#
KEEPFILES=0

if [ "x$1" = "x-k" ]; then
	KEEPFILES=1
	shift
fi

getyn()
{
	read ANS
	case x$ANS in
		xY|xy|xyes|xYES|xYes)
			;;
		*)
			echo "Aborted..."
			exit 1;;
	esac
}

echo "This will extract the Zen Load Balancer sources files from the Community ISO/Package and populate your current KLB git branch."
echo "YOU WILL NOT WANT TO DO THIS UNLESS THERE IS A NEW VERSION (AND POSSIBLY NOT EVEN THEN)."
echo ""
echo "Continue?"
getyn

if [ ! -f $ZENPKG ]; then
	if [ ! -f $ZENISO ]; then
		wget -O $ZENISO https://sourceforge.net/projects/zenloadbalancer/files/Distro/$ZENISO/download
	fi
	mkdir iso
	sudo mount -o loop -t iso9660 -r $ZENISO iso
	cp -p iso/pool/main/zen/$ZENPKG .
	sudo umount iso
	rmdir iso
fi

# extract files from package 
rm -rf $TMPDIR
mkdir $TMPDIR
dpkg -x $ZENPKG $TMPDIR

# move lb directory
mkdir -p ${TMPDIR}/${NEWPREFIX}
mv ${TMPDIR}/${OLDPATH} ${TMPDIR}/${NEWPATH}
( cd $TMPDIR; rmdir -p $OLDPREFIX )

# build filelist file
( cd $TMPDIR; find * -print ) | sort | \
	while read F; do
		if [ -d "$TMPDIR/$F" ]; then	
			echo "d $F"
		elif [ -L "$TMPDIR/$F" ]; then
			echo "l $F `readlink \"$TMPDIR/$F\"`"
		elif [ -f "$TMPDIR/$F" ]; then
			ELF="`file $TMPDIR/$F|grep ELF`"
			if [ "$ELF" ]; then
				echo "#f $F"
			else
				echo "f $F"
			fi
		fi
	done | sort -k 2 > $FILELIST

# copy source files to files directory
rm -rf $FILESDIR
mkdir $FILESDIR
cat $FILELIST | (
	while read T F X; do
		case $T in
			\#*)	echo "Skipping binary $F";;
			l)	echo "Skipping link $F -> $X";;
			d)	mkdir $FILESDIR/$F;;
			f)	cp -p $TMPDIR/$F $FILESDIR/$F
				if grep -q /$OLDPATH $FILESDIR/$F; then
					sed -i "s@/$OLDPATH@/$NEWPATH@g" $FILESDIR/$F
					echo "Modified $F"
				fi
				;;
		esac
	done
)
test $KEEPFILES -eq 1 || rm -rf $TMPDIR

# extract control files from package
rm -rf $CONTROLDIR
mkdir $CONTROLDIR
dpkg -e $ZENPKG $CONTROLDIR
# fix up control file
sed -i -e "s/^Package:.*/Package: $PKGNAME/" \
	-e "s/^Version:.*/Version: $PKGVERS/" \
	-e "s/^Maintainer:.*/Maintainer: $PKGMAIN/" \
	-e "s/^Architecture:.*/Architecture: $PKGARCH/" \
	$CONTROLDIR/control
