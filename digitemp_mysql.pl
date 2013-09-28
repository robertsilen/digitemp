#!/usr/bin/perl -W
##########################################################################
# $Id: digitemp_mysql.pl,v 1.21 2006-11-13 08:40:07 KoantdebAdminAnttiKoivisto Exp $
##########################################################################
# Improved DigiTemp script by Antti Koivisto
# Imptovements are based on examples found in http://www.perl.com/pub/a/1999/10/DBI.html
# 	A Short Guide to DBI
# 	Perl's Database Interface Module
# 	by Mark-Jason Dominus
# 	October 22, 1999
#
# This script is based on the original one:
#
# DigiTemp MySQL logging script
# Copyright 2002 by Brian C. Lane <bcl@brianlane.com>
# All Rights Reserved
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
#
# Additional information
# See README
# See mysql_create_tables.sql
# See mysql_grant_rights.sql
#
##########################################################################
# $Log: digitemp_mysql.pl,v $
# Revision 1.21  2006-11-13 08:40:07  KoantdebAdminAnttiKoivisto
# *** empty log message ***
#
# Revision 1.17  2005/11/03 13:24:15  ak
# debug mode variable d added
#
# Revision 1.16  2005/11/03 13:23:14  ak
# bug fix
#
# Revision 1.15  2005/11/03 13:21:19  ak
# Command line options v & d added & printing of debug / verbose messages.
#
# Revision 1.14  2005/11/03 13:09:20  ak
# First muthafuckin functional version where binding is done correctly
#
# Revision 1.13  2005/11/03 13:06:24  ak
# binding added
#
# Revision 1.12  2005/11/03 12:58:29  ak
# print data[] aded
#
# Revision 1.11  2005/11/03 12:56:36  ak
# my removed from _querys
#
# Revision 1.10  2005/11/03 12:54:19  ak
# Fuasfkasfsa
#
# Revision 1.9  2005/11/03 12:30:59  ak
# Variables moved inside while loop
#
# Revision 1.7  2005/11/03 12:17:44  ak
# Debug stuff taken out. Everything is printed...
#
# Revision 1.6  2005/11/03 12:15:17  ak
# Bugs fixed again3
#
# Revision 1.5  2005/11/03 12:11:37  ak
# Bugs fixed again2
#
# Revision 1.4  2005/11/03 12:10:23  ak
# Bugs fixed again
#
# Revision 1.3  2005/11/03 12:08:38  ak
# Bugs fixed
#
# Revision 1.2  2005/11/03 12:01:32  ak
# README & other usage information written
#
#
# 01/08/2004  The storage definition should have been decimal(6,2) instead
# bcl         of decimal(3,2). 
#             See http://www.mysql.com/doc/en/Numeric_types.html for a 
#             good description of how decimal(a,b) works.
#
# 08/18/2002  Putting together this MySQL logging script for the new 
# bcl         release of DigiTemp.
#
##########################################################################
#
# Globals
#
use vars qw/ %opt /;

#
# Command line options processing
#
sub init()
{
	use Getopt::Std;
	my $opt_string = 'hvds';
	getopts( "$opt_string", \%opt ) or usage();
	usage() if $opt{h};
}

#
# Message about this program and how to use it
#
sub usage()
{
	print STDERR " This program does... \n";
	print STDERR "\t usage: $0 [-hvd] \n";
	print STDERR " \t\t -h        : this (help) message \n";
	print STDERR " \t\t -v        : verbose output \n";
	print STDERR " \t\t -d        : Debug output	\n";
	print STDERR " \t\t -s        : Simulate (nothing is written to db)	\n";
	exit;
}

init();

print STDERR "Verbose mode ON.\n" if $opt{v};
print STDERR "Debugging mode ON.\n" if $opt{d};
print STDERR "Simulation mode ON.\n" if $opt{s};

use DBI;

# Database info
my $db_name     = "digitemp";
my $db_user     = "digitemp";
my $db_pass     = "DiGiTeMp";

my $db_name2     = "xxxxxx";
my $db_user2     = "xxxxxx";
my $db_pass2     = "xxxxxx";
# The DigiTemp Configuration file to use
my $digitemp_rcfile = "/usr/local/bin/digitemp/digitemp.cfg";
my $digitemp_binary = "/usr/local/bin/digitemp/digitemp";

print STDERR "Connecting to local database \n" if $opt{d};
# Connect to the database
my $dbh = DBI->connect("dbi:mysql:$db_name","$db_user","$db_pass")
          or die "I cannot connect to dbi:mysql:$db_name as $db_user - $DBI::errstr\n";

