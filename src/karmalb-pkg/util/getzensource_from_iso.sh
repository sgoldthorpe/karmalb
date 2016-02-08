#/!bin/sh -e
TMPDIR=tmp
ZENPKG=zenloadbalancer_3.7_i386.deb
ZENISO=zenloadbalancer-distro_37.iso
FILELIST=../filelist
FILESDIR=../files

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
		wget http://sourceforge.net/settings/mirror_choices?projectname=zenloadbalancer&filename=Distro/$ZENISO
	fi
	mkdir iso
	sudo mount -o loop -t iso9660 -r $ZENISO iso
	cp -p iso/pool/main/zen/$ZENPKG .
	sudo umount iso
	rmdir iso
fi

# extract files from package 
mkdir $TMPDIR
dpkg -x $ZENPKG $TMPDIR

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
	done > $FILELIST

rm -rf $FILESDIR
mkdir $FILESDIR
cat $FILELIST | (
	while read T F X; do
		case $T in
			\#*) echo "Skipping binary $F";;
			l) echo "Skipping link $F -> $X";;
			d) mkdir $FILESDIR/$F;;
			f) cp -p $TMPDIR/$F $FILESDIR/$F;;
		esac
	done
)

rm -rf $TMPDIR
