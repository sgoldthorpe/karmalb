###############################################################################
#
#     Karma Load Balancer CE Software License
#     This file is part of the Karma Load Balancer CE software package, a true
#     Community Edition derived from the Zen Load Balancer software package.
#     Sources available at https://github.com/sgoldthorpe/karmalb
#
#     Copyright (C) 2016 Steve Goldthorpe <dev@karmalb.org.uk>
#     Copyright (C) 2014 SOFINTEL IT ENGINEERING SL, Sevilla (Spain)
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

#STATUS of a HTTP(S) farm

if ( $viewtableclients eq "" ) { $viewtableclients = "no"; }

#if ($viewtableconn eq ""){ $viewtableconn = "no";}

# Real Server Table
my @netstat;
$fvip = &getFarmVip( "vip", $farmname );
$fpid = &getFarmChildPid( $farmname );

my @content = &getFarmBackendStatusCtl( $farmname );
my @backends = &getFarmBackendsStatus( $farmname, @content );

#TEMPORAL:
my @a_services;
my $sv;
foreach ( @content )
{
	if ( $_ =~ /Service/ )
	{
		my @l = split ( "\ ", $_ );
		$sv = @l[2];
		$sv =~ s/"//g;
		chomp ( $sv );
		push ( @a_service, $sv );
	}
}

my $backendsize    = @backends;
my $activebackends = 0;
my $activesessions = 0;
foreach ( @backends )
{
	my @backends_data = split ( "\t", $_ );
	if ( $backends_data[3] eq "up" )
	{
		$activebackends++;
	}
}
&refreshstats();
print "<br />";

print "<div class=\"box-header\">Real servers status<font size=\"1\">&nbsp;&nbsp;&nbsp; $backendsize servers, $activebackends active </font></div>";
print "<div class=\"box table\"><table cellspacing=\"0\">\n";
print "<thead>\n";

print "<tr><th>Service</th><th>Server</th><th>Address</th><th>Port</th><th>Status</th><th>Pending Conns</th><th>Established Conns</th></tr>";
print "</thead>\n";
print "<tbody>";

my $i = -1;
if ( scalar( @backends ) )
{
foreach ( @backends )
{
	my @backends_data = split ( "\t", $_ );
	$activesessions = $activesessions + $backends_data[6];
	print "<tr>";
	print "<td>";
	if ( $backends_data[0] == 0 )
	{
		$i++;
	}
	print "@a_service[$i]";

	print "</td>";
	print "<td> $backends_data[0] </td> ";
	print "<td> $backends_data[1] </td> ";
	print "<td> $backends_data[2] </td> ";
	if ( $backends_data[3] eq "maintenance" )
	{
		print "<td><img src=\"img/icons/small/warning.png\" title=\"Maintenance\" alt=\"!\" /></td> ";
	}
	elsif ( $backends_data[3] eq "up" )
	{
		print "<td><img src=\"img/icons/small/start.png\" title=\"Up\" alt=\"U\" /></td> ";
	}
	elsif ( $backends_data[3] eq "fgDOWN" )
	{
		print "<td><img src=\"img/icons/small/disconnect.png\" title=\"FarmGuardian down\" alt=\"D\" /></td> ";
	}
	else
	{
		print "<td><img src=\"img/icons/small/stop.png\" title=\"Down\" alt=\"d\" /></td> ";
	}
	$ip_backend     = $backends_data[1];
	$port_backend   = $backends_data[2];
	@netstat        = &getConntrack( "", $ip_backend, "", "", "tcp" );
	@synnetstatback = &getBackendSYNConns( $farmname, $ip_backend, $port_backend, @netstat );
	$npend          = @synnetstatback;
	print "<td>$npend</td>";
	@stabnetstatback = &getBackendEstConns( $farmname, $ip_backend, $port_backend, @netstat );
	$nestab = @stabnetstatback;
	print "<td>$nestab</td>";
	print "</tr>";
}
}
else
{
        print "<tr><td colspan=\"7\">There are no active sessions.</td></tr>";
}

print "</tbody>";
print "</table>";
print "</div>";

# Client Sessions Table
print "<div class=\"box-header\">";

if ( $viewtableclients eq "yes" )
{
	print "<a href=\"index.cgi?id=1-2&amp;action=managefarm&amp;farmname=$farmname&amp;viewtableclients=no\" title=\"Minimize\"><img src=\"img/icons/small/bullet_toggle_minus.png\" alt=\"*\" /></a>";
}
else
{
	print "<a href=\"index.cgi?id=1-2&amp;action=managefarm&amp;farmname=$farmname&amp;viewtableclients=yes\" title=\"Maximize\"><img src=\"img/icons/small/bullet_toggle_plus.png\" alt=\"+\" /></a>";
}

my @sessions = &getFarmBackendsClientsList( $farmname, @content );
my $t_sessions = $#sessions + 1;
print "Client sessions status<font size=\"1\">&nbsp;&nbsp;&nbsp; $t_sessions active sessions</font></div>\n";

if ( $viewtableclients eq "yes" )
{

	#my @sessions = &getFarmBackendsClientsList($farmname,@content);

	print "<div class=\"box table\"><table cellspacing=\"0\">\n";
	print "<thead>\n";
	print "<tr><th>Service</th><th>Client</th><th>Session ID</th><th>Server</th></tr>";
	print "</thead>\n";
	print "<tbody>";

	if ( scalar( @sessions ) > 0 )
	{
	foreach ( @sessions )
	{
		my @sessions_data = split ( "\t", $_ );
		print "<tr>";
		print "<td> $sessions_data[0] </td> ";
		print "<td> $sessions_data[1] </td> ";
		print "<td> $sessions_data[2] </td> ";
		print "<td> $sessions_data[3] </td> ";
		print "</tr>";
	}
	}
	else
	{
        print "<tr><td>There are no active sessions.</td></tr>";
	}


	print "</tbody>";
	print "</table>";
	print "</div>";
}

print "<!--END MANAGE-->";

print "<div class=\"page-header\"></div>";
print "<form method=\"get\" action=\"index.cgi\">";
print "<input type=\"hidden\" value=\"1-2\" name=\"id\" />";
print "<input type=\"submit\" value=\"Cancel\" name=\"action\" class=\"button small\" />";
print "</form>";
print "<div class=\"page-header\"></div>";

#print "@run";
