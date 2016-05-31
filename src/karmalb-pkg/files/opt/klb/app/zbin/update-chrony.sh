#!/bin/sh
###############################################################################
#     Karma Load Balancer CE Software License
#     This file is part of the Karma Load Balancer CE software package, a true
#     Community Edition derived from the Zen Load Balancer software package.
#     Sources available at https://github.com/sgoldthorpe/karmalb
#
#     Copyright (C) 2016 Steve Goldthorpe <dev@karmalb.org.uk>
#
#     This library is free software; you can redistribute it and/or modify it
#     under the terms of the GNU Lesser General Public License as published
#     by the Free Software Foundation; either version 2.1 of the License, or
#     (at your option) any later version.
#
#     This library is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
#     General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this library; if not, write to the Free Software Foundation,
#     Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
###############################################################################

# Update chrony server list with entries from file and restart chrony.
# Performs sense checks before replacing server/pool entries.
# Needs to be run as root user.

CONFIG=/etc/chrony/chrony.conf
TMPCF=$CONFIG.$$
TMPSF=`mktemp`

if [ "`id root`" != "`id`" ]; then
	echo "update-chrony.sh requires root permissions."
	exit 1
fi

if [ $# -ne 1 -o ! -f $1 ]; then
	echo "usage: update-chrony.sh <server_config_section_file>"
	exit 2
fi

trap 'rm -f $TMPSF $TMPCF; exit' 1 2 3 6

# remove any empty lines and comments
sed -e '/^\s*$/d' -e '/^\s*#/d' $1 > $TMPSF

OLC=`egrep -cv '^server|^pool' $TMPSF`
if [ $OLC -ne 0 ]; then
	echo "update-chrony.sh: non server or pool lines - aborted."
	rm -f $TMPSF
	exit 3
fi

SLC=`grep -c '^server' $TMPSF`
PLC=`grep -c '^pool' $TMPSF`
if [ \( $SLC -eq 0 -a $PLC -eq 0 \) -o \
	\( $SLC -ne 0 -a $PLC -ne 0 \) ]; then
	echo "update-chrony.sh: only server or pool lines allowed."
	rm -f $TMPSF
	exit 4
fi

if grep -q '^server' $CONFIG; then
	sed -n '0,/^server/ { /^server/b; p }' $CONFIG > $TMPCF
	cat $TMPSF >> $TMPCF
	sed -n '/^server/,$ { /^server/b; p }' $CONFIG >> $TMPCF
elif grep -q '^pool' $CONFIG; then
	sed -n '0,/^pool/ { /^pool/b; p }' $CONFIG > $TMPCF
	cat $TMPSF >> $TMPCF
	sed -n '/^pool/,$ { /^pool/b; p }' $CONFIG >> $TMPCF
else
	rm -f $TMPSF
	echo "update-chrony.sh: cannot find server or pool section"
	exit 5
fi
rm -f $TMPSF

mv $TMPCF $CONFIG && /usr/sbin/invoke-rc.d chrony restart

if [ $? -ne 0 ]; then
	echo "update-chrony.sh: problem restarting chrony"
	rm -f $TMPCF
	exit 6
fi
exit 0
