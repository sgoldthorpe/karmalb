#!/bin/sh -e

lookup() {
	awk "/^$1=/ { split(\$0,s,\"=\"); print s[2]; exit }" $VF
}

# DEFINITIONS
VF="../VERSION"
PROJNAME="`lookup PROJNAME`"
PROJREL="`lookup VERSION`"
PKGNAME="`lookup PKGNAME`"
OSNAME="`lookup OSNAME`"
OSREL="`lookup OSREL`"
DIST="`lookup DEBDIST`"
ARCH="`lookup ARCH`"
#
APTCONFIGS=apt-configs
BBFILE=isohdpfx.bin
DEST=cdrom
INITRD=install.amd/initrd.gz
MNT=iso
PKGCACHE=pkgcache
PUBREPO=pubrepo
REPO=repo
KEEPDEBUGPKGS=0
# DERIVED DEFINITIONS
NETLOC=http://cdimage.debian.org/debian-cd/$OSREL/$ARCH/iso-cd/
NETISO=debian-$OSREL-$ARCH-netinst.iso
TARGETISO=karmalb-${PROJREL}-$ARCH.iso
LABEL="`echo ${PKGNAME} ${PROJREL} ${ARCH}`"

# FUNCTIONS

fetch_pkg() {
	VER=`apt-cache show --no-all-versions $1|awk '/^Version/ { print $2 }'|sed 's/.*://'`
	FOUND="`find $PKGCACHE -name ${1}_${VER}_\*.deb`"
	if [ ! "$FOUND" ]; then
		( cd $PKGCACHE; apt-get download $1 )
		# epoch version confuses matters - rename if found
		RENAME="`find $PKGCACHE -name $1_[0-9]*%3a*.deb`"
		if [ "$RENAME" ]; then
			NEWNAME="`echo $RENAME | sed 's/_[0-9]*%3a/_/'`"
			mv $RENAME $NEWNAME
		fi
		FOUND="`find $PKGCACHE -name ${1}_${VER}\*.deb`"
	fi
	test -d $2 || mkdir -p $2
	cp -p $FOUND $2
}

calc_pkgdir() {
	case $1 in
		*karmalb*|mini-httpd*)
			echo k/karmalb
			;;
		lib*)
			echo `echo $1|cut -c1-4`/$1
			;;
		*)
			echo `echo $1|cut -c1-1`/$1
			;;
	esac
}

get_pkgdir() {
	FN="`apt-cache show $1| awk '/^Filename:/ { print $2; exit }'|sed -e 's@/updates/@/@'`"
	if [ "$FN" ]; then
		echo `dirname $FN`
	else
		echo "pool/name/`calc_pkgdir $1`"
	fi
}

# MAIN SCRIPT

while [ "x$1" != "x" ]; do
	case "x$1" in
		x-r)
			REPO=$PUBREPO;;
		x-d)
			KEEPDEBUGPKGS=1;;
		*)
			break;;
	esac
	shift
done

if [ ! -d $REPO ]; then
	echo "Please generate repo first before building ISO."
	exit 4
else
	PROJPKGFILE="$REPO/pool/main/`calc_pkgdir $PKGNAME`/${PKGNAME}_${PROJREL}_${ARCH}.deb"
	if [ ! -f $PROJPKGFILE ]; then
		echo "$PROJPKGFILE is missing..."
		exit 4
	fi
fi

if [ "$REPO" = "$PUBREPO" ]; then
	echo "Going to build a public ISO image..."
else
	echo "Going to build a working ISO image..."
fi

# fetch Debian iso if not already downloaded
if [ ! -f $NETISO ]; then
	echo "Fetching network iso image..."
	wget $NETLOC/$NETISO
fi

if [ ! -d $MNT ]; then
	mkdir $MNT
fi
sudo mount -r -o loop $NETISO $MNT
if [ -d $DEST ]; then
	sudo rm -rf $DEST
fi
mkdir $DEST

echo "Copying ISO image contents..."
cp -a $MNT/. $DEST/
sudo umount $MNT

