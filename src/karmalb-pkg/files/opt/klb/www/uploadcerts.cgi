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

require "/opt/klb/config/global.conf";
require "./functions.cgi";
use CGI qw(:standard escapeHTML);
print "Content-type: text/html\n\n";

##REQUIRES
#require "help-content.cgi";

print "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />

<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"css/base.css\" />
<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"css/grid.css\" />
<title>Upload Certificates</title></head>";

print "<body onunload=\"opener.location=('index.cgi?id=1-3')\">";

print "<div id=\"header\">
	 <div class=\"header-top tr\">";

print "<br /><br /><br />";
print "<div class=\"page-header\"></div>

	 </div>
      </div>";

#print "<b>Upload Backup.</b>";
#print "<div class=\"page-header\"></div>";

my $query      = new CGI;
my $upload_dir = $configdir;
my $action     = $query->param( "action" );
my $filename   = $query->param( "fileup" );

my $upload_filehandle = $query->upload( "fileup" );

if ( $action eq "Upload" && $filename !~ /^$/ )
{
	if ( $filename =~ /\.pem$/ )
	{
		if ( $filename =~ /\\/ )
		{
			@filen = split ( /\\/, $filename );
			$filename = $filen[-1];
		}

		open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
		binmode UPLOADFILE;
		while ( <$upload_filehandle> )
		{
			print UPLOADFILE;
		}
		close UPLOADFILE;
		print "<br />";
		&successmsg( "File $filename uploaded!" );
	}
	else
	{
		print "<br />";
		&errormsg( "file withuot pem extension" );
	}
}

print "<br />";
print "<br />";

print "<form method=\"post\" action=\"uploadcerts.cgi\" enctype=\"multipart/form-data\">";

#print "<form method=\"post\" action=\"index.cgi\">";
#print "<b>File:</b> <input  type=\"file\" name=\"file\" />";
#print qq{
#<input type="text" id="fileName" class="file_input_textbox" readonly="readonly">
#<div class="file_input_div">
#  <input type="button" value="Search files" class="button small" />
#  <input type="file" class="file_input_hidden" name="file" onchange="javascript: document.getElementById('fileName').value = this.value" >
#</div>
#};

print "<b>Upload file on pem format. <font size=\"1\"> filename.pem</font>:</b> <input   type=\"file\" name=\"fileup\" value=\"Ex\" />";
print "<br />";
print "<br />";
print "<input type=\"submit\" value=\"Upload\" name=\"action\" class=\"button small\" />";
print "</form>";
print "<br />";

print "</body>";
print "</html>";
