#!/usr/bin/perl
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

use CGI qw(:standard escapeHTML);
print "Content-type: text/html\n\n";

##REQUIRES
require "./help-content.cgi";

&login();

#loading form variables
my ( %Variables );    #reset hash

#read query send get
my $buffer = $ENV{ 'QUERY_STRING' };

#split variable post
my @pairs = split ( /&/, $buffer );
foreach my $pair ( @pairs )
{

	#separate variable with its name
	my ( $name, $value ) = split ( /=/, $pair );

	#
	$name  =~ tr/+/ /;
	$name  =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

	#get method
	#keys for values
	$Variables{ $name } = $value;
}

#variables in get string
$id = $Variables{ 'id' };

print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />

<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"css/base.css\" />
<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"css/grid.css\" />
<title>Help</title></head>";

$id = 1;
print "<body>";
print "<div id=\"header\">
	 <div class=\"header-top tr\">
	 $header[$id]
	 </div>
      </div>";

print "$body[$id]";
print "<br />";
print "</body>";
print "</html>";

