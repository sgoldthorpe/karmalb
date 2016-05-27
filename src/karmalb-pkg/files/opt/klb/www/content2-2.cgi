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

#my $type = &getFarmType($farmname);

print "
<!--Content INI-->
<div id=\"page-content\">

                <!--Content Header INI-->";
print "<h2>Monitoring::Conns stats</h2>";
print "<!--Content Header END-->";

if ( $action eq "managefarm" )
{
	$type = &getFarmType( $farmname );
	if ( $type == 1 )
	{
		&errormsg( "Unknown farm type of $farmname" );
	}
	else
	{
		$file = &getFarmFile( $farmname );
		if ( $type eq "http" || $type eq "https" )
		{
			require "./content1-25.cgi";
		}
		if ( $type eq "datalink" )
		{
			require "./content1-27.cgi";
		}
		if ( $type eq "l4xnat" )
		{
			require "./content1-29.cgi";
		}
		if ( $type eq "gslb" )
		{
			require "./content1-203.cgi";
		}
	}
}

@files = &getFarmList();

print "<div class=\"box-header\">Farms table</div>";
print "<div class=\"box table\">";

my @netstat;
my $thereisdl = "false";

print "<table cellspacing=\"0\">";
print "<thead>";
print "<tr>";
print "<th width=\"85\">Name</th>";
print "<th width=\"85\">Virtual IP</th>";
print "<th>Virtual Port(s)</th>";
print "<th>Pending Conns</th>";
print "<th>Established Conns</th>";
print "<th>Status</th>";
print "<th>Profile</th>";
print "<th>Actions</th>";
print "</tr>";
print "</thead>";
print "<tbody>";

foreach $file ( @files )
{
		$name = &getFarmName( $file );
		$type = &getFarmType( $name );
		$globalfarm++;
		if ( $type ne "datalink" )
		{

			if ( $farmname eq $name && $action ne "addfarm" && $action ne "Cancel" )
			{
				print "<tr class=\"selected\">";
			}
			else
			{
				print "<tr>";
			}

			#print the farm description name
			print "<td>$name</td>";

			#print the virtual ip
			$vip = &getFarmVip( "vip", $name );
			print "<td>$vip</td>";

			#print the virtual port where the vip is listening
			$vipp = &getFarmVip( "vipp", $name );
			print "<td>$vipp</td>";

			#print global connections bar
			$pid    = &getFarmPid( $name );
			$status = &getFarmStatus( $name );
			if ( $status eq "up" )
			{
				@netstat = &getConntrack( "", $vip, "", "", "" );

				# SYN_RECV connections
				my @synconnslist = &getFarmSYNConns( $name, @netstat );
				$synconns = @synconnslist;
				print "<td> $synconns </td>";
			}
			else
			{
				print "<td>0</td>";
			}
			if ( $status eq "up" )
			{
				@gconns = &getFarmEstConns( $name, @netstat );
				$global_conns = @gconns;
				print "<td>";
				print " $global_conns ";
				print "</td>";
			}
			else
			{
				print "<td>0</td>";
			}

			#print status of a farm
			if ( $status ne "up" )
			{
				print "<td><img src=\"img/icons/small/stop.png\" title=\"down\" alt=\"d\" /></td>";
			}
			else
			{
				print "<td><img src=\"img/icons/small/start.png\" title=\"up\" alt=\"U\" /></td>";
			}

			#type of farm
			print "<td>$type</td>";

			#menu
			print "<td>";
			&createmenuvipstats( $name, $id, $status, $type );
			print "</td>";
			print "</tr>";
		}
		else
		{
			$thereisdl = "true";
		}
}
print "</tbody>";

# DATALINK

if ( $thereisdl eq "true" )
{
	print "<thead>";
	print "<tr>";
	print "<th width=\"85\">Name</th>";
	print "<th width=\"85\" colspan=\"2\">IP</th>";
	print "<th>Rx Bytes/sec</th>";
	print "<th>Tx Bytes/sec</th>";
	print "<th>Status</th>";
	print "<th>Profile</th>";
	print "<th></th>";
	print "</tr>";
	print "</thead>";
	print "<tbody>";
	use Time::HiRes qw (sleep);

	foreach $file ( @files )
	{
		$name = &getFarmName( $file );
		$type = &getFarmType( $name );

		if ( $type eq "datalink" )
		{

			$vipp = &getFarmVip( "vipp", $name );
			my @startdata = &getDevData( $vipp );
			sleep ( 0.5 );
			my @enddata = &getDevData( $vipp );

			if ( $farmname eq $name && $action ne "addfarm" && $action ne "Cancel" )
			{
				print "<tr class=\"selected\">";
			}
			else
			{
				print "<tr>";
			}

			#print the farm description name
			print "<td>$name</td>";

			#print the virtual ip
			$vip = &getFarmVip( "vip", $name );
			print "<td colspan=2>$vip</td>";

			#print global packets
			$status = &getFarmStatus( $name );

			if ( $status eq "up" )
			{
				my $ncalc = ( @enddata[0] - @startdata[0] ) * 2;
				print "<td> $ncalc B/s </td>";
			}
			else
			{
				print "<td>0</td>";
			}

			if ( $status eq "up" )
			{
				my $ncalc = ( @enddata[2] - @startdata[2] ) * 2;
				print "<td> $ncalc B/s </td>";
			}
			else
			{
				print "<td>0</td>";
			}

			#print status of a farm
			if ( $status ne "up" )
			{
				print "<td><img src=\"img/icons/small/stop.png\" title=\"down\" alt=\"d\" /></td>";
			}
			else
			{
				print "<td><img src=\"img/icons/small/start.png\" title=\"up\" alt=\"U\" /></td>";
			}

			#type of farm
			print "<td>$type</td>";

			#menu
			print "<td>";
			print "</td>";
			print "</tr>";
		}
	}

## END DATALINK

	print "</tbody>";
}

#~ print "<tr><td colspan=\"8\"></td><td><a href=\"index.cgi?id=$id&amp;action=addfarm\"><img src=\"img/icons/small/farm_add.png\" title=\"Add new Farm\" alt=\"*\" /></a></td></tr>";

print "</table>";
print "</div>";


print "<br class=\"cl\" />";
print "</div>";

#print "<br class=\"cl\" />";
#rint "        </div>
#    <!--Content END-->";
#  </div>
#</div>
#";

