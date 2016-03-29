#/!bin/sh -e
# Extract src files from zen package as they don't provide sources.
#
TMPDIR=tmp
ZENPKG=zenloadbalancer_3.10.deb
FILELIST=filelist
FILESDIR=files
CONTROLDIR=control

if [ ! -f $ZENPKG ]; then
	echo "You need to get hold of $ZENPKG first..."
	exit 2
fi

rm -rf $TMPDIR
mkdir $TMPDIR
echo "extracting files..."
dpkg -x $ZENPKG $TMPDIR
echo "creating filelist..."
( cd $TMPDIR; find * -print ) | sort | \
	while read F; do
		if [ -d "$TMPDIR/$F" ]; then	
			echo "d $F"
		elif [ -L "$TMPDIR/$F" ]; then
			T="`readlink $TMPDIR/$F`"
			echo "l $F $T"
		elif [ -f "$TMPDIR/$F" ]; then
			ELF="`file $TMPDIR/$F|grep ELF`"
			if [ "$ELF" ]; then
				echo "#f $F"
			else
				echo "f $F"
			fi
		fi
	done > $FILELIST
echo "Creating files..."
rm -rf $FILESDIR
mkdir $FILESDIR
cat $FILELIST | while read T F X; do
	 case $T in
		d)
			mkdir $FILESDIR/$F
			;;
		f)
			cp -p $TMPDIR/$F $FILESDIR/$F
			;;
		l)	# ignore links
			;;
		\#*)
			# ignore binaries too
			;;
			
		*)
			echo "Not sure what to do with $T $F $X."
			exit 3
			;;
	esac
done
rm -rf $TMPDIR
echo "Extracting control files..."
rm -rf $CONTROLDIR
mkdir $CONTROLDIR
dpkg -e $ZENPKG $CONTROLDIR
echo "Done."
