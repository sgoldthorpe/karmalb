#!/bin/sh
KLBDIR=/opt/klb
FROM=$1
TO=$2

if [ "`id root`" != "`id`" ]; then
	echo "Must run as root."
	exit 3
fi
if [ ! -f $KLBDIR/config/if_${FROM}_conf ]; then
	echo "can't find existing interface $FROM - aborting..."
	exit 2
fi
if [ -f $KLBDIR/config/if_${TO}_conf ]; then
	echo "interface $TO is already defined in KLB - aborting..."
	exit 2
fi
if ! ifquery $TO >/dev/null 2>&1; then
	echo "can't find interface $TO - aborting..."
	exit 2
fi

echo "Stopping networking..."
/etc/init.d/zenloadbalancer stop >/dev/null 2>&1
/etc/init.d/networking stop >/dev/null 2>&1

echo "Updating config..."
/bin/sed "s/^${FROM}/${TO}/" ${KLBDIR}/config/if_${FROM}_conf > ${KLBDIR}/config/if_${TO}_conf
/bin/sed -i "s/table_${FROM}\$/table_${TO}/" /etc/iproute2/rt_tables
/bin/sed -i "/defaultgwif/ s/${FROM}/${TO}/" ${KLBDIR}/config/global.conf
/bin/rm -f ${KLBDIR}/config/if_${FROM}_conf

sleep 5
echo "Restarting networking..."
/etc/init.d/networking start >/dev/null 2>&1
/etc/init.d/zenloadbalancer start >/dev/null 2>&1

echo "Done."
exit 0
