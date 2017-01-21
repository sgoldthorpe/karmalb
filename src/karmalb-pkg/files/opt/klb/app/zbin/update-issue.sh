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

# Update /etc/issue with the details of where the current web admin is located.
# Needs to be run as root user.

ISSUE=/etc/issue
WEBCONF=/opt/klb/app/mini_httpd/mini_httpd.conf

if [ "`id root`" != "`id`" ]; then
	echo "update-issue.sh requires root permissions."
	exit 1
fi

HOST="`awk -F= '/^host=/ { print $2 }' $WEBCONF`"
PORT="`awk -F= '/^port=/ { print $2 }' $WEBCONF`"

if [ "x$HOST" = "x\*" ]; then
	HOST="`ip -4 -o addr list scope global|awk '/inet/ { split($4, A, "/"); print A[1]; exit; }'`"
fi

NEWLINE="Web admin on https://$HOST:$PORT"

if grep -q '^Web admin' $ISSUE; then
	sed -i.bak "s@^Web admin.*@$NEWLINE@" $ISSUE
else
	echo "$NEWLINE" >> $ISSUE
	echo "" >> $ISSUE
fi

exit 0
