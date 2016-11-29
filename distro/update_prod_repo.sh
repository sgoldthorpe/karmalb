EMOTEREPOSYNC="karmalb@web.sourceforge.net:/home/project-web/karmalb/htdocs/debian/"

lookup() {
	awk "/^$1=/ { split(\$0,s,\"=\"); print s[2]; exit }" $VF
}

# DEFINITIONS
VF="../VERSION"
DIST="`lookup DEBDIST`"
DEST=repo
WORKREPO=workrepo
PUBREPO=pubrepo
ARCH="`lookup ARCH`"
KEEPWORK=0
CLEANPUBREPO=0
FETCHONLY=0
UPDATEPUBREPO=0
INITPUBREPO=0
# DERIVED DEFINITIONS
REPOCONF=$WORKREPO/conf
REPOOPTS=$REPOCONF/options
REPODISTS=$REPOCONF/distributions

# MAIN SCRIPT

while [ "x$1" != "x" ]; do
	case "x$1" in
		x-c)
			CLEANPUBREPO=1;;
		x-k)
			KEEPWORK=1;;
		x-f)
			CLEANPUBREPO=1
			FETCHONLY=1;;
		x-u)
			UPDATEPUBREPO=1;;
		x-i)
			INITPUBREPO=1;;
		*)
			break;;
	esac
	shift
done

if [ $INITPUBREPO -eq 1 ]; then
	echo "Syncing from local repo..."
	rsync --delete -av $DEST/dists $DEST/pool $PUBREPO/
fi

if [ \( $CLEANPUBREPO -eq 1 -o ! -d $PUBREPO \) -a \( "x$KARMAREMOTEREPOSYNC" = "x" \) ]; then
	echo "Please set environment variable KARMAREMOTEREPOSYNC before running this script."
	echo "This is normally in the form of user@host:/path/."
	exit 2
fi

if [ $CLEANPUBREPO -eq 1 ]; then
	echo "Cleaning ${PUBREPO}..."
	rm -rf $PUBREPO
fi

if [ ! -d $PUBREPO ]; then
	echo "Syncing from remote repo..."
	mkdir -p $WORKREPO
	rsync -av $KARMAREMOTEREPOSYNC/dists $KARMAREMOTEREPOSYNC/pool $PUBREPO/
fi

if [ $FETCHONLY -eq 1 ]; then
	echo "Set to fetch $PUBREPO only - quitting."
	exit 0
fi

rm -rf $WORKREPO
mkdir -p $WORKREPO
rsync -av $PUBREPO/ $WORKREPO/

mkdir -p $REPOCONF
touch $REPOOPTS
test "$KARMALBKEY" && echo "ask-passphrase" >> $REPOOPTS
echo "Codename: $DIST" > $REPODISTS
echo "Components: main" >> $REPODISTS
echo "Architectures: $ARCH" >> $REPODISTS
test "$KARMALBKEY" && echo "SignWith: $KARMALBKEY" >> $REPODISTS

export GZIP="-9v" # ensure we shrink things as small as they will go

PKGLIST="`find $WORKREPO/pool -type f -name \*.deb -print`"
reprepro -b $WORKREPO includedeb $DIST $PKGLIST

# reset time stamps
rsync -av $PUBREPO/pool/ $WORKREPO/pool/

PKGLIST="`find $DEST/pool -type f -name \*.deb -print`"
NEWPKGS=""
OLDPKGS=""
for PKG in $PKGLIST; do
	BASEPKG=`basename $PKG`
	FOUND="`find $WORKREPO/pool -name $BASEPKG -print -quit`"
	if [ ! "$FOUND" ]; then
		NEWPKGS="$NEWPKGS $PKG"
	fi
done
echo $NEWPKGS

if [ ! "$NEWPKGS" ]; then
	echo "Nothing to do"
else
	echo "Rebuilding apt archive..."
	reprepro -b $WORKREPO includedeb $DIST $NEWPKGS

	echo "Syncing back to remote repo..."
	rsync --delete -av $WORKREPO/dists $WORKREPO/pool $PUBREPO/
fi

if [ $UPDATEPUBREPO -eq 1 ]; then
	echo "tip: any password will be for the external repo server"
	rsync -av --delete-delay repo/dists repo/pool $KARMAREMOTEREPOSYNC
fi

test $KEEPWORK -eq 0 && rm -rf $WORKREPO
echo "Done."
exit 0
