#!/bin/bash

fb="/etc/firstboot"
if [ ! -f $fb ]
then
	exit 0
fi

#stop installed services now taken over
insserv -r pound
#insserv -r ucarp	
insserv -r gdnsd
systemctl disable gdnsd >/dev/null 2>&1
/etc/init.d/gdnsd stop >/dev/null 2>&1
insserv -r networking
#insserv -r nfs-common
#insserv -r atd
insserv -r rsync
insserv -r x11-common
if dpkg -s exim4 >/dev/null 2>&1; then
	insserv -r exim4
	systemctl disable exim4 >/dev/null 2>&1
	/etc/init.d/exim4 stop >/dev/null 2>&1
fi
insserv -r snmpd
systemctl disable snmpd >/dev/null 2>&1
/etc/init.d/snmpd stop >/dev/null 2>&1
rm -f /etc/snmp/snmpd.conf

sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
cp /etc/motd.tail /etc/motd
invoke-rc.d ssh restart >/dev/null 2>&1

insserv -r snmpd

# add an interface file if we were installed with DHCP etc.
KDIR=/opt/klb
CDIR=$KDIR/config
MCFG=$KDIR/app/mini_httpd/mini_httpd.conf
NCONF=/etc/network/interfaces

if ! grep -qi "inet[[:space:]][[:space:]]*static" $NCONF; then
	# look for a default route
	EG="`ip route list|awk '/default/ { print $5 " " $3; exit }'`"
	if [ ! "$EG" ]; then
		# no default route set, this is usually because DHCP hasn't
		# been configured yet.  Give DHCP a little time to start...
		MAX=10
		SLEEP=6
		COUNT=0
		while [ ! "$EG" -a $COUNT -lt $MAX ]; do
			sleep $SLEEP
			COUNT=`expr $COUNT + 1`
			EG="`ip route list|awk '/default/ { print $5 " " $3; exit }'`"
		done
	fi
	if [ "EG" ]; then
		# everything is fine
		IF="`echo $EG|awk '{ print $1 }'`"
		GW="`echo $EG|awk '{ print $2 }'`"
	else
		# still no default routey, set up using the first UP interface
		GW=""
		IF="`ip -f inet link| grep -v lo: | awk '/UP/ { split($2, a, ":"); print a[1]; exit }'`"
		# if that fails, hardcode to eth0
		if [ ! "$IF" ]; then
			IF="eth0"
		fi
	fi
	IPM="`/sbin/ifconfig $IF | awk '/inet / { print $2 " " $4 }'`"
	if [ "$IPM" ]; then
		# found the IP and netmask of $IF
		IP="`echo $IPM| sed 's/addr:\([^ ]*\).*/\1/'`"
		MASK="`echo \"$IPM\" | sed 's/.*Mask://'`"
	else
		# everything failed, set to a (possibly) sensible default.
		IP="192.168.0.100"
		MASK="255.255.255.0"
	fi
	echo "$IF::$IP:$MASK:up::" > $CDIR/if_${IF}_conf
	sed -i "s/defaultgw=.*/defaultgw=\"${GW}\";/" $CDIR/global.conf
	sed -i "s/defaultgwif=.*/defaultgwif=\"${IF}\";/" $CDIR/global.conf
	echo "#zenmodified" > $NCONF
	echo "auto lo" >> $NCONF
	echo "iface lo inet loopback" >> $NCONF
	pkill dhclient >/dev/null 2>&1
	sed -i "s/^host=.*/host=$IP/" $MCFG
fi

#
rm $fb
exit 0