# Copied files are read-only so make some read-write
LIST="dists/$DIST/Release dists/$DIST/main/debian-installer/binary-$ARCH/ dists/$DIST/main/binary-$ARCH/ md5sum.txt isolinux/isolinux.bin $INITRD isolinux/menu.cfg isolinux/stdmenu.cfg"
for L in $LIST; do
	chmod u+w $DEST/$L
done
find $DEST/pool/main -type d -exec chmod u+w \{\} \;

mkdir -p $PKGCACHE

# UPGRADE MEDIA PACKAGES TO ENSURE CONSISTENT VERSIONING

echo "Upgrading packages..."
find $DEST/pool -type f -name \*.deb | while read PKG; do
	BASE=`basename $PKG|sed 's/_.*//'`
	VER=`apt-cache show --no-all-versions $BASE|awk '/^Version/ { print $2 }'|sed 's/.*://'`
	if [ ! "`echo $PKG|grep _${VER}_`" ]; then
		echo "upgrade $BASE to $VER"
		DIR=`dirname $PKG`
		rm $PKG
		fetch_pkg $BASE $DIR
	fi
done

# ADD PROJECT PACKAGES HERE
echo "Adding project packages..."
if [ $KEEPDEBUGPKGS -eq 1 ]; then
	echo "Including any debug packages..."
	REPOPKGS="`cd $REPO && find pool -type f -name \*.deb`"
else
	echo "Excluding debug packages..."
	REPOPKGS="`cd $REPO && find pool -type f -name \*.deb|grep -v debug`"
fi
if [ ! "$REPOPKGS" ]; then
	echo "ERROR: Couldn't find packages in repo."
	exit 5
fi
for PKG in $REPOPKGS; do
	B="`basename $PKG`"
	D="pool/main/`calc_pkgdir $B`"
	test -d $DEST/$D || mkdir -p $DEST/$D
	cp -p $REPO/$PKG $DEST/$D
done

# ADD PKG DEPENDENCIES HERE
PKGLIST="
apt-transport-https
chrony
conntrack
expect
fontconfig
fontconfig-config
fonts-dejavu-core
gdnsd
geoip-database
grub-pc
grub2-common
install-info
iputils-arping
irqbalance
libcap-ng0
libcairo2
libcommon-sense-perl
libcurl3-gnutls
libnetfilter-conntrack3
libdata-validate-ip-perl
libdatrie1
libdbi1
libev4
libexpect-perl
libfontconfig1
libgcc1
libgd3
libgd-perl
libglib2.0-data
libgeoip1
libgoogle-perftools4
libgraphite2-3
libharfbuzz0b
libio-interface-perl
libio-pty-perl
libio-stty-perl
libipc-run3-perl
libjbig0
libjpeg62-turbo
libldap-2.4-2
liblinux-inotify2-perl
libmoose-perl
libmysqlclient18
libnetaddr-ip-perl
libnet-ipv6addr-perl
libnet-netmask-perl
libnet-ssh-perl
libnetwork-ipv4addr-perl
libnuma1
libpango-1.0-0
libpangocairo-1.0-0
libpangoft2-1.0-0
libpcre3
libperl5.20
libpixman-1-0
libproc-daemon-perl
libproc-processtable-perl
libreadonly-perl
librrd4
librrds-perl
librtmp1
libsasl2-2
libsasl2-modules-db
libssh2-1
libsensors4
libsnmp-base
libsnmp30
libssl1.0.0
libtcl8.6
libtcmalloc-minimal4
libthai0
libthai-data
libtiff5
libtomcrypt0
libtommath0
libunwind8
liburcu2
libvpx1
libxcb-render0
libxcb-shm0
libxml2
libxpm4
libxrender1
monitoring-plugins-basic
monitoring-plugins-common
monitoring-plugins-ldap-karmalb
mysql-common
netstat-nat
perl
perl-base
pound
rrdtool
rsync
shared-mime-info
snmpd
snmptrapd
tcl8.6
tcl-expect
timelimit
ucarp
unzip
xdg-user-dirs
"

