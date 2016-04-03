#!/bin/bash

fb="/etc/firstboot"
if [ ! -f $fb ]
then
	exit 0
fi

#stop installed services in stallation process
insserv -r pound
#insserv -r ucarp	
insserv -r gdnsd
systemctl disable gdnsd
/etc/init.d/gdnsd stop
insserv -r networking
#insserv -r nfs-common
#insserv -r atd
insserv -r rsync
insserv -r x11-common
insserv -r exim4
systemctl disable exim4
/etc/init.d/exim4 stop
insserv -r snmpd
systemctl disable snmpd
/etc/init.d/snmpd stop
rm /etc/snmp/snmpd.conf


#change init scripts 
sed  -i 's/$remote_fs $syslog/$remote_fs $syslog zenloadbalancer/g' /etc/init.d/ssh
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
cp /etc/motd.tail /etc/motd
/etc/init.d/ssh restart

sed -i 's/^\# Required-Start:.*/# Required-Start:\t\$network \$remote_fs \$syslog zenloadbalancer/g' /etc/init.d/snmpd
sed -i 's/^\# Required-Stop:.*/# Required-Stop:\t\$network \$remote_fs \$syslog zenloadbalancer/g' /etc/init.d/snmpd
insserv -r snmpd


# add an interface file if we were installed with DHCP etc.
CDIR=/opt/klb/config
NCONF=/etc/network/interfaces

if ! grep -qi "inet static" $NCONF; then
	EG="`ip route list|awk '/default/ { print $5 " " $3; exit }'`"
	IF="`echo $EG|awk '{ print $1 }'`"
	GW="`echo $EG|awk '{ print $2 }'`"
	IPM="`/sbin/ifconfig $IF | awk '/inet / { print $2 " " $4 }'`"
	IP="`echo $IPM| sed 's/addr:\([^ ]*\).*/\1/'`"
	MASK="`echo \"$IPM\" | sed 's/.*Mask://'`"
	echo "$IF::$IP:$MASK:up::" > $CDIR/if_${IF}_conf
	sed -i "s/defaultgw=.*/defaultgw=$GW" $CDIR/global.conf
	sed -i "s/defaultgwif=.*/defaultgwif=$IF" $CDIR/global.conf
	echo "#zenmodified" > $NCONF
	echo "auto lo" >> $NCONF
	echo "iface lo inet loopback" >> $NCONF
fi


#
rm $fb
