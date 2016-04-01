#!/bin/sh -e
set -e

# DEFINITIONS
PROJNAME=KarmaLB
PROJREL=1.0a2
OSNAME=Debian
OSREL=8.3.0
DIST=jessie
ARCH=amd64
#
APTCONFIGS=apt-configs
BBFILE=isohdpfx.bin
DEST=cdrom
INITRD=install.amd/initrd.gz
MNT=iso
PKGCACHE=pkgcache
# DERIVED DEFINITIONS
NETLOC=http://cdimage.debian.org/debian-cd/$OSREL/$ARCH/iso-cd/
NETISO=debian-$OSREL-$ARCH-netinst.iso
TARGETISO=karmalb-${PROJREL}-$ARCH.iso
PKGLOC=$DEST/pool/main/karmalb
LABEL="`echo ${PROJNAME} ${PROJREL} ${ARCH}|tr '[a-z]. ' '[A-Z]__'`"

# FUNCTIONS

fetch_pkg() {
	VER=`apt-cache show --no-all-versions $1|awk '/^Version/ { print $2 }'|sed 's/.*://'`
	FOUND="`find $PKGCACHE -name $1_$VER_\*.deb`"
	if [ ! "$FOUND" ]; then
		( cd $PKGCACHE; apt-get download $1 )
		# epoch version confuses matters - rename if found
		RENAME="`find $PKGCACHE -name $1_[0-9]*%3a*.deb`"
		if [ "$RENAME" ]; then
			NEWNAME="`echo $RENAME | sed 's/_[0-9]*%3a/_/'`"
			mv $RENAME $NEWNAME
		fi
		FOUND="`find $PKGCACHE -name $1_${VER}\*.deb`"
	fi
	sudo cp -p $FOUND $2
}


# MAIN SCRIPT

# fetch Debian iso if not already downloaded
if [ ! -f $NETISO ]; then
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
# copy ISO contents to $DEST
cp -av $MNT/. $DEST/
sudo umount $MNT

# Copied files are read-only so make some read-write
LIST="pool/main dists/$DIST/Release dists/$DIST/main/debian-installer/binary-$ARCH/ dists/$DIST/main/binary-$ARCH/ md5sum.txt isolinux/isolinux.bin $INITRD isolinux/menu.cfg isolinux/stdmenu.cfg"
for L in $LIST; do
	chmod u+w $DEST/$L
done

mkdir -p $PKGCACHE

# UPGRADE MEDIA PACKAGES TO ENSURE CONSISTENT VERSIONING

find $DEST/pool -type f -name \*.deb | while read PKG; do
	BASE=`basename $PKG|sed 's/_.*//'`
	VER=`apt-cache show --no-all-versions $BASE|awk '/^Version/ { print $2 }'|sed 's/.*://'`2
	if [ ! "`echo $PKG|grep _${VER}_`" ]; then
		echo "upgrade $BASE to $VER"
		DIR=`dirname $PKG`
		sudo rm -f $PKG
		fetch_pkg $BASE $DIR
	fi
done

# ADD CUSTOM PACKAGES HERE
# PERL
( 
	PERLPKGS="`ls ../src/perl-pkgs/*/*.deb 2>&1`"
	set -- $PERLPKGS
	if [ $# -ne 5 ]; then
		echo "ERROR: Not all custom perl packages found."
		exit 5
	else
		mkdir -p $PKGLOC
		while [ "$1" ]; do
			cp -p $1 $PKGLOC
			shift
		done
	fi
)
# MISC
( 
	MISCPKGS="`ls ../src/misc-pkgs/*.deb 2>&1`"
	set -- $MISCPKGS
	if [ $# -ne 2 ]; then
		echo "ERROR: Not all packages found."
		exit 5
	else
		mkdir -p $PKGLOC
		while [ "$1" ]; do
			cp -p $1 $PKGLOC
			shift
		done
	fi
)

# FINALLY KARMA PKG ITSELF
KARMAPKG="`ls ../src/karmalb-pkg/karmalb*.deb 2>&1`"
if [ "$KARMAPKG" ]; then
	cp -p $KARMAPKG $PKGLOC
else
	echo "ERROR: Not all packages found."
	exit 5
fi

# ADD PKG DEPENDENCIES HERE
PKGLIST="`cat <<!EOM
apt-transport-https
conntrack
expect
fontconfig
fontconfig-config
fonts-dejavu-core
gdnsd
geoip-database
iputils-arping
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
libgd3
libgd-perl
libglib2.0-data
libgeoip1
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
libpango-1.0-0
libpangocairo-1.0-0
libpangoft2-1.0-0
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
libthai0
libthai-data
libtiff5
liburcu2
libvpx1
libxcb-render0
libxcb-shm0
libxml2
libxpm4
libxrender1
mysql-common
netstat-nat
ntpdate
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
ucarp
unzip
xdg-user-dirs
!EOM
`"
INSTALL=""
for PKG in $PKGLIST; do
	FOUND="`find $DEST/pool/main -type f -name ${PKG}_\*.deb -print`"
	if [ "$FOUND" ]; then
		echo "FOUND: $FOUND"
	else
		INSTALL="$INSTALL $PKG"
	fi
done
(
	if [ "$INSTALL" ]; then
		for PKG in $INSTALL; do
			fetch_pkg $PKG $PKGLOC
		done
	fi
)

TEMPLATED_CONFIGS="$APTCONFIGS/config-udeb.conf $APTCONFIGS/config-deb.conf $APTCONFIGS/config-rel.conf"
for TEMPLATE in $TEMPLATED_CONFIGS; do
	sed -e "s/@ARCHIVE@/$DEST/g" -e "s/@DIST@/$DIST/g" -e "s/@ARCH@/$ARCH/g" ${TEMPLATE}.tmpl > $TEMPLATE
done

# REBUILD PACKAGE ARCHIVES
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

# REBUILD INITRD WITH PRESEED FILE
(
	mkdir irmod
	cd irmod
	gzip -d < ../$DEST/$INITRD | \
		sudo -n cpio --extract --verbose --make-directories --no-absolute-filenames
	cp ../karmalb_preseed.cfg preseed.cfg
	find . | sudo -n cpio -H newc --create --verbose | \
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

#genisoimage -o test.iso -r -J -no-emul-boot -boot-load-size 4 \
# -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ./$DEST

#genisoimage -r -c isolinux/boot.cat  -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -b boot/grub/efi.img -no-emul-boot -o test2.iso ./cdrom
#xorriso -as mkisofs -r -c isolinux/boot.cat  -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o test2.iso ./cdrom

#isohybrid --uefi test2.iso

# EXTRACT BOOT BLOCK FROM ISO
dd if=$NETISO bs=512 count=1 of=$BBFILE

# MAKE HYBRID GRUB/EFI ISO
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
