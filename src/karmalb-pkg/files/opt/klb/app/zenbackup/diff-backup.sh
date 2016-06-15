#!/bin/sh

TMPDIR=/tmp/tmpdir
DIFFS=0
MERGE=1

do_diff() {
	echo ""
	diff -N --unified=1 --label "$3" --label "X" "$3" "$2" | sed -e '/^+++ /d' -e 's/^--- //' -e 's/^@@ .*/--/' -e '/^\s*$/d'
	echo "--"
}

if [ "x$1" = "x-c" ]; then
	MERGE=0
	shift
fi

TARFILE=$1
shift

rm -rf $TMPDIR
mkdir -p $TMPDIR

echo "Differences between current config (-) and backup (+):";
/opt/klb/app/zenbackup/extract-backup.sh -r $TMPDIR $TARFILE $* >/dev/null 2>&1

if [ $? -eq 0 ]; then
	while [ "$1" ]; do
		if [ -f "$TMPDIR/$1" ]; then
			if ! cmp -s "$TMPDIR/$1" "$1"; then
				do_diff "$1" "$TMPDIR/$1" "$1"
				DIFFS=`expr $DIFFS + 1`
			fi
		elif [ -d "$TMPDIR/$1" ]; then
			FLIST="`cd $TMPDIR/$1; find . -type f -print| sed 's@\./@@' | sort`"
			if [ "$FLIST" ]; then
				for F in $FLIST; do
					if ! cmp -s "$TMPDIR/$1/$F" "$1/$F"; then
						do_diff "$1" "$TMPDIR/$1/$F" "$1/$F"
						DIFFS=`expr $DIFFS + 1`
					fi
				done
			fi
			if [ $MERGE -eq 0 ]; then
				MLIST="`cd $1; find . -type f -print | sed 's@\./@@' | sort`"
				if [ "MFLIST" ]; then
					for M in $MLIST; do
						if [ ! -f "$TMPDIR/$1/$M" ]; then
							echo "$1/$M not included in backup"
							DIFFS=`expr $DIFFS + 1`
						fi
					done
				fi
			fi
			
		fi
		shift
	done
	echo ""
	if [ $DIFFS -ne 0 ]; then
		if [ $DIFFS -eq 1 ]; then
			echo "There is one file different to the current config."
		else
			echo "There are $DIFFS files different to the current config."
		fi
	else
		echo "The backup is the same as the current config."
	fi
else
	echo "Issue extracting files"	
fi
rm -rf $TMPDIR

exit 0
