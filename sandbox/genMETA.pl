#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
my $check = 0;
my $opt_v = 0;
GetOptions (
    "c|check"		=> \$check,
    "v|verbose:1"	=> \$opt_v,
    ) or die "usage: $0 [--check]\n";

my $version;
open my $pm, "<", "Read.pm" or die "Cannot read Read.pm";
while (<$pm>) {
    m/^our\s+.VERSION\s*=\s*"?([-0-9._]+)"?\s*;\s*$/ or next;
    $version = $1;
    last;
    }
close $pm;

my @yml;
while (<DATA>) {
    s/VERSION/$version/o;
    push @yml, $_;
    }

if ($check) {
    print STDERR "Check required and recommended module versions ...\n";
    BEGIN { $V::NO_EXIT = $V::NO_EXIT = 1 } require V;
    my %vsn = map { m/^\s*([\w:]+):\s+([0-9.]+)$/ ? ($1, $2) : () } @yml;
    delete @vsn{qw( perl version )};
    for (sort keys %vsn) {
	$vsn{$_} eq "0" and next;
	my $v = V::get_version ($_);
	$v eq $vsn{$_} and next;
	printf STDERR "%-35s %-6s => %s\n", $_, $vsn{$_}, $v;
	}

    print STDERR "Checking generated YAML ...\n";
    use YAML::Syck;
    use Test::YAML::Meta::Version;
    my $h;
    my $yml = join "", @yml;
    eval { $h = Load ($yml) };
    $@ and die "$@\n";
    $opt_v and print Dump $h;
    my $t = Test::YAML::Meta::Version->new (yaml => $h);
    $t->parse () and
	die join "\n", "Test::YAML::Meta reported failure:", $t->errors, "";

    use Parse::CPAN::Meta;
    eval { Parse::CPAN::Meta::Load ($yml) };
    $@ and die "$@\n";

    my $req_vsn = $h->{requires}{perl};
    print "Checking if $req_vsn is still OK as minimal version\n";
    use Test::MinimumVersion;
    all_minimum_version_ok ($req_vsn, { paths =>
	["t", "examples", "Read.pm", "Makefile.PL" ]});
    }
elsif ($opt_v) {
    print @yml;
    }
else {
    my @my = glob <*/META.yml>;
    @my == 1 && open my $my, ">", $my[0] or die "Cannot update META.yml\n";
    print $my @yml;
    close $my;
    chmod 0644, $my[0];
    }

__END__
--- #YAML:1.0
name:                   Read
version:                VERSION
abstract:               Meta-Wrapper for reading spreadsheet data
license:                perl
author:                 
  - H.Merijn Brand <h.m.brand@xs4all.nl>
generated_by:           Author
distribution_type:      module
provides:
  Spreadsheet::Read:
    file:               Read.pm
    version:            VERSION
requires:                       
  perl:                 5.006
  Exporter:             0
  Carp:                 0
  Data::Dumper:         0
configure_requires:
  ExtUtils::MakeMaker:  0
test_requires:
  Test::Harness:        0
  Test::More:           0.88
  Test::NoWarnings:     0
recommends:
  perl:                 5.012003
  File::Temp:           0.22
  IO::Scalar:           0
  Test::More:           0.96
resources:
  license:              http://dev.perl.org/licenses/
  repository:           http://repo.or.cz/w/Spreadsheet-Read.git
meta-spec:
  version:              1.4
  url:                  http://module-build.sourceforge.net/META-spec-v1.4.html
optional_features:
  opt_csv:
    description:        Provides parsing of CSV streams
    requires:
      Text::CSV_XS:                        0.69
    recommends:
      Text::CSV:                           1.21
      Text::CSV_PP:                        1.29
      Text::CSV_XS:                        0.80
  opt_excel:
    description:        Provides parsing of Microsoft Excel files
    requires:
      Spreadsheet::ParseExcel:             0.26
      Spreadsheet::ParseExcel::FmtDefault: 0
    recommends:
      Spreadsheet::ParseExcel:             0.58
  opt_excelx:
    description:        Provides parsing of Microsoft Excel 2007 files
    requires:
      Spreadsheet::XLSX:                   0.13
      Spreadsheet::XLSX::Fmt2007:          0
  opt_oo:
    description:        Provides parsing of OpenOffice spreadsheets
    requires:
      Spreadsheet::ReadSXC:                0.20
  opt_tools:
    description:        Spreadsheet tools
    recommends:
      Tk:                                  0
      Tk::NoteBook:                        0
      Tk::TableMatrix::Spreadsheet:        0
