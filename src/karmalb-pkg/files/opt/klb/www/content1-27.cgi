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

#STATUS of a DATALINK farm

#if ($viewtableclients eq ""){ $viewtableclients = "no";}
#if ($viewtableconn eq ""){ $viewtableconn = "no";}

# Real Server Table

use Time::HiRes qw (sleep);

#my $vipp = &getFarmVip("vipp",$farmname);
my @startdata = &getDevData( "" );

#print "@startdata<br />";
sleep ( 0.5 );
my @enddata = &getDevData( "" );

#print "@enddata<br />";

my @content = &getFarmBackendStatusCtl( $farmname );

#print"@content<br />";
my @backends = &getFarmBackendsStatus( $farmname, @content );

#print"@backends<br />";

my $backendsize    = @backends;
my $activebackends = 0;
foreach ( @backends )
{
	my @backends_data = split ( ";", $_ );
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
print "<tr><th>Server</th><th>Address</th><th>Interface</th><th>Status</th><th>Rx Total Bytes</th><th>Rx Bytes/sec</th><th>Rx Total Packets</th><th>Rx Packets/sec</th><th>Tx Total Bytes</th><th>Tx Bytes/sec</th><th>Tx Total Packets</th><th>Tx Packets/sec</th><th>Weight</th><th>Priority</th></tr>";
print "</thead>\n";
print "<tbody>";

my $index = 0;

foreach ( @backends )
{
	my @backends_data = split ( ";", $_ );

	my @startdataout;
	foreach $line ( @startdata )
	{
		my @curline = split ( ":", $line );
		my $ini = @curline[0];
		chomp ( $ini );
		if ( $ini ne "" && $ini =~ $backends_data[1] )
		{
			my @datain = split ( " ", @curline[1] );
			push ( @startdataout, @datain[0] );
			push ( @startdataout, @datain[1] );
			push ( @startdataout, @datain[8] );
			push ( @startdataout, @datain[9] );
		}
	}

	my @enddataout;
	foreach $line ( @enddata )
	{
		my @curline = split ( ":", $line );
		my $ini = @curline[0];
		chomp ( $ini );
		if ( $ini ne "" && $ini =~ $backends_data[1] )
		{
			my @datain = split ( " ", @curline[1] );
			push ( @enddataout, @datain[0] );
			push ( @enddataout, @datain[1] );
			push ( @enddataout, @datain[8] );
			push ( @enddataout, @datain[9] );
		}
	}

	print "<tr>";
	print "<td> $index </td> ";
	print "<td> $backends_data[0] </td> ";
	print "<td> $backends_data[1] </td> ";

	if ( $backends_data[4] eq "up" )
	{
		print "<td><img src=\"img/icons/small/start.png\" title=\"up\" alt=\"U\" /></td> ";
	}
	else
	{
		print "<td><img src=\"img/icons/small/stop.png\" title=\"down\" alt=\"d\" /></td> ";
	}
	my $calc = @enddataout[0];
	print "<td> $calc </td> ";
	my $calc = ( @enddataout[0] - @startdataout[0] ) * 2;
	print "<td> $calc </td> ";
	my $calc = @enddataout[1];
	print "<td> $calc </td> ";
	my $calc = ( @enddataout[1] - @startdataout[1] ) * 2;
	print "<td> $calc </td> ";
	my $calc = @enddataout[2];
	print "<td> $calc </td> ";
	my $calc = ( @enddataout[2] - @startdataout[2] ) * 2;
	print "<td> $calc </td> ";
	my $calc = @enddataout[3];
	print "<td> $calc </td> ";
	my $calc = ( @enddataout[3] - @startdataout[3] ) * 2;
	print "<td> $calc </td> ";

	print "<td> $backends_data[2] </td> ";
	print "<td> $backends_data[3] </td> ";

	print "</tr>";
	$index++;
}

print "</tbody>";
print "</table>";
print "</div>";

print "<!--END MANAGE-->";

print "<div class=\"page-header\"></div>";
print "<form method=\"get\" action=\"index.cgi\">";
print "<input type=\"hidden\" value=\"1-2\" name=\"id\" />";
print "<input type=\"submit\" value=\"Cancel\" name=\"action\" class=\"button small\" />";
print "</form>";
print "<div class=\"page-header\"></div>";

#print "@run";