echo "Adding package dependencies..."
INSTALL=""
for PKG in $PKGLIST; do
	FOUND="`find $DEST/pool/main -type f -name ${PKG}_\*.deb -print`"
	if [ ! "$FOUND" ]; then
		INSTALL="$INSTALL $PKG"
	fi
done
(
	if [ "$INSTALL" ]; then
		for PKG in $INSTALL; do
			D="`get_pkgdir $PKG`"
			fetch_pkg $PKG $DEST/$D
		done
	fi
)

TEMPLATED_CONFIGS="$APTCONFIGS/config-udeb.conf $APTCONFIGS/config-deb.conf $APTCONFIGS/config-rel.conf"
for TEMPLATE in $TEMPLATED_CONFIGS; do
	sed -e "s/@ARCHIVE@/$DEST/g" -e "s/@DIST@/$DIST/g" -e "s/@ARCH@/$ARCH/g" ${TEMPLATE}.tmpl > $TEMPLATE
done

# REBUILD PACKAGE ARCHIVES
echo "Rebuilding apt archive..."
export GZIP="-9v" # ensure we shrink things as small as they will go
apt-ftparchive generate $APTCONFIGS/config-udeb.conf
apt-ftparchive generate $APTCONFIGS/config-deb.conf
apt-ftparchive -c $APTCONFIGS/config-rel.conf release $DEST/dists/$DIST/ > $DEST/dists/$DIST/Release

# TIDY UP
LIST="dists/$DIST/main/binary-$ARCH/Packages dists/$DIST/main/debian-installer/binary-$ARCH/Packages"
for L in $LIST; do
	if [ -f $DEST/${L}.gz ]; then
		rm $DEST/$L
	fi
done

# CUSTOMISE INSTALL FILES HERE

echo "Building initrd..."
# REBUILD INITRD WITH PRESEED FILE
(
	mkdir irmod
	cd irmod
	gzip -d < ../$DEST/$INITRD | \
		sudo -n cpio --extract --make-directories --no-absolute-filenames
	sed -e "s/@SHORTNAME@/$PROJNAME/g" -e "s/@VERSION@/$PROJREL/g" ../karmalb_preseed.cfg > preseed.cfg
	find . | sudo -n cpio -H newc --create | \
		gzip -9 > ../$DEST/$INITRD
	cd ../
	sudo rm -fr irmod/
)

# UPDATE ISOLINUX
ISOLIST="menu.cfg stdmenu.cfg"
for F in $ISOLIST; do
	sed -e "s/@PROJNAME@/$PROJNAME/g" -e "s/@PROJREL@/$PROJREL/g" -e "s/@OSNAME@/$OSNAME/g" -e "s/@OSREL@/$OSREL/g" files/$F > $DEST/isolinux/$F
done

# REBUILD CHECKSUMS
( cd $DEST; md5sum `find ! -name "md5sum.txt" ! -path "./isolinux/*" -follow -type f` > md5sum.txt )

# EXTRACT BOOT BLOCK FROM ISO
dd if=$NETISO bs=512 count=1 of=$BBFILE

# MAKE HYBRID GRUB/EFI ISO
rm -f $TARGETISO
echo "Creating ISO image..."
xorriso -as mkisofs \
   -o $TARGETISO \
   -V "$LABEL" \
   -r \
   -J -joliet-long \
   -isohybrid-mbr $BBFILE \
   -c isolinux/boot.cat \
   -b isolinux/isolinux.bin \
      -no-emul-boot -boot-load-size 4 -boot-info-table \
   -eltorito-alt-boot \
   -e boot/grub/efi.img \
      -no-emul-boot \
      -isohybrid-gpt-basdat \
      -isohybrid-apm-hfsplus \
   ./$DEST

# CLEAN UP
# rm -rf $DEST
#for CLEAN in $TEMPLATED_CONFIGS $BBFILE; do
#	rm $CLEAN
#done
echo "Done."
