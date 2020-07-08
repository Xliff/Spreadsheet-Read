#!/usr/bin/perl

use strict;
use warnings;

my     $tests = 256;
use     Test::More;
require Test::NoWarnings;

BEGIN { $ENV{SPREADSHEET_READ_ODS} = "Spreadsheet::ReadSXC"; }

use Spreadsheet::Read;
my $parser = Spreadsheet::Read::parses ("ods") or
    plan skip_all => "No OpenOffice ODS parser found";

my $pv = $parser->VERSION;
$pv >= "0.25" and	# Spreadsheet::ReadSXC has never supported colors
    plan skip_all => "Use Spreadsheet::ParseODS instead please";

diag ("# Parser: $parser-$pv");

my $ods;
ok ($ods = ReadData ("files/attr.ods", attr => 1), "Excel Attributes testcase");

my $clr = $ods->[$ods->[0]{sheet}{Colours}];

is ($clr->{cell}[1][1],		"auto",	"Auto");
is ($clr->{attr}[1][1]{fgcolor}, undef,	"Unspecified font color");
is ($clr->{attr}[1][1]{bgcolor}, undef,	"Unspecified fill color");

my @clr = ( [],
    [ "auto",		undef     ],
    [ "red",		"#ff0000" ],
    [ "green",		"#008000" ],
    [ "blue",		"#0000ff" ],
    [ "white",		"#ffffff" ],
    [ "yellow",		"#ffff00" ],
    [ "lightgreen",	"#00ff00" ],
    [ "lightblue",	"#00ccff" ],
    [ "gray",		"#808080" ],
    );
foreach my $col (1 .. $#clr) {
    my $bg = $clr[$col][1];
    is ($clr->{cell}[$col][1],		$clr[$col][0],	"Column $col header");
    foreach my $row (1 .. $#clr) {
	my $fg = $clr[$row][1];
	is ($clr->{cell}[1][$row],	$clr[$row][0],	"Row $row header");
	is ($clr->{attr}[$col][$row]{fgcolor}, $fg,	"FG ($col, $row)");
	is ($clr->{attr}[$col][$row]{bgcolor}, $bg,	"BG ($col, $row)");
	}
    }

unless ($ENV{AUTOMATED_TESTING}) {
    Test::NoWarnings::had_no_warnings ();
    $tests++;
    }
done_testing ($tests);
