#!/bin/sh -e
CONFIG=karmacert.cnf
KEYFILE=karmacert.key
CRTFILE=karmacert.crt
VALIDFOR=3652
BITS=2048
ALG=rsa
DIGEST=sha256

yesno() {
	echo $1
	read ANS
	case x$ANS in
		xy|xY|xyes|xYES|xYes)
			ANS=Y;;
		*)
			ANS=N;;
	esac
}

if [ -f $KEYFILE -a -f $CRTFILE ]; then
	yesno "Certs already exist.  Replace?"
	if [ "$ANS" = "N" ]; then
		exit 2
	fi
fi

openssl req -${DIGEST} -x509 -keyout $KEYFILE -days $VALIDFOR -newkey \
	$ALG:$BITS -config $CONFIG -out $CRTFILE
if [ $? -eq 0 ]; then
	yesno "Replace existing self-signed certs in tree?"
	if [ "$ANS" = "Y" ]; then
		FILELIST="`awk '/\.pem$/ { print $2 }' ../filelist`"
		for F in $FILELIST; do
			echo "Replacing $F..."
			cat $KEYFILE > ../files/$F
			cat $CRTFILE >> ../files/$F
		done
	fi
fi

echo "Done."