print STDERR "Connecting to remote database \n" if $opt{d};
# Connect to the koant.com database
my $dbh2 = DBI->connect("dbi:mysql:$db_name2;host=db.int2000.net","$db_user2","$db_pass2")
          or print "I cannot connect to dbi:mysql:$db_name2 as $db_user2 - $DBI::errstr\n";

# Read the output from digitemp
# Output in form SerialNumber<SPACE>Temperature in Degrees Celcius
print STDERR "Opening digitemp bin & reading sensors \n" if $opt{d};
open( DIGITEMP, "$digitemp_binary -q -a -o\"%R %.2C\" -c $digitemp_rcfile |" );

while( <DIGITEMP> )
{
  my @data;
  # Prepare query that gets a unique integer id for the found sensors
  # This integer id is used when storing measurements
  my $sensor_query = $dbh->prepare('SELECT SensorID FROM Sensor WHERE SerialNumber = ?')
        or die "Couldn't prepare statement: " . $dbh->errstr;

  # Prepare a query to get the location id of the location where the sensor is currently located
  # If the sensor of a location is changed, the Location table needs to be updated to map readings of a sensor to a spesific location
  my $location_query = $dbh->prepare('SELECT LocationID, Description FROM Location WHERE SensorID = ?')
        or die "Couldn't prepare statement: " . $dbh->errstr;

  print "$_\n" if $opt{v} or $opt{d};
  chomp;

  ($serialnumber,$temperature) = split(/ /);
  
  $sensor_query->execute($serialnumber) # Execute the query to get the SensorID (integer) corresponding to the SerialNumber (varchar)
    or die "Couldn't execute statement: " . $sensor_query->errstr;


  my( $SensorID );
  $SensorID = 0;
  $sensor_query->bind_columns( undef, \$SensorID );

  while( $sensor_query->fetch() ) {
  	print "\tSensorID: " . $SensorID . " found for sensor with SerialNumber " .$serialnumber . "\n" if $opt{v} or $opt{d};
  }

  if ($sensor_query->rows == 0 ) {
    $sensor_query->finish;
    print "No sensors matched for SerialNumber " . $serialnumber  . ". Found sensor will be inserted to Sensor table. Details of the Sensor need to be edited manually later. \n\n";
    my $sql="INSERT INTO Sensor SET SerialNumber = '" . $serialnumber . "'";
    print "\tSQL: $sql\n" if $opt{v} or $opt{d};
    if(!$opt{s}){
	$dbh->do($sql) or die "Can't execute statement $sql because: $DBI::errstr";
    	if($dbh2){
		$dbh2->do($sql) or print "Can't execute statement $sql because: $DBI::errstr";}
	}
	else{
		print "\tNo inserts were made due to simulation mode.\n\n";
	}
  }
  
  if ($sensor_query->rows > 1) {
    $sensor_query->finish;
    die "Too many sensors matched for SerialNumber " . $serialnumber . "\n\n";
  }

  $sensor_query->finish;

  $location_query->execute($SensorID) # Execute the query to get the LocationId of the location whre the sensor with SensorID currently is
    or die "Couldn't execute statement: " . $location_query->errstr;

  my( $LocationID, $Description );
  $LocationID = 0;
  $Description = "";
  $location_query->bind_columns( undef, \$LocationID, \$Description );

  while( $location_query->fetch() ) {
    print "\tLocationID: " . $LocationID . "(" . $Description . ")" . " of SensorID " . $SensorID . " of sensor with SerialNumber " . $serialnumber . "\n" if $opt{v} or $opt{d};
  }

  if ($sensor_query->rows == 0) {
    print "No locations matched for SensorID " . $SensorID . " of sensor with SerialNumber " . $serialnumber . ". You need to add Location data. For the time being, the location id of the measurements of this sensor are 0. \n\n";
    $location_query->finish;
  }

  if ($sensor_query->rows > 1) {
    $location_query->finish;
    die "Too many locations matched for SensorID " . $SensorID . " of sensor with SerialNumber " . $serialnumber . "\n\n";
  }

  $location_query->finish;

  my $sql="INSERT INTO Temperature SET SensorID=$SensorID,Temperature=$temperature, Time=NOW(), LocationId=$LocationID";
  print "\tSQL: $sql\n" if $opt{v} or $opt{d};
  if(!$opt{s}){
  	$dbh->do($sql) or die "Can't execute statement $sql because: $DBI::errstr";
  	if($dbh2){
		$dbh2->do($sql) or print "Can't execute statement $sql because: $DBI::errstr";}
	}
	else{
		print "\tNo inserts were made due to simulation mode.\n\n";
	}
}

close( DIGITEMP );

$dbh->disconnect;
